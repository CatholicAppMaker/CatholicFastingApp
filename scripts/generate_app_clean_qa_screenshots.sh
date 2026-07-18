#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_ROOT="$ROOT_DIR/release/qa-screenshots/app-clean"
RESULTS_DIR="$ROOT_DIR/build/app-clean-qa-screenshots"
SCREENSHOT_CONFIG_PATH="/tmp/catholic-fasting-app-store-screenshot-config.json"
IPHONE_DEVICE="${IPHONE_DEVICE:-}"
IPAD_DEVICE="${IPAD_DEVICE:-}"
CAPTURE_IPHONE=1
CAPTURE_IPAD=1

usage() {
	cat <<'USAGE'
Capture raw app-wide Catholic clean QA screenshots.

Usage:
  scripts/generate_app_clean_qa_screenshots.sh [options]

Options:
  --iphone-only           Capture only the iPhone app-clean QA set.
  --ipad-only             Capture only the iPad app-clean QA set.
  --output DIR            Screenshot output root. Defaults to release/qa-screenshots/app-clean.
  --iphone-device NAME    Override the iPhone simulator name.
  --ipad-device NAME      Override the iPad simulator name.
  -h, --help              Show this help.

Environment overrides:
  IPHONE_DEVICE, IPAD_DEVICE
  SCREENSHOT_RESET_SIMULATOR=0   Reuse simulator state instead of erasing before capture.
USAGE
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--iphone-only)
		CAPTURE_IPHONE=1
		CAPTURE_IPAD=0
		shift
		;;
	--ipad-only)
		CAPTURE_IPHONE=0
		CAPTURE_IPAD=1
		shift
		;;
	--output)
		OUTPUT_ROOT="$2"
		shift 2
		;;
	--iphone-device)
		IPHONE_DEVICE="$2"
		shift 2
		;;
	--ipad-device)
		IPAD_DEVICE="$2"
		shift 2
		;;
	-h | --help)
		usage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 2
		;;
	esac
done

require_tool() {
	if ! command -v "$1" >/dev/null 2>&1; then
		echo "Missing required tool: $1" >&2
		exit 1
	fi
}

run_with_timeout() {
	local timeout_seconds="$1"
	shift
	python3 - "$timeout_seconds" "$@" <<'PY'
import subprocess
import sys

timeout_seconds = int(sys.argv[1])
command = sys.argv[2:]
process = subprocess.Popen(command)
try:
    process.wait(timeout=timeout_seconds)
except subprocess.TimeoutExpired:
    process.terminate()
    try:
        process.wait(timeout=20)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=20)
    sys.exit(124)
sys.exit(process.returncode)
PY
}

simulator_exists() {
	xcrun simctl list devices available | grep -F "$1 (" >/dev/null
}

simulator_id() {
	xcrun simctl list devices available \
		| sed -n "s/^[[:space:]]*$1 (\([0-9A-F-]*\)) .*/\1/p" \
		| head -1
}

choose_simulator() {
	local explicit="$1"
	shift
	if [[ -n "$explicit" ]]; then
		if ! simulator_exists "$explicit"; then
			echo "Simulator '$explicit' is not available." >&2
			exit 1
		fi
		printf '%s\n' "$explicit"
		return
	fi

	local candidate
	for candidate in "$@"; do
		if simulator_exists "$candidate"; then
			printf '%s\n' "$candidate"
			return
		fi
	done

	echo "None of the requested simulators are available: $*" >&2
	exit 1
}

write_capture_config() {
	local device_dir="$1"
	local raw_tmp="$2"

	python3 - "$SCREENSHOT_CONFIG_PATH" "$OUTPUT_ROOT" "$device_dir" "$raw_tmp" <<'PY'
import json
import sys

config_path, output_root, device_directory, raw_directory = sys.argv[1:]
with open(config_path, "w", encoding="utf-8") as handle:
    json.dump({
        "outputRoot": output_root,
        "deviceDirectory": device_directory,
        "rawDirectory": raw_directory,
    }, handle)
    handle.write("\n")
PY
}

run_capture() {
	local device="$1"
	local device_dir="$2"
	local test_name="$3"
	shift 3
	local expected_shots=("$@")
	local result_bundle="$RESULTS_DIR/$device_dir.xcresult"
	local raw_final="$OUTPUT_ROOT/$device_dir/raw"
	local raw_tmp
	local device_id
	device_id="$(simulator_id "$device")"
	if [[ -z "$device_id" ]]; then
		echo "Unable to resolve simulator identifier for '$device'." >&2
		return 1
	fi

	rm -rf "$result_bundle"
	mkdir -p "$raw_final" "$RESULTS_DIR"
	raw_tmp="$(mktemp -d "$RESULTS_DIR/$device_dir-raw.XXXXXX")"

	echo "Capturing app-clean QA $device_dir on $device"
	write_capture_config "$device_dir" "$raw_tmp"

	if [[ "${SCREENSHOT_RESET_SIMULATOR:-1}" == "1" ]]; then
		xcrun simctl shutdown "$device" >/dev/null 2>&1 || true
		xcrun simctl erase "$device" >/dev/null 2>&1 || true
	fi

	local capture_status=0
	OS_ACTIVITY_MODE=disable \
		run_with_timeout "${SCREENSHOT_CAPTURE_TIMEOUT_SECONDS:-900}" xcodebuild test \
		-project "$ROOT_DIR/CatholicFastingApp.xcodeproj" \
		-scheme CatholicFastingApp \
		-destination "platform=iOS Simulator,id=$device_id" \
		-destination-timeout 120 \
		-only-testing:"CatholicFastingAppUITests/CatholicFastingAppUITests/$test_name" \
		-parallel-testing-enabled NO \
		-test-timeouts-enabled YES \
		-default-test-execution-time-allowance "${SCREENSHOT_TEST_EXECUTION_TIME_ALLOWANCE:-180}" \
		-resultBundlePath "$result_bundle" || capture_status=$?
	rm -f "$SCREENSHOT_CONFIG_PATH"
	local shot
	for shot in "${expected_shots[@]}"; do
		if [[ ! -f "$raw_tmp/$shot.png" ]]; then
			rm -rf "$raw_tmp"
			echo "Capture did not produce expected raw screenshot: $shot.png" >&2
			echo "Existing raw screenshots were preserved in $raw_final" >&2
			if [[ "$capture_status" -ne 0 ]]; then
				return "$capture_status"
			fi
			return 1
		fi
	done

	if [[ "$capture_status" -ne 0 ]]; then
		echo "xcodebuild exited $capture_status after producing all $device_dir screenshots; preserving captured images." >&2
	fi

	rm -f "$raw_final"/*.png
	mv "$raw_tmp"/*.png "$raw_final/"
	rmdir "$raw_tmp"
}

require_tool xcrun
require_tool xcodebuild

IPHONE_DEVICE="$(choose_simulator "$IPHONE_DEVICE" "iPhone 17 Pro Max" "iPhone 16 Pro Max" "iPhone 15 Pro Max")"
IPAD_DEVICE="$(choose_simulator "$IPAD_DEVICE" "iPad Pro 13-inch (M5)" "iPad Pro 13-inch (M4)" "iPad Air 13-inch (M4)")"

if [[ "$CAPTURE_IPHONE" -eq 1 ]]; then
	run_capture "$IPHONE_DEVICE" "iphone-17-pro-max" "testIPhoneAppCleanQAScreenshots" \
		01-today \
		02-fasting-days \
		03-track-fast-active \
		04-premium \
		05-more-hub
fi

if [[ "$CAPTURE_IPAD" -eq 1 ]]; then
	run_capture "$IPAD_DEVICE" "ipad-pro-13" "testIPadAppCleanQAScreenshots" \
		01-ipad-today \
		02-ipad-fasting-days \
		03-ipad-track-fast \
		04-ipad-premium \
		05-ipad-more
fi

echo "App-clean QA screenshots are ready in $OUTPUT_ROOT"
