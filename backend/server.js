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
  streamUrl: 'http://s23.myradiostream.com:21022/',
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

// JSONBin.io functions for persistent storage
async function loadConfigFromJSONBin() {
  if (!JSONBIN_API_KEY || !JSONBIN_BIN_ID) {
    console.log('⚠️  JSONBin not configured - using in-memory config');
    return defaultConfig;
  }

  try {
    const response = await fetch(`https://api.jsonbin.io/v3/b/${JSONBIN_BIN_ID}/latest`, {
      headers: {
        'X-Master-Key': JSONBIN_API_KEY
      }
    });

    if (response.ok) {
      const data = await response.json();
      console.log('✅ Config loaded from JSONBin');
      return data.record;
    } else {
      console.error('❌ Failed to load config from JSONBin:', response.status);
      return defaultConfig;
    }
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
    const response = await fetch(`https://api.jsonbin.io/v3/b/${JSONBIN_BIN_ID}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-Master-Key': JSONBIN_API_KEY
      },
      body: JSON.stringify(config)
    });

    if (response.ok) {
      console.log('✅ Config saved to JSONBin');
      return true;
    } else {
      console.error('❌ Failed to save config to JSONBin:', response.status);
      return false;
    }
  } catch (error) {
    console.error('❌ Error saving config to JSONBin:', error.message);
    return false;
  }
}

// Load config on startup
(async function initializeConfig() {
  currentConfig = await loadConfigFromJSONBin();
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
app.get('/api/config', (req, res) => {
  try {
    const config = readConfig();
    // Don't expose sensitive fields
    const publicConfig = {
      stationName: config.stationName,
      streamUrl: config.streamUrl,
      albumArtUrl: config.albumArtUrl,
      description: config.description,
      updatedAt: config.updatedAt
    };
    res.json(publicConfig);
  } catch (error) {
    res.status(500).json({ error: 'Failed to read configuration' });
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

    // Validate required fields
    if (!streamUrl || streamUrl.trim() === '') {
      return res.status(400).json({ error: 'Stream URL is required' });
    }

    const currentConfig = readConfig();
    
    const newConfig = {
      stationName: stationName || currentConfig.stationName || 'VAS FM Online',
      streamUrl: streamUrl.trim(),
      albumArtUrl: albumArtUrl || '',
      description: description || currentConfig.description || '',
      updatedAt: new Date().toISOString()
    };

    const success = await writeConfig(newConfig);

    if (success) {
      res.json({
        message: 'Configuration updated successfully',
        config: newConfig
      });
    } else {
      res.status(500).json({ error: 'Failed to save configuration' });
    }
  } catch (error) {
    console.error('Error updating config:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get current config (Admin only - for admin panel)
app.get('/api/admin/config', authenticateAdmin, (req, res) => {
  try {
    const config = readConfig();
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
app.listen(PORT, () => {
  console.log(`🚀 Radio Server running on port ${PORT}`);
  console.log(`📻 Admin Panel: http://localhost:${PORT}/admin`);
  console.log(` API: http://localhost:${PORT}/api/config`);
  console.log(`🔑 Admin Password: ${ADMIN_PASSWORD}`);
  console.log('✅ Using in-memory config storage (persists during server runtime)');
});

module.exports = app;
