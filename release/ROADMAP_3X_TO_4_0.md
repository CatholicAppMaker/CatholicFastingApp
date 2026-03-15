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
- post-approval pricing correction:
  - `Premium Monthly` -> `3.99`
  - `Premium Yearly` -> `19.99`
- one narrow polish pass only on high-traffic screens if needed:
  - `Today`
  - `Fasting Days`
  - `Support & Premium`

Bar:

- pricing changes happen only after:
  - App Review approval is complete
  - live subscriptions load correctly in production
  - the subscription group and product IDs are already stable
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

Use `4.0` when the app moves beyond refinement and gains a broader capability in both of these areas.

### 4.0 Goal

Ship a real major release by expanding what the app can do, not just how polished it feels.

### 4.0 Core tracks

#### 1. Full Canada-aware support

Move Canada from `honest partial` to structurally complete support where claimed.

Ship:

- true Canada-aware rule/data handling at the model layer
- clear separation of universal, U.S.-specific, and Canada-specific observance behavior
- Canada-specific citations and source labeling where needed
- food guidance, Friday guidance, and observance detail that all reflect the selected region truthfully
- no fallback to U.S.-specific behavior unless it is explicitly labeled as informational

#### 2. Deeper premium formation product

Make premium a meaningfully deeper formation product instead of only a stronger paid surface.

Ship:

- structured seasonal programs or formation journeys
- stronger long-term review and reflection workflows
- deeper accountability and history synthesis
- clearer premium differentiation based on outcomes, not just tools
- premium depth without adding a second premium tier by default

#### 3. Optional trust-surface maturity

Only if budget allows during `4.0`:

- move privacy/support/terms/help from X-based links to first-party hosted pages
- align in-app legal/support surfaces and App Store metadata to those hosted pages

#### 4. Localization maturity

Ship:

- a full Spanish localization quality cleanup across core user-facing flows
- Canadian French localization only if full Canada-aware support ships in the same release

Do not add French Canadian in `4.0` if Canada remains partial.

### 4.0 release bar

`4.0` should not ship unless:

- Canada support is no longer described as partial for the scenarios the app claims to support
- premium offers at least one clearly deeper long-term formation workflow than `3.x`
- the App Store narrative can honestly present `4.0` as more than refinement
- tests cover the deeper region engine and premium workflow surfaces
- Spanish quality is materially improved
- French Canadian ships only if Canada support is truly first-class

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
- manual review must include iPhone, 11-inch iPad, and 13-inch iPad for the new regional and premium flows

## Working assumptions

Unless product strategy changes, assume:

- the four-tab shell stays intact through the rest of `3.x`
- food guidance remains a first-class use case, but not its own tab
- Canada remains honest-partial through `3.x`
- subscription tier structure stays stable through `3.x`
- subscription pricing remains stable until approval, then may change in `3.3`
- hosted first-party support/legal pages are optional and budget-dependent, not required for `3.x`
- `4.0` is the first version where full Canada depth and materially deeper premium formation workflows may land together
- Spanish cleanup fits naturally into `4.0`; Canadian French is conditional on full Canada support
