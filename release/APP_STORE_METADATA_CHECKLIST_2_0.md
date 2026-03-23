# App Store Metadata Checklist (4.0 Release Contract)

This file is the source of truth for App Store Connect metadata, subscription presentation, and legal-link alignment for the Catholic Fasting 4.0 release.

## App Version Metadata

| App Store Connect Field | Source of Truth | Current Value / Rule |
| --- | --- | --- |
| App Name | Product branding | `Catholic Fasting` |
| Subtitle | `release/APP_STORE_METADATA_DRAFT.md` | `Catholic Fasting Guidance` |
| Promotional Text | `release/APP_STORE_METADATA_DRAFT.md` | Must mention Canada baseline, multilingual setup, or Guided Seasonal Journey |
| Description | `release/APP_STORE_METADATA_DRAFT.md` | Must reflect current 4.0 behavior, not older 3.x or U.S.-only framing |
| Keywords | ASO set | Include catholic fasting, abstinence, Lent, penance, Canada, prayer |
| Support URL | `UIConstants.supportSiteURL` | `https://x.com/CatholicFasting` |
| Marketing URL | Release metadata | `https://x.com/CatholicFasting` |
| Privacy Policy URL | `UIConstants.privacyPolicyURL` | `https://x.com/CatholicFasting/status/2026354531273945191` |
| Terms of Use | `UIConstants.termsOfUseURL` + description/review context | Apple Standard EULA link |
| Copyright | Legal owner | `2026 Kevin Pierce` |

## Subscription Metadata (Auto-Renewable)

| Field | Source of Truth | Rule |
| --- | --- | --- |
| Subscription Group | App Store Connect | Single group only for premium tiers |
| Durations | App Store Connect + `SubscriptionOfferCatalog` | Monthly + Yearly in the same group |
| Product IDs | `SubscriptionOfferCatalog.catholicFasting` | Monthly: `com.kevpierce.catholicfasting.premium.monthly.v3`, Yearly: `com.kevpierce.catholicfasting.premium.yearly.v3` |
| Launch pricing target | `release/PRICING_ROLLOUT_PLAN_4_0.md` | Monthly `3.99`, Yearly `19.99` |
| Display text in-app | Premium SwiftUI surfaces | Must show title, duration, cadence, and live StoreKit price |
| Legal links in purchase UI | `UIConstants` | Terms + Privacy + Support visible near restore/manage controls |
| Premium story | Premium surfaces + metadata | Guided Seasonal Journey is the anchor premium value story |
| Review Notes | App Store Connect version page | Include navigation path to Support & Premium plus the journey value story |

## In-App Purchase Metadata (Tips)

| Field | Source of Truth | Rule |
| --- | --- | --- |
| Tip product IDs | `MonetizationStore.tipProductIDs` | Small, medium, large consumables |
| Positioning | In-app copy | Optional support only, no feature gating |

## Screenshots and Assets

| Field | Rule |
| --- | --- |
| iPhone screenshots | Required set uploaded for selected devices |
| iPad screenshots | 13-inch iPad screenshots uploaded because iPad is supported |
| Premium screenshot | Must show journey-led premium presentation with legal links visible |
| Localization screenshots | Optional, but any localized screenshot must match actual in-app language behavior |

## Review Compliance Checks

1. Monthly and yearly remain in one subscription group.
2. In-app purchase flow shows plan name, cadence, and live StoreKit pricing.
3. Terms, Privacy, and Support links are visible and functional in purchase flow.
4. App description and review notes no longer describe the app as U.S.-only if Canada baseline support is claimed.
5. No dead or placeholder URLs remain.
6. If pricing is changed at launch, screenshots and visible price references are refreshed before submission.
7. Guided Seasonal Journey is visible and coherent in at least one screenshot/review path.

## Privacy Contract

1. No third-party analytics SDK.
2. No user-identifiable telemetry upload.
3. Data remains local unless the user explicitly exports or opens a support/share action.
