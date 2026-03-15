# Catholic Fasting App 4.0 Product Plan

Last reviewed: March 10, 2026

## Goal

Make `4.0` the first release that is meaningfully larger than the current refinement line by combining:

- full Canada-aware support
- deeper premium formation workflows
- Spanish localization quality cleanup

Optional:

- Canadian French localization if full Canada support lands
- first-party hosted trust/legal/support pages if budget allows

## Product theme

**Regional depth + formation depth**

`4.0` should not be framed as a polish release. It should be presented as the version where the app becomes regionally deeper and spiritually deeper.

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

- structured seasonal programs or formation journeys
- deeper review and reflection workflows
- stronger accountability/history synthesis
- more explicit outcome-based premium differentiation

### Product surfaces affected

- `Support & Premium`
- iPad premium workspace
- review/reflection flows
- planning/history surfaces

## Localization maturity track

### Outcome

The app becomes more credible across North American use by improving existing Spanish quality and only expanding to Canadian French if the Canada track is truly first-class.

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

### Conditional Canada-French expansion

Only if full Canada-aware support is shipping in the same release:

- add French Canadian localization for the highest-value surfaces:
  - onboarding / region selection
  - Today
  - Fasting Days
  - food guidance
  - Support & Premium
- keep French Canadian wording aligned to the Canada-specific rule model and citations
- do not add French if Canada support remains partial

## Optional trust track

If budget allows:

- move privacy/support/terms/help from X-based links to first-party hosted pages
- align in-app legal/support surfaces and App Store metadata to those hosted pages

This is optional and should not delay the region/premium tracks if cost remains a blocker.

## Release bar

Do not call a release `4.0` unless:

1. Canada support is materially deeper than the `3.x` line.
2. Premium has at least one clearly deeper long-term workflow than `3.x`.
3. The release story is about new capability, not monetization tuning or UI cleanup.
4. Tests cover the deeper region engine and premium workflow model.
5. Spanish quality is materially improved over the `3.x` line.
6. French Canadian is included only if Canada support is fully first-class in the same release.

## Test expectations

- unit tests for Canada-aware branching and citation/context correctness
- unit tests for premium program/review models
- content review for Spanish parity on core guidance and premium wording
- UI tests for:
  - region selection and region-specific daily guidance
  - Canada-aware observance detail
  - premium program entry and review surfaces
  - iPhone and iPad premium workflows
- manual review on:
  - iPhone
  - 11-inch iPad
  - 13-inch iPad
  - Spanish localized flows
  - French Canadian localized flows if that track ships
