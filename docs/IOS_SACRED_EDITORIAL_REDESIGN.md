# iOS Sacred Editorial Redesign

## Direction decision

The June 2026 clean iPhone and iPad captures are the implementation baseline. The redesign uses the
Quiet Liturgical Edition lane: native navigation, editorial hierarchy, restrained seasonal color,
fewer containers, and direct source-backed actions.

| Direction | Task clarity 30 | Accessibility 20 | Native fit 20 | Density 15 | Brand 10 | Risk 5 | Weighted |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Current UI | 8.2 | 7.6 | 8.0 | 7.1 | 9.1 | 8.2 | 7.98 |
| Quiet Liturgical Edition | 9.4 | 9.2 | 9.4 | 9.1 | 9.2 | 8.4 | 9.23 |
| Parish Almanac | 9.1 | 8.9 | 9.3 | 9.5 | 8.3 | 8.0 | 9.02 |
| Seasonal Companion | 8.5 | 8.4 | 8.5 | 7.7 | 9.5 | 7.4 | 8.40 |

Quiet Liturgical Edition improves the weighted baseline by 15.7 percent. It wins because it keeps
the app's strongest Catholic trust signals while fixing nested cards, repeated metadata, first-fold
action visibility, and stretched phone layouts on iPad.

## Second-pass evidence audit

The July 2026 audit treats the earlier 9.24 score as unverified and rerates the implementation from
runtime evidence. Two independent reviews covered real-world journeys and technical risk. Confirmed
P1 findings were fixed before scoring: iPad Calendar transition stalls/crashes, misleading iPad test
readiness markers, incomplete observance localization, an unreliable onboarding switch interaction,
Premium catalog recovery, and StoreKit billing-grace entitlement handling.

The Quiet Liturgical direction remains the right choice. The second pass did not find a systemic
design failure, duplicated root hierarchy, or a reason to return to the previous card-heavy UI.

### July art-direction correction

Runtime inspection exposed a gap that the earlier score missed: the hierarchy was tighter, but
season-wide green chrome made dark appearance feel technological and light appearance still lacked
a strong Catholic anchor. That was a real art-direction failure, not a spacing defect.

The first Roman-missal correction improved Catholic identity but overcorrected toward a fixed
oxblood treatment and did not solve enough dead space. Runtime comparison therefore replaced it
with the Liturgical Parish Desk direction: warm ivory and black ink remain stable, while selection,
primary actions, progress, and a few devotional accents follow the active liturgical season. The
Sacred Heart sits beside the first decision instead of becoming a decorative banner. Turning
seasonal colors off deliberately keeps the Ordinary Time palette active year-round.

The app requests its finished light appearance in both system modes. A future dark appearance will
ship only after it receives its own complete Catholic art direction. WidgetKit surfaces continue to
adapt to required system rendering modes.

| Surface | Task clarity 30 | Accessibility 20 | Native fit 20 | Density 15 | Brand 10 | Risk 5 | Weighted |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Store/current baseline | 8.2 | 7.6 | 8.0 | 7.1 | 9.1 | 8.2 | 7.98 |
| Pre-correction iPhone redesign | 9.4 | 9.0 | 9.3 | 9.0 | 9.1 | 8.4 | 9.16 |
| Pre-correction iPad redesign | 9.3 | 8.9 | 9.3 | 9.1 | 9.0 | 8.2 | 9.11 |
| Pre-correction widgets | 9.2 | 8.4 | 9.1 | 9.2 | 8.8 | 8.2 | 8.93 |
| Pre-correction iOS-family average | — | — | — | — | — | — | 9.07 |

### Liturgical Parish Desk rerating

Fresh deterministic iPhone and iPad captures were inspected after three implementation passes and
compared side by side with the selected direction probe. The iPhone keeps the obligation, action,
and authority source above the fold, with live personal fasting immediately following. The iPad
uses a compact seasonal sidebar and a true guidance/context workspace instead of stretched phone
cards. The final stability loop also removed a SwiftUI 26.5 adaptive-grid crash and redundant
progress accessibility nodes.

| Surface | Task clarity 30 | Accessibility 20 | Native fit 20 | Density 15 | Brand 10 | Risk 5 | Weighted |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Store/current baseline | 8.2 | 7.6 | 8.0 | 7.1 | 9.1 | 8.2 | 7.98 |
| Parish Desk iPhone | 9.4 | 9.2 | 9.3 | 9.2 | 9.7 | 8.6 | 9.30 |
| Parish Desk iPad | 9.4 | 9.2 | 9.3 | 9.4 | 9.7 | 8.6 | 9.33 |
| Audited widgets | 9.2 | 8.4 | 9.1 | 9.2 | 8.8 | 8.2 | 8.93 |
| iOS-family average | — | — | — | — | — | — | 9.19 |

The final 9.19 iOS-family score is 15.2 percent above the store baseline. The iPhone/iPad app alone
averages 9.32, while the unchanged widget score keeps the combined rating conservative. The result
materially improves daily decision-making, platform fit, density, and Catholic identity without
changing business rules, storage, deep links, privacy, or subscription behavior.

### Verification evidence

- 174 XCTest core tests and 2 Swift Testing asset checks pass.
- The UI inventory grew from 94 to 109 tests; the release runner discovers every retained non-screenshot
  test instead of executing the former 41-test subset.
- Focused iPhone checks pass for the first-viewport decision, all root accessibility audits, and the
  seasonal-color ON/OFF contract with Ordinary Time as the year-round fallback.
- Focused iPad checks pass for dashboard structure, maximum accessibility text, all root
  accessibility audits, multilingual workspace cycling, and repeated quick-action cycles.
- The iPad crash loop produced a symbolicated SwiftUI `LazyVGrid` failure on iOS 26.5. Replacing the
  adaptive grid with a deterministic two-column/stack layout removed the crash; the audit and both
  repeated-navigation tests then passed.
- Fresh onboarding, Today, Calendar, Fast, More, Premium recovery, localization, age eligibility,
  maximum Dynamic Type, enhanced accessibility settings, and accessibility audits pass on iPhone.
- The repaired seven-test iPad gate passes on both iPadOS 26.5 and iPadOS 27. It asserts visible feature
  content rather than transparent state markers.
- Measured iPhone root-navigation time averaged 14.273 seconds for a four-surface round trip across
  three iterations, with a 30.45 MB peak and low run-to-run variance.
- Widget tests cover current, legacy, missing, and corrupt local snapshots plus localized fallback copy.
- Separate Address Sanitizer and Thread Sanitizer runs pass all 174 core tests and both Swift Testing
  asset checks without a reported sanitizer defect.
- The optimized iPhoneOS Release app and embedded widget compile and validate successfully. After the
  Apple account was connected, a signed build also installed and launched on the physical iPhone.

### Remaining manual release checks

- Apple account sign-in and a signed physical-device install/launch now succeed. Complete the full
  iPhone 14 Pro journey pass on that signed build before App Store submission.
- Manually confirm VoiceOver reading order, keyboard/pointer behavior, and every supported widget
  rendering mode. Automated semantics, contrast settings, Dynamic Type, and fallback contracts pass,
  but those manual behaviors should not be inferred from simulator screenshots.

## Non-negotiables

- Today answers the obligation and next action before formation or decorative imagery.
- Calendar means Church observances; Fast means optional personal practice.
- Sources, regional context, medical prudence, and local-only privacy remain visible.
- Liquid Glass belongs to navigation and controls, not decorative content containers.
- English, Spanish, and French Canadian strings and stable automation identifiers remain contracts.
