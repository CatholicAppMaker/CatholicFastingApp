# iOS Redesign Test Coverage

This map records the behavioral contracts protected by the iOS release suite. Test
names use the visible product language (`Today`, `Calendar`, `Fast`, and `More`).
Legacy values such as `fasting-days`, `intermittent`, and `fasting_days` remain only
where a deep link or accessibility identifier is an intentional compatibility
contract.

## Release inventory

- `scripts/run_ios_tests.sh` discovers all 97 retained non-screenshot UI tests:
  58 iPhone journeys and 39 iPad journeys.
- `TEST_SUITE=release-phone` runs every discovered iPhone journey.
- `TEST_SUITE=release-ipad` runs every discovered iPad journey.
- `TEST_SUITE=release` runs both inventories.
- `CatholicFastingApp.xctestplan` excludes only the six intentional screenshot
  capture tests.
- Screenshot capture remains available through
  `CatholicFastingAppScreenshots.xctestplan`.

## Feature-to-test map

| Journey or contract | iPhone evidence | iPad evidence | Core or static evidence |
| --- | --- | --- | --- |
| Fresh install and onboarding payoff | Fresh launch reaches populated Today; legal acknowledgment gating; English, Spanish, and French Canadian selection | Fresh launch renders Today workspace; region and localized onboarding | Launch policy, storage reset, corrupted-payload recovery, and localization contract tests |
| Today decision clarity | Obligation, primary action, sacred anchor, authority, next observance, and personal-fast state | Hero, actions, context rail, formation, season context, and quick-action routing | Companion snapshot, observance, regional-rule, and deterministic clock tests |
| Calendar planning | Scope and filter controls; agenda detail, rationale, source, reminder settings; Spanish and Canada variants | Selection/detail, filters, quick dates, future default selection, food-guidance routing | Observance calculator, query, localization, and reminder-planner tests |
| Optional personal Fast | Idle planning; start/cancel; active restoration; end/review note and saved history; locked custom target | Presets, live/planning/history panes, editable start, recap regression, advanced tools | Fast tracker, companion, reminder-policy, persistence-cap, and elapsed-time tests |
| More and secondary destinations | Every hub row opens expected content and returns; setup, profile, guidance, history, privacy, export gating | Every destination remains selected and responsive over repeated cycles | Storage, sync, localization, rule metadata, and history catalog tests |
| Premium boundaries | Plan/value/legal/journey hierarchy; locked tools; unavailable and deterministic offline recovery; unlocked journey; Spanish copy | Plan before legal before journey; restore/legal actions; catalog retry; Spanish copy | Premium catalog, entitlement, subscription health, journey, and recovery tests |
| Deep-link compatibility | All Calendar/Fast/More/Premium aliases route to the expected visible state; invalid URLs remain on Today | Canonical links select the expected workspace | Exact static destination compatibility guard; external-link activation remains a physical-device release check |
| Notifications and recovery | Deterministic denied-permission guidance points users back to Settings; reminder actions remain discoverable | Reminder controls remain reachable in the adaptive workspace | Reminder authorization, scheduling policy, and localized status contracts |
| Accessibility | Separate all-category audit for every root screen; XXXL text; increased contrast, button shapes, and Reduce Motion | Separate all-category audit for every workspace; XXXL text | Localization and accessible-state contracts where applicable |
| Performance and stability | Launch and primary navigation metrics | Workspace-switching metrics and repeated navigation | Bounded tracker persistence and deterministic engine tests |
| Widgets | App-side snapshot creation and corrupted/missing/legacy compatibility | Same local snapshot contract | Widget snapshot status/target, localization, fallback, and rendering-state tests |

## Semantic maintenance rules

- Prefer one end-to-end test per user outcome. Merge a second test when it only
  repeats element-existence assertions from the first.
- Keep separate tests for distinct states such as locked/unlocked, idle/active,
  allowed/denied, missing/corrupt/legacy, and phone/iPad adaptation.
- Avoid tests whose only contract is a decorative container or implementation
  detail. Assert the action, decision, source, or restored state the user receives.
- A conditional assertion that passes when the feature is absent is not coverage.
- Screenshot tests document presentation; release tests protect behavior.

## Simulator stability

The release runner refuses to start when another `xcodebuild` process is active or
when temporary storage has less than 10 GB free. It uses one DerivedData tree,
runs UI tests serially, and requires two consecutive healthy CoreSimulator checks
before touching a device. It shuts down its iPhone and iPad simulators when
finished and removes only temporary DerivedData paths by default. Result bundles
remain available for failure diagnosis.

For a sequence of suites from the same unchanged source, set
`KEEP_DERIVED_DATA=1` on the first run, then use `SKIP_BUILD=1` with the same
`DERIVED_DATA` path. `KEEP_SIMULATORS_RUNNING=1` avoids unnecessary runtime
unmounts between those suites. The Simulator app, if open, must come from the same
Xcode selected by `DEVELOPER_DIR`. These limits prevent disk pressure, redundant
runtime mounting, mismatched Xcode services, and overlapping simulator sessions
from destabilizing Apple system processes during long validation runs.
