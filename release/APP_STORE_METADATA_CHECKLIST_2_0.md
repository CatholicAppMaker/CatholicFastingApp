# App Store Metadata Checklist (2.0 Contract)

This file is the source-of-truth mapping between App Store Connect fields and in-app/legal text used by Catholic Fasting App 2.0.

## App Version Metadata

| App Store Connect Field | Source of Truth | Current Value / Rule |
| --- | --- | --- |
| App Name | Product branding | `Catholic Fasting App` |
| Subtitle | Product positioning | `Daily Catholic fasting guidance and tracking` |
| Promotional Text | Seasonal cadence | Rotate by season: Lent, Easter, Ordinary Time, Advent |
| Description | `release/APP_STORE_METADATA_DRAFT.md` | Must mention free core + premium + optional tip |
| Keywords | ASO set | Include catholic fasting, abstinence, lent, friday penance, prayer |
| Support URL | `UIConstants.supportSiteURL` | `https://x.com/CatholicFasting` |
| Privacy Policy URL | `UIConstants.privacyPolicyURL` | `https://x.com/CatholicFasting/status/2026354531273945191` |
| Terms of Use | `UIConstants.termsOfUseURL` + app description | Apple Standard EULA link |
| Copyright | Legal owner | `2026 Kevin Pierce` |

## Subscription Metadata (Auto-Renewable)

| Field | Source of Truth | Rule |
| --- | --- | --- |
| Subscription Group | App Store Connect | Single group only for premium tiers |
| Durations | App Store Connect + `SubscriptionOfferCatalog` | Monthly + Yearly in same group |
| Product IDs | `SubscriptionOfferCatalog.catholicFasting` | Monthly: `com.kevpierce.catholicfasting.premium.monthly.v3`, Yearly: `com.kevpierce.catholicfasting.premium.yearly.v3` |
| Display text in-app | `ContentView+PremiumCompanionSections.swift` | Must show title, duration, billing cadence, and price |
| Legal links in purchase UI | `UIConstants` | Terms + Privacy visible near restore/manage controls |
| Review Notes | ASC version page | Include navigation path to Support & Premium page and premium outcomes |

## In-App Purchase Metadata (Tips)

| Field | Source of Truth | Rule |
| --- | --- | --- |
| Tip product IDs | `MonetizationStore.tipProductIDs` | small, medium, large consumables |
| Positioning | In-app copy | Optional support only, no feature gating |

## Screenshots and Assets

| Field | Rule |
| --- | --- |
| iPhone screenshots | Required set uploaded for selected devices |
| iPad screenshots | 13-inch iPad screenshots uploaded if iPad supported |
| Paywall screenshot | Must include legal links and subscription details visibility |

## Review Compliance Checks

1. Premium monthly + yearly are in one subscription group.
2. In-app purchase flow shows subscription title, duration, billing cadence, and price.
3. Terms and Privacy links are visible and functional in purchase flow.
4. App description references Terms of Use link.
5. Subscription references selected on app version page before submission.
6. No dead links in support/privacy/terms URLs.

## Privacy Contract

1. No third-party analytics SDK.
2. No user-identifiable telemetry upload.
3. Data remains local unless user explicitly exports/share actions.
