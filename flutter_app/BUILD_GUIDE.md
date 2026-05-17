# 📱 VAS FM Online - Build Guide for Google Play Store

## 🎯 **Current Status:**
Building release APK in progress...

---

## 📦 **Build Types Explained:**

### **1. APK (Android Package)**
- ✅ For testing on devices
- ✅ Can be shared directly
- ✅ Quick to build
- ❌ NOT for Google Play Store

### **2. AAB (Android App Bundle)**
- ✅ REQUIRED for Google Play Store
- ✅ Optimized for each device
- ✅ Smaller downloads for users
- ✅ Must be signed with keystore

---

## 🔧 **Build Commands:**

### **Option 1: Test APK (Current Build)**
```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"
C:\src\flutter\bin\flutter.bat build apk --release --dart-define=API_URL=https://your-backend-url.com
```

**Output Location:**
```
build\app\outputs\flutter-apk\app-release.apk
```

### **Option 2: Release AAB (For Play Store)**
```powershell
# First, generate keystore (one-time only)
keytool -genkey -v -keystore C:\Users\Robin\vas-fm-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vas-fm-key

# Then create key.properties file
# (See instructions below)

# Then build AAB
C:\src\flutter\bin\flutter.bat build appbundle --release --dart-define=API_URL=https://your-backend-url.com
```

**Output Location:**
```
build\app\outputs\bundle\release\app-release.aab
```

---

## 🔑 **Step-by-Step: Prepare for Play Store**

### **Step 1: Generate Keystore**
```powershell
keytool -genkey -v -keystore C:\Users\Robin\vas-fm-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vas-fm-key
```

**You'll be asked:**
1. Keystore password: `CreateStrongPassword123!`
2. Re-enter password: (same)
3. First & Last Name: `Media VAS`
4. Organizational Unit: `Technology`
5. Organization: `Media VAS`
6. City: `Accra`
7. State: `Greater Accra`
8. Country: `GH`
9. Confirm: `yes`
10. Key password: (Press ENTER to use same as keystore)

**⚠️ SAVE THIS FILE AND PASSWORD!**
- Location: `C:\Users\Robin\vas-fm-release-key.jks`
- You NEED this for ALL future app updates!

---

### **Step 2: Create key.properties File**

Create file: `flutter_app/android/key.properties`

**Content:**
```properties
storePassword=CreateStrongPassword123!
keyPassword=CreateStrongPassword123!
keyAlias=vas-fm-key
storeFile=C:\\Users\\Robin\\vas-fm-release-key.jks
```

**⚠️ Replace `CreateStrongPassword123!` with your actual password!**

---

### **Step 3: Update build.gradle**

Open: `flutter_app/android/app/build.gradle`

**Add before `android {` block:**
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

**Replace the `buildTypes` section:**
```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

**Add before `buildTypes`:**
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

---

### **Step 4: Build AAB for Play Store**

```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"
C:\src\flutter\bin\flutter.bat build appbundle --release --dart-define=API_URL=https://your-backend-url.com
```

**Output:** `build\app\outputs\bundle\release\app-release.aab`

---

## 🌐 **IMPORTANT: Update API URL**

### **Before Building for Production:**

Replace `https://your-backend-url.com` with your actual DigitalOcean URL:

**Example:**
```powershell
C:\src\flutter\bin\flutter.bat build appbundle --release --dart-define=API_URL=https://vas-fm-backend.ondigitalocean.app
```

### **Where to Find Your DigitalOcean URL:**
1. Go to: https://cloud.digitalocean.com/apps
2. Click on your app
3. Copy the URL (e.g., `https://your-app-name.ondigitalocean.app`)

---

## 📊 **Build Comparison:**

| Feature | APK | AAB |
|---------|-----|-----|
| **Purpose** | Testing | Play Store |
| **Size** | Larger (~15-20MB) | Smaller (optimized) |
| **Signing** | Debug (default) | Release (your keystore) |
| **Distribution** | Direct install | Play Store only |
| **Build Time** | Fast (~2-3 min) | Similar (~2-3 min) |

---

## ✅ **Pre-Build Checklist:**

### **For Testing (APK):**
- [ ] Update API_URL to your production backend
- [ ] Test all features work
- [ ] Test login, streaming, about page
- [ ] Verify app name is "VAS FM Online"
- [ ] Check branding colors are correct

### **For Play Store (AAB):**
- [ ] Generate keystore (saved & backed up)
- [ ] Create key.properties file
- [ ] Update build.gradle signing config
- [ ] Update API_URL to production backend
- [ ] Test APK on device first
- [ ] Version code is 1
- [ ] Version name is 1.0.0

---

## 🚀 **After Building:**

### **Test APK:**
```powershell
# Install on your device
adb install build\app\outputs\flutter-apk\app-release.apk
```

### **Upload AAB to Play Store:**
1. Go to: https://play.google.com/console
2. Create new app or select existing
3. Go to "Production" or "Internal Testing"
4. Click "Create new release"
5. Upload `app-release.aab`
6. Add release notes
7. Review and publish

---

## 🐛 **Troubleshooting:**

### **Build Fails:**
```powershell
# Clean and rebuild
C:\src\flutter\bin\flutter.bat clean
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat build appbundle --release
```

### **Keystore Not Found:**
- Check path in key.properties uses double backslashes: `C:\\Users\\Robin\\...`
- Verify file exists at the specified location

### **Wrong API URL:**
- Rebuild with correct URL using `--dart-define=API_URL=...`
- Don't hardcode URLs in source code

---

## 📝 **Version Management:**

### **Update Version (for future releases):**

Open: `flutter_app/pubspec.yaml`

```yaml
version: 1.0.1+2
#         ^    ^
#         |    └─ Build number (increment for each upload)
#         └─ Version number (user sees this)
```

Then rebuild!

---

## 🎯 **Quick Commands Reference:**

```powershell
# Navigate to flutter app
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"

# Build test APK
C:\src\flutter\bin\flutter.bat build apk --release

# Build signed AAB (after keystore setup)
C:\src\flutter\bin\flutter.bat build appbundle --release

# Clean build
C:\src\flutter\bin\flutter.bat clean

# Check for issues
C:\src\flutter\bin\flutter.bat doctor
```

---

## ⚡ **Current Build Status:**

**Building APK...** Please wait for the build to complete.

Once complete, you'll find the APK at:
```
C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

---

**Ready to test or upload to Play Store!** 🎉
