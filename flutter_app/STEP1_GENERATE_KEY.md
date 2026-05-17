# 🔑 Step 1: Generate Signing Key (Keystore)

Run this command in PowerShell:

```powershell
keytool -genkey -v -keystore C:\Users\Robin\vas-fm-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias vas-fm-key
```

**You will be prompted to enter:**
1. **Keystore password:** (Create a strong password, e.g., `V@SFm2026!Key`)
2. **Re-enter password:** (Same as above)
3. **First and Last Name:** `Media VAS`
4. **Organizational Unit:** `Technology`
5. **Organization:** `Media VAS`
6. **City:** `Accra`
7. **State:** `Greater Accra`
8. **Country Code:** `GH`
9. **Confirm:** Type `yes`
10. **Key password:** (Press ENTER to use same as keystore password)

**⚠️ IMPORTANT:**
- Save the keystore file: `C:\Users\Robin\vas-fm-release-key.jks`
- Save the password securely - YOU WILL NEED IT FOR ALL FUTURE UPDATES!
- Back up this file - if you lose it, you CANNOT update your app on Play Store!
