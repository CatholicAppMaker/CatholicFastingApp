# Catholic Fasting 5.0 Companion Benchmark

Status: implementation baseline Release anchor: Companion OS

## Benchmark Matrix

Scores use 1-5 where 5 means category-leading execution for the Catholic Fasting product goal.

| Capability            | Zero / Fastic expectation                       | Hallow / Ascension expectation                                  | Current app baseline                                         | 5.0 target                                                                     | Priority |
| --------------------- | ----------------------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------ | -------- |
| First screen clarity  | Live state and next action are obvious          | Daily spiritual path is obvious                                 | Today has strong content but many competing sections         | Companion card answers rule, live state, and next faithful action first        | P0       |
| Live fasting tracker  | Timer, target, live state, recap, low friction  | Prayerful intention can shape the habit                         | Track Fast has controls, presets, live ring, and intentions  | Live state appears on Today and Track Fast with recap and intention continuity | P0       |
| Formation path        | Habit loops and trends keep users returning     | Guided journey, reminders, and journal support spiritual rhythm | Premium journey exists but competes with other surfaces      | Formation card connects season, next action, streak, and recovery              | P0       |
| Onboarding activation | Setup leads to immediate useful tracking        | Trust and personalization are established early                 | Onboarding covers language, eligibility, region, and consent | Adds reminder tier, first intention, and lands on Today payoff                 | P1       |
| Positive streaks      | Continuity is motivating and easy to understand | Habit language stays pastoral                                   | Current rhythm exists with no shame-heavy copy               | Streaks remain as positive continuity, with recovery when broken               | P1       |
| iPad workspace        | Clear high-density productivity layout          | Calm reading and formation at larger size                       | iPad workspaces are already split and useful                 | Today adds three-lane companion triad                                          | P1       |
| Trust and privacy     | Health disclaimers and subscription clarity     | Catholic authority and content credibility                      | Local-only posture and citations are strong                  | Keep rule source, independent notice, and local storage visible                | P1       |
| Premium boundary      | Core tracking works free, advanced depth paid   | Free value with deeper guided subscription                      | Boundary is mostly in Premium surfaces                       | Free gets companion clarity; Premium gets journey, trends, exports, review     | P0       |

## Backlog

- P0: Add companion snapshot model and next-action engine.
- P0: Add Today companion dashboard, live state, and formation cards.
- P0: Preserve excellent free Track Fast core while saving intention into session history.
- P0: Add tracker live-state handling and recap model with pastoral, non-medical language.
- P1: Add onboarding daily rhythm setup for reminder tier, intention, and quote reminder.
- P1: Add iPad Today companion triad.
- P1: Add unit tests for snapshots, tracker recaps, live states, and backward compatibility.
- P2: Continue deeper visual polish after screenshots on iPhone and iPad.
- P2: Extend Mac with a native companion summary after the iPhone/iPad pass stabilizes.

## Guardrails

- Do not copy competitor UI. Use competitors only as quality benchmarks.
- Do not present App Store status, release version, ratings, or competitive scores without verifying
  current sources first. Cached search snippets are not enough; prefer App Store Connect or live
  Apple metadata, and cross-check the repo's `MARKETING_VERSION`.
- Keep streaks positive: continuity, gratitude, and recovery; never spiritual scorekeeping.
- Keep privacy local-first. No account, analytics expansion, or cloud dependency.
- Keep rule sources and pastoral authority visible near user decisions.
