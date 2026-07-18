# Terra product review

**Scope:** iPhone core flow, reviewed on the CFA iPhone 17 simulator (iOS 26.5) on 2026-07-09.

**Evidence:** Fresh onboarding and live Today were captured directly. The existing `testIPhoneAppCleanQAScreenshots` UI test passed and produced Today, Fasting Days, active Track Fast, Premium, and More captures. The Fasting Days capture was rejected because it contains a black top band; it must be reproduced before it is used as visual evidence.

**Evidence limit:** Dynamic Type and VoiceOver were not exercised live. A one-off Xcode beta `SWBBuildService` crash occurred before compilation; rebuilding with fresh temporary Derived Data then succeeded, so it is not treated as an app failure.

## Verdict

**Needs targeted tightening.** This is a genuinely differentiated, production-quality app—not a generic faith tracker. Its strongest quality is turning Church guidance into a calm, actionable daily decision. Preserve the foundation; use SOL for any information-architecture or visual-system redesign.

| Dimension | Current score | Present-day build bar | Evidence and smallest worthwhile improvement |
| --- | ---: | ---: | --- |
| Overall | 8.1 / 10 | 9.2 / 10 | Strongly branded, calm, and unusually complete. The gap is chiefly first-fold clarity and a few flows that ask users to read too much before acting. |
| Task clarity | 8.2 | 9.2 | Today plainly states the current obligation, the next required day, the source, and one primary action. Keep this decision-first pattern. |
| Visual hierarchy | 8.3 | 9.3 | The warm ivory surface, Catholic-green accents, serif headings, spacious cards, and system glass navigation make a coherent, distinct product. Do not restyle it wholesale. |
| Navigation | 7.6 | 9.0 | The four root tabs are understandable, but Fasting Days and Track Fast need a one-line distinction between Church observances and optional personal practice. More remains a dense six-destination hub. |
| Catholic trust and tone | 9.1 | 9.5 | The Today card cites USCCB norms and communicates obligation without fear or guilt. This source-forward, non-coercive tone is a major strength. |
| Accessibility readiness | 7.6 | 9.2 | The source uses Dynamic Type-aware layouts, labels, hints, and stable identifiers. Large-text and VoiceOver behavior remain unverified; do not claim compliance yet. |
| Premium-path restraint | 7.4 | 9.0 | Premium is correctly kept out of the core tabs, but the Upgrade first fold says "Choose a plan first" while leading with a dense journey card rather than the plan choice. |

## Evidence from the current build

- **Onboarding:** the language-first welcome screen is polished, calm, and trustworthy. The real sacred-space photo supports the subject matter without becoming decorative clutter.
- **Today:** the Companion OS card is exemplary task design: current rule, next date, source, and a single useful action are visible before scrolling.
- **Track Fast:** the active session is legible at a glance, with the ring, remaining time, intention, elapsed time, target, and next step all visible together. The primary end action sits below the initial viewport, so it needs large-text verification.
- **Premium:** the use of a guided seasonal journey makes the value proposition feel pastoral rather than sales-led, but the card is text-dense and plan selection is not visible in the first fold.
- **More:** the six destinations are grouped clearly, use consistent row cards, and make advanced functions discoverable without polluting the core tabs.
- The iPhone shell exposes **Today**, **Fasting Days**, **Track Fast**, and **More** as first-level tabs (`ContentView+RootShell.swift:111-205`). More then groups six destinations and Premium adds five tools (`AppShellTypes.swift:44-84`, `105-142`; `ContentView+RootShell.swift:619-694`).
- Dynamic Type-aware layout, labels, hints, and stable identifiers are implemented across the source (`ContentView.swift:14`; `ContentView+iPadFastingDays.swift:64-67`; `ContentView+CalendarSections.swift:415-442`).

## Do now — targeted, low-risk follow-up

1. **Reproduce Fasting Days before changing it.** Reject the current screenshot-test image because of its black top band; capture the direct rendered screen once the Mac is unlocked. Treat a reproduced band as a release blocker.
2. **Clarify the root-tab distinction.** Add small supporting copy or accessibility hints: Fasting Days is for Church observances; Track Fast is for a personal fast. This preserves the existing navigation.
3. **Align the Premium first fold.** If Upgrade asks users to choose a plan, show the selectable plan/value summary before the long seasonal checklist; keep the pastoral tone and avoid a hard-sell paywall.
4. **Run large-text and VoiceOver verification.** Specifically inspect the Track Fast end action, the floating tab bar, every `minimumScaleFactor` use, focus order, and state-change announcements.
5. **Localize remaining literal accessibility copy** such as `"Selected"` before expanding language support.

## SOL later — deliberate redesign work

- Recompose Today around a single liturgically relevant decision and a small set of context cards, with deeper formation, analytics, and imagery progressively disclosed.
- Revisit the tab model and the distinction between observance planning, personal fast tracking, formation, and account/support areas.
- Evolve the visual system, sacred imagery, motion, and premium narrative only after live screenshots establish the current baseline.

## Runtime verification checklist

- Capture and accept a direct Fasting Days image with no system deep-link confirmation visible.
- Repeat Today, Fasting Days, Track Fast, More, and Premium at an accessibility Dynamic Type size.
- Verify VoiceOver labels, focus order, state-change announcements, and all navigation returns.
- Keep the existing iPhone UI screenshot test as the regression gate; it passed in this audit run.
