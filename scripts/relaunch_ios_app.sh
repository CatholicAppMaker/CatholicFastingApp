#!/usr/bin/env bash
set -euo pipefail

SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 17}"
APP_NAME="${APP_NAME:-CatholicFastingApp}"
BUNDLE_ID="${BUNDLE_ID:-com.kevpierce.CatholicFastingApp}"
DERIVED_DATA_ROOT="${DERIVED_DATA_ROOT:-$HOME/Library/Developer/Xcode/DerivedData}"
DERIVED_DATA_ROOTS="${DERIVED_DATA_ROOTS:-}"

find_latest_app_bundle() {
  local newest_path=""
  local newest_mtime=-1
  local -a search_roots=()

  if [[ -n "${DERIVED_DATA_ROOTS}" ]]; then
    IFS=':' read -r -a search_roots <<<"${DERIVED_DATA_ROOTS}"
  else
    search_roots=(
      "${DERIVED_DATA_ROOT}"
      "/tmp/CatholicFastingAppDerivedData"
    )
  fi

  for root in "${search_roots[@]}"; do
    [[ -d "${root}" ]] || continue
    while IFS= read -r -d '' candidate; do
      local mtime
      mtime=$(stat -f "%m" "$candidate")
      if (( mtime > newest_mtime )); then
        newest_mtime="$mtime"
        newest_path="$candidate"
      fi
    done < <(
      find "${root}" \
        -type d \
        -path "*/Build/Products/Debug-iphonesimulator/${APP_NAME}.app" \
        ! -path "*Index.noindex*" \
        -print0
    )
  done

  if [[ -z "${newest_path}" ]]; then
    return 1
  fi

  printf "%s\n" "${newest_path}"
}

echo "Booting simulator: ${SIMULATOR_NAME}"
xcrun simctl boot "${SIMULATOR_NAME}" >/dev/null 2>&1 || true
xcrun simctl bootstatus "${SIMULATOR_NAME}" -b

APP_PATH="$(find_latest_app_bundle)" || {
  echo "No valid ${APP_NAME}.app found under configured DerivedData roots." >&2
  echo "Set DERIVED_DATA_ROOTS as colon-separated paths if needed." >&2
  exit 1
}

INFO_PLIST="${APP_PATH}/Info.plist"
if [[ ! -f "${INFO_PLIST}" ]]; then
  echo "Missing Info.plist at ${INFO_PLIST}" >&2
  exit 1
fi

FOUND_BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "${INFO_PLIST}" 2>/dev/null || true)"
if [[ -z "${FOUND_BUNDLE_ID}" ]]; then
  echo "Unable to read bundle identifier from ${INFO_PLIST}" >&2
  exit 1
fi

if [[ "${FOUND_BUNDLE_ID}" != "${BUNDLE_ID}" ]]; then
  echo "Bundle ID mismatch. Expected ${BUNDLE_ID}, found ${FOUND_BUNDLE_ID}" >&2
  exit 1
fi

echo "Using app bundle: ${APP_PATH}"
echo "Bundle ID: ${FOUND_BUNDLE_ID}"

xcrun simctl terminate booted "${BUNDLE_ID}" >/dev/null 2>&1 || true
xcrun simctl install booted "${APP_PATH}"
xcrun simctl launch booted "${BUNDLE_ID}"
