@echo off
echo ========================================
echo  Build Progress Monitor
echo ========================================
echo.

:loop
cls
echo ========================================
echo  Build Progress Monitor
echo ========================================
echo Updated: %time%
echo.

echo Java Processes:
tasklist | findstr "java.exe"
if %errorlevel% neq 0 (
    echo No Java processes found - build may have completed or failed!
    echo.
    pause
    exit /b
)
echo.

echo Build Directory:
if exist "build\app\outputs\flutter-apk" (
    dir "build\app\outputs\flutter-apk" /s
    echo.
    echo APK FOUND! Build successful!
    pause
    exit /b
) else (
    echo APK not created yet...
)
echo.

echo Build Folders:
dir "build" /s /b | find /c "\"
echo.

echo Waiting 10 seconds before next check...
echo (Press Ctrl+C to stop monitoring)
timeout /t 10 /nobreak >nul
goto loop
