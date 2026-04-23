# Native macOS Port Design

## Purpose

Catholic Fasting 4.2 adds a native macOS app and macOS widget to the existing iPhone and iPad product. The Mac app is not Catalyst and is not an iPad layout stretched onto desktop. It is a separate AppKit-backed SwiftUI app target that shares the same core fasting logic, storage models, StoreKit products, and widget snapshot concepts as the iOS app.

The design goal is meaningful feature parity with desktop-native interaction patterns. A Mac user should be able to complete the main fasting, calendar, reminder, premium, export, and intermittent-fast workflows without encountering iPhone-only navigation concepts.

## Product Boundary

- The Mac app ships under the existing Catholic Fasting App Store product as a universal/cross-platform release.
- The native Mac app uses the existing app bundle ID, `com.kevpierce.CatholicFastingApp`, so App Store Connect treats it as the Mac platform for the same product family.
- The Mac widget uses `com.kevpierce.CatholicFastingApp.CatholicFastingMacWidget`.
- The shared app group remains `group.com.kevpierce.CatholicFastingApp`.
- The release remains local-only for 4.2. CloudKit or cross-device sync is intentionally out of scope.

## Target Strategy

The repo keeps a single Xcode project with separate deliverable targets:

- `CatholicFastingApp` is the existing iPhone and iPad target.
- `CatholicFastingWidget` is the existing iOS widget target.
- `CatholicFastingMacApp` is the native macOS app target.
- `CatholicFastingMacWidget` is the macOS widget target.
- `CatholicFastingMacAppTests` hosts model and desktop behavior tests inside the Mac app.
- `CatholicFastingMacAppUITests` covers signed end-to-end desktop UI behavior.

This is intentionally a separate native target instead of adding a Mac destination to the iOS target. The Mac app owns native SwiftUI scenes, `Settings`, commands, a `MenuBarExtra`, AppKit-backed share and subscription surfaces, and desktop-specific accessibility contracts. Keeping that shell separate avoids weakening the iOS app with desktop conditionals and avoids presenting iPhone/iPad layout assumptions on Mac.

## Shared Source Of Truth

The Mac target reuses existing domain code wherever possible:

- fasting observance calculation
- rule settings and regional profiles
- calendar entries and food guidance
- intermittent-fast session and tracker models
- premium journey, planner, analytics, recovery, reflection, and reminder engines
- storage keys and local persistence formats
- StoreKit product identifiers
- widget snapshot models
- localization helpers and formatting support

The Mac target should not fork fasting rules, monetization product IDs, storage schemas, or migration behavior. If a future feature changes the core rule model, update the shared models first and adapt the iOS and Mac shells around them.

## Native Mac Shell

The Mac app is organized around desktop scenes and surfaces:

- `WindowGroup` hosts the main app window.
- `NavigationSplitView` presents a sidebar and detail workspace.
- `Settings` hosts profile, reminder, and privacy/data controls.
- `Commands` expose common workspace and settings actions from the menu bar.
- `MenuBarExtra` replaces iOS Live Activity behavior with desktop status and quick actions.

Primary sidebar workspaces:

- Today
- Fasting Calendar
- Intermittent Fast
- Premium Toolkit
- Guidance

The iOS "More" hub is intentionally not part of the Mac main window. Profile, reminders, privacy, export, and legal/support controls belong in the native Settings window. Premium tools remain a first-class workspace because they are daily planning and review tools, not app configuration.

## Design Reference

The canonical source for macOS design templates and UI kits is Apple's Design Resources page:

- Apple Design Resources: `https://developer.apple.com/design/resources/#macos-apps`
- Relevant section: `macOS`
- Current resources listed there include the macOS 26 UI Kit in Figma and Sketch.

Use Apple's official resources as the highest-priority visual reference for native macOS controls, materials, icon production, typography, and platform fit. Community or copied Figma files are useful working references, but they should not override Apple's current design guidance.

The macOS visual reference for future polish is Apple's macOS 26 community UI Kit copy in Figma:

- File: `macOS-26--Community-`
- File key: `bxCEVRoxnh0CdCa6Ekegr8`
- Verified cover node: `131:8996`
- Verified cover frame: `197:2631`
- Source URL: `https://www.figma.com/design/bxCEVRoxnh0CdCa6Ekegr8/macOS-26--Community-?node-id=131-8996&p=f&t=DnnPiI4cr5ITr39s-0`

The verified node is only the cover artwork, so it should not be used as implementation reference for app surfaces. When applying this kit, select concrete component or layout nodes from the copied Figma file, then use those node-specific URLs as references for controls, materials, sidebar treatment, settings layout, toolbar spacing, and window polish.

For 4.2, this UI Kit is a design reference, not a release blocker. Do not introduce a late visual rewrite during archive prep unless a specific component-level node reveals a clear native macOS correctness issue.

## Surface Ownership

Mac source files are split by responsibility:

- `CatholicFastingMacApp.swift` owns scenes, commands, and top-level app composition.
- `CatholicFastingMacRootView.swift` owns sidebar navigation and main workspace routing.
- `CatholicFastingMacNavigation.swift` owns Mac surface and settings pane enums.
- `CatholicFastingMacModel.swift` owns observable desktop state and dependency setup.
- `CatholicFastingMacModel+Computed.swift` owns derived presentation state.
- `CatholicFastingMacModel+Lifecycle.swift` owns startup, reminders, deep links, settings opening, and refresh actions.
- `CatholicFastingMacModel+Intermittent.swift` owns active-fast actions.
- `CatholicFastingMacModel+Persistence.swift` owns local reset/export/import persistence flows.
- `CatholicFastingMacPlatformServices.swift` owns small Mac-specific service bridges.
- `CatholicFastingMacTodayView.swift` owns the Today workspace.
- `CatholicFastingMacCalendarView.swift` owns the calendar workspace.
- `CatholicFastingMacIntermittentView.swift` owns the intermittent-fast workspace.
- `CatholicFastingMacPremiumView.swift` owns premium planning, reminders, analytics, recovery, journal, export, and household-share surfaces.
- `CatholicFastingMacGuidanceView.swift` owns guidance and regional rationale.
- `CatholicFastingMacSettingsView.swift` owns native Settings and onboarding profile controls.
- `CatholicFastingMacMenuBarView.swift` owns menu bar status and quick actions.
- `CatholicFastingMacViewSupport.swift` owns small reusable Mac card/container helpers.
- `CatholicFastingMacUITestBootstrap.swift` owns deterministic launch state for UI tests only.

This split is the current refactor boundary. Avoid broad rewrites unless a future feature creates real ownership confusion or duplicates shared business logic between iOS and Mac.

## Platform Replacements

Some iOS features map to Mac surfaces instead of being copied directly:

- iOS tab and "More" navigation becomes Mac sidebar plus native Settings.
- iOS Live Activity status becomes `MenuBarExtra` status and quick actions.
- iOS widget code becomes shared snapshot concepts plus a dedicated macOS widget target.
- UIKit haptics are no-op or abstracted through platform services.
- UIKit presentation for share/export becomes an AppKit save/share bridge.
- `UIApplication` subscription-management behavior is behind Mac platform services.
- iOS alternate app icon behavior is not ported to Mac.

These are intentional product decisions, not missing features.

## Deep Links And Routing

The Mac app keeps explicit desktop routing:

- `today` opens the Today workspace.
- `calendar` opens the Fasting Calendar workspace.
- `intermittent` opens the Intermittent Fast workspace.
- `premium` opens the Premium Toolkit workspace.
- `settings` opens the native Settings scene.
- legacy `more` opens native Settings on macOS instead of an arbitrary workspace.

Future deep links should map to real Mac surfaces. Do not reintroduce an iOS-style More hub just to satisfy a legacy URL.

## Persistence And Privacy

Mac V1 persistence is local-only:

- storage keys remain compatible with shared domain models
- widget snapshots use the shared app group in normal app runs
- `DISABLE_APP_GROUP_STORAGE=1` forces process-local widget storage for UI tests
- delete-all actions reset local Mac state and feature stores
- exports are user-initiated
- no analytics or remote account sync are added for 4.2

The release privacy position remains "No data collected" as long as the app stays local-only and no analytics/network collection is introduced.

## StoreKit And Premium

The Mac app uses the existing StoreKit product family:

- `com.kevpierce.catholicfasting.premium.monthly.v3`
- `com.kevpierce.catholicfasting.premium.yearly.v3`
- existing optional tip products

Premium gating should remain shared in meaning across iOS and Mac. The Mac surface exposes high-value premium workflows directly in the Premium Toolkit workspace: adaptive planning, smart reminders, analytics, recovery coaching, journey/checklist, virtue check-ins, export/review summaries, and household share/import.

Debug or UI-test premium overrides must stay inert unless launched through explicit test/debug paths.

## Accessibility And Test Contract

Mac accessibility identifiers are a supported developer interface for critical automation. They are not throwaway labels.

Stable identifier families include:

- `mac.sidebar.*`
- `mac.surface.*.ready`
- `mac.today.*`
- `mac.calendar.*`
- `mac.intermittent.*`
- `mac.premium.*`
- `mac.settings.*`
- `mac.guidance.*`

The supported deterministic launch contract is documented in `docs/macos-testing.md`. Important hooks include:

- `UITEST_MODE=1`
- `DISABLE_APP_GROUP_STORAGE=1`
- `-uitest-reset`
- `-uitest-seed-deterministic`
- `-uitest-seed-missed`
- `-uitest-skip-onboarding`

Production code must not depend on these hooks unless the relevant test/debug environment is explicitly active.

## Release Readiness Contracts

The Mac release is verified through:

- unsigned Mac build
- hosted Mac app tests without signing friction
- signed Mac UI tests on a provisioned machine
- Swift package core tests
- deterministic iPhone and iPad UI tests
- release-contract preflight in `scripts/test-macos.sh`

The Mac release checklist lives in `docs/release-4.2.md`. The testing workflow lives in `docs/macos-testing.md`.

## Non-Goals For 4.2

- no Catalyst app
- no direct-download notarized `.dmg`
- no CloudKit or account sync
- no iOS-style More hub on Mac
- no broad feature-layer refactor just for symmetry
- no decorative parity work that makes the Mac app less native
- no separate GitHub repo or separate App Store product

## Refactor Guidance

Do not refactor the Mac port broadly just because it added surface area. The current architecture is acceptable as long as:

- shared business logic remains centralized
- Mac files are owned by scene, model responsibility, or workspace
- test-only hooks stay isolated
- iOS target behavior stays stable
- the Mac app remains native rather than conditionalizing iOS views into desktop layouts

Consider a larger refactor only if future work creates one of these problems:

- Mac premium/settings files mix unrelated state and become hard to reason about
- iOS and Mac duplicate meaningful business logic instead of sharing engines
- test-only affordances start driving production architecture
- `CatholicFastingMacModel` becomes a bottleneck for unrelated feature ownership
- platform service seams grow beyond small bridges and deserve shared protocols

Until then, favor targeted cleanup over churn.
