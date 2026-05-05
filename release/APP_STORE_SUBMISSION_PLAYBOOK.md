# App Store Submission Playbook (4.0)

## 1) Prepare Build
1. Run:
   - `swiftformat --lint .`
   - `swiftlint`
   - `swift test`
   - deterministic iPhone UI suite
   - deterministic iPad UI suite
   - Do not run `periphery` during release or cleanup passes unless Kevin explicitly asks for it.
2. Resolve all failures before archive.

## 2) Archive and Upload
1. In Xcode: `Product > Archive`
2. Validate archive
3. Distribute to App Store Connect

## 3) App Store Connect Version Setup
1. Create the new 4.0 version
2. Paste metadata from `release/APP_STORE_METADATA_DRAFT.md`
3. Upload screenshots and current support/privacy URLs
4. Select the uploaded build

## 4) Compliance Inputs
1. Complete App Privacy form using `release/APP_STORE_PRIVACY_QUESTIONNAIRE_DRAFT.md`
2. Confirm age rating and export compliance if prompted
3. Recheck legal links and premium descriptions one last time

## 5) Pricing Alignment
1. Use `release/PRICING_ROLLOUT_PLAN_4_0.md`
2. Keep the existing `v3` product IDs and single subscription group
3. Update App Store Connect pricing at launch only:
   - Monthly: `3.99`
   - Yearly: `19.99`

## 6) Submit and Release
1. Submit for review
2. Choose release mode:
   - `Manual Release` recommended
3. Monitor review feedback, support channels, and launch pricing alignment after approval
