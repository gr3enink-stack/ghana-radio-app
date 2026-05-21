# JSONBin.io Setup Guide - Persistent Config Storage

## 🎯 What This Does

Your admin dashboard settings (Stream URL, Album Art, Station Name) will now **PERSIST FOREVER** - even after Vercel restarts!

---

## ⚡ Setup (5 Minutes)

### **Step 1: Create JSONBin Account**

1. Go to: **https://jsonbin.io**
2. Click **"Sign Up"**
3. Sign up with GitHub, Google, or Email
4. Verify your email

---

### **Step 2: Get Your API Key**

1. Login to JSONBin
2. Go to **Dashboard**
3. Find **"API Keys"** section
4. Copy your **Master Key** (starts with `$2a$10$`)
5. **Save it somewhere safe**

---

### **Step 3: Create Your Config Bin**

1. Click **"Create Bin"** button
2. Enter this JSON:

```json
{
  "stationName": "VAS FM Online",
  "streamUrl": "http://s23.myradiostream.com:21022/",
  "albumArtUrl": "",
  "description": "Your favorite internet radio station"
}
```

3. Click **"Create"**
4. **Copy the Bin ID** (looks like: `67a1b2c3d4e5f6g7h8i9j0k1`)

---

### **Step 4: Add to Vercel**

1. Go to **Vercel Dashboard**: https://vercel.com
2. Select your **vasfm-online** project
3. Click **"Settings"** tab
4. Click **"Environment Variables"** in left sidebar
5. Add these two variables:

   **Variable 1:**
   - Name: `JSONBIN_API_KEY`
   - Value: Your Master Key (starts with `$2a$10$`)
   - Environments: ✅ Production ✅ Preview ✅ Development
   - Click **"Save"**

   **Variable 2:**
   - Name: `JSONBIN_BIN_ID`
   - Value: Your Bin ID
   - Environments: ✅ Production ✅ Preview ✅ Development
   - Click **"Save"**

---

### **Step 5: Redeploy**

1. Go to your project's **"Deployments"** tab
2. Click **"..."** on the latest deployment
3. Click **"Redeploy"**
4. Wait for deployment to complete (~2 minutes)

---

## ✅ Verify It Works

1. **Open your admin dashboard**: https://vasfm-online.vercel.app
2. **Login** with your admin password
3. **Change the Stream URL** to something different
4. Click **"Save"**
5. **Refresh the page**
6. Your changes should still be there! ✅

---

## 🔍 How to Check Logs

1. Go to Vercel Dashboard
2. Select your project
3. Click **"Logs"** tab
4. Look for:
   - `✅ Config loaded from JSONBin` - Good!
   - `✅ Config saved to JSONBin` - Good!
   - `⚠️ JSONBin not configured` - Need to add env vars

---

## 🎉 That's It!

Your config is now **persistent**:
- ✅ Survives Vercel restarts
- ✅ Survives redeployments
- ✅ Free forever (100,000 API calls/month)
- ✅ Secure (only you have the API key)

---

## 🆘 Troubleshooting

### **"JSONBin not configured" message**
- Check that you added both environment variables to Vercel
- Verify the names are EXACTLY: `JSONBIN_API_KEY` and `JSONBIN_BIN_ID`
- Redeploy after adding variables

### **"Failed to load config from JSONBin"**
- Check your API key is correct
- Verify the Bin ID exists
- Check JSONBin dashboard for any errors

### **Settings not saving**
- Check Vercel logs for errors
- Verify your JSONBin bin is active
- Make sure API key has write permissions

---

## 💰 Cost

**FREE** - JSONBin gives you:
- 100,000 API calls/month (plenty for your app)
- Unlimited bins
- Secure storage
- No credit card required

---

## 🔐 Security

- ✅ Your API key is encrypted in Vercel
- ✅ Only your backend can access it
- ✅ Never committed to Git
- ✅ Master key gives full access - keep it secret!

---

**Need help? Check Vercel logs for error messages!**
