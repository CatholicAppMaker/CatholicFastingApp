# Catholic Fasting App Pricing Rollout Plan (3.3)

Last reviewed: March 10, 2026

## Goal

Move premium pricing to a healthier long-term structure after approval, without adding risk to the current App Review cycle.

Target pricing:

- `Premium Monthly`: `3.99`
- `Premium Yearly`: `19.99`

## Placement

Treat this as a `3.3` monetization refinement, not a `4.0` feature.

Reason:

- pricing calibration is not a new product capability
- it belongs with conversion refinement
- `4.0` stays reserved for materially larger product depth

## Gating Rules

Do not change pricing until all of the following are true:

1. The current app version is approved.
2. Live subscriptions load correctly in production.
3. Monthly and yearly subscriptions are stable in one group.
4. No subscription architecture or product ID migration is happening at the same time.

## Operational Steps

After approval:

1. Confirm StoreKit loads:
   - `com.kevpierce.catholicfasting.premium.monthly.v3`
   - `com.kevpierce.catholicfasting.premium.yearly.v3`
2. Update App Store Connect pricing only:
   - Monthly -> `3.99`
   - Yearly -> `19.99`
3. Keep product IDs and subscription group unchanged.
4. Recheck in-app price display on:
   - iPhone `Support & Premium`
   - iPad premium workspace
5. Refresh any screenshots that show price values.
6. Recheck App Store description, subscription descriptions, and review notes for price/duration consistency.

## In-App Positioning

Keep the current offer framing, but ensure it matches the higher annual value:

- `Premium Yearly`: best value for users who want one steady rhythm through the full liturgical year
- `Premium Monthly`: lower-friction way to begin premium support and review habits

## Verification Checklist

1. Premium products still load using the same IDs.
2. Monthly and yearly cards display the new prices correctly.
3. No stale hardcoded prices remain in tests, screenshots, or store configuration files used for review.
4. Yearly remains the primary visual anchor.
5. UI tests still pass for premium entry points and purchase surfaces.
