#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

EXPECTED_SWIFTFORMAT_VERSION="0.62.1"
EXPECTED_SWIFTLINT_VERSION="0.65.0"
PROJECT="CatholicFastingApp.xcodeproj"
VERSION_CONFIG="Configurations/Version.xcconfig"
SWIFT_TEST_SCRATCH_PATH="${SWIFT_TEST_SCRATCH_PATH:-/private/tmp/CatholicFastingSwiftPM-quality-gate}"

fail() {
	echo "quality-gate: $*" >&2
	exit 1
}

require_command() {
	command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

print_toolchain() {
	echo "==> Toolchain"
	echo "DEVELOPER_DIR=${DEVELOPER_DIR:-$(xcode-select -p)}"
	xcodebuild -version
	swift --version | head -n 1
}

check_tool_versions() {
	local swiftformat_version swiftlint_version
	swiftformat_version="$(swiftformat --version | awk 'NR == 1 { print $1 }')"
	swiftlint_version="$(swiftlint version | awk 'NR == 1 { print $1 }')"
	[[ "${swiftformat_version}" == "${EXPECTED_SWIFTFORMAT_VERSION}" ]] || \
		fail "SwiftFormat ${EXPECTED_SWIFTFORMAT_VERSION} is required; found ${swiftformat_version:-unknown}"
	[[ "${swiftlint_version}" == "${EXPECTED_SWIFTLINT_VERSION}" ]] || \
		fail "SwiftLint ${EXPECTED_SWIFTLINT_VERSION} is required; found ${swiftlint_version:-unknown}"
	echo "SwiftFormat ${swiftformat_version}; SwiftLint ${swiftlint_version}"
}

read_version_source() {
	local key="$1"
	sed -nE "s/^${key}[[:space:]]*=[[:space:]]*([^[:space:]]+).*$/\\1/p" "${VERSION_CONFIG}"
}

check_version_source() {
	local marketing_version build_version duplicates_file
	[[ -f "${VERSION_CONFIG}" ]] || fail "missing ${VERSION_CONFIG}"
	marketing_version="$(read_version_source MARKETING_VERSION)"
	build_version="$(read_version_source CURRENT_PROJECT_VERSION)"
	[[ "${marketing_version}" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]] || fail "invalid marketing version: ${marketing_version:-missing}"
	[[ "${build_version}" =~ ^[1-9][0-9]*$ ]] || fail "invalid build number: ${build_version:-missing}"

	duplicates_file="$(mktemp "${TMPDIR:-/tmp}/cfa-version-literals.XXXXXX")"
	if rg -n '^[[:space:]]*(MARKETING_VERSION|CURRENT_PROJECT_VERSION)[[:space:]]*=' \
		CatholicFastingApp.xcodeproj/project.pbxproj Configurations \
		| rg -v '^Configurations/Version\.xcconfig:' >"${duplicates_file}"; then
		cat "${duplicates_file}" >&2
		rm -f "${duplicates_file}"
		fail "duplicate version literals found outside ${VERSION_CONFIG}"
	fi
	rm -f "${duplicates_file}"
	echo "Version source: ${marketing_version} (${build_version})"
}

check_resolved_versions() {
	local marketing_version build_version config target sdk settings
	local expected_marketing expected_build
	local targets=(
		CatholicFastingApp
		CatholicFastingWidget
		CatholicFastingAppUITests
		CatholicFastingAppStoreKitTests
		CatholicFastingMacApp
		CatholicFastingMacWidget
		CatholicFastingMacAppTests
		CatholicFastingMacAppUITests
	)
	local configurations=(Debug Release)
	expected_marketing="$(read_version_source MARKETING_VERSION)"
	expected_build="$(read_version_source CURRENT_PROJECT_VERSION)"

	for target in "${targets[@]}"; do
		if [[ "${target}" == CatholicFastingMac* ]]; then
			sdk="macosx"
		else
			sdk="iphonesimulator"
		fi
		for config in "${configurations[@]}"; do
			settings="$(xcodebuild -project "${PROJECT}" -target "${target}" -configuration "${config}" -sdk "${sdk}" -showBuildSettings 2>/dev/null)" || \
				fail "could not resolve build settings for ${target} ${config}"
			marketing_version="$(awk -F ' = ' '/^[[:space:]]+MARKETING_VERSION = / { print $2; exit }' <<<"${settings}")"
			build_version="$(awk -F ' = ' '/^[[:space:]]+CURRENT_PROJECT_VERSION = / { print $2; exit }' <<<"${settings}")"
			[[ "${marketing_version}" == "${expected_marketing}" ]] || fail "${target} ${config} resolves MARKETING_VERSION=${marketing_version:-missing}"
			[[ "${build_version}" == "${expected_build}" ]] || fail "${target} ${config} resolves CURRENT_PROJECT_VERSION=${build_version:-missing}"
		done
	done
	echo "Resolved version contract passed for ${#targets[@]} targets across Debug and Release."
}

check_storekit_catalog() {
	local storekit_ids catalog_ids temp_dir
	temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/cfa-quality-gate.XXXXXX")"
	storekit_ids="${temp_dir}/storekit-ids"
	catalog_ids="${temp_dir}/catalog-ids"

	rg -o '"productID"[[:space:]]*:[[:space:]]*"[^"]+"' CatholicFastingApp/Premium.storekit \
		| sed -E 's/.*"productID"[[:space:]]*:[[:space:]]*"([^"]+)"/\1/' \
		| sort -u >"${storekit_ids}"
	rg -o '"com\.kevpierce\.catholicfasting\.[^"]+"' CatholicFastingApp/MonetizationStore.swift \
		| tr -d '"' | sort -u >"${catalog_ids}"
	if ! diff -u "${catalog_ids}" "${storekit_ids}"; then
		rm -rf "${temp_dir}"
		fail "StoreKit fixture product IDs do not match the app catalog"
	fi
	echo "StoreKit SKU contract passed ($(wc -l <"${catalog_ids}" | tr -d ' ') products)."
	rm -rf "${temp_dir}"
}

check_project_and_plists() {
	local file
	for file in \
		CatholicFastingApp.xcodeproj/project.pbxproj \
		CatholicFastingApp/Info.plist \
		CatholicFastingAppUITests/Info.plist \
		CatholicFastingWidget/Info.plist \
		CatholicFastingMacApp/Info.plist \
		CatholicFastingMacAppUITests/Info.plist \
		CatholicFastingMacAppTests/Info.plist \
		CatholicFastingMacWidget/Info.plist \
		CatholicFastingApp/PrivacyInfo.xcprivacy \
		CatholicFastingApp/CatholicFastingApp.entitlements \
		CatholicFastingWidget/CatholicFastingWidget.entitlements \
		CatholicFastingMacApp/CatholicFastingMacApp.entitlements \
		CatholicFastingMacWidget/CatholicFastingMacWidget.entitlements; do
		plutil -lint "${file}" >/dev/null || fail "invalid property list/project file: ${file}"
	done
	echo "Project and plist validation passed."
}

require_command swiftformat
require_command swiftlint
require_command xcodebuild
require_command plutil
require_command swift
require_command rg

print_toolchain
check_tool_versions
check_version_source
check_resolved_versions
check_project_and_plists
check_storekit_catalog

echo "==> Formatting"
swiftformat . --lint --cache ignore

echo "==> SwiftLint"
swiftlint lint --config .swiftlint.yml --strict --no-cache

echo "==> Diff whitespace"
git diff --check

echo "==> Swift package tests"
swift test --scratch-path "${SWIFT_TEST_SCRATCH_PATH}" -Xswiftc -warnings-as-errors

echo "quality-gate: passed"
