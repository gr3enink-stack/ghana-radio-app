const express = require('express');
const cors = require('cors');
const path = require('path');
const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;

// Environment variables
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';
const JSONBIN_API_KEY = process.env.JSONBIN_API_KEY || '';
const JSONBIN_BIN_ID = process.env.JSONBIN_BIN_ID || '';
const JWT_SECRET = process.env.JWT_SECRET || 'vasfm-secret-key-change-in-production-2026';

// Rate limiting configuration
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    error: 'Too many requests, please try again later.',
    retryAfter: '15 minutes'
  },
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20, // Limit each IP to 20 requests per windowMs (for auth endpoints)
  message: {
    error: 'Too many attempts, please try again later.',
    retryAfter: '15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

const apiLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30, // Limit each IP to 30 requests per minute (for API endpoints)
  message: {
    error: 'Too many API requests, please try again later.',
    retryAfter: '1 minute'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

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

// Active listeners tracking
const activeListeners = new Map();

// Config loading state
let configLoading = true;
let configLoadedSuccessfully = false;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'admin')));

// Apply general rate limiter to all routes
app.use(generalLimiter);

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
    console.log('🔄 Loading configuration from JSONBin...');
    currentConfig = await loadConfigFromJSONBin();
    configLoaded = true;
    configLoading = false;
    configLoadedSuccessfully = true;
    console.log('✅ Initial config loaded successfully');
    console.log('📻 Station:', currentConfig.stationName);
    console.log('📡 Stream:', currentConfig.streamUrl);
  } catch (error) {
    console.error('❌ Failed to load initial config, using defaults:', error.message);
    configLoaded = true;
    configLoading = false;
    configLoadedSuccessfully = false;
    // Still mark as loaded to allow requests with default config
  }
})();

// Validate stream URL format
function isValidStreamUrl(url) {
  if (!url || typeof url !== 'string') {
    return { valid: false, error: 'Stream URL is required' };
  }
  
  const trimmed = url.trim();
  
  // Check if it starts with http:// or https://
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    return { valid: false, error: 'Stream URL must start with http:// or https://' };
  }
  
  try {
    const urlObj = new URL(trimmed);
    
    // Check for common issues
    const hasProtocol = urlObj.protocol === 'http:' || urlObj.protocol === 'https:';
    const hasHost = urlObj.hostname && urlObj.hostname.length > 0;
    
    if (!hasProtocol || !hasHost) {
      return { valid: false, error: 'Invalid URL format' };
    }
    
    // Warn about missing port and path (might be incomplete)
    if (!urlObj.port && urlObj.pathname === '/') {
      return { 
        valid: true, 
        warning: 'URL has no port or path. Consider adding /stream, /live, or /; (for Shoutcast)' 
      };
    }
    
    return { valid: true };
  } catch (error) {
    return { valid: false, error: 'Invalid URL format: ' + error.message };
  }
}

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
app.post('/api/listener/heartbeat', apiLimiter, (req, res) => {
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
app.get('/api/listeners', apiLimiter, (req, res) => {
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
app.get('/api/config', apiLimiter, (req, res) => {
  try {
    console.log('📱 Mobile app requesting config');
    
    // If config is still loading, wait briefly or return defaults
    if (configLoading) {
      console.log('⚠️ Config still loading, returning defaults');
      return res.json({
        stationName: defaultConfig.stationName,
        streamUrl: defaultConfig.streamUrl,
        albumArtUrl: defaultConfig.albumArtUrl,
        description: defaultConfig.description,
        updatedAt: defaultConfig.updatedAt,
        loading: true
      });
    }
    
    const config = readConfig();
    
    // Don't expose sensitive fields
    const publicConfig = {
      stationName: config.stationName,
      streamUrl: config.streamUrl,
      albumArtUrl: config.albumArtUrl,
      description: config.description,
      updatedAt: config.updatedAt,
      loaded: configLoadedSuccessfully
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
      updatedAt: defaultConfig.updatedAt,
      loaded: false
    });
  }
});

// ==================== ADMIN API ENDPOINTS ====================

// Simple authentication middleware with JWT
function authenticateAdmin(req, res, next) {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    console.log('❌ Auth failed: No authorization header');
    return res.status(401).json({ error: 'No authorization header provided' });
  }

  const token = authHeader.startsWith('Bearer ') 
    ? authHeader.slice(7) 
    : authHeader;

  try {
    // Verify JWT token
    const decoded = jwt.verify(token, JWT_SECRET);
    
    // Check if token is still valid
    if (decoded.exp && Date.now() >= decoded.exp * 1000) {
      console.log('❌ Auth failed: Token expired');
      return res.status(403).json({ error: 'Token expired, please login again' });
    }
    
    console.log('✅ Admin authentication successful (JWT verified)');
    next();
  } catch (error) {
    console.log('❌ Auth failed: Invalid token');
    return res.status(403).json({ error: 'Invalid or expired token' });
  }
}

// Admin login endpoint
app.post('/api/admin/login', strictLimiter, (req, res) => {
  try {
    const { password } = req.body;

    console.log('🔐 Admin login attempt');

    if (!password) {
      console.log('❌ Login failed: No password provided');
      return res.status(400).json({ error: 'Password is required' });
    }

    if (password === ADMIN_PASSWORD) {
      console.log('✅ Login successful');
      
      // Generate JWT token with 24-hour expiration
      const token = jwt.sign(
        { 
          role: 'admin',
          iat: Math.floor(Date.now() / 1000)
        },
        JWT_SECRET,
        { expiresIn: '24h' }
      );
      
      res.json({ 
        message: 'Login successful',
        token: token,
        expiresIn: '24 hours',
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      });
    } else {
      console.log('❌ Login failed: Invalid password');
      res.status(401).json({ error: 'Invalid password' });
    }
  } catch (error) {
    console.error('❌ Login endpoint error:', error.message);
    console.error('   Stack:', error.stack);
    res.status(500).json({ 
      error: 'Internal server error during login',
      details: error.message 
    });
  }
});

// Update radio configuration (Admin only)
app.post('/api/admin/update', strictLimiter, authenticateAdmin, async (req, res) => {
  try {
    console.log('📝 Admin update request received');
    console.log('   Request body:', req.body);
    
    const { stationName, streamUrl, albumArtUrl, description } = req.body;

    // Validate required fields
    if (!streamUrl || streamUrl.trim() === '') {
      console.log('❌ Validation failed: Stream URL is required');
      return res.status(400).json({ error: 'Stream URL is required' });
    }
    
    // Validate stream URL format
    const urlValidation = isValidStreamUrl(streamUrl);
    if (!urlValidation.valid) {
      console.log('❌ Validation failed:', urlValidation.error);
      return res.status(400).json({ error: urlValidation.error });
    }
    
    // Log warning if present
    if (urlValidation.warning) {
      console.log('⚠️ URL Warning:', urlValidation.warning);
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
        config: newConfig,
        warning: urlValidation.warning || null
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
app.get('/api/admin/config', strictLimiter, authenticateAdmin, (req, res) => {
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
