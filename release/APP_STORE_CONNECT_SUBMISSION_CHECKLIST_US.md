# App Store Connect Submission Checklist (4.0 North America Baseline)

Last reviewed: March 23, 2026
App: Catholic Fasting
Scope: United States and Canada storefronts if released together; no EU storefront assumptions in this checklist.

Use this checklist in order while preparing the 4.0 App Store Connect submission.

## 1) Create or Open App Record

- [ ] App Name: `Catholic Fasting`
- [ ] Primary Language: `English (U.S.)`
- [ ] Bundle ID: `com.kevpierce.CatholicFastingApp`
- [ ] SKU: `catholic-fasting-ios` (or preferred internal ID)
- [ ] User Access: `Full Access` (or preferred access policy)

## 2) App Information

- [ ] Name: `Catholic Fasting`
- [ ] Subtitle: `Catholic Fasting Guidance`
- [ ] Primary Category: `Lifestyle`
- [ ] Secondary Category: `Reference`
- [ ] Content Rights: confirm ownership of all included assets and copy

## 3) Pricing and Availability

- [ ] App Price: `Free`
- [ ] Availability matches actual supported storefronts for 4.0
- [ ] If Canada is enabled, confirm metadata and review notes no longer describe the app as U.S.-only
- [ ] If EU storefronts stay disabled, keep that consistent across privacy/compliance notes

## 4) App Privacy (Exact Current Posture)

Source of truth: `release/APP_STORE_PRIVACY_ANSWERS.md`

- [ ] Data Used to Track You: `No`
- [ ] Data Linked to You: `No`
- [ ] Data Not Linked to You: `No`
- [ ] Confirm no data collection declarations are added unless app behavior changes

## 5) Version Metadata

Source of truth: `release/APP_STORE_METADATA_DRAFT.md`

- [ ] Promotional Text pasted
- [ ] Description pasted
- [ ] Keywords pasted
- [ ] What's New pasted
- [ ] Support URL set to current live link
- [ ] Marketing URL set to current live link
- [ ] Privacy Policy URL set to current live link
- [ ] Terms of Use context is consistent with Apple Standard EULA usage

## 6) Screenshots

- [ ] Upload required iPhone screenshot sets
- [ ] Upload required iPad screenshot sets
- [ ] Include current 4.0 UI, not older 3.x layouts
- [ ] Include at least one premium screenshot showing Guided Seasonal Journey clearly
- [ ] Ensure no debug text, stale prices, or placeholder copy appears in screenshots

## 7) App Review Information

- [ ] Contact first name/last name/email/phone filled
- [ ] Review notes include:
  - Canada national-baseline guidance support
  - English, Spanish, and French Canadian setup/core flow support
  - Guided Seasonal Journey as the main premium workflow
  - No account required
  - Data remains on-device; exports are user-initiated
- [ ] Sign-in required: `No`

## 8) Export Compliance

- [ ] Answer export compliance truthfully based on current encryption usage
- [ ] If any export compliance form appears, complete it before submit
- [ ] Keep a note of the selections for future updates

## 9) Build and Submit

- [ ] Select the uploaded 4.0 build for this version
- [ ] Resolve all warnings on the version page
- [ ] Submit for Review
- [ ] Release option: `Manual Release`

## 10) Final Pre-Submit Quality Gate

- [ ] App opens cleanly on fresh install
- [ ] `Data & Privacy` page is visible and accurate
- [ ] Consent, export, and delete-all-data flows work end-to-end
- [ ] English, Spanish, and French Canadian key screens show without clipping in the final build
- [ ] No references to placeholder URLs, `3.3`, or U.S.-only framing remain in metadata or review notes unless intentionally limited by storefront scope
