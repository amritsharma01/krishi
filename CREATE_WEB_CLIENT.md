# How to Create Web OAuth Client for Google Sign-In

## The Problem
Your code uses `serverClientId` which requires a **Web OAuth client**, but you only have an Android OAuth client. You need both!

## Solution: Create a Web OAuth Client

### Step 1: Go to Google Cloud Console
1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Make sure you're in the **SAME project** where you created the Android OAuth client
3. Navigate to **APIs & Services** → **Credentials**

### Step 2: Create Web OAuth Client
1. Click **+ CREATE CREDENTIALS** button (top of the page)
2. Select **OAuth client ID**
3. If prompted, configure the OAuth consent screen first (follow the prompts)
4. In the "Create OAuth client ID" dialog:
   - **Application type:** Select **Web application**
   - **Name:** Enter something like "Web client for Krishi" or "Krishi Web Client"
   - **Authorized JavaScript origins:** Leave empty (not needed for mobile)
   - **Authorized redirect URIs:** Leave empty (not needed for mobile)
5. Click **CREATE**

### Step 3: Copy the Client ID
After creation, you'll see a dialog with:
- **Your Client ID** (something like: `318078992248-xxxxxxxxxxxxx.apps.googleusercontent.com`)
- **Your Client secret** (you don't need this for mobile)

**Copy the Client ID** - this is what you'll use in your code.

### Step 4: Update Your Code
The Client ID you just created should be used in:
- `lib/core/services/auth_service.dart` - as `serverClientId`
- `android/app/src/main/res/values/strings.xml` - as `default_web_client_id`

**Important:** Make sure the Web OAuth client is in the **SAME Google Cloud project** as your Android OAuth client!

## Why You Need Both

- **Android OAuth Client:** Used by Google Sign-In SDK to authenticate on Android
  - Requires: Package name + SHA-1 fingerprint
  - This is what you already created ✅

- **Web OAuth Client:** Used as `serverClientId` to get the ID token
  - The ID token is what you send to your backend server
  - This is what you need to create now ⚠️

## After Creating the Web Client

1. Update the code with the new Web Client ID
2. Wait 5-10 minutes for changes to propagate
3. Do a clean rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Quick Checklist

- ✅ Android OAuth client created (package: `com.example.krishi`, SHA-1 added)
- ⚠️ **Web OAuth client needs to be created** ← You are here
- ⚠️ Both clients must be in the same Google Cloud project
- ⚠️ Update code with Web Client ID after creation

