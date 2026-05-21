# 📦 Google Play Store Upload Guide for VAS FM Radio App

## ✅ AAB Build Complete!

**File Location:** `flutter_app\build\app\outputs\bundle\release\app-release.aab`
**Size:** 41.5 MB
**Version:** 1.0.0 (versionCode: 1)

---

## 🚀 Upload to Google Play Console

### **Step 1: Go to Google Play Console**
1. Visit: **https://play.google.com/console**
2. Sign in with your Google Developer account
3. Select your app: **VAS FM Radio** (or create new app)

### **Step 2: Create App (If New)**
1. Click **"Create app"**
2. Fill in:
   - **App name:** VAS FM Radio
   - **Default language:** English (US)
   - **App or game:** App
   - **Free or paid:** Free
3. Accept the declarations
4. Click **"Create app"**

### **Step 3: Set Up App Signing (RECOMMENDED)**
1. Go to **Setup** → **App integrity**
2. Choose **"Google Play App Signing"** (recommended)
3. Google will manage your signing key automatically
4. **No extra setup needed!** Just upload your AAB

### **Step 4: Upload Your AAB**
1. Go to **Production** or **Internal testing**
2. Click **"Create new release"**
3. Upload your AAB:
   ```
   c:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\build\app\outputs\bundle\release\app-release.aab
   ```
4. Add release notes:
   ```
   Version 1.0.0 - Initial Release
   
   Features:
   - Live radio streaming
   - Real-time listener tracking
   - Album art display
   - Dark/Light theme
   - Admin dashboard for configuration
   ```
5. Click **"Next"** and review
6. Click **"Save"** then **"Review release"**
7. Click **"Start rollout to Production"**

---

## 📋 Required Store Listing Items

Before you can publish, you need:

### **✅ Already Complete:**
- [x] AAB file built
- [x] App icon implemented (VAS FM logo)
- [x] Privacy policy URL: `https://vasfm-online.vercel.app/privacy`
- [x] Terms of service URL: `https://vasfm-online.vercel.app/terms`

### **📝 Still Needed:**
- [ ] **Short description** (80 characters max)
- [ ] **Full description** (4000 characters max)
- [ ] **Screenshots** (Phone: 2-8 required)
- [ ] **Feature graphic** (1024 x 500 pixels)
- [ ] **App category** (Music & Audio)
- [ ] **Contact email**
- [ ] **Content rating questionnaire**

---

## 📝 Store Listing Text Templates

### **Short Description (80 chars):**
```
Your favorite internet radio station - Stream live music 24/7
```

### **Full Description:**
```
🎵 VAS FM Radio - Your Favorite Internet Radio Station

Stream live music, news, and entertainment 24/7 with VAS FM Radio!

✨ FEATURES:
• Live radio streaming in high quality
• Beautiful album art display
• Dark & Light theme support
• Background playback - listen while using other apps
• Real-time listener tracking
• Easy-to-use interface
• Free to use, no subscription required

📻 ABOUT VAS FM:
VAS FM is your go-to internet radio station, bringing you the best music and entertainment around the clock. Whether you're at work, home, or on the go, VAS FM keeps you connected with great content.

🎧 HOW TO USE:
1. Open the app
2. Tap the play button
3. Enjoy your favorite radio station!

📱 ADMIN DASHBOARD:
Station administrators can easily manage:
- Stream URL configuration
- Station name and description
- Album art updates
- Real-time listener statistics

🔒 PRIVACY:
We respect your privacy. VAS FM Radio does not collect personal data. View our privacy policy for more details.

📧 SUPPORT:
Have questions or feedback? Contact us at: [YOUR EMAIL]

🌐 WEBSITE:
https://vasfm-online.vercel.app

---
Developed by Arthium Labs LLC
© 2026 VAS FM Radio. All rights reserved.
```

---

## 📸 Screenshots Guide

See: `GOOGLE_PLAY_SCREENSHOT_GUIDE.md` for detailed instructions.

### **Quick Capture:**
```bash
# Run app on emulator
flutter run -d emulator-5554

# Use emulator camera icon to capture screenshots
# Saved to: C:\Users\Robin\Pictures\Screenshots\
```

### **Required Screenshots:**
- **Phone:** 2-8 screenshots (1080 x 1920 minimum)
- **7" Tablet:** 2-8 screenshots (optional)
- **10" Tablet:** 2-8 screenshots (optional)

---

## 🎨 Feature Graphic

**Size:** 1024 x 500 pixels  
**Format:** PNG or JPEG

### **Quick Design in Canva:**
1. Go to: https://www.canva.com
2. Create: 1024 x 500 pixels
3. Add:
   - VAS FM Logo
   - Tagline: "Your Favorite Internet Radio"
   - Brand colors: Purple (#6A229C), Gold (#FFB300)
4. Export as PNG

---

## 🏷️ App Category & Contact

- **Category:** Music & Audio
- **App Type:** Free
- **Contact Email:** [YOUR EMAIL]
- **Website:** https://vasfm-online.vercel.app
- **Privacy Policy:** https://vasfm-online.vercel.app/privacy

---

## 📊 Content Rating

You'll need to complete the IARC questionnaire:
- [ ] Does the app contain violence? **No**
- [ ] Does the app contain offensive language? **No**
- [ ] Does the app have unrestricted web access? **Yes** (for streaming)
- [ ] Does the app share user data? **No**
- [ ] Is the app suitable for all ages? **Yes**

Expected rating: **Everyone (E)**

---

## 🔍 Before Publishing Checklist

- [ ] AAB file uploaded
- [ ] App icon displays correctly
- [ ] Screenshots uploaded (minimum 2 for phone)
- [ ] Feature graphic uploaded (1024 x 500)
- [ ] Short description added (80 chars)
- [ ] Full description added
- [ ] Privacy policy URL set
- [ ] Contact email provided
- [ ] Content rating completed
- [ ] App signing set up (Google Play App Signing)
- [ ] Target audience selected (Everyone)
- [ ] News apps declaration (No)
- [ ] COVID-19 contact tracing declaration (No)

---

## 🚀 Publishing Options

### **Option 1: Internal Testing (Recommended First)**
- Test with up to 100 testers
- Quick approval (few hours)
- Get feedback before public release

### **Option 2: Production (Public Release)**
- Available to everyone on Google Play
- Review time: 1-7 days (usually 1-2 days)
- Cannot downgrade versionCode

### **Option 3: Closed Testing**
- Specific group of testers
- Good for beta testing

---

## 💡 Pro Tips

### **Version Management:**
- Current: `versionCode: 1`, `versionName: 1.0.0`
- Next update: `versionCode: 2`, `versionName: 1.0.1`
- Always increment versionCode for each release

### **Release Notes Best Practices:**
- Be specific about new features
- Mention bug fixes
- Keep it user-friendly
- Use emojis for visual appeal (optional)

### **After Publishing:**
- Monitor crash reports in Play Console
- Respond to user reviews
- Update screenshots as app improves
- Keep descriptions current

---

## 🐛 Troubleshooting

### **AAB Upload Fails:**
- Check file size (max 150 MB)
- Ensure versionCode is unique
- Verify package name matches: `com.arthiumlabs.radio`

### **App Rejected:**
- Review rejection reasons carefully
- Update privacy policy if needed
- Ensure all required fields completed
- Check content rating accuracy

### **Need to Update:**
1. Make changes in Flutter
2. Update versionCode in `pubspec.yaml`
3. Rebuild: `flutter build appbundle --release`
4. Upload new AAB to Play Console

---

## 📞 Need Help?

### **Google Play Console Support:**
- Help center: https://support.google.com/googleplay/android-developer
- Developer guidelines: https://play.google.com/about/developer-content-policy/

### **Flutter Documentation:**
- Deploy to Play Store: https://docs.flutter.dev/deployment/android
- App bundles: https://developer.android.com/guide/app-bundle

---

## ✨ You're Almost There!

**What's Done:**
✅ AAB built successfully  
✅ App icon implemented  
✅ Privacy policy & terms ready  
✅ Backend deployed  
✅ Admin dashboard working  

**What's Left:**
📝 Capture 2-8 screenshots  
🎨 Design feature graphic (1024 x 500)  
📝 Write descriptions  
📤 Upload to Google Play Console  
⏳ Wait for review (1-7 days)  
🎉 **APP PUBLISHED!**

---

**Good luck with your Google Play submission! 🚀**

**Your AAB is ready at:**
```
c:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\build\app\outputs\bundle\release\app-release.aab
```
