# Catholic Fasting App 4.0 Product Plan

Last reviewed: March 21, 2026

## Goal

Make `4.0` the first release that is meaningfully larger than the current refinement line by combining:

- full Canada-aware support
- deeper premium formation workflows
- a flagship Guided Seasonal Journey
- Spanish localization quality cleanup
- required French Canadian support

Also carry forward the already-started post-`3.2` work:

- premium presentation refinement
- onboarding/setup improvements
- Track Fast simplification
- iPad interaction hardening

Launch pricing at `4.0`:

- `Premium Monthly`: `3.99`
- `Premium Yearly`: `19.99`

Optional:

- first-party hosted trust/legal/support pages if budget allows

## Product theme

**Canada depth + multilingual onboarding + premium formation depth**

`4.0` should not be framed as a polish release. It should be presented as the version where the app becomes regionally deeper, more multilingual, and spiritually deeper.

## Canada track

### Outcome

Canada is no longer `honest partial` for the scenarios the app explicitly supports.

### Ship

- Canada-aware rules/data where support is claimed
- region-conditioned observance handling at the model layer
- explicit separation of universal, U.S., and Canada guidance
- Canada-aware citations/source labels
- no silent reuse of U.S.-specific behavior in supported Canada flows

### Product surfaces affected

- `Today`
- `Fasting Days`
- food guidance
- Friday guidance
- observance detail / transparency surfaces

## Premium formation track

### Outcome

Premium becomes a stronger long-term formation product, not just a better-presented paid tier.

### Ship

- a flagship **Guided Seasonal Journey** for:
  - Lent
  - Advent
  - Ordinary Time
- weekly journey structure with:
  - one fasting focus
  - one prayer focus
  - one penance/charity focus
  - one short checkpoint/review
- visible journey progress:
  - current week
  - completed actions
  - next action
  - short completion/review state
- deeper review and reflection workflows
- stronger accountability/history synthesis
- more explicit outcome-based premium differentiation

The Guided Seasonal Journey should become the clearest premium anchor feature and the strongest annual-subscription value story.

### Product surfaces affected

- `Support & Premium`
- iPad premium workspace
- review/reflection flows
- planning/history surfaces

## Localization maturity track

### Outcome

The app becomes more credible across North American use by improving existing Spanish quality and adding first-class French Canadian support.

### Ship

- a full Spanish quality pass across:
  - daily guidance
  - food guidance
  - premium surfaces
  - region-aware wording
  - App Store-facing subscription/localization copy where localized
- consistency review so Spanish wording matches the English source-of-truth on:
  - fast vs abstinence vs penance
  - food examples and caveats
  - premium value framing

### Required French Canadian expansion

Ship:

- French Canadian localization for the highest-value surfaces:
  - onboarding / region selection
  - Today
  - Fasting Days
  - food guidance
  - Support & Premium
  - region-aware wording
  - core trust/legal/support copy shown in-app
- keep French Canadian wording aligned to the Canada-specific rule model and citations
- use `fr-CA`, not generic `fr`

Do not treat English fallback as complete French support.

## Optional trust track

If budget allows:

- move privacy/support/terms/help from X-based links to first-party hosted pages
- align in-app legal/support surfaces and App Store metadata to those hosted pages

This is optional and should not delay the region/premium tracks if cost remains a blocker.

## Release bar

Do not call a release `4.0` unless:

1. Canada support is materially deeper than the `3.x` line.
2. Guided Seasonal Journey is present and clearly usable.
3. Premium has at least one clearly deeper long-term workflow than `3.x`.
4. Launch pricing is live at `3.99 / 19.99`.
5. The release story is about new capability, not monetization tuning or UI cleanup.
6. Tests cover the deeper region engine and premium workflow model.
7. Spanish quality is materially improved over the `3.x` line.
8. French Canadian support exists across the defined core flows.

## Test expectations

- unit tests for Canada-aware branching and citation/context correctness
- unit tests for premium program/review models
- content review for Spanish parity on core guidance and premium wording
- content review for French Canadian parity on core guidance and premium wording
- UI tests for:
  - onboarding language switching updates visible setup copy live
  - region selection and region-specific daily guidance
  - Canada-aware observance detail
  - premium Guided Seasonal Journey entry and review surfaces
  - iPhone and iPad premium workflows
- manual review on:
  - iPhone
  - 11-inch iPad
  - 13-inch iPad
  - Spanish localized flows
  - French Canadian localized flows
