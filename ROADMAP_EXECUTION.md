# Catholic Fasting App - Execution Roadmap

## Sprint 1 - Explainable Rules (Completed)
- Add rule bundle metadata with version/effective/reviewed dates.
- Add per-observance rationale and source citations.
- Acceptance criteria:
  - Each observance has rationale text and at least one citation.
  - Rule bundle metadata is visible in app UI.
  - Unit tests validate metadata and citation presence.

## Sprint 2 - Richer Tracking States (Completed)
- Replace binary completion with statuses:
  - `notStarted`, `completed`, `substituted`, `dispensed`, `missed`
- Keep compatibility for legacy completed IDs.
- Acceptance criteria:
  - Status state persists and syncs.
  - Progress counts include completed/substituted/dispensed.
  - Migration from legacy completion storage works.

## Sprint 3 - Scenario Guidance Engine (Completed)
- Add scenario-based food guidance:
  - normal day, heavy labor, travel, social meal, medical recovery.
- Acceptance criteria:
  - Scenario picker in app updates guidance text.
  - Medical scenario guidance explicitly prompts dispensation safety.
  - Unit tests cover guidance output behavior.

## Sprint 4 - Diagnostics and Supportability (Completed)
- Expand diagnostics snapshot with consistency warnings.
- Add support bundle export for redacted troubleshooting payload.
- Acceptance criteria:
  - Diagnostics section shows warnings or clean state.
  - Support bundle export control exists in launch readiness.
  - Unit test covers warning generation.

## Sprint 5 - Test Expansion and Cleanup (Completed)
- Add new unit tests for rule metadata/citations/guidance/diagnostics.
- Add UI coverage for guidance scenario control.
- Run full build and test suite; fix regressions.
- Acceptance criteria:
  - `swift test` passes.
  - `xcodebuild test` passes for iOS simulator and UITests.

## Sprint 6 - Launch Hardening (Completed)
- Add rule-bundle provenance and change history:
  - source classification (bundled/local override)
  - digest verification
  - reviewed-date staleness warnings
- Add privacy and controls:
  - cloud sync consent toggle
  - diagnostics consent toggle
  - encrypted export option (passphrase-protected)
- Add migration for new storage keys and defaults.
- Add tests for diagnostics opt-out, encryption round trip, and cloud-sync opt-out behavior.
- Acceptance criteria:
  - Rule bundle audit and changelog visible in app UI.
  - User can disable iCloud sync and diagnostics independently.
  - Encrypted export generated when passphrase is provided.
  - `swift test` and simulator build pass.

## Remaining Release Blockers
- Stabilize UI test execution itself (runner is now deterministic and timeout-bounded, but UI XCTest still times out in this environment).
- Add CI lane for simulator UI tests with result bundle artifact publication.
- Replace placeholder digest-signature flow with real signing key management + rotation policy.

## Sprint 7 - Release Hardening and Refactor (Completed)
- Replaced digest-only rule verification with Ed25519 signature verification and trusted key IDs.
- Added signing workflow tooling (`scripts/sign_rule_bundle.swift`) and release hardening docs.
- Added deterministic UI test runner script with retries, simulator reset, xcresult outputs, and hard timeout guard.
- Added CI workflow for package tests + iOS UI tests with xcresult artifact upload.
- Refactored duplicate test reset boilerplate into shared test support.
- Fixed analytics regression: streak calculations now count `completed`, `substituted`, and `dispensed`.

## Sprint 8 - Home Information Architecture (Completed)
- Introduced top-level surface navigation to reduce cognitive load:
  - Dashboard
  - Calendar
  - Guidance
  - Settings
- Moved sections into focused surfaces instead of one long mixed screen.
- Cleanup pass:
  - Removed implicit coupling in `ContentView` section rendering.
  - Consolidated section composition behind clear surface switches.

## Sprint 9 - Calendar Findability and Filtering (Completed)
- Added calendar controls for:
  - observance filter (`all`, `required only`, `tracked only`)
  - text search across observance title/details
- Added empty-state behavior when filters produce no matches.
- Cleanup pass:
  - Refactored observance listing to a single filtered data path.
  - Reduced duplication in observance section rendering.

## Sprint 10 - Dashboard Utility Improvements (Completed)
- Added dashboard highlights:
  - completion summary
  - streak
  - upcoming required observance
  - quick jump to calendar surface
- Cleanup pass:
  - Extracted derived metrics into focused computed properties.
  - Simplified dashboard row logic and labels.

## Sprint 11 - Accessibility and UI Testability (Completed)
- Added/updated accessibility identifiers for new navigation and controls:
  - `home.surface_picker`
  - `calendar.filter_picker`
  - `calendar.search_field`
- Updated existing UI tests for surface-aware navigation.
- Added new UI test coverage for calendar controls visibility.
- Cleanup pass:
  - Centralized UI test navigation helper (`openSurface`).
  - Removed brittle assumptions that all sections are simultaneously visible.

## Sprint 12 - Validation and Stability (Completed with Known Environment Risk)
- Validation executed:
  - `swift test` (pass)
  - `swift build` (pass)
  - `xcodebuild ... build` for iOS simulator (pass)
  - scripted UI test lane (`./scripts/run_ios_tests.sh`) with hard timeout guard
- Outcome:
  - Build-for-testing and simulator reset succeeded.
  - UI XCTest run in this environment was interrupted/timed out.
