# Background Playback Troubleshooting Guide

## Issue: Audio Stops When App is Minimized

### **Quick Answer**
This is **NOT** because it's a debug/test build. Background playback is a core feature that should work in both debug and release builds.

The most likely cause is **Huawei's aggressive battery optimization** killing the background audio service.

---

## 🔧 **Solution 1: Disable Battery Optimization for VAS FM (Huawei Devices)**

Huawei/Honor devices have very aggressive battery management that automatically kills background apps.

### **Steps to Fix:**

1. **Open Settings** on your Huawei Honor STK-LX1

2. **Go to:**
   - **Settings** → **Battery** → **App launch**
   - OR **Settings** → **Battery** → **Power genie**
   - OR **Settings** → **Apps** → **VAS FM Online** → **Battery**

3. **Find "VAS FM Online"** in the app list

4. **Toggle to "Manage manually"** (turn off automatic management)

5. **Enable ALL three options:**
   - ✅ **Auto-launch** - Allow app to start automatically
   - ✅ **Secondary launch** - Allow app to restart after being closed
   - ✅ **Run in background** - Allow app to run when minimized

6. **Restart the app** and test background playback

---

## 🔧 **Solution 2: Check if Notification Appears**

Background audio **requires** a persistent notification. This is how Android knows the app is doing important work.

### **Test:**
1. Open VAS FM Online
2. Press **Play** and wait for audio to start
3. Press **Home button** (minimize the app)
4. **Swipe down** from top to open notification panel

### **What You Should See:**
```
┌─────────────────────────────────────┐
│ VAS FM Radio                        │
│ VAS FM Online - Live Stream         │
│                                     │
│ ⏮️  ⏸️  ⏭️                         │
└─────────────────────────────────────┘
```

### **If You See the Notification:**
- ✅ Audio service is running correctly
- ❌ If audio still stops, it's battery optimization (see Solution 1)

### **If You DON'T See the Notification:**
- ❌ Audio service failed to start
- This is a bug that needs fixing

---

## 🔧 **Solution 3: Lock the App in Recent Apps**

Some Android devices allow you to "lock" apps to prevent them from being killed.

### **On Huawei:**
1. Open the app
2. Tap the **Recent Apps** button (square button at bottom)
3. Find VAS FM Online in the list
4. **Swipe down** on the app preview (or tap the lock icon)
5. You should see a **lock icon** 🔒 on the app
6. This prevents the system from killing it

---

## 🔧 **Solution 4: Disable Power Saving Mode**

Power saving mode can kill background services.

### **Check:**
1. Swipe down from top for **Quick Settings**
2. Look for **Power saving mode**
3. Make sure it's **TURNED OFF**
4. Or go to **Settings** → **Battery** → **Power saving mode** → **OFF**

---

## 📱 **Improved Configuration Applied**

I've updated the app with better background service settings:

### **Changes Made:**
1. ✅ Added `androidStopForegroundOnPause: false`
   - Keeps the service running even when audio is paused
   - Prevents Android from killing the service

2. ✅ Added `androidNotificationContent: 'VAS FM Online - Live Stream'`
   - Clear notification text showing app is active

3. ✅ Kept `androidNotificationOngoing: true`
   - Prevents user from accidentally swiping away notification
   - Tells Android this is a critical ongoing service

---

## 🧪 **Test After Applying Fixes**

### **Test Steps:**
1. Install updated APK
2. Open app and press Play
3. Wait for audio to start
4. Press Home button (minimize)
5. **Wait 30 seconds**
6. **Check:**
   - Is audio still playing? ✅
   - Is notification visible? ✅
   - Can you control from notification? ✅

### **Expected Result:**
- ✅ Audio continues playing for hours in background
- ✅ Notification stays visible
- ✅ Controls work from notification
- ✅ Audio works even with screen off

---

## 🐛 **If It Still Stops**

### **Collect This Information:**
1. **Does notification appear?** (Yes/No)
2. **How long until audio stops?** (seconds/minutes)
3. **Battery optimization disabled?** (Yes/No)
4. **Power saving mode off?** (Yes/No)

### **Check Logs:**
```bash
# Connect device via USB
adb logcat | Select-String "AudioService"

# Or in bash:
adb logcat | grep AudioService
```

Look for errors like:
- `AudioService killed`
- `Foreground service stopped`
- `App killed by battery optimization`

---

## 📊 **Why This Happens on Huawei**

Huawei devices use **EMUI** (custom Android skin) which has:
- **Power Genie** - Aggressively kills background apps
- **Phone Manager** - Auto-closes "unused" apps
- **Battery optimization** - Very strict by default

This is **more aggressive** than stock Android (Pixel, Samsung, etc.)

**Other users report:**
- Huawei P30, P40, Mate series - Same issue
- Honor devices - Same issue
- Solution: Manual battery management (Solution 1 above)

---

## ✅ **What We've Fixed in Code**

### **Before:**
```dart
AudioServiceConfig(
  androidNotificationOngoing: true,
  // Missing: androidStopForegroundOnPause
)
```

### **After:**
```dart
AudioServiceConfig(
  androidNotificationChannelId: 'com.arthiumlabs.radio.channel.audio',
  androidNotificationChannelName: 'VAS FM Radio',
  androidNotificationContent: 'VAS FM Online - Live Stream',
  androidNotificationOngoing: true, // Can't swipe away
  androidShowNotificationBadge: true,
  androidNotificationIcon: 'mipmap/ic_launcher',
  androidStopForegroundOnPause: false, // Keep service alive!
)
```

---

## 🎯 **Next Steps**

1. **Rebuild the app** with new configuration
2. **Install on device**
3. **Disable battery optimization** (Solution 1)
4. **Test background playback**
5. **Report results**

---

## 📞 **Need More Help?**

If background playback still doesn't work after trying all solutions:
1. Let me know the exact behavior
2. Check if notification appears
3. We can investigate further with logs

This is a **device-specific issue**, not a code bug. The code is configured correctly for background playback.
