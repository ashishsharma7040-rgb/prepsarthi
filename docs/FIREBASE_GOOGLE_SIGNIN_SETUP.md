# Firebase Google Sign-In Setup

This app expects the Android Firebase app package to be exactly:

`com.prepsarthi.app`

If Google account selection opens and then sign-in fails, the most common cause is Firebase Android configuration, not Flutter UI logic.

## 1. Create or verify the Firebase Android app

In Firebase Console:

1. Open your project.
2. Go to `Project settings`.
3. Under `Your apps`, verify there is an Android app with package:
   `com.prepsarthi.app`

Do not use:

- `com.prepsarhi.app`
- `com.prepsarthi.app.debug`

## 2. Enable Google Sign-In in Firebase Auth

In Firebase Console:

1. Go to `Authentication`.
2. Open `Sign-in method`.
3. Enable `Google`.

## 3. Add SHA-1 and SHA-256 fingerprints

You must add the fingerprints for the key that signed the APK you installed.

Required fingerprints usually include:

1. Local debug key SHA-1 and SHA-256.
2. Codemagic debug signing SHA-1 and SHA-256.
3. Release signing SHA-1 and SHA-256.

This repo includes a Codemagic signing report step so you can copy the exact fingerprints from build logs.

## 4. Download a fresh google-services.json

After:

- creating the Android app
- enabling Google provider
- adding SHA fingerprints

download a fresh `google-services.json` from Firebase Console.

The file must correspond to:

`com.prepsarthi.app`

## 5. Correct file path

The required Android Firebase config path is:

`android/app/google-services.json`

Do not use:

- `android/google-services.json`
- `lib/google-services.json`
- `google-services (1).json`

## 6. Local build setup

If you build the APK locally on your own machine, put the real file at:

`android/app/google-services.json`

This repo already ignores that file in `.gitignore`, so it stays local and does not get committed accidentally.

## 7. Codemagic secure setup

Do not commit the real Firebase config to a public repo.

Recommended Codemagic setup:

1. Base64-encode the real `google-services.json`.
2. Create a variable group in Codemagic named:
   `firebase_credentials`
3. Store the base64 output in that group as an environment variable:
   `GOOGLE_SERVICES_JSON_B64`
4. During the build, Codemagic decodes it into:
   `android/app/google-services.json`

This repo's `codemagic.yaml` now imports the `firebase_credentials` group and fails early with a clear message if `GOOGLE_SERVICES_JSON_B64` is missing.

On Windows, you can generate the base64 string with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/firebase/encode_google_services.ps1 -InputPath "C:\path\to\google-services.json" -OutputPath "google-services.base64.txt"
```

Then copy the contents of `google-services.base64.txt` into the Codemagic variable.

## 8. Codemagic build logs

The build now runs:

```bash
cd android
./gradlew signingReport
```

Use the output from `Variant: debug` and `Variant: release` to copy SHA-1 and SHA-256 into Firebase.

## 9. Rebuild after updating Firebase

After adding the correct `google-services.json` and SHA fingerprints:

1. Trigger a fresh Codemagic build.
2. Install the new APK.
3. Test Google Sign-In again.

## 10. What success looks like

Correct production flow:

1. User taps `Continue with Google`.
2. Google account picker opens.
3. Selected account returns to app.
4. Firebase Auth signs in successfully.
5. Local user profile is created or updated.
6. Subscription entitlement is synced from `subscriptions/{uid}`.
7. User is routed to onboarding or dashboard.
