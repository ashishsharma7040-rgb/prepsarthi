// ═══════════════════════════════════════════════════════════════════════
// FIREBASE SETUP INSTRUCTIONS
// Place this file at: firebase/SETUP.md
// ═══════════════════════════════════════════════════════════════════════

/*
STEP 1 – Create Firebase Project
─────────────────────────────────
1. Go to https://console.firebase.google.com
2. Click "Add project" → Name it "PrepSarthi"
3. Disable Google Analytics (optional) → Create project

STEP 2 – Add Android App
─────────────────────────
1. Click "Add app" → Android icon
2. Android package name: com.prepsarthi.app
3. App nickname: PrepSarthi
4. Debug SHA-1: run → keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
5. Click "Register app"
6. Download google-services.json
7. Place at: android/app/google-services.json

STEP 3 – Enable Authentication
────────────────────────────────
1. Firebase Console → Build → Authentication
2. Click "Get started"
3. Sign-in method → Google → Enable
4. Add your SHA-1 and SHA-256 fingerprints
5. Save

STEP 4 – Enable Firestore
──────────────────────────
1. Firebase Console → Build → Firestore Database
2. "Create database" → Start in production mode
3. Choose region closest to India (asia-south1 recommended)
4. Apply the security rules below

STEP 5 – Enable Vertex AI (Gemini)
────────────────────────────────────
1. Firebase Console → Build → AI Logic (or Vertex AI)
2. Enable the API
3. Billing must be enabled on the Google Cloud project
4. Model: gemini-2.5-flash is used in gemini_service.dart

STEP 6 – Firestore Security Rules
───────────────────────────────────
Paste these rules in Firestore → Rules tab:
*/

// firestore.rules
const firestoreRules = `
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ⚠️ subscriptions/{uid} is READ-ONLY for the client.
    // ONLY the Cloud Function (admin SDK) writes to this collection.
    // Client write is intentionally blocked — this is correct and required.
    match /subscriptions/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false; // Cloud Function uses admin SDK — bypasses rules
    }

    // purchaseVerificationRequests: client can CREATE (submit token for verification).
    // Cloud Function reads and processes these. Client cannot update/delete.
    match /purchaseVerificationRequests/{requestId} {
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid;
      allow read, update, delete: if false;
    }

    // Users can read and write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Block all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
`;

// ═══════════════════════════════════════════════════════════════════════
// GOOGLE PLAY BILLING SETUP
// ═══════════════════════════════════════════════════════════════════════

/*
STEP 1 – Create Subscription Products in Play Console
──────────────────────────────────────────────────────
1. Go to https://play.google.com/console
2. Select your app → Monetise → Subscriptions
3. Create ONE subscription product with multiple base plans:

   ⚠️ IMPORTANT: Google Play new subscription model uses ONE product ID
   with separate Base Plan IDs and Offer IDs. Do NOT create composite
   product IDs like 'prepsarthi_premium:monthly'.

   Subscription Product ID: prepsarthi_premium
   Name: PrepSarthi Pro

   Under 'prepsarthi_premium', create 3 base plans:

   Base Plan ID: monthly
     Name: Monthly
     Price: ₹99 / month
     Billing period: 1 month

   Base Plan ID: quarterly
     Name: Quarterly
     Price: ₹239 / 3 months
     Billing period: 3 months

   Base Plan ID: annual
     Name: Annual
     Price: ₹799 / year
     Billing period: 12 months

   Under each base plan, create a trial offer:
     Offer ID: trial_7_days_new_user
     Eligibility: New subscribers only
     Trial duration: 7 days free
     Attach to: monthly, quarterly, annual (all three base plans)

STEP 2 – Add Test Accounts
────────────────────────────
1. Play Console → Setup → License testing
2. Add your Gmail for testing
3. Test purchases won't charge real money

STEP 3 – in_app_purchase Integration (already implemented in v4)
─────────────────────────────────────────────────────────────────
The billing flow is fully implemented. Key points:
- App queries the single product ID: 'prepsarthi_premium'
- Android returns separate GooglePlayProductDetails per base plan / offer
- offerIdToken (NOT offerToken) is used to select the correct offer
- Trial offer is selected by matching offerId == 'trial_7_days_new_user'
- Purchase stream is handled centrally in app.dart

  // Correct query (single product ID, not composite)
  const ids = {kSubscriptionProductId}; // 'prepsarthi_premium'
  final response = await iap.queryProductDetails(ids);

  // On Android, use GooglePlayPurchaseParam with offerIdToken
  final purchaseParam = GooglePlayPurchaseParam(
    productDetails: gpd,           // GooglePlayProductDetails
    offerToken: targetOffer.offerIdToken, // from SubscriptionOfferDetailsWrapper
  );
  await iap.buyNonConsumable(purchaseParam: purchaseParam);

  // Purchase stream is handled in app.dart — do NOT add a second listener
          purchase.status == PurchaseStatus.restored) {
        // Verify and activate premium
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  });
*/

// ═══════════════════════════════════════════════════════════════════════
// GOOGLE SERVICES JSON TEMPLATE
// Replace with actual file from Firebase Console
// ═══════════════════════════════════════════════════════════════════════

const googleServicesTemplate = '''
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "YOUR_PROJECT_ID",
    "storage_bucket": "YOUR_PROJECT_ID.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:YOUR_PROJECT_NUMBER:android:HASH",
        "android_client_info": {
          "package_name": "com.prepsarthi.app"
        }
      },
      "oauth_client": [
        {
          "client_id": "YOUR_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "YOUR_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
''';
