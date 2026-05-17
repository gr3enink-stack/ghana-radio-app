# 📱 Build & Test APK on Your Phone

## 🎯 Quick Build Guide

### Option 1: Build Debug APK (Fastest - For Testing)

Open PowerShell and run:

```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"
C:\src\flutter\bin\flutter.bat build apk --debug
```

**Build Time**: 2-5 minutes (first build), 1-2 minutes (subsequent builds)

**Output Location**: 
```
C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\build\app\outputs\flutter-apk\app-debug.apk
```

---

### Option 2: Build Release APK (For Play Store Testing)

```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"
C:\src\flutter\bin\flutter.bat build apk --release
```

**Output Location**:
```
C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

---

## 📲 Install APK on Your Phone

### Method 1: USB Cable (Recommended)

1. **Enable Developer Options on Android Phone**:
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times
   - You'll see "You are now a developer!"

2. **Enable USB Debugging**:
   - Go to **Settings** → **Developer Options**
   - Turn on **USB Debugging**
   - Turn on **Install via USB** (if available)

3. **Connect Phone to PC via USB**

4. **Install APK**:
   ```powershell
   cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\build\app\outputs\flutter-apk"
   adb install app-debug.apk
   ```

5. **App is installed!** Open it from your app drawer.

---

### Method 2: Transfer APK to Phone

1. **Build the APK** (see Option 1 above)

2. **Copy APK to Phone**:
   - **Via USB**: Copy `app-debug.apk` to your phone's Downloads folder
   - **Via Email**: Email the APK to yourself, download on phone
   - **Via Google Drive/Cloud**: Upload to Drive, download on phone
   - **Via WhatsApp/Telegram**: Send to yourself, download on phone

3. **Install on Phone**:
   - Open **File Manager** on your phone
   - Navigate to where you saved `app-debug.apk`
   - Tap the file to install
   - If prompted: **Allow installation from unknown sources**
   - Tap **Install**

4. **App is installed!** Open it from your app drawer.

---

## 🧪 Test the App

### What to Test:

1. **Splash Screen**:
   - ✅ Does the VAS Media logo appear? (or fallback radio icon)
   - ✅ Purple gradient background
   - ✅ Loading spinner shows

2. **Main Player Screen**:
   - ✅ Does it connect to your backend? (https://vasfm-online.vercel.app)
   - ✅ Can you play/pause the stream?
   - ✅ Does the album art show?
   - ✅ Station name displays correctly

3. **Now Playing Features**:
   - ✅ Play/Pause button works
   - ✅ Volume control works
   - ✅ Live indicator shows when playing
   - ✅ Music note animation plays

4. **About Screen**:
   - ✅ Logo appears (or fallback icon)
   - ✅ "VAS FM Online" title
   - ✅ "Media VAS" subtitle
   - ✅ Developer credit: "Arthium Labs Product"

5. **App Drawer**:
   - ✅ Menu opens from top-right
   - ✅ About option works
   - ✅ Share option works

---

## 🐛 Troubleshooting

### "Flutter command not found"
**Solution**: Always use full path:
```powershell
C:\src\flutter\bin\flutter.bat
```

### "Build failed - Gradle error"
**Solution**:
```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"
C:\src\flutter\bin\flutter.bat clean
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat build apk --debug
```

### "App not installed" on phone
**Causes**:
- APK already installed → Uninstall old version first
- Not enough storage → Free up space
- Unknown sources blocked → Enable in Settings

**Solution**: 
- Uninstall old app: Long press app icon → Uninstall
- Try installing again

### "Cannot connect to server"
**Solution**: 
- Make sure your backend is running on Vercel
- Test: Open https://vasfm-online.vercel.app/api/health in browser
- Check phone has internet connection

### "adb not recognized"
**Install ADB**:
```powershell
winget install --id=Google.PlatformTools
```

Then add to PATH or use full path:
```powershell
$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe install app-debug.apk
```

---

## 📊 Build Comparison

| Feature | Debug APK | Release APK |
|---------|-----------|-------------|
| Build Time | Fast (2-5 min) | Slow (5-10 min) |
| File Size | Larger (~30-50 MB) | Smaller (~15-25 MB) |
| Performance | Slower | Optimized |
| Debugging | ✅ Enabled | ❌ Disabled |
| Code Obfuscation | ❌ No | ✅ Yes |
| For Testing | ✅ Perfect | ⚠️ Overkill |
| For Play Store | ❌ No | ✅ Required |

---

## 🎯 What to Do After Testing

### If Everything Works:
1. ✅ Build release AAB (Android App Bundle) for Play Store
2. ✅ Generate signing key (if not done yet)
3. ✅ Submit to Google Play Console

### If Issues Found:
1. 🐛 Report the bug
2. 🔧 Fix the code
3. 🔄 Rebuild APK
4. 📲 Reinstall and test again

---

## 🚀 Next Steps After Testing

### Build Release AAB for Play Store:

```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"
C:\src\flutter\bin\flutter.bat build appbundle --release
```

**Output**: 
```
build\app\outputs\bundle\release\app-release.aab
```

This AAB file is what you upload to Google Play Console!

---

## 💡 Pro Tips

1. **Test on Multiple Devices**: Different screen sizes, Android versions
2. **Test Offline**: See how app handles no internet
3. **Test Background**: Play stream, switch to another app
4. **Test Lock Screen**: Controls should work on lock screen
5. **Test Headphones**: Plug/unplug headphones while playing
6. **Test Notifications**: Audio notification should show in status bar

---

**Ready to build?** Run the debug APK build command above! 🚀
