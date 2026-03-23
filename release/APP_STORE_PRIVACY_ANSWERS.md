# App Store Connect Privacy Answers (4.0 Draft)

Last reviewed: March 23, 2026
App: Catholic Fasting
Release posture: local-first app with no server-side data collection

Use this as the current copy/paste baseline in App Store Connect. Final legal/compliance sign-off is still your responsibility.

## High-level selection

- Data Used to Track You: `No`
- Data Linked to You: `No`
- Data Not Linked to You: `No`
- Does this app collect data?: `No`

## Why this is the current answer

- User data is stored on-device (`UserDefaults` and local app storage).
- No account system or cloud sync is used.
- Data export/share is user-initiated only.
- No third-party analytics SDK, ad SDK, or tracking code is present.
- No remote telemetry upload is currently part of the app behavior.
- Privacy manifest sets tracking to false and no collected data types.

## If behavior changes later, update App Store privacy immediately

If you add any of the following, these answers likely need to change:

- Remote telemetry uploads (analytics, crash reports, diagnostics) to your backend or a third-party service
- Account creation, login, or cloud storage on your own backend
- Push-token collection tied to users
- Advertising SDKs or cross-app tracking identifiers
- Server-side processing of exports, notes, or fasting history

## In-app privacy copy alignment

The in-app `Data & Privacy` page states:
- what is stored in app
- what may be transmitted (manual export or support/email actions only)
- what is not collected (ad tracking IDs and third-party analytics SDKs)
- user controls for consent and local data management (export/delete)

## Scope note

This draft is intentionally based on current app behavior, not on a U.S.-only assumption. If storefront scope changes, recheck regional compliance requirements separately from these privacy answers.
