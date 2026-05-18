const express = require('express');
const cors = require('cors');
const path = require('path');
const { Redis } = require('@upstash/redis');

const app = express();
const PORT = process.env.PORT || 3000;

// Environment variables
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';

// Initialize Redis client
const redis = process.env.UPSTASH_REDIS_REST_URL && process.env.UPSTASH_REDIS_REST_TOKEN
  ? new Redis({
      url: process.env.UPSTASH_REDIS_REST_URL,
      token: process.env.UPSTASH_REDIS_REST_TOKEN,
    })
  : null;

// Redis key for config storage
const CONFIG_KEY = 'radio:config';

// Listener tracking
const activeListeners = new Map(); // deviceId -> lastHeartbeat

// Default configuration
const defaultConfig = {
  stationName: 'My Radio Station',
  streamUrl: 'https://your-icecast-stream.example.com/stream',
  albumArtUrl: '',
  description: 'Your favorite internet radio station',
  updatedAt: new Date().toISOString()
};

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'admin')));

// Read configuration from Redis
async function readConfig() {
  try {
    if (!redis) {
      console.warn('Redis not configured, using default config');
      return defaultConfig;
    }
    
    console.log('Reading config from Redis');
    const data = await redis.get(CONFIG_KEY);
    
    if (data) {
      console.log('Config loaded successfully from Redis');
      console.log('Config data:', data);
      return JSON.parse(data);
    }
    
    console.log('No config found in Redis, checking if we need to initialize');
    
    // If no config exists, save the default config to Redis
    console.log('Initializing Redis with default config');
    await redis.set(CONFIG_KEY, JSON.stringify(defaultConfig));
    console.log('Default config saved to Redis');
    
    return defaultConfig;
  } catch (error) {
    console.error('Error reading config from Redis:', error);
    console.error('Error stack:', error.stack);
    return defaultConfig;
  }
}

// Write configuration to Redis
async function writeConfig(config) {
  try {
    if (!redis) {
      console.error('Redis not configured, cannot save config');
      console.error('Make sure UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN are set');
      return false;
    }
    
    console.log('Writing config to Redis');
    console.log('Config to save:', JSON.stringify(config, null, 2));
    
    await redis.set(CONFIG_KEY, JSON.stringify(config));
    console.log('Config written successfully to Redis');
    
    // Verify the write by reading it back
    const verification = await redis.get(CONFIG_KEY);
    if (verification) {
      console.log('Verification: Config successfully stored in Redis');
    } else {
      console.error('Verification failed: Config not found after write!');
    }
    
    return true;
  } catch (error) {
    console.error('Error writing config to Redis:', error);
    console.error('Error stack:', error.stack);
    return false;
  }
}

// ==================== LISTENER TRACKING ====================

// Heartbeat endpoint - app calls this every 30 seconds while playing
app.post('/api/listener/heartbeat', (req, res) => {
  const { deviceId, stationName } = req.body;
  
  if (!deviceId) {
    return res.status(400).json({ error: 'deviceId is required' });
  }

  // Update or add listener
  activeListeners.set(deviceId, {
    lastHeartbeat: new Date().toISOString(),
    stationName: stationName || 'Unknown',
    deviceType: req.body.deviceType || 'mobile'
  });

  res.json({ status: 'ok', message: 'Heartbeat received' });
});

// Get active listener count
app.get('/api/listeners', (req, res) => {
  const now = new Date();
  const timeout = 60 * 1000; // 1 minute timeout
  
  // Remove stale listeners (no heartbeat in last 60 seconds)
  for (const [deviceId, data] of activeListeners.entries()) {
    const lastBeat = new Date(data.lastHeartbeat);
    if (now - lastBeat > timeout) {
      activeListeners.delete(deviceId);
    }
  }

  const listenerList = Array.from(activeListeners.entries()).map(([id, data]) => ({
    deviceId: id,
    ...data
  }));

  res.json({
    activeListeners: activeListeners.size,
    listeners: listenerList
  });
});

// ==================== PUBLIC API ENDPOINTS ====================

// Get current radio configuration
app.get('/api/config', async (req, res) => {
  try {
    console.log('GET /api/config - Request received');
    const config = await readConfig();
    console.log('GET /api/config - Config loaded:', JSON.stringify(config, null, 2));
    
    // Don't expose sensitive fields
    const publicConfig = {
      stationName: config.stationName,
      streamUrl: config.streamUrl,
      albumArtUrl: config.albumArtUrl,
      description: config.description,
      updatedAt: config.updatedAt
    };
    
    console.log('GET /api/config - Sending response:', JSON.stringify(publicConfig, null, 2));
    res.json(publicConfig);
  } catch (error) {
    console.error('GET /api/config - Error:', error);
    console.error('GET /api/config - Stack:', error.stack);
    res.status(500).json({ error: 'Failed to read configuration', details: error.message });
  }
});

// ==================== ADMIN API ENDPOINTS ====================

// Simple authentication middleware
function authenticateAdmin(req, res, next) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    return res.status(401).json({ error: 'No authorization header provided' });
  }

  // Support Bearer token or Basic auth
  const token = authHeader.startsWith('Bearer ') 
    ? authHeader.slice(7) 
    : authHeader;

  if (token !== ADMIN_PASSWORD) {
    return res.status(403).json({ error: 'Invalid password' });
  }

  next();
}

// Update radio configuration (Admin only)
app.post('/api/admin/update', authenticateAdmin, async (req, res) => {
  try {
    const { stationName, streamUrl, albumArtUrl, description } = req.body;

    console.log('Received update request:', { stationName, streamUrl, albumArtUrl, description });

    // Validate required fields
    if (!streamUrl || streamUrl.trim() === '') {
      console.error('Validation failed: Stream URL is required');
      return res.status(400).json({ error: 'Stream URL is required' });
    }

    const currentConfig = await readConfig();
    console.log('Current config loaded:', currentConfig);
    
    const newConfig = {
      stationName: stationName || currentConfig.stationName || 'My Radio Station',
      streamUrl: streamUrl.trim(),
      albumArtUrl: albumArtUrl || '',
      description: description || currentConfig.description || '',
      updatedAt: new Date().toISOString()
    };

    console.log('Attempting to write new config to Redis:', newConfig);
    const success = await writeConfig(newConfig);

    if (success) {
      console.log('Configuration updated successfully in Redis');
      res.json({
        message: 'Configuration updated successfully',
        config: newConfig
      });
    } else {
      console.error('Failed to write config to Redis');
      res.status(500).json({ error: 'Failed to save configuration' });
    }
  } catch (error) {
    console.error('Error updating config:', error);
    console.error('Stack trace:', error.stack);
    res.status(500).json({ 
      error: 'Internal server error', 
      details: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
});

// Get current config (Admin only - for admin panel)
app.get('/api/admin/config', authenticateAdmin, async (req, res) => {
  try {
    const config = await readConfig();
    res.json(config);
  } catch (error) {
    res.status(500).json({ error: 'Failed to read configuration' });
  }
});

// Admin login endpoint
app.post('/api/admin/login', (req, res) => {
  const { password } = req.body;

  if (!password) {
    return res.status(400).json({ error: 'Password is required' });
  }

  if (password === ADMIN_PASSWORD) {
    res.json({ 
      message: 'Login successful',
      token: ADMIN_PASSWORD // Simple token (same as password for now)
    });
  } else {
    res.status(401).json({ error: 'Invalid password' });
  }
});

// ==================== HEALTH CHECK ====================

app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Serve admin panel for any other routes
app.get('/privacy', (req, res) => {
  res.sendFile(path.join(__dirname, 'privacy-policy.html'));
});

app.get('/terms', (req, res) => {
  res.sendFile(path.join(__dirname, 'terms-of-service.html'));
});

app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'admin', 'index.html'));
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(PORT, async () => {
  console.log(`🚀 Radio Server running on port ${PORT}`);
  console.log(`📻 Admin Panel: http://localhost:${PORT}/admin`);
  console.log(` API: http://localhost:${PORT}/api/config`);
  console.log(`🔑 Admin Password: ${ADMIN_PASSWORD}`);
  
  if (redis) {
    console.log('✅ Redis client initialized');
    console.log('🔗 Redis URL:', process.env.UPSTASH_REDIS_REST_URL?.substring(0, 30) + '...');
    
    // Test Redis connection
    try {
      await redis.ping();
      console.log('✅ Redis connection test: SUCCESS');
      
      // Check if config exists
      const existingConfig = await redis.get(CONFIG_KEY);
      if (existingConfig) {
        console.log('✅ Found existing config in Redis');
      } else {
        console.log('ℹ️  No config in Redis yet - will initialize on first read');
      }
    } catch (error) {
      console.error('❌ Redis connection test FAILED:', error.message);
      console.error('Check your UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN');
    }
  } else {
    console.log('️  Redis not configured - using default config (read-only mode)');
    console.log(' To enable config updates, set UPSTASH_REDIS_REST_URL and UPSTASH_REDIS_REST_TOKEN environment variables');
  }
});

module.exports = app;
