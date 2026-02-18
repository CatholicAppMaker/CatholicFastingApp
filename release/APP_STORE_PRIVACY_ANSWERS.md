# App Store Connect Privacy Answers (Draft)

Last reviewed: February 15, 2026
App: Catholic Fasting
Release scope: United States only (not released in EU storefronts)

Use this as your copy/paste baseline in App Store Connect. Final legal/compliance sign-off is still your responsibility.

## High-level selection

- Data Used to Track You: `No`
- Data Linked to You: `No` (current implementation)
- Data Not Linked to You: `No` (current implementation)
- Does this app collect data?: `No` (current implementation)

## Region assumption

- This guidance assumes U.S.-only availability and no EU distribution.
- EU-specific consent frameworks and disclosures are intentionally out of scope for this draft.

## Why this is the current answer

- User data is stored on-device (`UserDefaults` and local app storage).
- Optional iCloud sync uses the user's own iCloud account (`NSUbiquitousKeyValueStore`) and is user-controlled.
- Data export/share is user-initiated only.
- No third-party analytics SDK, ad SDK, or tracking code is present.
- Privacy manifest sets tracking to false and no collected data types.

## If behavior changes later, update App Store privacy immediately

If you add any of the following, you likely need to change the answers above:

- Remote telemetry uploads (analytics, crash reports, diagnostics) to your backend or third-party service.
- Account creation, login, or cloud storage on your own backend.
- Push-token collection tied to users.
- Advertising SDKs or cross-app tracking identifiers.
- Server-side processing of exports, notes, or fasting history.

## In-app privacy copy alignment

The in-app `Data & Privacy` page now states:

- What is stored in app.
- What may be transmitted (optional iCloud sync and manual export/email actions).
- What is not collected (ad tracking IDs and third-party analytics SDKs).
- User controls for consent, iCloud sync, diagnostics, and last sync visibility.
