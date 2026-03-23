# Catholic Fasting App Pricing Rollout Plan (4.0)

Last reviewed: March 23, 2026

## Goal

Launch 4.0 with the updated premium pricing while keeping the current subscription architecture stable.

Target pricing:
- `Premium Monthly`: `3.99`
- `Premium Yearly`: `19.99`

## 4.0 Positioning

This pricing change is part of the 4.0 release alignment, not a standalone monetization patch.

Why:
- 4.0 now includes a clearer premium product story
- Guided Seasonal Journey makes yearly value easier to justify
- the premium surfaces already present yearly as the primary plan
- the product IDs and subscription group remain unchanged

## Guardrails

Do not change pricing until all of the following are true:
1. The 4.0 build is approved for release.
2. Live subscriptions load correctly in production.
3. Monthly and yearly subscriptions are stable in one group.
4. No subscription ID migration is happening at the same time.

## Operational Steps

1. Confirm StoreKit loads:
   - `com.kevpierce.catholicfasting.premium.monthly.v3`
   - `com.kevpierce.catholicfasting.premium.yearly.v3`
2. Update App Store Connect pricing only:
   - Monthly -> `3.99`
   - Yearly -> `19.99`
3. Keep product IDs and the single subscription group unchanged.
4. Recheck in-app price display on:
   - iPhone `Support & Premium`
   - iPad premium workspace
5. Refresh any screenshots or review notes that show stale prices.
6. Recheck App Store description, subscription descriptions, and review notes for price/duration consistency.

## In-App Positioning

Keep the current offer framing aligned to the 4.0 premium story:
- `Premium Yearly`: best value for users who want one steady formation rhythm through the liturgical year
- `Premium Monthly`: lower-friction way to begin premium support and review habits

## Verification Checklist

1. Premium products still load using the same IDs.
2. Monthly and yearly cards display the new prices correctly.
3. No stale hardcoded prices remain in docs, screenshots, or store configuration files used for review.
4. Yearly remains the primary visual anchor.
5. Review notes explain the Guided Seasonal Journey value story clearly.
