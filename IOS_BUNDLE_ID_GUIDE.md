# iOS Bundle ID Guide for Google Sign-In

## Your Bundle ID

**Your iOS Bundle ID is:** `com.example.krishi`

This was found in your Xcode project configuration file (`ios/Runner.xcodeproj/project.pbxproj`).

---

## Where to Find Bundle ID (Alternative Methods)

### Method 1: In Xcode (if you have it open)
1. Open `ios/Runner.xcodeproj` in Xcode
2. Click on the **Runner** project in the left sidebar
3. Select the **Runner** target
4. Go to the **General** tab
5. Look for **Bundle Identifier** - it should show: `com.example.krishi`

### Method 2: In Project File (what we did)
- Found in: `ios/Runner.xcodeproj/project.pbxproj`
- Search for: `PRODUCT_BUNDLE_IDENTIFIER`
- Value: `com.example.krishi`

---

## How to Use Bundle ID in Google Cloud Console

### Step-by-Step Instructions:

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/
   - Make sure you're in the **same project** that has your Android and Web OAuth clients

2. **Navigate to Credentials**
   - Click on **"APIs & Services"** in the left menu
   - Click on **"Credentials"**

3. **Create iOS OAuth Client**
   - Click the **"+ CREATE CREDENTIALS"** button at the top
   - Select **"OAuth client ID"**

4. **Fill in the Form**
   - **Application type**: Select **"iOS"**
   - **Name**: Enter something like `Krishi iOS App` (optional, for your reference)
   - **Bundle ID**: Enter exactly: `com.example.krishi`
     - ⚠️ **IMPORTANT**: Copy and paste this exactly - it's case-sensitive!
     - No spaces, no extra characters

5. **Click "CREATE"**
   - Google will create the iOS OAuth client
   - You'll see a popup with the Client ID (you don't need to save this separately)
   - Click "OK" to close

6. **Verify It Was Created**
   - You should now see your iOS OAuth client in the credentials list
   - It will show as type "iOS" with Bundle ID: `com.example.krishi`

---

## Important Notes

✅ **Bundle ID must match exactly:**
- In Xcode: `com.example.krishi`
- In Google Cloud Console: `com.example.krishi`
- They must be **identical** (case-sensitive, no spaces)

✅ **All OAuth clients must be in the same Google Cloud Project:**
- Your Web Client ID: `22500384416-5choujjs47148lfal8k3g2ugs0nic29j.apps.googleusercontent.com`
- Your Android OAuth client (for package: `com.example.krishi`)
- Your new iOS OAuth client (for Bundle ID: `com.example.krishi`)

✅ **Wait for propagation:**
- After creating the iOS OAuth client, wait **15-30 minutes** before testing
- Google needs time to propagate the changes

---

## What Happens After Setup

Once you create the iOS OAuth client:
1. ✅ Your app code is already configured correctly
2. ✅ URL schemes are already set up in `Info.plist`
3. ✅ AppDelegate is already handling URL callbacks
4. ✅ Google Sign-In will work on iOS devices

---

## Testing

After waiting 15-30 minutes:
1. Build and run your app on a **physical iOS device** (simulators may have limitations)
2. Try signing in with Google
3. It should work! 🎉

---

## Troubleshooting

**If it doesn't work:**
1. Double-check the Bundle ID matches exactly in both places
2. Verify all OAuth clients are in the same Google Cloud project
3. Wait longer (up to 1 hour) for changes to propagate
4. Check that the OAuth consent screen is configured
5. Make sure you're testing on a physical device, not just simulator

