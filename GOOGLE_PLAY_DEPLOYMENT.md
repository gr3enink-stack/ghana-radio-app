# Google Play Store Deployment Guide for VAS FM

## 📋 Prerequisites

- ✅ Google Play Developer Account ($25 one-time fee)
- ✅ App signed with release key
- ✅ App Bundle (AAB) file
- ✅ App screenshots and graphics
- ✅ Privacy Policy

---

## Step 1: Get Google Play Developer Account

1. Visit: https://play.google.com/console/register
2. Sign in with Google account
3. Pay $25 registration fee
4. Complete developer profile
5. Verify identity (may take 1-2 days)

---

## Step 2: Generate Signing Key (First Time Only)

```powershell
# Navigate to your Flutter app
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"

# Generate a keystore (Windows)
keytool -genkey -v -keystore C:\Users\Robin\vas-fm-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vas-fm-key

# You'll be prompted for:
# - Keystore password (remember this!)
# - Your name
# - Organizational unit: Media VAS
# - Organization: Media VAS
# - City, State, Country
# - Key password (can be same as keystore)
```

**⚠️ IMPORTANT: Back up this keystore file! If you lose it, you can't update your app!**

---

## Step 3: Configure Android for Release

### Create key.properties file:

Create `flutter_app/android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=vas-fm-key
storeFile=C:/Users/Robin/vas-fm-release-key.jks
```

### Update build.gradle:

Open `flutter_app/android/app/build.gradle` and add BEFORE `android {`:

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
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

---

## Step 4: Update App Info for Release

### Update pubspec.yaml:

```yaml
name: vas_fm_online
description: VAS FM Online - Verify Authenticity Specific - Media VAS
version: 1.0.0+1  # version+build_number
```

### Update AndroidManifest.xml:

Ensure in `flutter_app/android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="VAS FM Online"
    android:icon="@mipmap/ic_launcher"
    android:usesCleartextTraffic="false">  <!-- Set to false for production -->
```

---

## Step 5: Build Release App Bundle

```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release AAB (Android App Bundle)
flutter build appbundle --release --dart-define=API_URL=https://your-backend-url.com

# Output: build/app/outputs/bundle/release/app-release.aab
```

**Note:** Replace `https://your-backend-url.com` with your actual DigitalOcean URL once deployed.

---

## Step 6: Test Release Build

```powershell
# Install the app bundle on device for testing
# First, convert AAB to APK for testing (requires bundletool)
java -jar bundletool.jar build-apks --bundle=build/app/outputs/bundle/release/app-release.aab --output=app.apks --ks=C:\Users\Robin\vas-fm-release-key.jks --ks-pass=pass:YOUR_PASSWORD

# Or test on Play Store's internal testing track first
```

---

## Step 7: Create App in Google Play Console

1. Go to: https://play.google.com/console
2. Click **"Create App"**
3. Fill in:
   - **App name**: VAS FM Online
   - **Default language**: English (US)
   - **App or game**: App
   - **Free or paid**: Free
4. Accept the declarations
5. Click **"Create app"**

---

## Step 8: Complete Store Listing

### **Main Store Listing:**

1. Go to **Store presence** → **Main store listing**

2. **App name**: VAS FM Online
3. **Short description**: "Your trusted internet radio station - Verify, Authentic, Specific"
4. **Full description**:

```
VAS FM Online - Where Quality Meets Authenticity

Experience premium internet radio with Media VAS. We deliver verified, authentic, and specific content tailored for you.

🎯 OUR MISSION:
V - Verify: All content is verified and reliable
A - Authenticity: Genuine, quality programming
S - Specific: Targeted content for our audience

✨ FEATURES:
• 24/7 Internet Radio Streaming
• High-Quality Audio
• Background Playback
• Beautiful Modern Interface
• Accessible Anywhere, Anytime

📻 ABOUT MEDIA VAS:
Media VAS is dedicated to delivering high-quality audio content to listeners around the clock.

Developed by Arthium Labs
Version: 1.0.0
```

5. **Category**: Music & Audio → Radio

---

## Step 9: Upload Graphics

### **App Icon:**
- Upload 512x512 PNG icon

### **Feature Graphic:**
- Create 1024x500 image with VAS FM branding
- Use gradient purple theme (#6C63FF)

### **Screenshots:**
Upload minimum 2 screenshots showing:
1. Now Playing screen
2. About screen

---

## Step 10: Privacy Policy

Create a simple privacy policy (can use Google Sites or GitHub Pages):

```
Privacy Policy for VAS FM Online

Last updated: [Date]

Media VAS operates the VAS FM Online app. This page informs you of our policies regarding the collection, use, and disclosure of personal information.

Information Collection:
- We do not collect personal information
- We only track active listening sessions for analytics
- Device ID is generated locally and not linked to personal identity

Data Usage:
- Listener analytics to improve service
- No data is sold or shared with third parties

Contact:
For questions about this policy, contact: [your-email@domain.com]
```

Add the URL in **Store presence** → **Privacy policy**

---

## Step 11: Content Rating

1. Go to **App content** → **Content rating**
2. Complete the questionnaire:
   - No violence, profanity, sexual content
   - Should get "Everyone" rating

---

## Step 12: App Access

1. Go to **App content** → **App access**
2. Select: **All functionality is available**
3. No login required for users

---

## Step 13: Ads Declaration

1. Go to **App content** → **Ads**
2. Select: **No, my app doesn't contain ads**

---

## Step 14: Target Audience

1. Go to **App content** → **Target audience and content**
2. Select age groups:
   - ✅ 18 and older
   - ✅ 13-17
   - ✅ Under 13 (if appropriate)
3. Select content rating

---

## Step 15: Upload App Bundle

1. Go to **Production** → **Create new release**
2. Upload `app-release.aab` from `build/app/outputs/bundle/release/`
3. Add release notes:

```
Version 1.0.0 - Initial Release

✨ Features:
• 24/7 internet radio streaming
• Beautiful modern UI
• Background audio playback
• Real-time stream configuration
• About page with station info

🎵 Powered by Media VAS
🔧 Developed by Arthium Labs
```

4. Review and save

---

## Step 16: Review and Submit

1. Go to **Publishing overview**
2. Check all sections are complete:
   - ✅ Store listing
   - ✅ Content rating
   - ✅ Privacy policy
   - ✅ App bundle uploaded
   - ✅ App access
   - ✅ Ads declaration
3. Click **"Review release"**
4. Fix any warnings
5. Click **"Start rollout to Production"**

---

## Step 17: Wait for Review

- Google review takes **1-7 days** (first app usually takes longer)
- You'll receive email when approved
- App will appear on Play Store after approval

---

## 📊 After Publishing

### **Monitor Your App:**

1. **Play Console Dashboard**:
   - Downloads
   - Active installs
   - Crashes & ANRs
   - Ratings & reviews

2. **Update App**:
   ```powershell
   # Increment version in pubspec.yaml
   version: 1.0.1+2
   
   # Rebuild
   flutter build appbundle --release
   
   # Upload new release in Play Console
   ```

---

## 🎯 Pro Tips

### **App Store Optimization (ASO):**
- Use keywords: "radio", "streaming", "music", "FM"
- Add relevant tags
- Respond to reviews
- Update regularly

### **Testing Before Release:**
- Test on multiple devices
- Test with slow internet
- Test background playback
- Test app restart

### **Keep Your Keystore Safe:**
- Backup to cloud storage
- Keep password secure
- Never commit to Git
- You NEED it for all future updates!

---

## 🐛 Troubleshooting

### **Build fails:**
```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

### **Signing issues:**
- Verify key.properties path
- Check passwords are correct
- Ensure keystore file exists

### **Play Console rejects:**
- Read rejection email carefully
- Fix the specific issues
- Resubmit

---

## ✅ Pre-Flight Checklist

Before submitting:

- [ ] App builds without errors
- [ ] Tested on physical device
- [ ] Background audio works
- [ ] All screens functional
- [ ] App icon looks good
- [ ] Screenshots ready
- [ ] Privacy policy created
- [ ] Description written
- [ ] Version number set
- [ ] Keystore backed up
- [ ] $25 fee paid

---

**Good luck with your VAS FM app submission! 🚀**
