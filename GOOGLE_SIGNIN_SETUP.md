# Google Sign-In Setup Guide

## Problem
You're getting error code `10` (DEVELOPER_ERROR) when trying to sign in with Google. This happens because your machine's SHA-1 fingerprint is not registered in Google Cloud Console.

## Solution

### Step 1: Get Your SHA-1 and SHA-256 Fingerprints

Run the provided script:
```bash
./get_sha1.sh
```

**Your current fingerprints are:**
- **SHA-1:** `A8:BE:60:4A:FD:CE:2D:D9:AA:F5:EB:A2:2D:FA:4E:2F:92:6C:7D:D9`
- **SHA-256:** `46:55:A1:CB:D1:6B:F8:DD:5D:5F:12:DD:33:9D:9F:76:44:80:D3:FD:47:A0:5C:BC:05:81:D1:1D:BD:86:12:2E`

### Step 2: Add Fingerprints to Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create one if needed)
3. Navigate to **APIs & Services** → **Credentials**
4. Find your **OAuth 2.0 Client ID** of type **Android** (package name: `com.example.krishi`)
   - If you don't have an Android OAuth client, create one:
     - Click **+ CREATE CREDENTIALS** → **OAuth client ID**
     - Select **Android** as application type
     - Package name: `com.example.krishi`
     - SHA-1 certificate fingerprint: `A8:BE:60:4A:FD:CE:2D:D9:AA:F5:EB:A2:2D:FA:4E:2F:92:6C:7D:D9`
5. Edit the Android OAuth client and add:
   - **SHA-1:** `A8:BE:60:4A:FD:CE:2D:D9:AA:F5:EB:A2:2D:FA:4E:2F:92:6C:7D:D9`
   - **SHA-256:** `46:55:A1:CB:D1:6B:F8:DD:5D:5F:12:DD:33:9D:9F:76:44:80:D3:FD:47:A0:5C:BC:05:81:D1:1D:BD:86:12:2E`

### Step 3: Verify Configuration

Make sure you have:
- ✅ Android OAuth 2.0 Client ID with package name: `com.example.krishi`
- ✅ SHA-1 fingerprint added: `A8:BE:60:4A:FD:CE:2D:D9:AA:F5:EB:A2:2D:FA:4E:2F:92:6C:7D:D9`
- ✅ SHA-256 fingerprint added: `46:55:A1:CB:D1:6B:F8:DD:5D:5F:12:DD:33:9D:9F:76:44:80:D3:FD:47:A0:5C:BC:05:81:D1:1D:BD:86:12:2E`
- ✅ Web Client ID configured in `auth_service.dart`: `318078992248-8o586u81irpfgkar3uqupc83tt6vrnl2.apps.googleusercontent.com`

### Step 4: Wait and Test

- Changes in Google Cloud Console can take a few minutes to propagate
- After adding the fingerprints, wait 2-5 minutes
- Then try running the app again: `flutter run`

## Additional Notes

- **Different machines need different fingerprints**: Each computer has its own debug keystore, so you need to add the SHA-1 from each machine that will run the app
- **Release builds**: For release builds, you'll need to add the SHA-1 from your release keystore
- **Package name must match**: The package name in Google Cloud Console (`com.example.krishi`) must exactly match the `applicationId` in `android/app/build.gradle.kts`

## Troubleshooting

If it still doesn't work after adding fingerprints:
1. Double-check the package name matches exactly
2. Verify the SHA-1 fingerprint is correct (run `./get_sha1.sh` again)
3. Make sure you're editing the **Android** OAuth client, not the Web client
4. Wait a few more minutes for changes to propagate
5. Try uninstalling and reinstalling the app: `flutter clean && flutter pub get && flutter run`

