# Flutter Installation Guide for Windows

## 📥 Quick Installation Steps

### Step 1: Download Flutter SDK

1. Open your browser and go to:
   **https://docs.flutter.dev/get-started/install/windows**

2. Scroll down to "Get the Flutter SDK" section

3. Click the **"flutter_windows_3.x.x-stable.zip"** download link
   - (The version number will be the latest stable release)

4. Wait for download to complete (~500MB file)

---

### Step 2: Extract Flutter SDK

1. **Create the installation folder:**
   - Open File Explorer
   - Navigate to `C:\`
   - Create a new folder called `src` (if it doesn't exist)
   - Inside `src`, create a folder called `flutter`
   - Final path: `C:\src\flutter`

2. **Extract the downloaded zip:**
   - Find the downloaded zip file (usually in `Downloads` folder)
   - Right-click → Extract All
   - Set destination to: `C:\src`
   - This will create `C:\src\flutter` with all Flutter files

3. **Verify extraction:**
   - Open File Explorer to `C:\src\flutter`
   - You should see files like: `bin`, `packages`, `README.md`, etc.

---

### Step 3: Add Flutter to PATH

#### **Method 1: Using PowerShell (Quick)**

Run this command in PowerShell **as Administrator**:

```powershell
# Add Flutter to PATH permanently
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$flutterPath = "C:\src\flutter\bin"

if ($userPath -notlike "*$flutterPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$flutterPath", "User")
    Write-Host "✅ Flutter added to PATH successfully!" -ForegroundColor Green
} else {
    Write-Host "✅ Flutter already in PATH" -ForegroundColor Green
}

Write-Host "`n⚠️  IMPORTANT: Close and reopen PowerShell for changes to take effect!" -ForegroundColor Yellow
```

#### **Method 2: Using Windows GUI (Manual)**

1. Press `Windows Key` and search: **"Environment Variables"**
2. Click: **"Edit the system environment variables"**
3. Click the **"Environment Variables"** button (bottom right)
4. In the top section **"User variables"**, find and select **"Path"**
5. Click **"Edit"**
6. Click **"New"**
7. Add: `C:\src\flutter\bin`
8. Click **"OK"** on all dialogs
9. **Close and reopen PowerShell** (IMPORTANT!)

---

### Step 4: Verify Installation

1. **Open a NEW PowerShell window** (must be new to load updated PATH)

2. **Run:**
   ```powershell
   flutter --version
   ```

3. **You should see:**
   ```
   Flutter 3.x.x • channel stable
   Tools • Dart 3.x.x
   ```

   ✅ If you see version info → **Success!**  
   ❌ If you get "not recognized" → PATH not set correctly, go back to Step 3

---

### Step 5: Run Flutter Doctor

```powershell
flutter doctor
```

This checks your setup. You'll see output like:

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Microsoft Windows)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
[✗] Chrome - develop for the web (Cannot find Chrome executable)
[✓] Connected device (1 available)
```

**Don't worry about the ✗ marks yet** - we'll fix them next!

---

### Step 6: Install Android Studio (Required for Android Apps)

1. **Download Android Studio:**
   - Go to: https://developer.android.com/studio
   - Click "Download Android Studio"
   - Run the installer

2. **During installation:**
   - ✅ Check "Android Virtual Device"
   - ✅ Check "Android SDK"
   - ✅ Check "Android SDK Platform"
   - Accept default locations
   - Complete installation

3. **First launch:**
   - Open Android Studio
   - Choose "Do not import settings"
   - Follow the setup wizard
   - When prompted, install:
     - ✅ Android SDK Platform (latest version)
     - ✅ Android SDK Build-Tools
     - ✅ Android Emulator

4. **Accept Android Licenses:**
   ```powershell
   flutter doctor --android-licenses
   ```
   - Type `y` and press Enter for each license

---

### Step 7: Run Flutter Doctor Again

```powershell
flutter doctor
```

Now you should see more green checkmarks:

```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Android Studio (version 2023.x)
```

**Any remaining ✗ marks are okay** - you only need Android for mobile apps.

---

### Step 8: Test Your Setup

```powershell
# Navigate to your Flutter app
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"

# Get dependencies
flutter pub get

# Check for connected devices
flutter devices

# Run the app (if you have a device connected or emulator running)
flutter run
```

---

## 🎯 **Creating an Android Emulator (Optional but Recommended)**

If you don't have a physical Android device:

### **Method 1: Using Android Studio**

1. Open Android Studio
2. Click **"More Actions"** → **"Virtual Device Manager"**
3. Click **"Create Virtual Device"**
4. Select a device (e.g., Pixel 6)
5. Click **Next**
6. Download a system image (e.g., API 34)
7. Click **Next** → **Finish**
8. Click the ▶️ button to start the emulator

### **Method 2: Using Command Line**

```powershell
# List available system images
flutter emulators

# Create an emulator
flutter emulators --create --name pixel_6

# Launch the emulator
flutter emulators --launch pixel_6
```

---

## ⚡ **Quick Commands Reference**

```powershell
# Check Flutter version
flutter --version

# Check setup health
flutter doctor

# Get project dependencies
flutter pub get

# List connected devices
flutter devices

# Run app on connected device/emulator
flutter run

# Build APK for Android
flutter build apk --release

# Build for web
flutter build web
```

---

## 🐛 **Troubleshooting**

### Issue: "flutter is not recognized"

**Solution:**
1. Verify Flutter is extracted to `C:\src\flutter`
2. Verify `C:\src\flutter\bin` is in your PATH
3. **Close and reopen PowerShell** (PATH changes require this)
4. Test: `where.exe flutter`

### Issue: flutter doctor shows Android SDK errors

**Solution:**
```powershell
# Set Android SDK path
flutter config --android-sdk C:\Users\YOUR_USERNAME\AppData\Local\Android\Sdk

# Accept licenses
flutter doctor --android-licenses
```

### Issue: No devices found

**Solutions:**
1. Enable USB debugging on physical Android device
2. Connect via USB
3. OR create/start an emulator (see above)
4. Run: `flutter devices`

---

## ✅ **Installation Checklist**

- [ ] Downloaded Flutter SDK zip
- [ ] Extracted to `C:\src\flutter`
- [ ] Added `C:\src\flutter\bin` to PATH
- [ ] Closed and reopened PowerShell
- [ ] `flutter --version` works
- [ ] `flutter doctor` runs
- [ ] Android Studio installed
- [ ] Android SDK installed
- [ ] `flutter doctor --android-licenses` accepted
- [ ] Emulator created or device connected
- [ ] `flutter run` works

---

## 🎉 **You're Ready!**

Once all checkboxes are complete, you can:

```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"
flutter pub get
flutter run
```

**Your Internet Radio Player app will launch!** 📻
