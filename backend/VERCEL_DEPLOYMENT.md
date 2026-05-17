# 🚀 Deploy VAS FM Backend to Vercel (FREE - No Card Required!)

## ✅ **Why Vercel is Better for This:**
- ✅ **100% FREE** - No credit card needed!
- ✅ **Automatic HTTPS** - SSL included
- ✅ **Fast global CDN** - Better performance
- ✅ **Easy deployment** - Just push to GitHub
- ✅ **Free custom domains**
- ✅ **Perfect for Node.js backends**

---

## 📋 **Step-by-Step Deployment:**

### **Step 1: Push Backend to GitHub** (Already Done!)
✅ Your backend is already at: `https://github.com/gr3enink-stack/ghana-radio-app`

### **Step 2: Create Vercel Account**
1. Go to: **https://vercel.com**
2. Click **"Sign Up"**
3. Choose **"Continue with GitHub"** (easiest)
4. Authorize Vercel to access your GitHub
5. ✅ **No credit card needed!**

### **Step 3: Import Your Project**
1. After logging in, click **"Add New Project"**
2. Find and select: **`gr3enink-stack/ghana-radio-app`**
3. Click **"Import"**

### **Step 4: Configure Project**

**Root Directory:** 
- Click "Edit" next to Root Directory
- Change to: **`backend`** (important!)

**Build Command:** 
- Leave blank (Vercel auto-detects)

**Output Directory:** 
- Leave blank

**Install Command:** 
- Leave blank (auto-detects `npm install`)

### **Step 5: Add Environment Variables**

Click **"Environment Variables"** and add:

| Variable | Value | Environment |
|----------|-------|-------------|
| `ADMIN_PASSWORD` | `YourStrongPassword123!` | Production, Preview, Development |
| `NODE_ENV` | `production` | Production, Preview, Development |

**⚠️ IMPORTANT:**
- Replace `YourStrongPassword123!` with a strong password
- Click "Add" for each variable
- These will be encrypted automatically

### **Step 6: Deploy!**
1. Click **"Deploy"**
2. Wait ~1-2 minutes
3. ✅ **Your app is live!**

---

## 🌐 **Your Vercel URLs:**

After deployment, you'll get:

**Main URL:**
```
https://ghana-radio-app.vercel.app
```
(or similar - Vercel will show you the exact URL)

**All Endpoints Work:**
```
✅ https://your-app.vercel.app/                    (Admin Dashboard)
✅ https://your-app.vercel.app/api/config           (Radio Config API)
✅ https://your-app.vercel.app/api/admin/login      (Admin Login)
✅ https://your-app.vercel.app/api/admin/update     (Update Config)
✅ https://your-app.vercel.app/api/listeners        (Listener Count)
✅ https://your-app.vercel.app/api/listener/heartbeat (Heartbeat)
✅ https://your-app.vercel.app/privacy              (Privacy Policy)
✅ https://your-app.vercel.app/terms                (Terms of Service)
```

---

## 🔄 **Alternative: Deploy via Vercel CLI**

If you prefer command line:

### **Install Vercel CLI:**
```powershell
npm install -g vercel
```

### **Login to Vercel:**
```powershell
vercel login
```
(Choose GitHub option)

### **Deploy from Backend Folder:**
```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\backend"
vercel
```

**First deployment prompts:**
- Set up and deploy? **Yes**
- Which scope? **Choose your account**
- Link to existing project? **No**
- Project name? **vas-fm-backend** (or any name)
- Directory? **./** (current)
- Add environment variables? **Yes**
  - `ADMIN_PASSWORD` = `YourStrongPassword123!`
  - `NODE_ENV` = `production`

### **Deploy to Production:**
```powershell
vercel --prod
```

---

## 📱 **Update Flutter App with Vercel URL**

After deployment, update these files:

### **1. splash_screen.dart**
```dart
// Line ~95, change:
defaultValue: 'http://172.20.10.3:3000',

// To:
defaultValue: 'https://your-app.vercel.app',
```

### **2. now_playing_screen.dart**
```dart
// Line ~180, change:
defaultValue: 'http://172.20.10.3:3000',

// To:
defaultValue: 'https://your-app.vercel.app',
```

### **3. radio_provider.dart**
```dart
// Line ~100, change:
defaultValue: 'http://172.20.10.3:3000',

// To:
defaultValue: 'https://your-app.vercel.app',
```

### **Then rebuild:**
```powershell
cd "C:\Users\Robin\Desktop\Arthium Labs LLC\Radio\flutter_app"
C:\src\flutter\bin\flutter.bat build apk --release --dart-define=API_URL=https://your-app.vercel.app
```

---

## 🎯 **Quick Comparison:**

| Feature | Vercel | DigitalOcean |
|---------|--------|--------------|
| **Cost** | ✅ FREE | $5/month |
| **Credit Card** | ✅ Not needed | Required |
| **Setup Time** | 2 minutes | 10 minutes |
| **HTTPS** | ✅ Automatic | ✅ Automatic |
| **Performance** | ✅ Global CDN | Single region |
| **Custom Domain** | ✅ Free | Free |
| **Auto Deploy** | ✅ Git push | Manual/CI |
| **Scalability** | ✅ Auto | Manual upgrade |

**Vercel is perfect for this project!** 🎉

---

## ✅ **After Deployment Checklist:**

- [ ] Test admin dashboard loads: `https://your-app.vercel.app/`
- [ ] Test login with your ADMIN_PASSWORD
- [ ] Test API endpoint: `https://your-app.vercel.app/api/config`
- [ ] Test privacy policy: `https://your-app.vercel.app/privacy`
- [ ] Test terms of service: `https://your-app.vercel.app/terms`
- [ ] Update Flutter app with Vercel URL
- [ ] Rebuild Flutter app with new URL
- [ ] Test app connects to backend

---

## 🔄 **Updating Your Backend:**

Every time you push to GitHub:
```powershell
git push origin main
```

Vercel will **automatically redeploy** in ~1 minute! ✨

---

## 🐛 **Troubleshooting:**

### **Build Fails:**
- Check that `vercel.json` is in the backend folder
- Verify `package.json` has correct scripts
- Check Vercel deployment logs

### **404 Errors:**
- Make sure Root Directory is set to `backend`
- Verify `vercel.json` routes are correct
- Check server.js exports properly

### **Can't Login to Admin:**
- Verify ADMIN_PASSWORD environment variable is set
- Check for typos in password
- Password is case-sensitive

---

## 🎊 **You're All Set!**

**Vercel is:**
- ✅ Free forever for this usage
- ✅ No credit card required
- ✅ Faster than DigitalOcean
- ✅ Automatic deployments
- ✅ Better performance

**Deploy now and you'll have your backend live in 2 minutes!** 🚀
