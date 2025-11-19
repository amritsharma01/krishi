#!/bin/bash
# Script to get SHA-1 fingerprint for Google Sign-In configuration

echo "Getting SHA-1 fingerprint for Google Sign-In..."
echo ""

# Find keytool - try Android Studio's Java first, then system Java
KEYTOOL=""
if [ -f "/snap/android-studio/current/jbr/bin/keytool" ]; then
    KEYTOOL="/snap/android-studio/current/jbr/bin/keytool"
elif [ -f "/snap/android-studio/209/jbr/bin/keytool" ]; then
    KEYTOOL="/snap/android-studio/209/jbr/bin/keytool"
elif command -v keytool &> /dev/null; then
    KEYTOOL="keytool"
else
    echo "ERROR: keytool not found. Please install Java or use Android Studio's Java."
    exit 1
fi

# Try to get SHA-1 from debug keystore
KEYSTORE_PATH="$HOME/.android/debug.keystore"

if [ -f "$KEYSTORE_PATH" ]; then
    echo "Found debug keystore at: $KEYSTORE_PATH"
    echo ""
    echo "SHA-1 Fingerprint:"
    $KEYTOOL -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -E "SHA1:" | head -1
    echo ""
    echo "SHA-256 Fingerprint:"
    $KEYTOOL -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -E "SHA256:" | head -1
else
    echo "Debug keystore not found at: $KEYSTORE_PATH"
    echo ""
    echo "Creating debug keystore..."
    $KEYTOOL -genkey -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
    echo ""
    echo "SHA-1 Fingerprint:"
    $KEYTOOL -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -E "SHA1:" | head -1
    echo ""
    echo "SHA-256 Fingerprint:"
    $KEYTOOL -list -v -keystore "$KEYSTORE_PATH" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -E "SHA256:" | head -1
fi

echo ""
echo "=========================================="
echo "IMPORTANT: Add these fingerprints to:"
echo "1. Google Cloud Console -> APIs & Services -> Credentials"
echo "2. Find your OAuth 2.0 Client ID (Android type)"
echo "3. Add SHA-1 and SHA-256 fingerprints"
echo "=========================================="

                                                                                                                                                                                                                            