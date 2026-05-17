# Internet Radio Player

A production-ready Internet Radio Player mobile app built with Flutter, featuring background audio support and a web-based admin panel for easy stream management.

## 🚀 Features

### Mobile App (iOS & Android)
- **Beautiful UI** with Material Design 3
- **Background audio playback** - continues when screen is off or app is minimized
- **Now Playing screen** with album art, station name, and controls
- **Automatic configuration** - fetches stream URL from API on startup
- **Splash screen** with loading indicator
- **Error handling** with retry functionality
- **System notifications** for audio controls

### Admin Panel (Web)
- **Secure login** with password protection
- **Easy configuration** - update stream URL, station name, album art, and description
- **Instant updates** - changes reflect immediately on app restart
- **Mobile-friendly** responsive design

### Backend API
- **RESTful API** built with Node.js + Express
- **Public endpoints** for app configuration
- **Protected admin routes** with authentication
- **Health check endpoint** for monitoring
- **File-based storage** (simple, no database needed)

## 📁 Project Structure

```
Radio/
├── flutter_app/              # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart        # App entry point
│   │   ├── models/          # Data models
│   │   ├── providers/       # State management
│   │   └── screens/         # UI screens
│   ├── pubspec.yaml         # Flutter dependencies
│   └── assets/              # App assets
│
├── backend/                  # Node.js backend
│   ├── server.js            # Express server
│   ├── package.json         # Node dependencies
│   ├── config.json          # Auto-generated config file
│   └── admin/               # Admin panel
│       └── index.html       # Web interface
│
└── DEPLOYMENT_GUIDE.md      # Complete deployment instructions
```

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js + Express
- **Audio**: just_audio + audio_service
- **State Management**: Provider
- **Deployment**: DigitalOcean App Platform

## 📦 Quick Start

### Backend Setup

```bash
cd backend
npm install
npm start
```

Server runs at `http://localhost:3000`

**Admin Panel**: `http://localhost:3000`  
**API**: `http://localhost:3000/api/config`  
**Default Password**: `admin123`

### Flutter App Setup

```bash
cd flutter_app
flutter pub get
flutter run
```

## 🌐 Deployment

See the complete [Deployment Guide](DEPLOYMENT_GUIDE.md) for:
- Deploying backend to DigitalOcean App Platform ($5-10/month)
- Building Android APK/App Bundle
- Building iOS app
- Publishing to app stores

## 🔧 Configuration

### Environment Variables (Backend)

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | `3000` |
| `ADMIN_PASSWORD` | Admin panel password | `admin123` |

### API Endpoints

**Public:**
- `GET /api/config` - Get current radio configuration
- `GET /api/health` - Health check

**Admin (requires authentication):**
- `POST /api/admin/login` - Authenticate
- `GET /api/admin/config` - Get full config
- `POST /api/admin/update` - Update configuration

## 📱 Flutter Build Commands

**Android APK:**
```bash
flutter build apk --release --dart-define=API_URL=https://your-api-url.com
```

**iOS:**
```bash
flutter build ios --release --dart-define=API_URL=https://your-api-url.com
```

## 💰 Hosting Costs

- **DigitalOcean App Platform**: $5-12/month
- **Total**: ~$5-12/month

## 🎯 Key Features Explained

### Background Audio
The app uses `just_audio_background` to ensure audio continues playing when:
- Screen is locked
- App is in background
- User switches to another app

Audio controls are available in the system notification shade.

### Dynamic Configuration
Stream URL is NOT hardcoded in the app. Instead:
1. App fetches configuration from API on startup
2. Admin can update stream URL anytime via web panel
3. Changes take effect on next app restart

### Icecast/Shoutcast Support
Compatible with:
- Icecast v2 streams
- Shoutcast v2 streams
- Any HTTP audio stream (MP3, AAC, OGG)

## 🔐 Security

- Admin routes protected with password authentication
- CORS enabled for cross-origin requests
- HTTPS recommended for production
- Environment variables for sensitive data

## 📄 License

MIT License - Feel free to use this for your projects!

## 🤝 Support

For issues, questions, or contributions:
1. Check the [Deployment Guide](DEPLOYMENT_GUIDE.md)
2. Review troubleshooting section
3. Open an issue on GitHub

---

**Built with ❤️ for radio enthusiasts everywhere**
