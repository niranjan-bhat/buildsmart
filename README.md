# BuildSmart

AI-powered construction site analysis app for Android. Takes photos of construction work, identifies the current build stage, flags defects, and provides rectification steps.

**Platform:** Android (Flutter)
**AI:** Google Gemini 1.5 Flash via Cloud Function
**Backend:** Firebase (Auth + Firestore + Storage + Functions + FCM + App Check)

---

## Current State (as of April 2026)

M3 (Analysis UI) and M4 (Checklist Module) are complete. The app is functional end-to-end — users can sign in, create projects, capture images, receive AI analysis, manage defects, and work through stage checklists.

**What exists:**
- All screens (splash, onboarding, auth, projects, camera, analysis, checklist, settings)
- Authentication: Google OAuth + Phone OTP (Firebase Auth) — no email/password
- Phone OTP screen: country code picker, 6-box OTP input, 60s resend timer, Android SMS auto-retrieval
- Full data layer: models, repositories, Riverpod providers
- Cloud Function (`analyzeConstructionImage`) — Firestore trigger → Gemini 1.5 Flash → writes result back
- Firestore + Storage security rules
- FCM service with 8s timeout and fire-and-forget (non-blocking auth flow)
- Material 3 theme — teal palette (#2C7A7B), light + dark mode
- Hive local cache for checklist (Firestore-synced, offline-capable)
- Multi-image upload — up to 5 images analysed in parallel, each with its own result
- Defect rectification — mark individual defects as resolved; persisted to Firestore
- Shimmer placeholders on project cards and image grid
- Reverse geocoding — shows city/state/country instead of raw coordinates
- Localisation — English, Hindi, Kannada
- Firebase App Check — debug provider in dev, Play Integrity in release builds

**What is NOT done yet:**
- `lib/firebase_options.dart` is gitignored — must regenerate locally (see setup)
- FCM push notifications not fully integrated
- No tests written yet (target ≥ 70% coverage)
- CI/CD (GitHub Actions + Fastlane) not configured
- Play Store listing / production release

---

## Quick Start

### Prerequisites

- Flutter 3.x (`flutter --version`)
- Node.js 22 + npm
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)
- A Google account with access to the `buildsmart-35f5b` Firebase project

### 1. Clone and install dependencies

```bash
git clone <repo-url>
cd buildsmart
flutter pub get
cd functions && npm install && cd ..
```

### 2. Regenerate Firebase config (gitignored secrets)

```bash
firebase login
flutterfire configure --project=buildsmart-35f5b
```

This regenerates `lib/firebase_options.dart` and `android/app/google-services.json`.

### 3. Run the app

```bash
flutter run
```

---

## Project Structure

```
buildsmart/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart          # gitignored — regenerate with flutterfire configure
│   ├── core/
│   │   ├── constants/                 # app constants, construction stage definitions
│   │   ├── router/                    # go_router config with _RouterNotifier bridge
│   │   └── theme/                     # Material 3 light/dark theme (teal palette)
│   ├── data/
│   │   ├── models/                    # Dart data classes (user, project, image, analysis, checklist, defect)
│   │   ├── repositories/              # Firebase implementations (auth, project, image, checklist)
│   │   └── services/                  # Low-level service wrappers (Firestore, Storage, Auth, FCM)
│   └── presentation/
│       ├── providers/                 # Riverpod providers (auth, project, image, checklist)
│       ├── screens/                   # One folder per feature
│       │   └── auth/                  # login_screen.dart, phone_auth_screen.dart
│       └── widgets/                   # Shared widgets (project card, defect card, stage badge, etc.)
├── functions/
│   └── index.js                       # Cloud Function: Firestore trigger → Gemini → result
├── android/
│   └── app/
│       └── google-services.json       # gitignored — regenerate with flutterfire configure
├── firestore.rules
├── storage.rules
└── firebase.json
```

---

## Authentication

Sign-in methods: **Google OAuth** and **Phone OTP** only.

| Flow | How it works |
|---|---|
| Google | `google_sign_in` → Firebase credential → Firestore user doc created on first sign-in |
| Phone OTP | `FirebaseAuth.verifyPhoneNumber` → 6-digit SMS code → `PhoneAuthProvider.credential` → sign in. Android auto-retrieves the SMS via Play Services. |

Firebase Phone Auth requires SHA-1 and SHA-256 fingerprints registered in the Firebase Console under Project Settings → Your apps → Android app.

Get debug fingerprints:
```bash
# Using Android Studio's keytool (adjust path if needed)
"C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v \
  -keystore %USERPROFILE%\.android\debug.keystore \
  -alias androiddebugkey -storepass android -keypass android
```

---

## Image Analysis Flow

1. User picks image in app → compressed if > 5 MB
2. Uploaded to `project_images/{userId}/{projectId}/{imageId}` in Cloud Storage
3. Firestore doc written at `users/{uid}/projects/{pid}/images/{iid}` with `status: "pending"`
4. Cloud Function fires on `onCreate`, calls Gemini 1.5 Flash with the image
5. Result written back to the same Firestore doc (`status: "complete"`, `analysisResult: {...}`)
6. Flutter UI updates via real-time snapshot listener (no polling)
7. FCM notification sent if app is in background

---

## Cloud Function

**File:** `functions/index.js`
**Trigger:** Firestore `onCreate` at `users/{userId}/projects/{projectId}/images/{imageId}`
**Runtime:** Node.js 22, 2nd gen, 120s timeout, 1 GiB memory, 1 min instance
**Secret:** `GEMINI_API_KEY` stored in Firebase Secret Manager — never in code or APK

### Deploy the function

```bash
firebase deploy --only functions
```

### Set the Gemini API key (first time)

```bash
firebase functions:secrets:set GEMINI_API_KEY
```

### View function logs

```bash
firebase functions:log
```

---

## Firebase Setup

**Project ID:** `buildsmart-35f5b`
**Services in use:** Auth, Firestore, Storage, Functions, Messaging, Analytics, App Check

### Enable Phone Auth

Firebase Console → Authentication → Sign-in methods → Phone → Enable.

### Enable App Check

Firebase Console → App Check → Android app → Play Integrity → Save.
Add SHA-1 and SHA-256 fingerprints under Project Settings → Your apps.

### Deploy rules

```bash
firebase deploy --only firestore:rules,storage
```

### Run emulators locally

```bash
firebase emulators:start
```

---

## Firestore Data Model

```
users/{userId}
  └── projects/{projectId}
        ├── images/{imageId}          status: pending | complete | error
        ├── analysisResults/{id}      written by Cloud Function only
        └── checklist/{stage}         per-stage completion state

appContent/bestPractices              read-only, admin-managed
```

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `firebase_*` | Auth, Firestore, Storage, FCM, App Check |
| `google_sign_in` | Google OAuth |
| `image_picker` + `flutter_image_compress` | Camera/gallery + compression |
| `hive` + `hive_flutter` | Local cache for checklist |
| `geolocator` + `geocoding` | GPS coordinates + reverse geocoding |
| `crypto` | Image hashing (dedup before Gemini call) |
| `pdf` + `printing` | PDF export of analysis results |

---

## Useful Commands

```bash
# Run with verbose logging
flutter run --verbose

# Build release APK
flutter build apk --release

# Generate Riverpod/Hive code
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## Environment Notes

- Billing alert set at $50/month in Google Cloud Console
- Firebase Blaze plan required for Cloud Function outbound network and Phone Auth beyond 10k SMS/month
- Gemini Flash is the default model (not Pro) — ~$0.0003 per analysis
- Rate limit in Cloud Function: 50 analyses/user/day
- Duplicate image uploads are deduped by image hash (skips Gemini call)
