# Google Sign-In Android Checklist

Use this checklist when the account picker opens but Firebase sign-in fails after selecting an account.

## Package name

The Android package name for both debug and release must be:

`com.prepsarthi.app`

This repo now keeps the debug APK on that same package name. Do not register `com.prepsarthi.app.debug` in Firebase unless you intentionally bring that suffix back.

## Required Firebase file

You must use the real Firebase config file for this Android app:

- `android/app/google-services.json`

That file is intentionally `.gitignore`d and is not stored in the public repo.

## Firebase Console setup

In Firebase Console:

1. Open the Android app with package `com.prepsarthi.app`
2. Enable `Authentication > Sign-in method > Google`
3. Add SHA-1 and SHA-256 for every signing key that can produce an APK/AAB you install

## SHA fingerprints you must register

Register all that apply:

1. Local debug keystore SHA-1 and SHA-256
2. Codemagic debug signing SHA-1 and SHA-256 if the debug build is not using your release key
3. Release signing SHA-1 and SHA-256 for Play / signed AAB builds

If `android/key.properties` is available during the build, this repo now reuses that signing key for debug builds too. That helps Codemagic debug/release builds share the same SHA.

## How to get the SHA fingerprints

### Local debug keystore

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### App signing report

```bash
cd android
./gradlew signingReport
```

On Windows PowerShell:

```powershell
cd android
.\gradlew signingReport
```

## Common failure meaning

If the account picker opens and then sign-in fails immediately, the most common causes are:

1. Wrong or missing `google-services.json`
2. Firebase Android app package mismatch
3. Missing SHA-1 / SHA-256 for the APK signing key
4. Google provider not enabled in Firebase Authentication
5. Installing a Codemagic-built debug APK signed with a different key than your local build
