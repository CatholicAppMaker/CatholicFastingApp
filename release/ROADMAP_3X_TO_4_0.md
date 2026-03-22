# Catholic Fasting App Roadmap: 3.x to 4.0

Last reviewed: March 21, 2026
Current stable baseline: `3.2 (10)`

This roadmap defines the approved `3.2` baseline and the major-version work now reserved for `4.0`.

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

That means the current refinement line is effectively complete. The previously discussed `3.3` premium/onboarding work is now absorbed into `4.0` instead of shipping as a separate point release.

## 3.x release track

## 3.2: Approved baseline

Primary goal: finish the practical “what applies today?” layer and stabilize the current shell.

Ship:

- stronger food-guidance entry points from `Today`, `Fasting Days`, and `Guidance & Rules`
- a compact abstinence explainer that answers whether common foods count as meat
- clearer fast vs abstinence vs penance wording across U.S. and Canada contexts
- a tighter feast/memorial summary when no food restriction applies

Bar:

- users can get the practical food answer quickly
- wording is authoritative but careful
- no additional top-level navigation
- this is the final approved refinement baseline before the next major release

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

`4.0` is now the next planned release and should be treated as a materially larger product step.

Recommended theme:

**Canada depth + multilingual onboarding + premium formation depth**

`4.0` should combine the already-started premium/onboarding refinements with a real Canada-aware product step and a stronger premium journey.

### 4.0 Goal

Ship a real major release by expanding what the app can do, not just how polished it feels.

This release should combine:

- the already-completed post-`3.2` refinement work:
  - premium surface cleanup
  - setup/onboarding improvements
  - Track Fast simplification
  - iPad interaction hardening
- full Canada-aware support
- a flagship premium formation feature
- multilingual North American support
- launch pricing of:
  - `Premium Monthly` -> `3.99`
  - `Premium Yearly` -> `19.99`

### 4.0 Core tracks

#### 1. Full Canada-aware support

Move Canada from `honest partial` to structurally complete support where claimed.

Ship:

- true Canada-aware rule/data handling at the model layer
- clear separation of universal, U.S.-specific, and Canada-specific observance behavior
- Canada-specific citations and source labeling where needed
- food guidance, Friday guidance, and observance detail that all reflect the selected region truthfully
- no fallback to U.S.-specific behavior unless it is explicitly labeled as informational

#### 2. Guided Seasonal Journey and deeper premium formation

Make premium a meaningfully deeper formation product instead of only a stronger paid surface.

Ship:

- a flagship **Guided Seasonal Journey** for at least:
  - Lent
  - Advent
  - Ordinary Time
- weekly seasonal guidance instead of static one-off prompts
- each journey week should include:
  - one fasting focus
  - one prayer focus
  - one penance/charity focus
  - one short checkpoint/review
- journey progress should show:
  - current week
  - completed actions
  - next action
  - a short completion/review state
- stronger long-term review and reflection workflows
- deeper accountability and history synthesis
- clearer premium differentiation based on outcomes, not just tools
- premium depth without adding a second premium tier by default

The seasonal journey should become the clearest “why premium” story, especially for yearly subscribers.

#### 3. Optional trust-surface maturity

Only if budget allows during `4.0`:

- move privacy/support/terms/help from X-based links to first-party hosted pages
- align in-app legal/support surfaces and App Store metadata to those hosted pages

#### 4. Localization maturity

Ship:

- a full Spanish localization quality cleanup across core user-facing flows
- required French Canadian support for the highest-value user-facing flows:
  - onboarding/setup
  - Today
  - Fasting Days
  - food guidance
  - Support & Premium
  - region-aware wording
  - core trust/legal/support copy shown in-app

Default:

- use `fr-CA`, not generic `fr`
- French Canadian is a required `4.0` deliverable, not a conditional bonus
- core flows must be truly localized; English fallback is not “done”

### 4.0 release bar

`4.0` should not ship unless:

- Canada support is no longer described as partial for the scenarios the app claims to support
- the Guided Seasonal Journey is present and clearly usable
- premium offers at least one clearly deeper long-term formation workflow than `3.x`
- launch pricing is live at `3.99 / 19.99`
- the App Store narrative can honestly present `4.0` as more than refinement
- tests cover the deeper region engine and premium workflow surfaces
- Spanish quality is materially improved
- French Canadian support exists across the defined core flows

## Test and release expectations

## 3.x

For the approved `3.2` baseline and any emergency `3.x` patches:

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
- new tests must cover the deeper region engine and Guided Seasonal Journey workflow layer
- migrations and compatibility must be reviewed explicitly if region logic deepens
- the App Store description and review notes must explain why the release is more than polish
- manual review must include iPhone, 11-inch iPad, and 13-inch iPad for the new regional, premium, and localized flows

## Working assumptions

Unless product strategy changes, assume:

- the four-tab shell stays intact through `4.0`
- food guidance remains a first-class use case, but not its own tab
- the approved `3.2 (10)` build is the stable release baseline
- the former `3.3` premium/onboarding work is now part of `4.0`
- subscription tier structure stays stable through `4.0`
- pricing changes at `4.0` launch, not earlier
- hosted first-party support/legal pages remain optional and budget-dependent
- `4.0` is the release where full Canada depth, Guided Seasonal Journey, Spanish cleanup, and French Canadian support land together
