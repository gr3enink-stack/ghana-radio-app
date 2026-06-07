# VAS FM Online - Quick Test Reference Card

## 📦 APK Location
```
c:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app\build\app\outputs\flutter-apk\app-debug.apk
```

## ⚡ Quick Install
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

## 🔍 Quick Performance Check
```bash
# PowerShell
adb logcat | Select-String "PERF"

# Bash/Git Bash
adb logcat | grep PERF
```

## ✅ Two Critical Tests

### Test 1: No White Screen on Launch
1. Kill app completely
2. Launch app
3. **Expected**: Purple screen → Logo (NO white flash)

### Test 2: Fast Playback with Feedback
1. Press Play button
2. **Expected**: 
   - Spinner appears instantly (< 200ms)
   - "Starting playback..." message shows
   - Audio starts in 1-2 seconds

## 📊 Performance Targets

| Metric | Target | Acceptable |
|--------|--------|------------|
| Startup Latency | < 1s | < 2s |
| Visual Feedback | < 50ms | < 200ms |
| Pre-buffering | < 1.5s | < 2s |

## 🎯 What to Look For in Logs

```
⏱️ [PERF] Play button pressed at: ...    ← User tapped
⏱️ [PERF] Playback started at: ...       ← Audio playing
⏱️ [PERF] ⚡ Startup latency: 1234ms     ← Key metric!
⭐ [PERF] Rating: GOOD                   ← Performance grade
```

## 📱 Report Format
```
Test: _______________
Result: [✅ Pass / ❌ Fail]
Latency: _______ ms
Device: _______________
Network: [WiFi / 4G / 3G]
Notes: _______________
```

## 🐛 Common Issues

**White screen still appears?**
→ Check launch_background.xml uses @color/ic_launcher_background

**No visual feedback on Play?**
→ Check isUserInitiatedPlay flag is set

**Slow startup (>3s)?**
→ Check pre-buffering succeeded in splash screen

**No performance logs?**
→ Make sure it's debug build, not release

## 📞 Need Help?
See full guide: `DEBUG_APK_TESTING_GUIDE.md`
