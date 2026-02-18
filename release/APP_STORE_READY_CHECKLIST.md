# App Store Ready Checklist

## Engineering (Completed)
- [x] Unit tests pass (`swift test`)
- [x] Simulator debug build passes
- [x] Simulator release build passes (`-configuration Release`)
- [x] Deterministic UI smoke and deep suites pass (`./scripts/run_ios_tests.sh`)
- [x] App icon asset warnings cleaned
- [x] Privacy manifest added (`CatholicFastingApp/PrivacyInfo.xcprivacy`)

## App Store Connect (Manual)
- [ ] Set `DEVELOPMENT_TEAM` and signing profile in Xcode target settings
- [ ] Archive with `Any iOS Device` destination and upload to App Store Connect
- [ ] Fill version metadata from `release/APP_STORE_METADATA_DRAFT.md`
- [ ] Complete step-by-step submission from `release/APP_STORE_CONNECT_SUBMISSION_CHECKLIST_US.md`
- [ ] Provide Support URL
- [ ] Publish and provide Privacy Policy URL
- [ ] Complete App Privacy form using `release/APP_STORE_PRIVACY_QUESTIONNAIRE_DRAFT.md`
- [ ] Upload screenshots for required device sizes
- [ ] Complete App Review notes (include USCCB source links and non-medical disclaimer)
- [ ] Submit first version as Manual Release

## Final Gate Before Submit
- [ ] Verify in-app legal/disclaimer copy one last time
- [ ] Verify Spanish localization screens for truncation
- [ ] Verify "Delete All App Data" behavior on a fresh install
- [ ] Validate no placeholders in description/keywords/subtitle
