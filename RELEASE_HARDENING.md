# Release Hardening

## 1) Deterministic iOS Test Execution

- Use `scripts/run_ios_tests.sh` for simulator UI test execution.
- The script:
  - performs `build-for-testing`
  - resets simulator state per Release test shard
  - runs each Release UI test in its own `test-without-building` process with an
    explicit `.xcresult` bundle
  - enforces a wall-clock watchdog per Release test (`RELEASE_TEST_TIMEOUT_SECONDS`,
    default 90 seconds) and kills the entire xcodebuild process group on expiry
  - checks CoreSimulator connectivity and `/tmp` free space before and after
    each Release shard
  - allows failed UI runs to be retried with `MAX_ATTEMPTS`
- The current defaults are `MAX_ATTEMPTS=1` and 600 seconds per phone/iPad
  lane. A pathological UI wait therefore fails its individual shard quickly
  instead of consuming the whole lane budget.
- Release simulator resolution prefers the stable `iOS-26-5` runtime. Override
  this with `RELEASE_IOS_RUNTIME` or provide `PHONE_SIMULATOR_ID` and
  `IPAD_SIMULATOR_ID` explicitly. Performance tests are excluded from the
  general Release inventory by default; opt in with
  `RELEASE_INCLUDE_PERFORMANCE=1` for a separately bounded run.
- The default suite is `release`, which runs the separate `release-phone` and
  `release-ipad` inventories. Available suites are `smoke`, `deep`, `ipad`,
  `release`, `release-phone`, `release-ipad`, `storekit-ui`, and `storekit`.
  `storekit-ui` runs the rendered catalog/price UI test; `storekit` runs the
  hosted same-process StoreKit test target. StoreKit is deliberately separate
  because both lanes are pinned to Xcode 26.2.

Run:

```bash
chmod +x scripts/run_ios_tests.sh
./scripts/run_ios_tests.sh
```

## 2) StoreKit Local Fixture and Sandbox Verification

The development scheme, `CatholicFastingApp`, attaches the canonical
`CatholicFastingApp/Premium.storekit` fixture to its Run and Test actions. This
is the only StoreKit fixture; there is no root-level duplicate. Use the
development scheme for local StoreKit testing of the monthly and yearly
subscriptions and the three optional tips. The fixture is intentionally not
part of the production archive path.

The `CatholicFastingApp-Sandbox` scheme has no local StoreKit configuration.
Use it for a signed device build against App Store sandbox products configured
in App Store Connect. Use TestFlight for the final end-to-end verification of
product loading, purchase, entitlement persistence, restore, cancellation, and
subscription management. Local StoreKit verifies app behavior against the
fixture; it does not verify App Store Connect product configuration, review
availability, or production pricing.

For Apple's distinction between local StoreKit testing and sandbox testing, see
[Testing in-app purchases with sandbox](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox).

The app's deterministic Premium unlock path is opt-in only. It is enabled by
`UITEST_MODE=1` or an explicit `UITEST_PREMIUM_UNLOCKED` environment override.
A normal Debug simulator launch therefore exercises StoreKit instead of
silently granting Premium access.

The fast presence/layout UI tests use the explicit `UITEST_MODE=1` override.
StoreKit behavior tests must launch without that override and use the local
fixture. StoreKit tests reset and clear their transaction state independently;
they run in dedicated `TEST_SUITE=storekit-ui` and `TEST_SUITE=storekit` lanes,
separate from the fast entitlement-override smoke lane. CI invokes both lanes
through the pinned `ios-storekit` job and uploads their StoreKit `.xcresult`
bundles.

The current StoreKit UI coverage includes catalog prices. The hosted StoreKit
coverage includes monthly/yearly purchase and relaunch persistence, restore
with and without transactions, pending/cancelled handling, and
`testCatalogFailurePreservesExistingEntitlement`, which
also launches with an existing entitlement and an offline catalog state, then
asserts that Premium remains active. This documents regression coverage, not a
passing run. The separate core policy regression,
`testIOS26AccessibilityArtifactPolicyIsNarrow`, verifies that the known iOS 26
accessibility-artifact exception remains narrow and does not apply to iOS 27 or
unrelated audit types.

## 3) Signed Rule Bundle Workflow

- Rule bundle verification now uses Ed25519 signatures with trusted key IDs.
- Signing metadata is embedded in the rule bundle JSON under `signing`.
- To sign a bundle:

```bash
export RULE_BUNDLE_PRIVATE_KEY_B64="<ed25519-private-key-base64>"
export RULE_BUNDLE_KEY_ID="release-2026-q1"
xcrun swift scripts/sign_rule_bundle.swift unsigned-rule-bundle.json signed-rule-bundle.json
```

- The app verifies:
  - algorithm is `ed25519`
  - key ID exists in trusted key map
  - signature over canonical payload (`metadata` + `changes`, sorted keys)

## 4) Productization Controls

- Legal acknowledgment is required before scheduling reminders and exports.
- Export/support bundles now include legal acceptance timestamps and consent flags.
- Critical user controls include accessibility hints and identifiers for UI testing.

## 5) Accessibility and Localization Production Pass

- Completed bilingual (English/Spanish) Settings copy for profile, regional norms, privacy, export,
  and data management actions.
- Added accessibility hints on consent/export controls to improve VoiceOver clarity.
- Added readiness checklist in `ACCESSIBILITY_LOCALIZATION_READINESS.md`.

## 6) Launch Operations Workflows

- Added legal/compliance package in `LEGAL_COMPLIANCE_PACKAGE.md`.
- Added launch runbook, incident tiers, and support SLA in `LAUNCH_OPERATIONS_RUNBOOK.md`.
- Defined pre-launch and launch-day validation sequence for engineering + QA.

## 7) App Store Submission Assets

- Added submission drafts under `release/`:
  - `APP_STORE_METADATA_DRAFT.md`
  - `APP_STORE_PRIVACY_QUESTIONNAIRE_DRAFT.md`
  - `APP_REVIEW_PRECHECK.md`
  - `APP_STORE_SUBMISSION_PLAYBOOK.md`
  - `SDK_COMPLIANCE_CHECK.md`
  - `PRIVACY_POLICY_TEMPLATE.md`
  - `APP_STORE_READY_CHECKLIST.md`

## 8) Version 6 Release Acceptance Checklist

Version 6 currently resolves from
`Configurations/Version.xcconfig`:

```text
MARKETING_VERSION = 6.0
CURRENT_PROJECT_VERSION = 5
```

The quality gate is the single checked-in command:

```bash
./scripts/quality-gate.sh
```

It checks the approved SwiftFormat `0.62.1` and SwiftLint `0.65.0` versions,
the shared version source and cross-target resolution, project/plist validity,
StoreKit SKU/fixture parity, formatting, strict SwiftLint, whitespace, and
strict Swift package tests. The same gate is invoked by the source-quality CI
job. This document records the required checks; it does not claim a pass
unless a dated command result is recorded separately.

Before calling Version 6 release-ready, check off every item below and attach
the corresponding evidence:

- [x] Typed Premium navigation exposes Planner, Reminders, Analytics, Journal,
  and Export, with the Premium route UI coverage present.
- [x] The canonical fixture is `CatholicFastingApp/Premium.storekit`; the
  development and sandbox schemes are distinct.
- [x] The Premium override is explicit and opt-in; ordinary Debug simulator
  launches do not receive an unconditional Premium unlock.
- [x] Version settings inherit from `Configurations/Version.xcconfig` and
  use future-safe syntax/consistency checks rather than fixed `6.0 (5)` test
  assertions.
- [x] Opaque phone navigation and tab-bar chrome is implemented in the design
  system.
- [x] StoreKit has dedicated `TEST_SUITE=storekit-ui` and
  `TEST_SUITE=storekit` script lanes and a pinned CI job; StoreKit tests are
  excluded from the general release inventory.
- [x] Local UI coverage includes the offline existing-entitlement regression
  and the narrow iOS 26 accessibility-artifact policy test.
- [ ] `./scripts/quality-gate.sh` passes on the release machine with its
  output retained.
- [ ] A passing StoreKit-lane result is retained, covering catalog loading,
  monthly/yearly purchase, pending/cancelled handling, relaunch persistence,
  restore with and without transactions, and offline preservation of an
  existing entitlement. No pass is claimed here without the retained result.
- [ ] The fast smoke, deep, iPad, and release-phone/release-iPad simulator
  suites pass; retain their `.xcresult` bundles. Do not infer this from a
  build-only result.
- [x] The screenshot UI-test file contains retained XCTest-artifact coverage
  for scrolled Fast, Calendar, and More/Premium on phone and iPad, plus the
  Premium Planner on phone. This is source-level capture coverage and is not a
  claim that a simulator capture passed.
- [ ] Capture compact-iPhone and iPad screenshots from the current build at
  the top, middle, and bottom of Fast, Calendar, More/Premium, and each
  reachable Premium tool. Manually inspect that no underlying text ghosts
  through the navigation or tab chrome. The screenshot scripts are
  `scripts/generate_app_store_screenshots.sh` with `--iphone-only` and
  `--ipad-only`; screenshots are evidence only after capture succeeds.
- [ ] Run the signed `CatholicFastingApp-Sandbox` build on a physical device
  or TestFlight with real App Store Connect products. Verify product loading,
  purchase, entitlement persistence, restore, cancellation/pending behavior,
  and subscription management. Local StoreKit cannot substitute for this
  check.
- [ ] Confirm the worktree is clean after validation, then make the release
  commit separately.
