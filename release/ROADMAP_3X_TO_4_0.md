# Catholic Fasting App Roadmap: 3.x to 4.0

Last reviewed: March 9, 2026
Current stable baseline: `3.1`

This roadmap defines what should still ship in the `3.x` line versus what should be held for `4.0`.

## Product split

Use this rule:

- `3.x` finishes and hardens the current product
- `4.0` ships only when the app gains a meaningfully larger capability

The current app already has:

- a stable four-tab shell
- iPhone and iPad product surfaces
- strong food guidance as a real use case
- premium subscriptions with a coherent offering
- partial U.S./Canada regional support

That means the remaining `3.x` work should focus on completion, trust, clarity, and conversion rather than new surface area.

## 3.x release track

## 3.2: Daily answer completion

Primary goal: finish the practical “what applies today?” layer.

Ship:

- stronger food-guidance entry points from `Today`, `Fasting Days`, and `Guidance & Rules`
- a compact abstinence explainer that answers whether common foods count as meat
- clearer fast vs abstinence vs penance wording across U.S. and Canada contexts
- a tighter feast/memorial summary when no food restriction applies

Bar:

- users can get the practical food answer quickly
- wording is authoritative but careful
- no additional top-level navigation

## 3.3: Premium conversion and narrow UX polish

Primary goal: improve conversion without changing the product model.

Ship:

- contextual upgrade prompts at real premium boundaries
- one or two stronger premium preview moments
- improved iPhone premium hierarchy to better match the iPad premium surface
- consistent subscription naming and wording across the app and App Store metadata
- one narrow polish pass only on high-traffic screens if needed:
  - `Today`
  - `Fasting Days`
  - `Support & Premium`

Bar:

- no pricing changes
- no new premium tier
- no broad UI overhaul

## 3.4: Hardening and cleanup

Primary goal: reduce future drag before starting a larger major version.

Ship:

- low-value legacy compatibility cleanup where safe
- small file splits only where growth is clearly continuing
- test additions around region-aware guidance and premium entry points
- submission and metadata resilience improvements
- review-surface consistency checks before App Store submission

Bar:

- build and tests remain green
- no user-facing workflow regression
- no speculative architecture churn

## 3.x items to avoid

Do not put these in `3.x` unless they are bug fixes:

- full UI overhaul
- new top-level tab
- watchOS
- Android
- broad international rollout
- second premium tier
- backend account system
- community/social features
- product expansion beyond fasting support

## 4.0 release track

`4.0` should be reserved for a materially larger product step.

Recommended theme:

**Regional depth + formation depth**

That means `4.0` should include one or both of these tracks.

## 4.0 Option A: Real Canada support

Use `4.0` for Canada if the app moves beyond “honest partial.”

Ship:

- true Canada-aware rules/data where support is claimed
- region-conditioned observance handling at the model level
- Canada-specific citations/sources where needed
- no silent fallback to U.S.-specific behavior unless it is labeled as informational

This is the cleanest structural reason to call a release `4.0`.

## 4.0 Option B: Deeper premium formation product

Use `4.0` for premium if the paid product becomes meaningfully deeper.

Ship:

- more structured seasonal programs or formation journeys
- stronger long-term review and reflection workflows
- deeper accountability/history synthesis
- better premium differentiation beyond planning, reminders, and review

This only belongs in `4.0` if premium becomes a broader capability, not just a better sales surface.

## 4.0 Option C: Both together

Best major-version candidate:

- full Canada-aware support
- deeper premium formation workflows
- optional hosted first-party legal/support pages if budget allows by then

That combination is large enough to justify a new App Store narrative and a new major version.

## Test and release expectations

## 3.x

For every `3.x` release:

- build must pass
- package tests must pass
- focused UI tests must pass for:
  - `Today`
  - `Fasting Days`
  - `Track Fast`
  - `Support & Premium`
  - affected iPad workspaces
- manual review must happen on iPhone and iPad for touched flows
- App Store metadata and subscription wording must be rechecked before submission

## 4.0

Before calling a release `4.0`:

- the release must add a clearly bigger product capability
- new tests must cover any deeper region engine or premium workflow layer
- migrations and compatibility must be reviewed explicitly if region logic deepens
- the App Store description and review notes must explain why the release is more than polish

## Working assumptions

Unless product strategy changes, assume:

- the four-tab shell stays intact through the rest of `3.x`
- food guidance remains a first-class use case, but not its own tab
- Canada remains honest-partial through `3.x`
- subscription pricing and tier structure stay stable through `3.x`
- hosted first-party support/legal pages are optional and budget-dependent, not required for `3.x`
