#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REQUIRE_UI=0
if [[ "${1:-}" == "--require-ui" ]]; then
  REQUIRE_UI=1
fi

UI_DERIVED_DATA="${TMPDIR:-/tmp}/CatholicFastingMacUI-DD"
MAC_DERIVED_DATA="${TMPDIR:-/tmp}/CatholicFastingMac-DD"
XCODE_SCANNER_WATCHDOG_PID=""

start_xcode_scanner_watchdog() {
  if [[ "${DISABLE_XCODE_SCANNER_WATCHDOG:-0}" == "1" ]]; then
    return
  fi

  (
    while true; do
      pkill -9 -f 'com.apple.dt.Xcode.sourcecontrol.WorkingCopyScanner' 2>/dev/null || true
      sleep 10
    done
  ) &
  XCODE_SCANNER_WATCHDOG_PID="$!"
}

stop_xcode_scanner_watchdog() {
  if [[ -n "$XCODE_SCANNER_WATCHDOG_PID" ]]; then
    kill "$XCODE_SCANNER_WATCHDOG_PID" 2>/dev/null || true
  fi
}

trap stop_xcode_scanner_watchdog EXIT

start_xcode_scanner_watchdog

run_step() {
  local label="$1"
  shift
  printf '\n[%s]\n' "$label"
  "$@"
}

reset_xcode_build_services() {
  pkill -9 -x SWBBuildService 2>/dev/null || true
  pkill -9 -x XCBBuildService 2>/dev/null || true
  pkill -9 -f 'com.apple.dt.Xcode.sourcecontrol.WorkingCopyScanner' 2>/dev/null || true
}

run_xcodebuild_step() {
  local label="$1"
  shift

  reset_xcode_build_services
  run_step "$label" xcodebuild "$@"
  reset_xcode_build_services
}

prepare_xcode_scratch_space() {
  reset_xcode_build_services
  rm -rf "$MAC_DERIVED_DATA" "$UI_DERIVED_DATA"
}

assert_file_contains() {
  local file="$1"
  local expected="$2"

  if ! grep -Fq "$expected" "$file"; then
    printf 'Expected %s to contain: %s\n' "$file" "$expected" >&2
    exit 1
  fi
}

assert_plist_value() {
  local plist="$1"
  local key="$2"
  local expected="$3"
  local actual

  actual="$(/usr/libexec/PlistBuddy -c "Print :$key" "$plist")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'Expected %s:%s to be %s, got %s\n' "$plist" "$key" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_plist_array_count() {
  local plist="$1"
  local key="$2"
  local expected="$3"
  local actual

  actual="$(/usr/libexec/PlistBuddy -c "Print :$key" "$plist" | grep -Ec '^[[:space:]]+[0-9A-Za-z_.-]+$' || true)"
  if [[ "$actual" != "$expected" ]]; then
    printf 'Expected %s:%s to contain %s item(s), got %s\n' "$plist" "$key" "$expected" "$actual" >&2
    exit 1
  fi
}

assert_asset_slot_count() {
  local asset_json="$1"
  local idiom="$2"
  local expected="$3"
  local actual

  actual="$(python3 - "$asset_json" "$idiom" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    payload = json.load(handle)
print(sum(1 for image in payload.get("images", []) if image.get("idiom") == sys.argv[2]))
PY
)"

  if [[ "$actual" != "$expected" ]]; then
    printf 'Expected %s to contain %s %s icon slot(s), got %s\n' "$asset_json" "$expected" "$idiom" "$actual" >&2
    exit 1
  fi
}

verify_release_contract() {
  plutil -lint \
    CatholicFastingMacApp/Info.plist \
    CatholicFastingMacWidget/Info.plist \
    CatholicFastingMacApp/CatholicFastingMacApp.entitlements \
    CatholicFastingMacWidget/CatholicFastingMacWidget.entitlements \
    CatholicFastingApp/PrivacyInfo.xcprivacy >/dev/null

  assert_file_contains Configurations/macOS/CatholicFastingMacApp.Debug.xcconfig \
    "PRODUCT_BUNDLE_IDENTIFIER = com.kevpierce.CatholicFastingApp"
  assert_file_contains Configurations/macOS/CatholicFastingMacApp.Release.xcconfig \
    "PRODUCT_BUNDLE_IDENTIFIER = com.kevpierce.CatholicFastingApp"
  assert_file_contains Configurations/macOS/CatholicFastingMacWidget.Debug.xcconfig \
    "PRODUCT_BUNDLE_IDENTIFIER = com.kevpierce.CatholicFastingApp.CatholicFastingMacWidget"
  assert_file_contains Configurations/macOS/CatholicFastingMacWidget.Release.xcconfig \
    "PRODUCT_BUNDLE_IDENTIFIER = com.kevpierce.CatholicFastingApp.CatholicFastingMacWidget"
  assert_file_contains Configurations/macOS/MacSharedDebug.xcconfig "MARKETING_VERSION = 4.2"
  assert_file_contains Configurations/macOS/MacSharedRelease.xcconfig "MARKETING_VERSION = 4.2"
  assert_file_contains Configurations/macOS/MacSharedDebug.xcconfig "CURRENT_PROJECT_VERSION = 10"
  assert_file_contains Configurations/macOS/MacSharedRelease.xcconfig "CURRENT_PROJECT_VERSION = 10"
  assert_file_contains CatholicFastingApp.xcodeproj/project.pbxproj "ASSETCATALOG_COMPILER_APPICON_NAME = MacAppIcon"
  assert_asset_slot_count CatholicFastingApp/Assets.xcassets/MacAppIcon.appiconset/Contents.json "mac" "10"
  assert_asset_slot_count CatholicFastingApp/Assets.xcassets/AppIcon.appiconset/Contents.json "mac" "0"

  assert_plist_value CatholicFastingMacApp/CatholicFastingMacApp.entitlements \
    "com.apple.security.app-sandbox" "true"
  assert_plist_value CatholicFastingMacWidget/CatholicFastingMacWidget.entitlements \
    "com.apple.security.app-sandbox" "true"
  assert_plist_value CatholicFastingMacApp/CatholicFastingMacApp.entitlements \
    "com.apple.security.application-groups:0" "group.com.kevpierce.CatholicFastingApp"
  assert_plist_value CatholicFastingMacWidget/CatholicFastingMacWidget.entitlements \
    "com.apple.security.application-groups:0" "group.com.kevpierce.CatholicFastingApp"
  assert_plist_value CatholicFastingApp/PrivacyInfo.xcprivacy "NSPrivacyTracking" "false"
  assert_plist_array_count CatholicFastingApp/PrivacyInfo.xcprivacy "NSPrivacyCollectedDataTypes" "0"
}

explain_ui_signing_blocker() {
  local log_file="$1"

  printf '\n[macOS UI tests]\n'
  printf 'Signed UI tests could not be prepared on this Mac.\n'
  printf 'Common fix path:\n'
  printf '1. Open Xcode > Settings > Accounts and confirm the Apple Developer team is signed in.\n'
  printf '2. Open the project once in Xcode and let signing register this Mac for:\n'
  printf '   - com.kevpierce.CatholicFastingApp\n'
  printf '   - com.kevpierce.CatholicFastingApp.CatholicFastingMacWidget\n'
  printf '3. Re-run this script, or run:\n'
  printf "   xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppUITests -destination 'platform=macOS' -scmProvider system -allowProvisioningUpdates -allowProvisioningDeviceRegistration build-for-testing\n"
  printf '\nRelevant signing output:\n'
  rg -n 'No Accounts|not registered|No profile|provisioning profile|signing|Apple Development|Communication with Apple' "$log_file" || true
}

run_step "release contract preflight" verify_release_contract

prepare_xcode_scratch_space

run_xcodebuild_step "macOS build" \
  -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacApp -destination 'platform=macOS' -derivedDataPath "$MAC_DERIVED_DATA" -scmProvider system CODE_SIGNING_ALLOWED=NO COMPILER_INDEX_STORE_ENABLE=NO build

run_xcodebuild_step "macOS hosted tests" \
  -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppTests -destination 'platform=macOS' -derivedDataPath "$MAC_DERIVED_DATA" -scmProvider system CODE_SIGNING_ALLOWED=NO COMPILER_INDEX_STORE_ENABLE=NO test

run_step "Swift package tests" swift test

ui_log="$(mktemp)"
reset_xcode_build_services
if xcodebuild \
  -project CatholicFastingApp.xcodeproj \
  -scheme CatholicFastingMacAppUITests \
  -destination 'platform=macOS' \
  -derivedDataPath "$UI_DERIVED_DATA" \
  -scmProvider system \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration \
  COMPILER_INDEX_STORE_ENABLE=NO \
  build-for-testing >"$ui_log" 2>&1; then
  rm -f "$ui_log"
  run_xcodebuild_step "macOS UI tests" \
    -project CatholicFastingApp.xcodeproj -scheme CatholicFastingMacAppUITests -destination 'platform=macOS' -derivedDataPath "$UI_DERIVED_DATA" -scmProvider system COMPILER_INDEX_STORE_ENABLE=NO test-without-building
else
  if (( REQUIRE_UI )); then
    explain_ui_signing_blocker "$ui_log"
    rm -f "$ui_log"
    exit 1
  fi
  explain_ui_signing_blocker "$ui_log"
  printf '\nSkipping signed macOS UI tests. Re-run with `--require-ui` to fail hard when provisioning is unavailable.\n'
  rm -f "$ui_log"
fi
