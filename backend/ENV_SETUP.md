# 🔐 DigitalOcean Environment Variables - Quick Reference

## **Required Variables:**

```env
NODE_ENV=production
PORT=3000
ADMIN_PASSWORD=YourSecurePassword123!
```

---

## **📋 Copy-Paste for DigitalOcean:**

### **Variable 1:**
- **Key:** `NODE_ENV`
- **Value:** `production`
- **Scope:** Run Time
- **Encrypt:** ❌ No

### **Variable 2:**
- **Key:** `PORT`
- **Value:** `3000`
- **Scope:** Run Time
- **Encrypt:** ❌ No

### **Variable 3:**
- **Key:** `ADMIN_PASSWORD`
- **Value:** `YourSecurePassword123!` (CHANGE THIS!)
- **Scope:** Run Time
- **Encrypt:** ✅ YES (Important!)

---

## **🔒 Password Recommendations:**

**Strong Password Examples:**
```
V@SFm2026!R@d1o#Secure
M3d1@V@S!R@d1o2026#Secure
Arth1umL@bs!V@SFm2026
```

**Requirements:**
- ✅ Minimum 12 characters
- ✅ Mix of uppercase & lowercase
- ✅ Include numbers
- ✅ Include special characters (!@#$%^&*)
- ✅ No spaces

---

## **🚀 Quick Deploy Steps:**

1. **Go to:** https://cloud.digitalocean.com/apps
2. **Click:** "Create App"
3. **Connect:** GitHub → `gr3enink-stack/ghana-radio-app`
4. **Branch:** `main`
5. **Source Directory:** `backend` ⚠️ (Important!)
6. **Add Environment Variables:** (Use the 3 variables above)
7. **Deploy:** Click "Create Resources"
8. **Wait:** ~2-3 minutes
9. **Access:** `https://your-app-name.ondigitalocean.app`

---

## **✅ After Deployment:**

**Test Your Backend:**
```
https://your-app-name.ondigitalocean.app/api/config
```

**Login to Admin:**
```
https://your-app-name.ondigitalocean.app
Password: [Your ADMIN_PASSWORD]
```

**Privacy Policy:**
```
https://your-app-name.ondigitalocean.app/privacy
```

**Terms of Service:**
```
https://your-app-name.ondigitalocean.app/terms
```

---

## **⚠️ Important Notes:**

- ✅ Always encrypt `ADMIN_PASSWORD` in DigitalOcean
- ✅ Source Directory MUST be `backend`
- ✅ PORT must be `3000` (DigitalOcean may override this)
- ✅ NODE_ENV should be `production`
- ✅ Don't share your admin password
- ✅ Use HTTPS (automatic on DigitalOcean)

---

**That's it! Just 3 environment variables needed!** 🎉
