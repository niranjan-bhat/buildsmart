# BuildSmart — AI-Powered Construction Assistant

## Project Overview

BuildSmart is an Android mobile application built with Flutter. It serves house owners undertaking self-build projects and contractors/site engineers managing construction sites. The app uses Google Gemini 1.5 Flash to analyse photographs of construction work, identify the current stage of construction, flag errors or deviations from accepted practice, and provide actionable rectification steps.

- **Version:** 2.0
- **Platform:** Android (Flutter)
- **Backend:** Firebase (Auth + Firestore + Cloud Storage + Functions)
- **AI Provider:** Google Gemini 1.5 Flash
- **Connectivity:** Online only

---

## Architecture

### Stack

| Layer | Technology |
|---|---|
| Mobile UI | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Firebase SDK | FlutterFire (firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging) |
| Image Handling | image_picker + flutter_image_compress |
| Local Cache | Hive (checklist content + offline last results) |
| Cloud Function | Node.js 20 + @google/generative-ai SDK |
| AI Model | Google Gemini 1.5 Flash |
| Auth | Firebase Authentication (Email + Google OAuth) |
| Database | Cloud Firestore (real-time listeners) |
| Storage | Firebase Cloud Storage (private buckets) |
| Notifications | Firebase Cloud Messaging (FCM) |
| CI/CD | GitHub Actions + Fastlane |

### Code Architecture

Follow **Clean Architecture** with three layers in Flutter:
- **Presentation** — UI, widgets, screens
- **Domain** — use cases, entities, repository interfaces
- **Data** — Firebase implementations, Gemini data sources

The Gemini model must be abstracted behind an `AnalysisRepository` interface so models can be swapped without UI changes.

---

## Image Analysis Data Flow

1. User captures/selects image in Flutter app
2. App compresses image (if > 5 MB) and uploads to Firebase Cloud Storage
3. App writes image document to Firestore with `status: "pending"`
4. Firestore `onCreate` trigger fires the Cloud Function automatically
5. Cloud Function reads image from Cloud Storage via GCS URI, calls Gemini 1.5 Flash API
6. Cloud Function writes structured JSON result back to Firestore
7. Flutter app updates UI via real-time Firestore snapshot listener (no polling)
8. FCM push notification sent as fallback if app is in background

**API key:** Stored in Firebase Functions Secret Manager (`GEMINI_API_KEY`) — never in the APK or version control.

---

## Firestore Data Model

```
users/{userId}
  - name, role, email, photoUrl, createdAt

users/{userId}/projects/{projectId}
  - name, location, description, createdAt, updatedAt, thumbnailUrl, currentStage

users/{userId}/projects/{projectId}/images/{imageId}
  - storageUrl, timestamp, gpsLat, gpsLng, note, status, analysisResult{}
  - status: pending | complete | error

users/{userId}/projects/{projectId}/checklist/{stage}
  - items: [{id, text, completed, completedAt}]

appContent/bestPractices
  - stages: [{name, items: [{text, explanation}]}]  (read-only, admin-updated)
```

---

## Gemini Analysis — Output JSON Schema

```json
{
  "construction_stage": "<one of 11 stages>",
  "stage_confidence": "HIGH | MEDIUM | LOW",
  "defects": [
    {
      "title": "string",
      "description": "string (<=150 words)",
      "confidence": "HIGH | MEDIUM | LOW",
      "rectification_steps": ["string"]
    }
  ],
  "best_practices": ["string (3-5 items)"],
  "overall_assessment": "PASS | ATTENTION_NEEDED | CRITICAL",
  "analysis_id": "uuid"
}
```

- Temperature: **0.2** (consistent, factual output)
- If not a construction scene: return `{ "error": "NON_CONSTRUCTION_IMAGE" }`
- Prompt strategy: chain-of-thought — describe observations → classify stage → identify defects → output JSON only, no preamble

### Supported Construction Stages (11)

Site Preparation, Foundation, Plinth, Superstructure / Framing, Brickwork / Masonry, Roofing, Plumbing rough-in, Electrical rough-in, Plastering, Flooring, Finishing

---

## Cloud Function Configuration

- Runtime: Node.js 20, Firebase Cloud Functions 2nd gen
- Trigger: Firestore `onCreate` at `users/{userId}/projects/{projectId}/images/{imageId}`
- Timeout: 60 seconds | Memory: 512 MB
- Minimum instances: 1 (keep warm, avoids cold-start latency, ~$2/month)

---

## Security Rules

- Firestore rules: users can only read/write their own documents (`userId` match)
- Cloud Storage rules: images accessible only to owning user and Cloud Function service account
- Gemini API key: Firebase Functions Secret Manager only — never in APK
- Firebase App Check (Play Integrity API): enabled to block unauthorised API calls

---

## Key Functional Requirements

### Authentication
- Google OAuth and Phone OTP via Firebase Auth — no email/password
- Phone OTP: `FirebaseAuth.verifyPhoneNumber` → 6-digit SMS → `PhoneAuthProvider.credential`
- Android SMS auto-retrieval via Play Services (instantaneous on supported devices)
- User profile in Firestore `users/{userId}` — auto-created on first sign-in, recovered by `_userStream` if the write fails
- FCM token update is fire-and-forget (8s timeout) — never blocks the auth flow
- App Check: `AndroidProvider.debug` in dev, `AndroidProvider.playIntegrity` in release (`kReleaseMode`)

### Projects
- CRUD in Firestore, ordered by `updatedAt` descending
- Soft delete with 30-day recovery

### Image Upload
- Compress images > 5 MB using `flutter_image_compress`
- Show upload progress via Firebase Storage upload task stream
- Supported formats: JPEG, PNG, HEIC
- Store GPS coordinates (if permission granted) in Firestore

### Checklist
- Content from Firestore `appContent/bestPractices`, cached locally in Hive
- Per-project completion state persisted in Firestore in real time
- Refresh from Firestore on app launch; use cached version if offline

---

## Performance Targets

| Metric | Target |
|---|---|
| Gemini analysis turnaround | < 8 seconds p95 |
| App cold start | < 3 seconds (Snapdragon 665, 4 GB RAM) |
| Firestore listener update latency | < 2 seconds after Cloud Function write |
| Stage classification accuracy | ≥ 85% |
| Defect detection precision | ≥ 80% |

---

## Cost Model

- **Firebase:** Blaze plan active. Phone Auth free up to 10k SMS/month; charged per SMS beyond that (~₹0.05–0.10/SMS for Indian numbers).
- **Gemini 1.5 Flash:** ~$0.0003 per analysis (~$0.075/1M input tokens, ~$0.30/1M output tokens)
- **Billing alert:** Set at $50/month in Google Cloud Console

### Cost Optimisations
- Cache results in Firestore by image hash — skip Gemini call for duplicate uploads
- Per-user rate limit in Cloud Function (e.g. max 50 analyses/day on free tier)
- Aggressively compress images before upload to reduce input tokens
- Use Gemini Flash (not Pro) as default model

---

## Screens

| Screen | Notes |
|---|---|
| Splash / Onboarding | 3-screen tour, role selector, then navigates to Login |
| Log In | Google OAuth + Phone OTP buttons only — no email/password |
| Phone OTP | Country code + phone number → 6-box OTP input, 60s resend timer |
| Projects Home | Firestore-backed cards, FAB to create project |
| Project Detail | Recent images, stage progress ring, action buttons |
| Camera / Gallery Picker | image_picker sheet |
| Analysis Result | Stage badge, defect cards, confidence chips, rectification accordion |
| Checklist | Stage tabs, Hive-cached items, Firestore-synced completion |
| Analysis History | Firestore-streamed cards with thumbnails, stage tag, defect count |
| Settings | Profile edit, theme toggle, notification prefs, sign out |
| Feedback / Flag | Reason selector, written to Firestore for admin review |

---

## Accessibility & UI

- Material Design 3; light and dark themes follow system setting
- Minimum tap-target: 48 × 48 dp
- All interactive elements have semantic labels (TalkBack compatible)
- Text contrast: WCAG 2.1 AA (≥ 4.5:1 for body text)

---

## Test Coverage

- Target: ≥ 70% for business logic and Cloud Function

---

## Release Milestones

| Milestone | Duration | Deliverables |
|---|---|---|
| M0 — Discovery & Design | 2 weeks | PRD v2.0, Figma wireframes, Firestore schema, Gemini prompt prototype |
| M1 — Firebase Setup & Auth | 2 weeks | Firebase project, Auth, Firestore rules, CI/CD |
| M2 — Image Upload + Cloud Function | 3 weeks | Camera/gallery, Cloud Storage, Cloud Function → Gemini integration |
| M3 — Analysis UI | 2 weeks | Real-time result display, defect cards, rectification steps |
| M4 — Checklist Module | 2 weeks | Phase checklists, Hive cache, Firestore sync, progress tracking |
| M5 — Polish & Beta | 2 weeks | Dark mode, accessibility audit, FCM, App Distribution beta |
| M6 — Play Store Launch | 1 week | Store listing, privacy policy, production rules, billing alerts |

---

## Open Questions

1. Should the Gemini prompt be tuned for Indian construction standards (IS codes) in v1.0, or remain generic?
2. Will a freemium model be adopted (e.g. 20 free analyses/month)? Which Firebase plan tier gates this?
3. Image retention policy after project archival — how long are files kept in Cloud Storage?
4. Should best-practices checklist content be editable via a Firestore admin console, or updated only via app releases?
5. Is multi-image analysis (3–5 images per request) required in v1.0?
6. Should the Cloud Function use Gemini's file upload API (for larger images) or inline base64 for MVP?
