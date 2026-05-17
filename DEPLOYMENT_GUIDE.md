# Internet Radio Player - Deployment Guide

## 📋 Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Backend Deployment (DigitalOcean App Platform)](#backend-deployment)
4. [Flutter App Configuration](#flutter-app-configuration)
5. [Building the Mobile App](#building-the-mobile-app)
6. [Testing & Verification](#testing--verification)
7. [Maintenance & Updates](#maintenance--updates)
8. [Troubleshooting](#troubleshooting)

---

## Overview

This guide will walk you through deploying the Internet Radio Player backend to DigitalOcean App Platform and building the Flutter mobile app for iOS and Android.

**Architecture:**
- **Backend**: Node.js + Express API hosted on DigitalOcean ($5-10/month)
- **Admin Panel**: Web interface for managing radio configuration
- **Mobile App**: Flutter app (iOS & Android) with background audio support

---

## Prerequisites

### For Backend Deployment:
- DigitalOcean account (sign up at digitalocean.com)
- Git installed on your computer
- Your Icecast/Shoutcast stream URL ready

### For Flutter App Development:
- Flutter SDK (3.0.0 or higher)
- Android Studio (for Android builds)
- Xcode (for iOS builds - Mac only)
- VS Code or Android Studio as IDE

---

## Backend Deployment

### Step 1: Prepare Your Backend Code

1. **Navigate to the backend folder:**
   ```bash
   cd backend
   ```

2. **Test locally first:**
   ```bash
   npm install
   npm start
   ```

3. **Verify it's working:**
   - Open browser: `http://localhost:3000`
   - Admin panel should load
   - Test API: `http://localhost:3000/api/config`

4. **Create a Git repository:**
   ```bash
   cd ..
   git init
   git add backend/
   git commit -m "Initial backend commit"
   ```

### Step 2: Push to GitHub/GitLab

1. **Create a new repository on GitHub**

2. **Push your code:**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/radio-backend.git
   git branch -M main
   git push -u origin main
   ```

### Step 3: Deploy to DigitalOcean App Platform

1. **Log in to DigitalOcean** and click "Create" → "Apps"

2. **Connect your repository:**
   - Select GitHub/GitLab
   - Choose your repository
   - Select the `main` branch

3. **Configure the app:**
   - **Name**: `radio-backend` (or your preference)
   - **Region**: Choose closest to your users (e.g., New York, San Francisco, Amsterdam)
   - **Branch**: `main`
   - **Source Directory**: `backend` (IMPORTANT!)
   - **Build Command**: `npm install`
   - **Run Command**: `npm start`

4. **Set Environment Variables:**
   Click "Edit Plan" and add:
   ```
   ADMIN_PASSWORD = your-secure-password-here
   NODE_ENV = production
   ```
   ⚠️ **Change the password to something strong!**

5. **Choose your plan:**
   - **Basic**: $5/month (512MB RAM) - Good for starting
   - **Professional**: $12/month (1GB RAM) - Better for production
   - Start with Basic, upgrade if needed

6. **Click "Launch Starter App"**

7. **Wait for deployment** (takes 2-5 minutes)

8. **Note your app URL:**
   - DigitalOcean will give you a URL like: `https://radio-backend-xxxxx.ondigitalocean.app`
   - **SAVE THIS URL** - you'll need it for the Flutter app

### Step 4: Verify Deployment

1. **Test the API:**
   ```
   https://your-app-url.ondigitalocean.app/api/config
   ```

2. **Access Admin Panel:**
   ```
   https://your-app-url.ondigitalocean.app
   ```

3. **Login with your ADMIN_PASSWORD**

4. **Update your radio configuration:**
   - Station Name: Your station name
   - Stream URL: Your Icecast/Shoutcast URL
   - Album Art URL (optional): Logo/artwork URL
   - Description (optional): Station description
   - Click "Save Configuration"

---

## Flutter App Configuration

### Step 1: Update API URL

Open `flutter_app/lib/screens/splash_screen.dart` and find this line:

```dart
const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000',
);
```

Change the `defaultValue` to your DigitalOcean URL:

```dart
const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://your-app-url.ondigitalocean.app',
);
```

### Step 2: Configure App Metadata (Optional)

#### Android:
Open `flutter_app/android/app/src/main/AndroidManifest.xml` and update:
- App name
- Package name
- Permissions (already configured)

#### iOS:
Open `flutter_app/ios/Runner/Info.plist` and update:
- App name
- Bundle identifier
- Background modes (already configured for audio)

### Step 3: Add App Icon & Assets

1. Create the assets directory:
   ```bash
   cd flutter_app
   mkdir -p assets/images
   ```

2. Add your app logo to `assets/images/` (optional)

3. Generate app icons:
   ```bash
   flutter pub add flutter_launcher_icons
   flutter pub run flutter_launcher_icons
   ```

---

## Building the Mobile App

### For Android:

1. **Navigate to Flutter app:**
   ```bash
   cd flutter_app
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Build APK (for testing):**
   ```bash
   flutter build apk --release --dart-define=API_URL=https://your-app-url.ondigitalocean.app
   ```

4. **Build App Bundle (for Play Store):**
   ```bash
   flutter build appbundle --release --dart-define=API_URL=https://your-app-url.ondigitalocean.app
   ```

5. **Find your build:**
   - APK: `build/app/outputs/flutter-apk/app-release.apk`
   - AAB: `build/app/outputs/bundle/release/app-release.aab`

### For iOS (Mac only):

1. **Navigate to Flutter app:**
   ```bash
   cd flutter_app
   ```

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Open in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

4. **Configure in Xcode:**
   - Set your Team (Apple Developer account required)
   - Set Bundle Identifier
   - Configure signing & capabilities

5. **Build for release:**
   ```bash
   flutter build ios --release --dart-define=API_URL=https://your-app-url.ondigitalocean.app
   ```

6. **Archive and upload to App Store:**
   - In Xcode: Product → Archive
   - Follow App Store Connect submission process

---

## Testing & Verification

### Test the Complete Flow:

1. **Backend API Test:**
   ```bash
   curl https://your-app-url.ondigitalocean.app/api/config
   ```
   Should return JSON with your station config.

2. **Admin Panel Test:**
   - Visit admin panel URL
   - Login with your password
   - Update station name
   - Save and verify

3. **Mobile App Test:**
   - Install APK on Android device
   - Open app
   - Verify it fetches config from API
   - Test play/pause
   - Turn off screen - audio should continue
   - Open another app - audio should continue

### Background Audio Testing:

✅ **Audio continues when:**
- Screen is locked
- App is in background
- User switches to another app

✅ **Notification controls work:**
- Play/pause from notification
- Shows station name
- Shows album art (if configured)

---

## Maintenance & Updates

### Updating Stream URL or Station Info:

1. Visit your admin panel
2. Login with your password
3. Update any field
4. Click "Save"
5. Users will see changes on next app restart

### Updating the Backend Code:

1. Make changes locally
2. Commit to Git:
   ```bash
   git add .
   git commit -m "Update description"
   git push origin main
   ```
3. DigitalOcean automatically redeploys

### Updating the Mobile App:

1. Make Flutter code changes
2. Increment version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # version+build_number
   ```
3. Rebuild with commands above
4. Submit to app stores

### Monitoring:

1. **DigitalOcean Dashboard:**
   - View logs
   - Monitor CPU/memory usage
   - Check uptime

2. **Health Check Endpoint:**
   ```
   https://your-app-url.ondigitalocean.app/api/health
   ```

---

## Troubleshooting

### Issue: App can't connect to API

**Solutions:**
- Verify your DigitalOcean app URL is correct
- Check if backend is running: visit `/api/health`
- Ensure CORS is enabled (already configured)
- Check for typos in the API_URL

### Issue: Audio not playing in background

**Solutions:**
- Verify `just_audio_background` is initialized in `main.dart`
- Check Android permissions in `AndroidManifest.xml`
- Check iOS background modes in `Info.plist`
- Test on physical device (simulators may have limitations)

### Issue: Admin panel login fails

**Solutions:**
- Verify `ADMIN_PASSWORD` environment variable is set
- Check DigitalOcean app logs
- Ensure password matches exactly (case-sensitive)

### Issue: Stream URL doesn't work

**Solutions:**
- Test URL in VLC or browser first
- Ensure URL ends with `/stream` or `.mp3`
- Verify Icecast/Shoutcast server is running
- Check if stream requires authentication

### Issue: Build fails on Android

**Solutions:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Issue: Build fails on iOS

**Solutions:**
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter build ios --release
```

### DigitalOcean Deployment Fails

**Solutions:**
- Check build logs in DigitalOcean dashboard
- Verify `package.json` is in `backend/` directory
- Ensure `server.js` exists
- Check environment variables are set correctly
- Verify Node.js version is >= 16

---

## Cost Breakdown

**DigitalOcean App Platform:**
- Basic: $5/month (sufficient for most radio apps)
- Professional: $12/month (if you have many users)

**Total Monthly Cost: $5-12/month** 🎉

---

## Security Notes

1. **Change the default password** - Never use `admin123` in production
2. **Use HTTPS** - DigitalOcean provides this automatically
3. **Keep dependencies updated** - Run `npm update` regularly
4. **Monitor logs** - Check DigitalOcean dashboard weekly
5. **Backup config.json** - Download periodically

---

## Support & Resources

- **Flutter Docs**: https://flutter.dev/docs
- **DigitalOcean Docs**: https://docs.digitalocean.com/products/app-platform/
- **just_audio Package**: https://pub.dev/packages/just_audio
- **Audio Service Package**: https://pub.dev/packages/audio_service

---

## Next Steps

1. ✅ Deploy backend to DigitalOcean
2. ✅ Configure radio stream URL via admin panel
3. ✅ Build Flutter app for Android/iOS
4. ✅ Test background audio
5. ✅ Submit to app stores
6. ✅ Monitor and maintain

**You're now running a production-ready Internet Radio app! 🎉**
