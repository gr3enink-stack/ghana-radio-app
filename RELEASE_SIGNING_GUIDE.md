# 🔐 How to Fix "Signed in Debug Mode" Error

## ✅ RECOMMENDED: Use Google Play App Signing (Easiest)

### **No setup required! Just follow these steps:**

1. **Go to Google Play Console**
   - Visit: https://play.google.com/console
   - Select your VAS FM Radio app

2. **Enable Google Play App Signing**
   - Click **Setup** in the left menu
   - Click **App integrity**
   - Click **Continue** on "Google Play App Signing"
   - Accept the terms

3. **Upload Your AAB**
   - Go to **Production** or **Internal testing**
   - Click **Create new release**
   - Upload: `app-release.aab`
   - Google will sign it automatically!

4. **Done!** ✅
   - No keystore needed
   - No password management
   - More secure than manual signing

---

## 🔧 ALTERNATIVE: Manual Signing (Advanced)

If you prefer to sign the app yourself:

### **Step 1: Find Your Java Installation**

```powershell
# Find Java path (usually one of these):
C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe
C:\Program Files\Java\jdk-17\bin\keytool.exe
```

### **Step 2: Create a Release Keystore**

Open PowerShell and run (replace path with your actual Java path):

```powershell
cd "c:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\android\app"

# Use full path to keytool
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore vasfm-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vasfm-key
```

**You'll be prompted for:**
- **Keystore password:** (create a strong password, SAVE IT!)
- **First and last name:** Your Name
- **Organizational unit:** (optional)
- **Organization:** Arthium Labs LLC
- **City:** Your City
- **State:** Your State
- **Country code:** e.g., US

### **Step 3: Create key.properties File**

Create `c:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\android\key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=vasfm-key
storeFile=../app/vasfm-release-key.jks
```

⚠️ **IMPORTANT:** Add this file to `.gitignore` - never commit passwords!

### **Step 4: Update build.gradle**

Edit `flutter_app/android/app/build.gradle`:

Replace:
```gradle
android {
    
    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
```

With:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### **Step 5: Rebuild AAB**

```powershell
cd "c:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"
flutter build appbundle --release --dart-define=API_URL=https://vasfm-online.vercel.app
```

### **Step 6: Upload to Google Play**

Upload the newly signed AAB to Google Play Console.

---

## ⚠️ IMPORTANT: Backup Your Keystore!

If you choose manual signing:

1. **Backup your keystore file:** `vasfm-release-key.jks`
2. **Backup your passwords:** Store in a password manager
3. **Never lose it!** You need the SAME keystore for all future updates
4. **If lost:** You cannot update your app on Google Play!

---

## 🎯 RECOMMENDATION

**Use Google Play App Signing** because:
- ✅ Easier (no setup)
- ✅ More secure (Google manages keys)
- ✅ Automatic key recovery
- ✅ App signing key rotation support
- ✅ Required for Android App Bundles anyway

**Only use manual signing if:**
- You need to distribute outside Google Play
- You have specific security requirements
- You want full control over signing keys

---

## 📝 Quick Summary

### **Google Play App Signing (Recommended):**
1. Enable in Play Console → Setup → App integrity
2. Upload AAB as-is
3. Google signs it for you ✅

### **Manual Signing (Advanced):**
1. Create keystore with keytool
2. Configure key.properties
3. Update build.gradle
4. Rebuild AAB
5. Upload to Play Console

---

**We recommend Google Play App Signing for your VAS FM Radio app!** 🚀
