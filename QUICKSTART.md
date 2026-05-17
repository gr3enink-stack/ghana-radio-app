# 🚀 Quick Start Guide

Get your Internet Radio Player up and running in under 5 minutes!

## Step 1: Start the Backend

```bash
cd backend
npm install
npm start
```

✅ Backend running at: `http://localhost:3000`

## Step 2: Access Admin Panel

Open your browser: `http://localhost:3000`

**Login:** `admin123`

Update the configuration with your radio stream URL.

## Step 3: Run the Flutter App

```bash
cd flutter_app
flutter pub get
flutter run
```

✅ App is now running on your device/emulator!

## Step 4: Test

1. App opens with splash screen
2. Fetches config from backend
3. Shows "Now Playing" screen
4. Click play button → Music plays!
5. Lock screen → Audio continues ✅

## Next Steps

- Change admin password in backend
- Deploy to DigitalOcean (see DEPLOYMENT_GUIDE.md)
- Build for production
- Submit to app stores

---

**Need help?** Check [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
