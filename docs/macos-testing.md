# macOS Testing

The native macOS port has two verification lanes:

1. `Hosted macOS tests`
These are always expected to run locally, even on a machine that is not provisioned for Mac app signing.

2. `Signed macOS UI tests`
These are the real desktop end-to-end lane. They require the Apple Developer team to be signed into Xcode and able to provision the Mac app and widget bundle IDs on this Mac.

## One-command local verification

Run:

```bash
./scripts/test-macos.sh
```

That script runs:

```bash
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacApp -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppTests -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
swift test
```

It then attempts the signed UI-test lane with provisioning enabled. If signing is not ready, it prints the likely blocker and skips the UI lane instead of failing with an opaque `xcodebuild` log.

The script uses a dedicated DerivedData directory for the signed UI lane so the runner does not inherit stale unsigned products from the hosted-test lane.

To require the signed UI lane:

```bash
./scripts/test-macos.sh --require-ui
```

## Manual signed UI-test lane

If you want to run the UI suite directly, use:

```bash
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppUITests -destination 'platform=macOS' -derivedDataPath /tmp/CatholicFastingMacUI-DD -allowProvisioningUpdates -allowProvisioningDeviceRegistration build-for-testing
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppUITests -destination 'platform=macOS' -derivedDataPath /tmp/CatholicFastingMacUI-DD test-without-building
```

## Provisioning checklist

If the signed UI lane does not prepare successfully:

1. Open Xcode and confirm the Apple Developer account is signed in under Settings > Accounts.
2. Open the project once in Xcode and let signing resolve Debug for:
   - `com.kevpierce.CatholicFastingApp`
   - `com.kevpierce.CatholicFastingApp.CatholicFastingMacWidget`
   - `com.kevpierce.CatholicFastingMacAppUITests` (non-shipping UI test bundle)
3. If prompted, allow Xcode to register this Mac and refresh development profiles.
4. Re-run `./scripts/test-macos.sh --require-ui`.

## Test-mode contract

The macOS app supports deterministic launch state for tests through launch arguments and `UITEST_MODE=1`.

Supported arguments:

- `-uitest-reset`
- `-uitest-seed-deterministic`
- `-uitest-seed-missed`
- `-uitest-skip-onboarding`

Supported environment variables:

- `UITEST_MODE=1`
- `DISABLE_APP_GROUP_STORAGE=1`
- `UITEST_REGION_PROFILE=<raw value>`
- `UITEST_LANGUAGE_MODE=<raw value>`
- `UITEST_PREMIUM_UNLOCKED=1`

These hooks are shared with the desktop test suite and should be treated as a supported developer interface, not throwaway test-only behavior.

`DISABLE_APP_GROUP_STORAGE=1` forces widget snapshot reads and writes to stay local to the app process instead of touching the shared app-group container. The Mac UI tests set this automatically so desktop verification does not trigger shared-container privacy prompts.
