# Google Sign-In Troubleshooting Guide

## Current Status
✅ Android OAuth client created with:
- Package name: `com.example.krishi`
- SHA-1: `A8:BE:60:4A:FD:CE:2D:D9:AA:F5:EB:A2:2D:FA:4E:2F:92:6C:7D:D9`

## Still Getting Error 10? Try These Steps:

### 1. Verify Project Consistency
**IMPORTANT:** Make sure both OAuth clients (Android and Web) are in the **SAME Google Cloud Project**:
- Go to Google Cloud Console → APIs & Services → Credentials
- Check that your Android OAuth client and Web OAuth client are both listed
- They should both be under the same project

### 2. Add SHA-256 Fingerprint
Even though SHA-1 is required, adding SHA-256 can help:
- Edit your Android OAuth client
- Add SHA-256: `46:55:A1:CB:D1:6B:F8:DD:5D:5F:12:DD:33:9D:9F:76:44:80:D3:FD:47:A0:5C:BC:05:81:D1:1D:BD:86:12:2E`
- Save changes

### 3. Verify OAuth Consent Screen
- Go to APIs & Services → OAuth consent screen
- Make sure it's configured (even for testing)
- Add your email as a test user if needed

### 4. Enable Required APIs
Make sure these APIs are enabled:
- Google Sign-In API (or Identity Toolkit API)
- Google+ API (if still available)

### 5. Clean Rebuild the App
The app might be using cached credentials. Do a complete clean rebuild:

```bash
# Stop the app if running
# Then run:
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### 6. Uninstall and Reinstall
Sometimes the app needs to be completely removed:
```bash
# Uninstall from device
adb uninstall com.example.krishi

# Then rebuild and install
flutter run
```

### 7. Wait for Propagation
Google Cloud Console changes can take:
- **Minimum:** 5 minutes
- **Typical:** 15-30 minutes
- **Maximum:** A few hours (rare)

If you just created the Android OAuth client, wait at least 15-30 minutes before testing again.

### 8. Verify Client ID Match
Check that the Web Client ID in your code matches the one in Google Cloud Console:
- Current in code: `318078992248-lcplalh0b5fe5p8ics5c5nmlvu4905qr.apps.googleusercontent.com`
- Verify this exists in Google Cloud Console → Credentials → OAuth 2.0 Client IDs (Web application type)

### 9. Check for Multiple Projects
If you have multiple Google Cloud projects, make sure:
- The Android OAuth client is in the same project as the Web OAuth client
- The project number matches (318078992248 in your Web client ID)

### 10. Verify Package Name Exactly
Double-check the package name matches exactly (case-sensitive):
- In `android/app/build.gradle.kts`: `applicationId = "com.example.krishi"`
- In Google Cloud Console Android OAuth client: `com.example.krishi`
- They must match **exactly** (no spaces, correct case)

## Still Not Working?

If after trying all these steps it still doesn't work:

1. **Check the Android OAuth Client ID**: In Google Cloud Console, note the Client ID of your Android OAuth client (it will be different from the Web client ID). You might need to verify it's being used correctly.

2. **Check Logs**: Look for more detailed error messages in the Android logcat:
   ```bash
   adb logcat | grep -i "google\|oauth\|signin"
   ```

3. **Verify Internet Connection**: Make sure your device/emulator has internet access and can reach Google's servers.

4. **Try on a Different Device/Emulator**: Sometimes device-specific issues can occur.

