# App Store Ready Checklist (4.0)

## Engineering (Completed / Verify Again Before Archive)
- [x] Unit tests pass (`swift test`)
- [x] Simulator debug build passes
- [x] Privacy manifest added (`CatholicFastingApp/PrivacyInfo.xcprivacy`)
- [ ] Deterministic iPhone UI suite rerun on final release-candidate build
- [ ] Deterministic iPad UI suite rerun on final release-candidate build
- [ ] Archive build passes from Xcode Organizer

## App Store Connect (Manual)
- [ ] Set `DEVELOPMENT_TEAM` and signing profile in Xcode target settings
- [ ] Archive with `Any iOS Device` destination and upload to App Store Connect
- [ ] Fill version metadata from `release/APP_STORE_METADATA_DRAFT.md`
- [ ] Complete step-by-step submission from `release/APP_STORE_CONNECT_SUBMISSION_CHECKLIST_US.md`
- [ ] Confirm Support URL uses current live link
- [ ] Confirm Privacy Policy URL uses current live link
- [ ] Complete App Privacy form using `release/APP_STORE_PRIVACY_QUESTIONNAIRE_DRAFT.md`
- [ ] Upload screenshots for required device sizes
- [ ] Complete App Review notes (include Canada baseline, multilingual setup, and non-medical disclaimer)
- [ ] Submit first version as Manual Release

## Final Gate Before Submit
- [ ] Verify in-app legal/disclaimer copy one last time
- [ ] Verify English, Spanish, and French Canadian key screens for truncation
- [ ] Verify `Delete All App Data` behavior on a fresh install
- [ ] Validate no placeholder URLs or `3.3` references remain in release copy
- [ ] Validate premium pricing docs align to `3.99 / 19.99`
