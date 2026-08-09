#!/usr/bin/env bash
set -euo pipefail

PROJECT="CatholicFastingApp.xcodeproj"
SCHEME="CatholicFastingApp"
STOREKIT_SCHEME="${STOREKIT_SCHEME:-CatholicFastingAppStoreKitTests}"
STOREKIT_XCODE_VERSION="${STOREKIT_XCODE_VERSION:-26.2}"
RESULT_ROOT="${RESULT_ROOT:-/tmp/CatholicFastingAppTestResults}"
DERIVED_DATA="${DERIVED_DATA:-/tmp/CatholicFastingAppDerivedData}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-1}"
TEST_TIMEOUT_SECONDS="${TEST_TIMEOUT_SECONDS:-900}"
SMOKE_TIMEOUT_SECONDS="${SMOKE_TIMEOUT_SECONDS:-240}"
DEEP_TIMEOUT_SECONDS="${DEEP_TIMEOUT_SECONDS:-600}"
IPAD_TIMEOUT_SECONDS="${IPAD_TIMEOUT_SECONDS:-600}"
RELEASE_PHONE_TIMEOUT_SECONDS="${RELEASE_PHONE_TIMEOUT_SECONDS:-600}"
RELEASE_IPAD_TIMEOUT_SECONDS="${RELEASE_IPAD_TIMEOUT_SECONDS:-600}"
RELEASE_TEST_TIMEOUT_SECONDS="${RELEASE_TEST_TIMEOUT_SECONDS:-90}"
SIMULATOR_COMMAND_TIMEOUT_SECONDS="${SIMULATOR_COMMAND_TIMEOUT_SECONDS:-120}"
SIMULATOR_HEALTH_TIMEOUT_SECONDS="${SIMULATOR_HEALTH_TIMEOUT_SECONDS:-15}"
RELEASE_IOS_RUNTIME="${RELEASE_IOS_RUNTIME:-iOS-26-5}"
RELEASE_INCLUDE_PERFORMANCE="${RELEASE_INCLUDE_PERFORMANCE:-0}"
STOREKIT_TIMEOUT_SECONDS="${STOREKIT_TIMEOUT_SECONDS:-600}"
TEST_SUITE="${TEST_SUITE:-release}"
PHONE_SIMULATOR_NAME="${PHONE_SIMULATOR_NAME:-iPhone 17}"
PHONE_SIMULATOR_ID="${PHONE_SIMULATOR_ID:-}"
IPAD_SIMULATOR_NAME="${IPAD_SIMULATOR_NAME:-iPad Pro 13-inch (M5)}"
IPAD_SIMULATOR_ID="${IPAD_SIMULATOR_ID:-}"
MIN_FREE_DISK_GB="${MIN_FREE_DISK_GB:-10}"
KEEP_DERIVED_DATA="${KEEP_DERIVED_DATA:-0}"
SKIP_BUILD="${SKIP_BUILD:-0}"
KEEP_SIMULATORS_RUNNING="${KEEP_SIMULATORS_RUNNING:-0}"

echo "Developer directory: ${DEVELOPER_DIR:-$(xcode-select -p)}"
XCODE_VERSION="$(xcodebuild -version | sed -n '1p')"
echo "${XCODE_VERSION}"

verify_storekit_toolchain() {
	if [[ "${XCODE_VERSION}" != "Xcode ${STOREKIT_XCODE_VERSION}" ]]; then
		echo "StoreKit lanes require Xcode ${STOREKIT_XCODE_VERSION}; found ${XCODE_VERSION}." >&2
		echo "Set DEVELOPER_DIR to the pinned Xcode before running TEST_SUITE=${TEST_SUITE}." >&2
		return 2
	fi
}

validate_test_suite() {
	case "${TEST_SUITE}" in
	smoke|deep|ipad|release|release-phone|release-ipad|storekit-ui|storekit)
		;;
	*)
		echo "Unknown TEST_SUITE='${TEST_SUITE}'. Expected smoke, deep, ipad, release, release-phone, release-ipad, storekit-ui, or storekit." >&2
		exit 2
		;;
	esac
}

validate_test_suite

case "${TEST_SUITE}" in
storekit|storekit-ui)
	verify_storekit_toolchain
	;;
esac

resolve_simulator_id() {
	local requested_name="$1"
	local family="$2"
	local preferred_runtime="${3:-}"
	python3 - "${requested_name}" "${family}" "${preferred_runtime}" <<'PY'
import json
import re
import subprocess
import sys

requested_name, family, preferred_runtime = sys.argv[1:]
try:
    payload = json.loads(
        subprocess.check_output(
            ["xcrun", "simctl", "list", "devices", "available", "-j"],
            text=True,
            stderr=subprocess.DEVNULL,
        )
    )
except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
    sys.exit(
        "CoreSimulator is unavailable; cannot resolve iOS simulators. Run: "
        "sudo launchctl kickstart -k system/com.apple.CoreSimulator.simdiskimaged"
    )

try:
    runtimes_payload = json.loads(
        subprocess.check_output(
            ["xcrun", "simctl", "list", "runtimes", "available", "-j"],
            text=True,
            stderr=subprocess.DEVNULL,
        )
    )
except (OSError, subprocess.CalledProcessError, json.JSONDecodeError):
    runtimes_payload = {}

runtime_metadata = {
    runtime.get("identifier", ""): runtime
    for runtime in runtimes_payload.get("runtimes", [])
    if runtime.get("identifier")
}

def runtime_version(identifier):
    match = re.search(r"iOS-(\d+)-(\d+)", identifier)
    return tuple(map(int, match.groups())) if match else (0, 0)

candidates = []
for runtime, devices in payload.get("devices", {}).items():
    for device in devices:
        if not device.get("isAvailable", True):
            continue
        device_type = device.get("deviceTypeIdentifier", "")
        if family == "iphone" and "iPhone" not in device_type:
            continue
        if family == "ipad" and "iPad" not in device_type:
            continue
        metadata = runtime_metadata.get(runtime, {})
        metadata_text = " ".join(
            str(metadata.get(key, ""))
            for key in ("name", "identifier", "version", "buildversion", "availability")
        )
        is_beta = bool(
            re.search(r"(?:beta|seed|preview|developer)", metadata_text, re.IGNORECASE)
        )
        candidates.append((runtime_version(runtime), runtime, device, not is_beta))

def runtime_matches(candidate):
    if not preferred_runtime:
        return False
    runtime, device = candidate[1], candidate[2]
    metadata = runtime_metadata.get(runtime, {})
    return any(
        preferred_runtime == value or preferred_runtime in value
        for value in (
            runtime,
            str(metadata.get("identifier", "")),
            str(metadata.get("name", "")),
            str(metadata.get("version", "")),
        )
    )

def requested_name_matches(candidate):
    name = candidate[2].get("name", "")
    # Local release simulators are deliberately named "CFA <device name>" to
    # distinguish them from ephemeral test devices. Treat that label as the
    # configured device name without accepting broader fuzzy matches such as
    # the separate StoreKit iOS 27 simulator.
    return name == requested_name or name == f"CFA {requested_name}"

exact = [candidate for candidate in candidates if requested_name_matches(candidate)]
preferred = [candidate for candidate in candidates if runtime_matches(candidate)]
stable = [candidate for candidate in candidates if candidate[3]]

# A configured runtime is the primary selector. This keeps local validation on
# the requested stable runtime even when a newer preview device has the exact
# default model name.
selection_groups = [
    [candidate for candidate in exact if runtime_matches(candidate)],
    preferred,
    [candidate for candidate in exact if candidate[3]],
    exact,
    stable,
    candidates,
]
selected = next(
    (max(group, key=lambda candidate: candidate[0]) for group in selection_groups if group),
    None,
)
if selected is None:
    sys.exit(f"No available {family} Simulator is installed.")

_, runtime, device, is_stable = selected
if not requested_name_matches(selected):
    print(
        f"Requested Simulator '{requested_name}' is unavailable; using "
        f"'{device['name']}' ({device['udid']}).",
        file=sys.stderr,
    )
if preferred_runtime and not runtime_matches(selected):
    print(
        f"Preferred iOS runtime '{preferred_runtime}' is unavailable for the requested "
        f"{family} device; using '{runtime}'.",
        file=sys.stderr,
    )
if preferred_runtime and not is_stable:
    print(
        f"Selected runtime '{runtime}' is marked as beta/preview; set the release "
        "simulator ID explicitly to avoid running validation on a preview runtime.",
        file=sys.stderr,
    )
print(device["udid"])
PY
}

preferred_ios_runtime="${RELEASE_IOS_RUNTIME}"
case "${TEST_SUITE}" in
storekit|storekit-ui)
	# StoreKit lanes are pinned to a separate Xcode toolchain and may require
	# its matching simulator runtime.
	preferred_ios_runtime=""
	;;
esac

if [[ -z "${PHONE_SIMULATOR_ID}" ]]; then
	PHONE_SIMULATOR_ID="$(resolve_simulator_id "${PHONE_SIMULATOR_NAME}" iphone "${preferred_ios_runtime}")"
fi
if [[ -z "${IPAD_SIMULATOR_ID}" ]]; then
	IPAD_SIMULATOR_ID="$(resolve_simulator_id "${IPAD_SIMULATOR_NAME}" ipad "${preferred_ios_runtime}")"
fi

if pgrep -x xcodebuild >/dev/null 2>&1; then
	echo "Another xcodebuild process is already running. Wait for it to finish before starting simulator tests." >&2
	exit 2
fi

available_kb="$(df -Pk /tmp | awk 'NR == 2 { print $4 }')"
required_kb="$((MIN_FREE_DISK_GB * 1024 * 1024))"
if [[ -z "${available_kb}" || "${available_kb}" -lt "${required_kb}" ]]; then
	echo "Simulator tests require at least ${MIN_FREE_DISK_GB} GB free in /tmp to avoid unstable system processes." >&2
	exit 2
fi

mkdir -p "${RESULT_ROOT}"
mkdir -p "${DERIVED_DATA}"

cleanup_test_environment() {
	if [[ "${KEEP_SIMULATORS_RUNNING}" != "1" ]]; then
		run_simulator_command shutdown "${PHONE_SIMULATOR_ID:-${PHONE_SIMULATOR_NAME}}" >/dev/null 2>&1 || true
		run_simulator_command shutdown "${IPAD_SIMULATOR_ID:-${IPAD_SIMULATOR_NAME}}" >/dev/null 2>&1 || true
	fi
	if [[ "${KEEP_DERIVED_DATA}" != "1" ]]; then
		case "${DERIVED_DATA}" in
		/tmp/* | /private/tmp/*)
			rm -rf "${DERIVED_DATA}"
			;;
		*)
			echo "Retaining non-temporary DerivedData path: ${DERIVED_DATA}"
			;;
		esac
	fi
}
trap cleanup_test_environment EXIT INT TERM

wait_for_simulator_service() {
	local successful_checks=0
	local attempt=0

	while [[ "${attempt}" -lt 10 ]]; do
		attempt="$((attempt + 1))"
		if run_with_timeout "${SIMULATOR_HEALTH_TIMEOUT_SECONDS}" xcrun simctl list devices >/dev/null 2>&1; then
			successful_checks="$((successful_checks + 1))"
			if [[ "${successful_checks}" -ge 2 ]]; then
				return 0
			fi
		else
			successful_checks=0
		fi
		sleep 2
	done

	echo "CoreSimulator did not remain healthy for two consecutive checks." >&2
	echo "If simdiskimaged is stopped, run: sudo launchctl kickstart -k system/com.apple.CoreSimulator.simdiskimaged" >&2
	return 1
}

run_with_timeout() {
	local timeout_seconds="$1"
	shift
	python3 - "$timeout_seconds" "$@" <<'PY'
import os
import signal
import subprocess
import sys
import time

timeout_seconds = float(sys.argv[1])
command = sys.argv[2:]
if timeout_seconds <= 0:
    raise SystemExit("timeout must be greater than zero")
if not command:
    raise SystemExit("run_with_timeout requires a command")

# CoreSimulator's XPC connection is tied to the caller session on this host.
# `start_new_session=True` therefore makes otherwise healthy `simctl` calls
# fail immediately. Keep simulator commands in this session, but isolate
# xcodebuild in a separate process group so its descendants are still bounded.
is_simctl = command[:2] == ["xcrun", "simctl"]
process = subprocess.Popen(command, start_new_session=not is_simctl)

def stop_process(signum):
    try:
        if is_simctl:
            process.send_signal(signum)
        else:
            os.killpg(process.pid, signum)
    except ProcessLookupError:
        pass

def reap_until(deadline):
    while process.poll() is None and time.time() < deadline:
        time.sleep(0.25)

deadline = time.time() + timeout_seconds
try:
    # Poll against wall-clock time so a wedged XCTest process or host sleep
    # cannot turn a short test allowance into an hours-long wait.
    while process.poll() is None:
        remaining = deadline - time.time()
        if remaining <= 0:
            print(
                f"watchdog: command exceeded {timeout_seconds:g}s; terminating "
                f"{'process' if is_simctl else 'process group'}",
                file=sys.stderr,
                flush=True,
            )
            stop_process(signal.SIGTERM)
            reap_until(time.time() + 20)
            if process.poll() is None:
                print(
                    f"watchdog: {'process' if is_simctl else 'process group'} did not exit; "
                    "sending SIGKILL",
                    file=sys.stderr,
                    flush=True,
                )
                stop_process(signal.SIGKILL)
                reap_until(time.time() + 20)
            sys.exit(124)
        time.sleep(min(0.25, remaining))
except KeyboardInterrupt:
    stop_process(signal.SIGTERM)
    reap_until(time.time() + 5)
    if process.poll() is None:
        stop_process(signal.SIGKILL)
        reap_until(time.time() + 5)
    sys.exit(130)

sys.exit(process.returncode)
PY
}

run_simulator_command() {
	local operation="$1"
	shift
	if ! run_with_timeout "${SIMULATOR_COMMAND_TIMEOUT_SECONDS}" xcrun simctl "${operation}" "$@"; then
		echo "CoreSimulator command timed out or failed: simctl ${operation} $*" >&2
		return 1
	fi
}

check_disk_space() {
	local available_kb=""
	available_kb="$(df -Pk /tmp | awk 'NR == 2 { print $4 }')"
	if [[ -z "${available_kb}" || "${available_kb}" -lt "${required_kb}" ]]; then
		echo "Disk guard tripped: /tmp has ${available_kb:-unknown} KB free; require at least ${MIN_FREE_DISK_GB} GB." >&2
		return 1
	fi
	return 0
}

check_host_health() {
	local context="$1"
	if ! run_with_timeout "${SIMULATOR_HEALTH_TIMEOUT_SECONDS}" xcrun simctl list devices >/dev/null 2>&1; then
		echo "CoreSimulator health check failed ${context}; refusing to start the next iOS test shard." >&2
		echo "If simdiskimaged is stopped, run: sudo launchctl kickstart -k system/com.apple.CoreSimulator.simdiskimaged" >&2
		return 1
	fi
	check_disk_space
}

wall_clock_deadline() {
	python3 - "$1" <<'PY'
import sys
import time

print(time.time() + float(sys.argv[1]))
PY
}

wall_clock_remaining() {
	python3 - "$1" <<'PY'
import sys
import time

print(max(0, int(float(sys.argv[1]) - time.time())))
PY
}

run_suite() {
	local suite="$1"
	local timeout_seconds="$2"
	local simulator_name="$3"
	local simulator_id="$4"
	shift 4
	local selectors=("$@")
	local scheme="${RUN_SCHEME:-${SCHEME}}"
	local configuration="${RUN_CONFIGURATION:-}"
	local simulator_ref="${simulator_id:-${simulator_name}}"
	local destination="platform=iOS Simulator,name=${simulator_name}"
	local shard_each_test="${SHARD_EACH_TEST:-0}"
	local result_bundle=""
	local test_name=""
	local attempt_failed=0
	local suite_deadline=""
	local remaining_seconds=""
	local shard_timeout=""
	local shard_status=0

	for selector in "${selectors[@]}"; do
		test_name="${selector##*/}"
		if [[ "${selector}" == *CatholicFastingAppUITests/* ]] && ! rg -q "func[[:space:]]+${test_name}\\(" CatholicFastingAppUITests; then
			echo "Unknown UI test selector: ${test_name}" >&2
			return 2
		fi
	done

	if [[ -n "${simulator_id}" ]]; then
		destination="platform=iOS Simulator,id=${simulator_id}"
	fi

	for attempt in $(seq 1 "${MAX_ATTEMPTS}"); do
		attempt_failed=0
		if [[ "${shard_each_test}" == "1" ]]; then
			suite_deadline="$(wall_clock_deadline "${timeout_seconds}")"
			echo "==> [${suite}] Attempt ${attempt}/${MAX_ATTEMPTS}: running ${#selectors[@]} bounded test shards"

			for selector in "${selectors[@]}"; do
				test_name="${selector##*/}"
				if ! check_host_health "before ${test_name}"; then
					attempt_failed=1
					break
				fi

				remaining_seconds="$(wall_clock_remaining "${suite_deadline}")"
				if (( remaining_seconds <= 0 )); then
					echo "[${suite}] Lane wall-clock budget expired before ${test_name}." >&2
					attempt_failed=1
					break
				fi

				echo "==> [${suite}/${test_name}] Resetting simulator state"
				run_simulator_command shutdown "${simulator_ref}" || true
				if ! run_simulator_command erase "${simulator_ref}" \
					|| ! run_simulator_command boot "${simulator_ref}" \
					|| ! run_simulator_command bootstatus "${simulator_ref}" -b; then
					attempt_failed=1
					break
				fi

				remaining_seconds="$(wall_clock_remaining "${suite_deadline}")"
				if (( remaining_seconds <= 0 )); then
					echo "[${suite}] Lane wall-clock budget expired while preparing ${test_name}." >&2
					attempt_failed=1
					break
				fi
				shard_timeout="${RELEASE_TEST_TIMEOUT_SECONDS}"
				if (( shard_timeout > remaining_seconds )); then
					shard_timeout="${remaining_seconds}"
				fi

				result_bundle="${RESULT_ROOT}/ui-tests-${suite}-${test_name}-attempt-${attempt}.xcresult"
				rm -rf "${result_bundle}"
				command=(
					xcodebuild
					-project "${PROJECT}"
					-scheme "${scheme}"
					-destination "${destination}"
					-derivedDataPath "${DERIVED_DATA}"
					-resultBundlePath "${result_bundle}"
					-parallel-testing-enabled NO
					-collect-test-diagnostics "${COLLECT_TEST_DIAGNOSTICS:-never}"
					-test-timeouts-enabled YES
					-default-test-execution-time-allowance "${TEST_EXECUTION_TIME_ALLOWANCE:-120}"
				)
				if [[ -n "${configuration}" ]]; then
					command+=(-configuration "${configuration}")
				fi
				command+=("${selector}" test-without-building)

				echo "==> [${suite}/${test_name}] Running (watchdog: ${shard_timeout}s; result: ${result_bundle})"
				shard_status=0
				if ! run_with_timeout "${shard_timeout}" "${command[@]}"; then
					shard_status=1
					echo "[${suite}/${test_name}] Failed or exceeded its wall-clock watchdog." >&2
				else
					echo "[${suite}/${test_name}] Passed."
				fi

				if ! check_host_health "after ${test_name}"; then
					shard_status=1
				fi
				if (( shard_status != 0 )); then
					attempt_failed=1
					break
				fi
			done
		else
			result_bundle="${RESULT_ROOT}/ui-tests-${suite}-attempt-${attempt}.xcresult"
			rm -rf "${result_bundle}"
			if ! check_host_health "before ${suite}"; then
				attempt_failed=1
			else
				echo "==> [${suite}] Attempt ${attempt}/${MAX_ATTEMPTS}: resetting simulator state"
				run_simulator_command shutdown "${simulator_ref}" || true
				if ! run_simulator_command erase "${simulator_ref}" \
					|| ! run_simulator_command boot "${simulator_ref}" \
					|| ! run_simulator_command bootstatus "${simulator_ref}" -b; then
					attempt_failed=1
				else
					command=(
						xcodebuild
						-project "${PROJECT}"
						-scheme "${scheme}"
						-destination "${destination}"
						-derivedDataPath "${DERIVED_DATA}"
						-resultBundlePath "${result_bundle}"
						-parallel-testing-enabled NO
						-collect-test-diagnostics "${COLLECT_TEST_DIAGNOSTICS:-never}"
						-test-timeouts-enabled YES
						-default-test-execution-time-allowance "${TEST_EXECUTION_TIME_ALLOWANCE:-120}"
					)
					if [[ -n "${configuration}" ]]; then
						command+=(-configuration "${configuration}")
					fi
					command+=("${selectors[@]}")
					command+=(test-without-building)

					echo "==> [${suite}] Running UI tests (result: ${result_bundle})"
					if ! run_with_timeout "${timeout_seconds}" "${command[@]}"; then
						attempt_failed=1
					fi
					if ! check_host_health "after ${suite}"; then
						attempt_failed=1
					fi
				fi
			fi
		fi

		if (( attempt_failed == 0 )); then
			echo "[${suite}] UI tests passed on attempt ${attempt}."
			return 0
		fi

		echo "[${suite}] UI tests failed or timed out on attempt ${attempt}." >&2
	done

	echo "[${suite}] UI tests failed after ${MAX_ATTEMPTS} attempts."
	return 1
}

discover_release_tests() {
	local target_family="$1"
	local test_name=""
	while IFS= read -r test_name; do
		[[ -n "${test_name}" ]] || continue
		[[ "${test_name}" == *Screenshots ]] && continue
		[[ "${test_name}" == testStoreKit* ]] && continue
		if [[ "${RELEASE_INCLUDE_PERFORMANCE}" != "1" && "${test_name}" == *Performance ]]; then
			continue
		fi
		if [[ "${target_family}" == "ipad" ]]; then
			[[ "${test_name}" == *IPad* ]] || continue
		else
			[[ "${test_name}" == *IPad* ]] && continue
		fi
		printf '%s\n' "-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/${test_name}"
	done < <(
		rg --no-filename -o 'func[[:space:]]+test[A-Za-z0-9_]+\(' CatholicFastingAppUITests \
			| sed -E 's/func[[:space:]]+//; s/\($//' \
			| sort -u
	)
}

run_release_suite() {
	local phone_selectors=()
	local ipad_selectors=()
	local selector=""

	while IFS= read -r selector; do
		phone_selectors+=("${selector}")
	done < <(discover_release_tests phone)
	while IFS= read -r selector; do
		ipad_selectors+=("${selector}")
	done < <(discover_release_tests ipad)

	echo "==> Release inventory: ${#phone_selectors[@]} iPhone tests, ${#ipad_selectors[@]} iPad tests"
	RUN_CONFIGURATION=Release SHARD_EACH_TEST=1 run_suite "release-phone" "${RELEASE_PHONE_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${phone_selectors[@]}"
	RUN_CONFIGURATION=Release SHARD_EACH_TEST=1 run_suite "release-ipad" "${RELEASE_IPAD_TIMEOUT_SECONDS}" "${IPAD_SIMULATOR_NAME}" "${IPAD_SIMULATOR_ID}" "${ipad_selectors[@]}"
}

run_release_phone_suite() {
	local selectors=()
	local selector=""

	while IFS= read -r selector; do
		selectors+=("${selector}")
	done < <(discover_release_tests phone)

	echo "==> Release inventory: ${#selectors[@]} iPhone tests"
	RUN_CONFIGURATION=Release SHARD_EACH_TEST=1 run_suite "release-phone" "${RELEASE_PHONE_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${selectors[@]}"
}

run_release_ipad_suite() {
	local selectors=()
	local selector=""

	while IFS= read -r selector; do
		selectors+=("${selector}")
	done < <(discover_release_tests ipad)

	echo "==> Release inventory: ${#selectors[@]} iPad tests"
	RUN_CONFIGURATION=Release SHARD_EACH_TEST=1 run_suite "release-ipad" "${RELEASE_IPAD_TIMEOUT_SECONDS}" "${IPAD_SIMULATOR_NAME}" "${IPAD_SIMULATOR_ID}" "${selectors[@]}"
}

run_storekit_suite() {
	local selectors=(
		-only-testing:CatholicFastingAppStoreKitTests
	)

	echo "==> StoreKit inventory: hosted same-process unit/integration target"
	RUN_SCHEME="${STOREKIT_SCHEME}" RUN_CONFIGURATION=Debug run_suite "storekit" "${STOREKIT_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${selectors[@]}"
}

run_storekit_catalog_ui_suite() {
	local selectors=(
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testStoreKitCatalogLoadsMonthlyAndYearlyPrices
	)

	echo "==> StoreKit inventory: rendered catalog/price UI coverage"
	RUN_CONFIGURATION=Debug run_suite "storekit-ui" "${STOREKIT_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${selectors[@]}"
}

run_smoke_suite() {
	local selectors=(
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testFreshLaunchIPhoneCanCompleteOnboardingAndReachToday
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeCalendarControlsVisible
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeExportsRequireLegalAcknowledgment
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeGuidanceDestinationOpens
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhonePremiumLockedToolsAndAccountActionsRemainAvailable
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhonePremiumToolsOpenAllDestinations
	)
	run_suite "smoke" "${SMOKE_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${selectors[@]}"
}

run_deep_suite() {
	local selectors=(
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhoneSetupOpensFridayNotesHistory
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhonePrivacyDataShowsExportAndDeleteControls
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testTodayShowsDecisionActionAndAuthorityInInitialViewport
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testTodayExposesNextObservanceAndPersonalFastStatusWithoutFormationClutter
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhoneVisibleTabBarSwitchesAllPrimarySurfaces
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testPhonePrimarySurfacesFillViewportAboveTabBar
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhoneMoreHubRowsOpenExpectedDestinationContent
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepCompanionActiveFastActionOpensFast
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhoneTodayRequiredActionOpensFilteredCalendar
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepCalendarAgendaOpensRuleSourceAndReminderDetail
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepRecoveryPlanVisibleWhenMissedSeeded
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepQuickSetupConsentIncrementsProgress
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepQuickSetupReminderActionsVisible
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepHouseholdProfileCanBeCreatedAndReapplied
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhoneFastCanStartAndCancel
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhoneFastCanEndAndWriteSessionHistory
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhoneFastPlanningControlsAreAvailable
	)
	run_suite "deep" "${DEEP_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${selectors[@]}"
}

run_ipad_suite() {
	local selectors=(
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadSidebarSwitchesPrimaryWorkspaces
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadTodayShowsGuidanceActionsAndContext
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadTodayQuickActionsOpenTargetWorkspaces
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadCalendarSelectionShowsDetail
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadCalendarShowsFiltersAndQuickDates
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadOnboardingShowsRegionSelector
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadMoreProfileDestinationShowsRegionPicker
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadCanadaModeShowsModeledBaselineContext
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadMorePremiumShowsPlansAndLegal
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadPremiumPlanChoicePrecedesLegalAndJourney
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadFastDefaultsToLiveControlsAndCollapsedAdvancedTools
	)
	run_suite "ipad" "${IPAD_TIMEOUT_SECONDS}" "${IPAD_SIMULATOR_NAME}" "${IPAD_SIMULATOR_ID}" "${selectors[@]}"
}

wait_for_simulator_service

if [[ "${SKIP_BUILD}" == "1" ]]; then
	if ! find "${DERIVED_DATA}/Build/Products" -maxdepth 1 -name '*.xctestrun' -print -quit 2>/dev/null | rg -q .; then
		echo "SKIP_BUILD=1 requires existing test artifacts in ${DERIVED_DATA}." >&2
		exit 2
	fi
	echo "==> Reusing existing test artifacts"
else
	echo "==> Building test artifacts"
	build_scheme="${SCHEME}"
	build_configuration=""
	if [[ "${TEST_SUITE}" == "storekit" ]]; then
		build_scheme="${STOREKIT_SCHEME}"
	fi
	case "${TEST_SUITE}" in
	release|release-phone|release-ipad)
		build_configuration=Release
		;;
	storekit|storekit-ui)
		build_configuration=Debug
		;;
	esac
	build_command=(
		xcodebuild
		-project "${PROJECT}"
		-scheme "${build_scheme}"
		-destination "generic/platform=iOS Simulator"
		-derivedDataPath "${DERIVED_DATA}"
	)
	if [[ -n "${build_configuration}" ]]; then
		build_command+=(-configuration "${build_configuration}")
	fi
	build_command+=(build-for-testing)
	"${build_command[@]}"
fi

case "${TEST_SUITE}" in
smoke)
	run_smoke_suite
	;;
deep)
	run_deep_suite
	;;
ipad)
	run_ipad_suite
	;;
release)
	run_release_suite
	;;
release-phone)
	run_release_phone_suite
	;;
release-ipad)
	run_release_ipad_suite
	;;
storekit)
	run_storekit_suite
	;;
storekit-ui)
	run_storekit_catalog_ui_suite
	;;
	*)
	echo "Unexpected TEST_SUITE='${TEST_SUITE}'."
	exit 2
	;;
esac
