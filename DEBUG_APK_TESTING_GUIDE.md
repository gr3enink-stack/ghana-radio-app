# VAS FM Online v1.1.0 - Debug APK Testing Guide

## 📦 Build Information

- **Version**: 1.1.0+14
- **Build Type**: Debug (with performance metrics enabled)
- **Build Date**: June 5, 2026
- **APK Size**: ~148 MB
- **APK Location**: `build\app\outputs\flutter-apk\app-debug.apk`

---

## ✅ Fixes Included in This Build

### Issue #1: Startup White Screen ✅ FIXED
- **What Changed**: Launch background now uses brand purple (#6A229C) instead of white
- **Expected Result**: No white flash on app launch - seamless purple-to-splash transition
- **Files Modified**: 
  - `android/app/src/main/res/drawable/launch_background.xml`
  - `android/app/src/main/res/values/styles.xml`

### Issue #2: Playback Start Latency ✅ FIXED
- **What Changed**: 
  - Pre-buffering during splash screen (stream ready before user sees player)
  - Immediate visual feedback when Play button is pressed
  - Animated loading indicators with status messages
  - Performance optimizations in audio pipeline
- **Expected Result**: 
  - Play button shows spinner within 50ms of tap
  - "Starting playback..." message appears immediately
  - Audio starts in 1-2 seconds (was 3-5 seconds)
- **Files Modified**:
  - `lib/services/radio_audio_handler.dart`
  - `lib/providers/radio_provider.dart`
  - `lib/screens/now_playing_screen.dart`
  - `lib/screens/splash_screen.dart`

---

## 🧪 Testing Checklist

### Test 1: Startup White Screen Fix

**Steps:**
1. Kill the app completely (swipe away from recent apps)
2. Launch the app from home screen
3. Observe the startup sequence carefully

**Expected Behavior:**
- ✅ Purple screen appears immediately (no white flash)
- ✅ Smooth transition to splash screen with logo
- ✅ No visual glitches or flickering

**What to Report:**
- [ ] Pass: No white screen visible
- [ ] Fail: White screen still appears (note duration)
- Device: _______________
- Android Version: _______________

---

### Test 2: Playback Latency - Cold Start

**Steps:**
1. Kill the app completely
2. Launch the app
3. Wait for Now Playing screen to appear
4. Immediately press the Play button
5. Observe the visual feedback and measure time until audio starts

**Expected Behavior:**
- ✅ Play button icon changes to spinner within 50ms
- ✅ "Starting playback..." message appears below button
- ✅ Message may change to "Buffering..." briefly
- ✅ Audio starts within 1-2 seconds
- ✅ Smooth, professional experience

**Performance Metrics (Check Console):**
```
Look for these logs in Android Studio Logcat or adb logcat:
⏱️ [PERF] Play button pressed at: ...
⏱️ [PERF] Playback started at: ...
⏱️ [PERF] ⚡ Startup latency: XXXXms
⭐ [PERF] Rating: EXCELLENT/GOOD/ACCEPTABLE/SLOW
```

**What to Report:**
- [ ] Pass: Audio starts within 2 seconds with visual feedback
- [ ] Fail: Audio takes longer than 3 seconds
- Startup latency: _______ ms
- Visual feedback appeared: [ ] Yes [ ] No
- Device: _______________
- Network: [ ] WiFi [ ] 4G [ ] 3G

---

### Test 3: Playback Latency - Warm Start

**Steps:**
1. Open the app
2. Press Play and let audio start
3. Press Pause
4. Press Play again
5. Observe the response time

**Expected Behavior:**
- ✅ Immediate visual feedback on Play button
- ✅ Audio should start faster than cold start (<1 second ideal)
- ✅ Smooth experience

**What to Report:**
- [ ] Pass: Audio resumes quickly
- [ ] Fail: Slow response on resume
- Resume time: _______ ms
- Device: _______________

---

### Test 4: Network Variations

**Test on different network conditions:**

#### 4A: WiFi (Fast Connection)
- [ ] Audio starts within 1-2 seconds
- [ ] No buffering interruptions
- Startup time: _______ ms

#### 4B: Mobile Data (4G)
- [ ] Audio starts within 2-3 seconds
- [ ] Handles network switching gracefully
- Startup time: _______ ms

#### 4C: Weak Network (3G/Slow)
- [ ] Visual feedback still appears immediately
- [ ] Shows "Buffering..." message appropriately
- [ ] Eventually connects or shows clear error
- Startup time: _______ ms

---

### Test 5: Error Handling

**Steps:**
1. Turn on Airplane Mode
2. Press Play button
3. Observe the behavior

**Expected Behavior:**
- ✅ Spinner appears immediately
- ✅ Clear error message shown to user
- ✅ Error indicator appears in top status
- ✅ User can retry when connection is restored

**What to Report:**
- [ ] Pass: Error handled gracefully with feedback
- [ ] Fail: App crashes or hangs
- Error message shown: _______________
- Device: _______________

---

### Test 6: Background Playback

**Steps:**
1. Start playing audio
2. Press Home button (minimize app)
3. Verify audio continues playing
4. Check notification controls
5. Try pause/play from notification

**Expected Behavior:**
- ✅ Audio continues in background
- ✅ Notification shows with controls
- ✅ Notification controls work (pause/play)
- ✅ App state syncs correctly when reopened

**What to Report:**
- [ ] Pass: Background playback works perfectly
- [ ] Fail: Audio stops or controls don't work
- Device: _______________

---

### Test 7: Visual Feedback Quality

**Steps:**
1. Press Play button
2. Observe the animations and transitions
3. Note the timing and smoothness

**Expected Behavior:**
- ✅ Loading message fades in smoothly (200ms animation)
- ✅ Slide-up effect on status message
- ✅ Spinner rotates smoothly in play button
- ✅ Text changes are clear and readable

**What to Report:**
- [ ] Pass: Animations are smooth and professional
- [ ] Fail: Animations are choppy or missing
- Notes: _______________

---

## 📊 Performance Metrics Collection

### Method 1: Using Android Studio Logcat

1. Connect device via USB
2. Open Android Studio
3. Open Logcat tab
4. Filter by "PERF"
5. Test the app and collect metrics

**Filter:** `PERF`

**Look for:**
```
⏱️ [PERF] Play button pressed at: ...
⏱️ [PERF] Playback started at: ...
⏱️ [PERF] ⚡ Startup latency: XXXXms
⭐ [PERF] Rating: EXCELLENT/GOOD/ACCEPTABLE/SLOW
⏱️ [PERF] Pre-buffering completed in: XXXXms
```

---

### Method 2: Using ADB Command Line

```bash
# Connect device
adb devices

# Start logcat with PERF filter
adb logcat | grep PERF

# Or on Windows PowerShell:
adb logcat | Select-String "PERF"
```

---

### Method 3: In-App Performance Display (Debug Mode Only)

After playing audio at least once, look below the Play button for:
```
⚡ Last startup: 1234ms
```

This shows the last measured startup latency in real-time.

---

## 📝 Performance Rating Guide

Use this guide to evaluate the startup latency:

| Rating | Time | User Experience |
|--------|------|-----------------|
| ⚡ EXCELLENT | < 500ms | Instant, feels magical |
| ✅ GOOD | 500ms - 1s | Fast, responsive |
| 👍 ACCEPTABLE | 1s - 2s | Good, noticeable but fine |
| ⚠️ SLOW | 2s - 3s | Noticeable delay, needs improvement |
| 🐌 VERY SLOW | > 3s | Poor experience, user frustration |

**Target**: GOOD or better (< 2 seconds)

---

## 🐛 Known Issues to Watch For

### Issue A: Pre-buffering Fails
**Symptoms**: First Play takes longer than subsequent plays
**Expected**: Pre-buffer during splash should make first play fast
**Report if**: First play takes > 3 seconds

### Issue B: Visual Feedback Delayed
**Symptoms**: Spinner appears more than 200ms after tap
**Expected**: Immediate feedback (< 50ms)
**Report if**: Noticeable delay between tap and spinner

### Issue C: Loading State Stuck
**Symptoms**: "Starting playback..." message doesn't disappear
**Expected**: Message disappears when audio starts
**Report if**: Message stays for > 10 seconds

---

## 📱 Test Device Information

Please record device details for each test:

- **Device Model**: _______________ (e.g., Huawei Honor STK-LX1)
- **Android Version**: _______________ (e.g., Android 10)
- **RAM**: _______________ (e.g., 3GB)
- **Network Type**: [ ] WiFi [ ] 4G [ ] 3G
- **Test Date**: _______________
- **Tester Name**: _______________

---

## 🎯 Success Criteria

### Must Have (Blocking Issues):
- [ ] No white screen flash on startup
- [ ] Play button shows visual feedback within 200ms
- [ ] Audio starts within 3 seconds on WiFi
- [ ] No crashes or ANRs (App Not Responding)
- [ ] Error states handled gracefully

### Should Have (Important):
- [ ] Audio starts within 2 seconds on WiFi
- [ ] Smooth animations and transitions
- [ ] Background playback works
- [ ] Notification controls functional

### Nice to Have (Optional):
- [ ] Audio starts within 1 second (EXCELLENT rating)
- [ ] Pre-buffering always succeeds
- [ ] Perfect performance on slow networks

---

## 📤 How to Submit Test Results

### For Each Test:
1. ✅ Pass / ❌ Fail
2. Performance metrics (from logs)
3. Device information
4. Screenshots/videos if issues found
5. Detailed description of any problems

### Example Report:
```
Test 2: Playback Latency - Cold Start
Status: ✅ PASS
Startup Latency: 1456ms
Performance Rating: GOOD
Visual Feedback: Yes (appeared immediately)
Device: Huawei Honor STK-LX1
Android: 10
Network: WiFi
Notes: Smooth experience, spinner appeared instantly, audio started in 1.5s
```

---

## 🔧 Troubleshooting

### App Won't Install
```bash
# Uninstall old version first
adb uninstall com.arthiumlabs.radio

# Install debug APK
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Performance Logs Not Showing
```bash
# Make sure app is debug build
adb shell pm list packages | grep arthium

# Check logcat permissions
adb logcat -c  # Clear logcat
adb logcat | grep PERF
```

### App Crashes on Launch
```bash
# Check crash logs
adb logcat | Select-String "FATAL"

# Or in bash:
adb logcat | grep FATAL
```

---

## 📞 Support

If you encounter any issues during testing:
1. Capture the error logs
2. Take screenshots/videos
3. Note the exact steps to reproduce
4. Contact the development team with details

---

## 🎉 Testing Complete Checklist

- [ ] Test 1: Startup White Screen
- [ ] Test 2: Playback Latency (Cold Start)
- [ ] Test 3: Playback Latency (Warm Start)
- [ ] Test 4A: Network - WiFi
- [ ] Test 4B: Network - 4G
- [ ] Test 4C: Network - 3G/Slow
- [ ] Test 5: Error Handling
- [ ] Test 6: Background Playback
- [ ] Test 7: Visual Feedback Quality
- [ ] Performance metrics collected
- [ ] Test results documented
- [ ] Issues reported (if any)

---

**Build Date**: June 5, 2026  
**Test Period**: 14-day Google Play closed testing  
**Minimum Tests Required**: All tests on at least 1 device  
**Recommended**: Test on 3+ different devices/networks
