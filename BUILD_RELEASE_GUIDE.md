# Release Build Guide for Lead Flow Business App

## 📱 Android Release Build (App Bundle for Google Play Store)

### Step 1: Create a Keystore (One-time setup)

1. Open terminal/command prompt in your project root directory
2. Run the following command:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important Notes:**
- Replace `~/upload-keystore.jks` with your desired keystore file path
- Remember the password you set - you'll need it later
- Remember the alias name (e.g., "upload")
- Keep the keystore file safe - you'll need it for all future updates

### Step 2: Create key.properties file

1. Create a file named `key.properties` in the `android` folder
2. Add the following content (replace with your actual values):

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-your-keystore-file>
```

**Example:**
```properties
storePassword=YourPassword123
keyPassword=YourPassword123
keyAlias=upload
storeFile=C:\\Users\\YourName\\upload-keystore.jks
```

**⚠️ Security Note:** Add `key.properties` to `.gitignore` to keep it secure!

### Step 3: Configure Signing in build.gradle.kts

Update `android/app/build.gradle.kts` to use the keystore for release builds.

### Step 4: Build the App Bundle

Run this command in your project root:

```bash
flutter build appbundle --release
```

**Output Location:**
- The `.aab` file will be created at: `build/app/outputs/bundle/release/app-release.aab`

### Step 5: Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to "Production" → "Create new release"
4. Upload the `app-release.aab` file
5. Fill in release notes and submit for review

---

## 🍎 iOS Release Build (for App Store)

### Prerequisites:
- Mac computer with Xcode installed
- Apple Developer account ($99/year)
- Valid provisioning profiles and certificates

### Step 1: Update Version Number

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # versionName+versionCode
```

### Step 2: Open in Xcode

```bash
open ios/Runner.xcworkspace
```

### Step 3: Configure Signing in Xcode

1. Select "Runner" in the project navigator
2. Go to "Signing & Capabilities" tab
3. Select your Team
4. Ensure "Automatically manage signing" is checked
5. Select your Bundle Identifier

### Step 4: Build Archive

1. In Xcode, select "Product" → "Archive"
2. Wait for the archive to complete
3. The Organizer window will open

### Step 5: Upload to App Store

1. In Organizer, select your archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Follow the wizard to upload

**Alternative: Using Flutter Command**

```bash
flutter build ipa --release
```

Then upload the `.ipa` file from `build/ios/ipa/` to App Store Connect.

---

## 🔧 Quick Commands Reference

### Android:
```bash
# Build App Bundle (for Play Store)
flutter build appbundle --release

# Build APK (for direct installation)
flutter build apk --release

# Build split APKs (smaller file sizes)
flutter build apk --split-per-abi --release
```

### iOS:
```bash
# Build IPA
flutter build ipa --release

# Build for iOS (without IPA)
flutter build ios --release
```

### General:
```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Check for issues
flutter doctor
```

---

## 📝 Pre-Release Checklist

### Before Building:
- [ ] Update version number in `pubspec.yaml`
- [ ] Update app name and description
- [ ] Test app thoroughly in release mode
- [ ] Check all API endpoints are production URLs
- [ ] Verify all assets are included
- [ ] Test on multiple devices/screen sizes
- [ ] Check dark mode works correctly
- [ ] Verify all permissions are properly configured
- [ ] Test offline functionality (if applicable)

### Android Specific:
- [ ] Keystore file is created and secured
- [ ] `key.properties` is configured
- [ ] Signing config is set up in `build.gradle.kts`
- [ ] App icon is set for all densities
- [ ] Splash screen is configured

### iOS Specific:
- [ ] Bundle identifier is unique
- [ ] App icons are set (all sizes)
- [ ] Launch screen is configured
- [ ] Privacy permissions are declared in Info.plist
- [ ] App Store Connect app is created

---

## 🚨 Common Issues & Solutions

### Android:
**Issue:** "Keystore file not found"
- Solution: Check the path in `key.properties` is correct

**Issue:** "Signing config not found"
- Solution: Ensure signing config is properly set in `build.gradle.kts`

### iOS:
**Issue:** "No valid code signing certificates found"
- Solution: Download certificates from Apple Developer portal

**Issue:** "Provisioning profile doesn't match"
- Solution: Update provisioning profile in Xcode

---

## 📞 Need Help?

- Flutter Documentation: https://flutter.dev/docs/deployment
- Android: https://developer.android.com/studio/publish
- iOS: https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases

