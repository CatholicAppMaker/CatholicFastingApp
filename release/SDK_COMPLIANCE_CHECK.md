# SDK Compliance Check

## Current Project Baseline
- Deployment target: iOS 17.0
- Recent builds use iPhoneSimulator SDK 26.2 (from xcodebuild logs)
- No ad SDKs detected in current codebase

## Apple Timing Requirement
- App submissions after April 28, 2026 must be built with iOS 26 SDK or later.

## Pre-Submission Commands
- `xcodebuild -version`
- `xcodebuild -showsdks | rg -n "iphoneos|iphonesimulator"`
- `xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingApp -destination 'generic/platform=iOS' archive`

## Third-Party SDK Verification
- [ ] Confirm all integrated SDKs (if any) are on Apple's required SDK list compliance path
- [ ] Confirm required privacy manifests/signatures for third-party SDKs

## Release Gate
- [ ] Archive generated with compliant Xcode/iOS SDK
- [ ] No blocked SDK compliance warnings in App Store Connect upload
