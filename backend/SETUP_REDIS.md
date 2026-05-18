#  Setup Upstash Redis for Vercel Backend

## ⚠️ IMPORTANT: Vercel KV is Deprecated

Vercel has deprecated their KV storage. We now use **Upstash Redis** (free tier available) for persistent config storage.

---

##  Step-by-Step Setup:

### **Step 1: Create Upstash Redis Database**

1. Go to: **https://console.upstash.com**
2. Click **"Sign Up"** (use GitHub for easiest setup)
3. After login, click **"Create Database"**
4. Choose:
   - **Name:** `vas-fm-config` (or any name)
   - **Region:** Choose closest to your users (e.g., `US East`)
   - **Plan:** **Free** (10,000 commands/day - enough for this app)
5. Click **"Create"**

### **Step 2: Get Redis Credentials**

After creating the database:

1. Click on your database name
2. Scroll down to **"REST API"** section
3. You'll see two values:
   - **REST URL:** `https://your-db-name.upstash.io`
   - **REST Token:** `your-long-token-string`

4. **Copy both values** - you'll need them for Vercel

### **Step 3: Add Environment Variables to Vercel**

1. Go to your Vercel dashboard: **https://vercel.com/dashboard**
2. Click on your project (e.g., `ghana-radio-app`)
3. Go to **"Settings"** → **"Environment Variables"**
4. Add these two variables:

| Variable Name | Value | Environment |
|--------------|-------|-------------|
| `UPSTASH_REDIS_REST_URL` | `https://your-db-name.upstash.io` | Production, Preview, Development |
| `UPSTASH_REDIS_REST_TOKEN` | `your-long-token-string` | Production, Preview, Development |

5. Click **"Save"** for each

### **Step 4: Redeploy**

After adding the environment variables:

1. Go to **"Deployments"** tab
2. Click the **⋮** (three dots) on your latest deployment
3. Click **"Redeploy"**
4. Wait ~1-2 minutes

---

## ✅ Verification:

After redeployment, test the admin dashboard:

1. Open: `https://your-app.vercel.app/admin`
2. Login with your admin password
3. Try updating the station config
4. **It should save without 500 errors!** ✅

Check the Vercel logs to see:
```
✅ Redis connection configured
Reading config from Redis
Config written successfully to Redis
```

---

##  Free Tier Limits:

Upstash Free tier includes:
- ✅ 10,000 commands/day (plenty for config updates)
- ✅ 256 MB storage
- ✅ 1 database
- ✅ REST API access

Your app will use maybe 100-200 commands/day, so you're well within limits!

---

## 🔄 How It Works:

**Before (File System - Failed on Vercel):**
```
Config saved to config.json ❌ (Vercel filesystem is read-only)
```

**After (Upstash Redis - Works on Vercel):**
```
Config saved to Redis ✅ (Cloud database, persists across deployments)
```

---

## 🐛 Troubleshooting:

### **"Redis not configured" warning in logs:**
- Environment variables not set in Vercel
- Check Settings → Environment Variables
- Redeploy after adding variables

### **500 error when saving config:**
- Check Upstash database is active
- Verify REST URL and Token are correct
- Check Vercel deployment logs for errors

### **Config not persisting:**
- Redis is working if no errors appear
- Check that UPSTASH_REDIS_REST_URL doesn't have trailing slash
- Verify token has no extra spaces

---

## 💡 Pro Tips:

1. **Monitor usage:** Upstash dashboard shows command usage
2. **Backup:** You can export data from Upstash if needed
3. **Upgrade:** If you need more, paid plans start at $9/month
4. **Security:** Tokens are encrypted in Vercel - never commit them!

---

## 🎉 You're All Set!

Once Redis is configured:
- ✅ Config saves work on Vercel
- ✅ Data persists across deployments
- ✅ Free tier is sufficient for your needs
- ✅ No more 500 errors!

**Happy streaming!** 📻✨
