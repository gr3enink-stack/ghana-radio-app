const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3000;

// Environment variables
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';
const CONFIG_FILE = path.join(__dirname, 'config.json');

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

// Ensure config file exists
function ensureConfigFile() {
  if (!fs.existsSync(CONFIG_FILE)) {
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(defaultConfig, null, 2));
    console.log('Created default config.json');
  }
}

// Read configuration from file
function readConfig() {
  try {
    ensureConfigFile();
    console.log('Reading config from:', CONFIG_FILE);
    const data = fs.readFileSync(CONFIG_FILE, 'utf8');
    const config = JSON.parse(data);
    console.log('Config loaded successfully');
    return config;
  } catch (error) {
    console.error('Error reading config:', error);
    console.error('Config file path:', CONFIG_FILE);
    console.error('Error code:', error.code);
    return defaultConfig;
  }
}

// Write configuration to file
function writeConfig(config) {
  try {
    ensureConfigFile();
    console.log('Writing config to:', CONFIG_FILE);
    fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
    console.log('Config written successfully');
    return true;
  } catch (error) {
    console.error('Error writing config:', error);
    console.error('Config file path:', CONFIG_FILE);
    console.error('Error code:', error.code);
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
app.post('/api/admin/update', authenticateAdmin, (req, res) => {
  try {
    const { stationName, streamUrl, albumArtUrl, description } = req.body;

    console.log('Received update request:', { stationName, streamUrl, albumArtUrl, description });

    // Validate required fields
    if (!streamUrl || streamUrl.trim() === '') {
      console.error('Validation failed: Stream URL is required');
      return res.status(400).json({ error: 'Stream URL is required' });
    }

    const currentConfig = readConfig();
    console.log('Current config loaded:', currentConfig);
    
    const newConfig = {
      stationName: stationName || currentConfig.stationName || 'My Radio Station',
      streamUrl: streamUrl.trim(),
      albumArtUrl: albumArtUrl || '',
      description: description || currentConfig.description || '',
      updatedAt: new Date().toISOString()
    };

    console.log('Attempting to write new config:', newConfig);
    const success = writeConfig(newConfig);

    if (success) {
      console.log('Configuration updated successfully');
      res.json({
        message: 'Configuration updated successfully',
        config: newConfig
      });
    } else {
      console.error('Failed to write config file');
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
ensureConfigFile();
app.listen(PORT, () => {
  console.log(`🚀 Radio Server running on port ${PORT}`);
  console.log(`📻 Admin Panel: http://localhost:${PORT}/admin`);
  console.log(`🔌 API: http://localhost:${PORT}/api/config`);
  console.log(`🔑 Admin Password: ${ADMIN_PASSWORD}`);
});

module.exports = app;
