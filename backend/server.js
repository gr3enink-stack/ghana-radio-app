const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Environment variables
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';
const JSONBIN_API_KEY = process.env.JSONBIN_API_KEY || '';
const JSONBIN_BIN_ID = process.env.JSONBIN_BIN_ID || '';

// Default config (used if JSONBin is not configured or fails)
const defaultConfig = {
  stationName: 'VAS FM Online',
  streamUrl: 'http://s23.myradiostream.com:21022/;',  // Shoutcast V1 format with semicolon
  albumArtUrl: '',
  description: 'Your favorite internet radio station',
  updatedAt: new Date().toISOString()
};

// In-memory cache (will be loaded from JSONBin on startup)
let currentConfig = { ...defaultConfig };

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'admin')));

// Log startup
console.log('🚀 VAS FM Radio Backend Starting...');
console.log('📡 Admin Password:', ADMIN_PASSWORD ? '***configured***' : '***using default***');
console.log('💾 JSONBin:', JSONBIN_API_KEY && JSONBIN_BIN_ID ? '✅ configured' : '⚠️  not configured (using in-memory)');

// JSONBin.io functions for persistent storage
async function loadConfigFromJSONBin() {
  if (!JSONBIN_API_KEY || !JSONBIN_BIN_ID) {
    console.log('⚠️  JSONBin not configured - using in-memory config');
    return defaultConfig;
  }

  try {
    const https = require('https');
    
    return new Promise((resolve, reject) => {
      const url = `https://api.jsonbin.io/v3/b/${JSONBIN_BIN_ID}/latest`;
      
      https.get(url, {
        headers: {
          'X-Master-Key': JSONBIN_API_KEY
        }
      }, (response) => {
        let data = '';
        
        response.on('data', (chunk) => {
          data += chunk;
        });
        
        response.on('end', () => {
          try {
            if (response.statusCode === 200) {
              const parsed = JSON.parse(data);
              console.log('✅ Config loaded from JSONBin');
              resolve(parsed.record);
            } else {
              console.error('❌ Failed to load config from JSONBin:', response.statusCode);
              resolve(defaultConfig);
            }
          } catch (error) {
            console.error('❌ Error parsing JSONBin response:', error.message);
            resolve(defaultConfig);
          }
        });
      }).on('error', (error) => {
        console.error('❌ Error loading config from JSONBin:', error.message);
        resolve(defaultConfig);
      });
    });
  } catch (error) {
    console.error('❌ Error loading config from JSONBin:', error.message);
    return defaultConfig;
  }
}

async function saveConfigToJSONBin(config) {
  if (!JSONBIN_API_KEY || !JSONBIN_BIN_ID) {
    console.log('⚠️  JSONBin not configured - config will not persist');
    return true;
  }

  try {
    const https = require('https');
    
    return new Promise((resolve, reject) => {
      const url = `https://api.jsonbin.io/v3/b/${JSONBIN_BIN_ID}`;
      const postData = JSON.stringify(config);
      
      const options = {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData),
          'X-Master-Key': JSONBIN_API_KEY
        }
      };
      
      const req = https.request(url, options, (response) => {
        let data = '';
        
        response.on('data', (chunk) => {
          data += chunk;
        });
        
        response.on('end', () => {
          if (response.statusCode === 200) {
            console.log('✅ Config saved to JSONBin');
            resolve(true);
          } else {
            console.error('❌ Failed to save config to JSONBin:', response.statusCode, data);
            resolve(false);
          }
        });
      });
      
      req.on('error', (error) => {
        console.error('❌ Error saving config to JSONBin:', error.message);
        resolve(false);
      });
      
      req.write(postData);
      req.end();
    });
  } catch (error) {
    console.error('❌ Error saving config to JSONBin:', error.message);
    return false;
  }
}

// Load config on startup (with error handling)
let configLoaded = false;
(async function initializeConfig() {
  try {
    currentConfig = await loadConfigFromJSONBin();
    configLoaded = true;
    console.log('✅ Initial config loaded');
  } catch (error) {
    console.error('❌ Failed to load initial config, using defaults:', error.message);
    configLoaded = true; // Still mark as loaded to allow requests
  }
})();

// Read configuration from memory
function readConfig() {
  return currentConfig;
}

// Write configuration to memory and JSONBin
async function writeConfig(config) {
  currentConfig = config;
  // Save to JSONBin for persistence
  const success = await saveConfigToJSONBin(config);
  return success;
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
  try {
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
  } catch (error) {
    console.error('❌ Error getting listeners:', error);
    res.json({
      activeListeners: 0,
      listeners: []
    });
  }
});

// ==================== PUBLIC API ENDPOINTS ====================

// Get current radio configuration (Public - for mobile app)
app.get('/api/config', (req, res) => {
  try {
    console.log('📱 Mobile app requesting config');
    const config = readConfig();
    
    // Don't expose sensitive fields
    const publicConfig = {
      stationName: config.stationName,
      streamUrl: config.streamUrl,
      albumArtUrl: config.albumArtUrl,
      description: config.description,
      updatedAt: config.updatedAt
    };
    
    console.log('📱 Config sent:', publicConfig.stationName, publicConfig.streamUrl);
    res.json(publicConfig);
  } catch (error) {
    console.error('❌ Error reading config for mobile app:', error);
    // Always return default config on error
    res.json({
      stationName: defaultConfig.stationName,
      streamUrl: defaultConfig.streamUrl,
      albumArtUrl: defaultConfig.albumArtUrl,
      description: defaultConfig.description,
      updatedAt: defaultConfig.updatedAt
    });
  }
});

// ==================== ADMIN API ENDPOINTS ====================

// Simple authentication middleware
function authenticateAdmin(req, res, next) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    console.log('❌ Auth failed: No authorization header');
    return res.status(401).json({ error: 'No authorization header provided' });
  }

  // Support Bearer token or Basic auth
  const token = authHeader.startsWith('Bearer ') 
    ? authHeader.slice(7) 
    : authHeader;

  if (token !== ADMIN_PASSWORD) {
    console.log('❌ Auth failed: Invalid password provided');
    return res.status(403).json({ error: 'Invalid password' });
  }

  console.log('✅ Admin authentication successful');
  next();
}

// Admin login endpoint
app.post('/api/admin/login', (req, res) => {
  const { password } = req.body;

  console.log('🔐 Admin login attempt');

  if (!password) {
    console.log('❌ Login failed: No password provided');
    return res.status(400).json({ error: 'Password is required' });
  }

  if (password === ADMIN_PASSWORD) {
    console.log('✅ Login successful');
    res.json({ 
      message: 'Login successful',
      token: ADMIN_PASSWORD // Simple token (same as password for now)
    });
  } else {
    console.log('❌ Login failed: Invalid password');
    res.status(401).json({ error: 'Invalid password' });
  }
});

// Update radio configuration (Admin only)
app.post('/api/admin/update', authenticateAdmin, async (req, res) => {
  try {
    console.log('📝 Admin update request received');
    console.log('   Request body:', req.body);
    
    const { stationName, streamUrl, albumArtUrl, description } = req.body;

    // Validate required fields
    if (!streamUrl || streamUrl.trim() === '') {
      console.log('❌ Validation failed: Stream URL is required');
      return res.status(400).json({ error: 'Stream URL is required' });
    }

    const currentConfig = readConfig();
    console.log('📋 Current config:', currentConfig);
    
    const newConfig = {
      stationName: stationName || currentConfig.stationName || 'VAS FM Online',
      streamUrl: streamUrl.trim(),
      albumArtUrl: albumArtUrl || '',
      description: description || currentConfig.description || '',
      updatedAt: new Date().toISOString()
    };

    console.log('💾 Saving new config:', newConfig);
    const success = await writeConfig(newConfig);
    console.log('💾 Save result:', success ? 'SUCCESS' : 'FAILED');

    if (success) {
      console.log('✅ Configuration updated successfully');
      res.json({
        message: 'Configuration updated successfully',
        config: newConfig
      });
    } else {
      console.error('❌ Failed to save configuration');
      res.status(500).json({ error: 'Failed to save configuration' });
    }
  } catch (error) {
    console.error('❌ Error updating config:', error);
    console.error('   Stack:', error.stack);
    res.status(500).json({ error: 'Internal server error: ' + error.message });
  }
});

// Get current config (Admin only - for admin panel)
app.get('/api/admin/config', authenticateAdmin, (req, res) => {
  try {
    console.log('📋 Admin requesting current config');
    const config = readConfig();
    console.log('📋 Config loaded:', config.stationName, config.streamUrl);
    res.json(config);
  } catch (error) {
    console.error('❌ Error reading config for admin:', error);
    // Return default config even on error
    res.json(defaultConfig);
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
app.listen(PORT, () => {
  console.log('✅ ========================================');
  console.log('✅ VAS FM Radio Server is READY!');
  console.log('✅ ========================================');
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📻 Admin Panel: http://localhost:${PORT}`);
  console.log(`📱 Mobile API: http://localhost:${PORT}/api/config`);
  console.log(`💾 Config Storage: ${JSONBIN_API_KEY && JSONBIN_BIN_ID ? 'JSONBin (Persistent)' : 'In-Memory (Temporary)'}`);
  console.log('✅ ========================================');
});

module.exports = app;
