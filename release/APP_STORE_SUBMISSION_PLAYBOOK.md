# App Store Submission Playbook

## 1) Prepare Build
1. Run:
   - `swift test`
   - `xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingApp -destination 'platform=iOS Simulator,name=iPhone 17' build`
   - `./scripts/run_ios_tests.sh`
2. Resolve all failures before archive.

## 2) Archive and Upload
1. In Xcode: Product > Archive
2. Validate archive
3. Distribute to App Store Connect

## 3) App Store Connect Version Setup
1. Create new version
2. Paste metadata from `release/APP_STORE_METADATA_DRAFT.md`
3. Upload screenshots and support/privacy URLs
4. Select uploaded build

## 4) Compliance Inputs
1. Complete App Privacy form using `release/APP_STORE_PRIVACY_QUESTIONNAIRE_DRAFT.md`
2. Confirm age rating and export compliance if prompted
3. Confirm accessibility nutrition labels (if used)

## 5) Submit and Release
1. Submit for review
2. Choose release mode:
   - Manual release recommended for first launch
3. Monitor review feedback and crash/support channels
