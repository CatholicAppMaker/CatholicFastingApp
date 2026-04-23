# macOS Testing

The native macOS port has two verification lanes:

1. `Hosted macOS tests`
These are always expected to run locally, even on a machine that is not provisioned for Mac app signing.

2. `Signed macOS UI tests`
These are the real desktop end-to-end lane. They require the Apple Developer team to be signed into Xcode and able to provision the Mac app and widget bundle IDs on this Mac.

For 4.2, App Shortcuts and App Intents remain `iPhone/iPad-only`. The Mac targets opt out of shortcut metadata generation and flexible matching so local Mac verification stays focused on the native desktop app surface.

## One-command local verification

Run:

```bash
./scripts/test-macos.sh
```

That script runs:

```bash
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacApp -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppTests -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO test
swift test
```

It then attempts the signed UI-test lane with provisioning enabled. If signing is not ready, it prints the likely blocker and skips the UI lane instead of failing with an opaque `xcodebuild` log.

The script uses a dedicated DerivedData directory for the signed UI lane so the runner does not inherit stale unsigned products from the hosted-test lane.
It also strips the known Apple `linkd.autoShortcut` hosted-test chatter from the canonical output so local runs stay focused on actionable failures.

To require the signed UI lane:

```bash
./scripts/test-macos.sh --require-ui
```

## Manual signed UI-test lane

If you want to run the UI suite directly, use:

```bash
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppUITests -destination 'platform=macOS,arch=arm64' -derivedDataPath /tmp/CatholicFastingMacUI-DD -allowProvisioningUpdates -allowProvisioningDeviceRegistration build-for-testing
xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppUITests -destination 'platform=macOS,arch=arm64' -derivedDataPath /tmp/CatholicFastingMacUI-DD test-without-building
```

## Provisioning checklist

If the signed UI lane does not prepare successfully:

1. Open Xcode and confirm the Apple Developer account is signed in under Settings > Accounts.
2. Open the project once in Xcode and let signing resolve Debug for:
   - `com.kevpierce.CatholicFastingApp.macdebug`
   - `com.kevpierce.CatholicFastingApp.macdebug.CatholicFastingMacWidget`
   - `com.kevpierce.CatholicFastingMacAppUITests` (non-shipping UI test bundle)
3. If prompted, allow Xcode to register this Mac and refresh development profiles.
4. Re-run `./scripts/test-macos.sh --require-ui`.

## UI runner doctor

Use this sequence when the signed UI lane fails or times out while enabling automation mode:

1. In Xcode, open `Settings > Accounts` and confirm team `22L6MB4Z6V` is signed in.
2. Open the project, select the `CatholicFastingMacApp` scheme, and confirm Debug automatic signing resolves for:
   - `com.kevpierce.CatholicFastingApp.macdebug`
   - `com.kevpierce.CatholicFastingApp.macdebug.CatholicFastingMacWidget`
3. Open `System Settings > Privacy & Security > Accessibility` and make sure `Xcode` is allowed.
4. If you run `xcodebuild` from Codex or Terminal instead of pressing Run in Xcode, also allow that launcher app under `Accessibility`.
5. Open `System Settings > Privacy & Security > Automation` and allow `Xcode`, `Codex`, or your terminal app to control `System Events` if macOS asks.
5. Quit Xcode and stop any leftover test runners:
   ```bash
   pkill -9 -x Xcode || true
   pkill -9 -x xctest || true
   pkill -9 -x XCTRunner || true
   pkill -9 -x CatholicFastingMacApp || true
   rm -rf /tmp/CatholicFastingMacUI-DD
   ```
6. Reopen Xcode once so signing state refreshes, then rerun:
   ```bash
   ./scripts/test-macos.sh --require-ui
   ```

If the first rerun succeeds, run it a second time immediately. The lane is only considered stable when both back-to-back runs pass.

If the script reports `UI scripting enabled: false`, the machine-level Accessibility gate is still off. The signed UI lane will keep failing with foreground-activation issues until that is enabled.

If you intentionally keep macOS Accessibility / UI scripting disabled on a locked-down machine, treat the signed Mac UI lane as unavailable on that machine rather than as a release-blocking repo failure. In that case, use the hosted Mac tests plus manual Mac smoke testing as the local release gate, and run the signed UI lane only on a provisioned Mac where Accessibility has been granted on purpose.

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
