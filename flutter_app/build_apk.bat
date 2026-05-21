@echo off
echo ========================================
echo  VAS FM Radio App - Build Script
echo ========================================
echo.

echo Step 1: Getting dependencies...
C:\src\flutter\bin\flutter.bat pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies!
    pause
    exit /b 1
)
echo.

echo Step 2: Building Debug APK...
C:\src\flutter\bin\flutter.bat build apk --debug
if %errorlevel% neq 0 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)
echo.

echo ========================================
echo  BUILD SUCCESSFUL!
echo ========================================
echo.
echo APK Location:
echo build\app\outputs\flutter-apk\app-debug.apk
echo.
echo Next Steps:
echo 1. Connect your Android phone via USB
echo 2. Enable USB Debugging on phone
echo 3. Run: adb install build\app\outputs\flutter-apk\app-debug.apk
echo.
echo OR
echo.
echo Copy the APK to your phone and install manually!
echo.
pause
