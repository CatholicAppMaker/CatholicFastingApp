# 4.2 Release Checklist

## Version Alignment

- `CatholicFastingApp`: `MARKETING_VERSION = 4.2`, `CURRENT_PROJECT_VERSION = 10`.
- `CatholicFastingWidget`: `MARKETING_VERSION = 4.2`, `CURRENT_PROJECT_VERSION = 10`.
- `CatholicFastingMacApp`: `MARKETING_VERSION = 4.2`, `CURRENT_PROJECT_VERSION = 10`.
- `CatholicFastingMacWidget`: `MARKETING_VERSION = 4.2`, `CURRENT_PROJECT_VERSION = 10`.
- Test bundles are kept aligned for local developer clarity, but only app and widget targets are App Store deliverables.

If App Store Connect has already consumed build `10` for version `4.2`, bump every deliverable target to the same next build number before archiving.

## Asset Catalogs

- iOS app target uses `AppIcon`.
- Native Mac app target uses `MacAppIcon`.
- `AppIcon.appiconset` should contain only iPhone, iPad, and iOS marketing slots.
- `MacAppIcon.appiconset` should contain the full 10-slot macOS icon set from 16x16 through 512x512 at 1x and 2x.

## App Store Connect

- Add macOS as a platform on the existing Catholic Fasting app record.
- Add macOS to the existing Catholic Fasting App Store record for universal purchase.
- Use the existing app bundle ID for the native Mac app and a unique extension bundle ID for the Mac widget in `Release`:
  - `com.kevpierce.CatholicFastingApp`
  - `com.kevpierce.CatholicFastingApp.CatholicFastingMacWidget`
- Keep the local `Debug` Mac IDs separate so unsigned desktop verification does not trigger iOS shortcut-registration noise:
  - `com.kevpierce.CatholicFastingApp.macdebug`
  - `com.kevpierce.CatholicFastingApp.macdebug.CatholicFastingMacWidget`
- Keep subscriptions in the existing product family:
  - `com.kevpierce.catholicfasting.premium.monthly.v3`
  - `com.kevpierce.catholicfasting.premium.yearly.v3`
- Keep optional tip products unchanged.
- Keep App Privacy as "No data collected" while behavior remains local-only with no analytics.

## Review Notes

- No account is required.
- Fasting profile, journal, checklist, and reminder state are stored locally.
- Exports are user-initiated.
- Premium can be restored and managed from the Premium Toolkit.
- The app is an unofficial Catholic fasting aid and is not medical advice.

## What's New Draft

Catholic Fasting 4.2 adds native Mac support, including a desktop sidebar layout, native Settings window, menu bar fasting status, and a macOS widget. The Mac app includes the same core fasting calendar, today guidance, intermittent fast tracking, and high-value premium planning and review tools as the iPhone and iPad app, adapted for desktop workflows.

## Screenshot Set

- iPhone: Today, Calendar, Intermittent Fast, Premium Toolkit.
- iPad: Today workspace, Fasting Calendar, Premium Toolkit.
- Mac: Today, Calendar, Intermittent Fast, Premium Toolkit, Settings, Menu Bar Extra, Widget.

## Local Gate

```bash
swift test
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingApp -destination 'generic/platform=iOS' build
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingWidget -destination 'generic/platform=iOS' build
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacApp -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppTests -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO test
./scripts/test-macos.sh --require-ui
```

For 4.2, App Shortcuts and App Intents remain iPhone/iPad-only. The native Mac targets explicitly disable App Intents metadata generation and App Shortcuts flexible matching in the shared Mac xcconfigs.

## Release Candidate Gate

- Run deterministic iPhone and iPad UI tests:
  - `./scripts/run_ui_tests_deterministic.sh iphone`
  - `./scripts/run_ui_tests_deterministic.sh ipad`
- Run signed Mac UI tests on the provisioned Mac.
- Smoke test StoreKit sandbox on Mac: product loading, restore, manage subscription, premium-unlocked UI, and reminder gating.
- Archive iOS and macOS app targets from Xcode Organizer.
- Validate both archives before upload.

If Xcode hangs opening the project from Desktop/iCloud file coordination, copy the workspace to a local temporary directory and run the deterministic UI script there. The script resolves the project relative to its own location, so the command works from either the repo or a clean release-candidate copy.
