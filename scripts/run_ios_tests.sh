#!/usr/bin/env bash
set -euo pipefail

PROJECT="CatholicFastingApp.xcodeproj"
SCHEME="CatholicFastingApp"
RESULT_ROOT="${RESULT_ROOT:-/tmp/CatholicFastingAppTestResults}"
DERIVED_DATA="${DERIVED_DATA:-/tmp/CatholicFastingAppDerivedData}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-1}"
TEST_TIMEOUT_SECONDS="${TEST_TIMEOUT_SECONDS:-900}"
SMOKE_TIMEOUT_SECONDS="${SMOKE_TIMEOUT_SECONDS:-240}"
DEEP_TIMEOUT_SECONDS="${DEEP_TIMEOUT_SECONDS:-900}"
IPAD_TIMEOUT_SECONDS="${IPAD_TIMEOUT_SECONDS:-900}"
RELEASE_PHONE_TIMEOUT_SECONDS="${RELEASE_PHONE_TIMEOUT_SECONDS:-3600}"
RELEASE_IPAD_TIMEOUT_SECONDS="${RELEASE_IPAD_TIMEOUT_SECONDS:-3600}"
TEST_SUITE="${TEST_SUITE:-all}"
PHONE_SIMULATOR_NAME="${PHONE_SIMULATOR_NAME:-iPhone 17}"
PHONE_SIMULATOR_ID="${PHONE_SIMULATOR_ID:-}"
IPAD_SIMULATOR_NAME="${IPAD_SIMULATOR_NAME:-iPad Pro 13-inch (M5)}"
IPAD_SIMULATOR_ID="${IPAD_SIMULATOR_ID:-}"
MIN_FREE_DISK_GB="${MIN_FREE_DISK_GB:-10}"
KEEP_DERIVED_DATA="${KEEP_DERIVED_DATA:-0}"
SKIP_BUILD="${SKIP_BUILD:-0}"
KEEP_SIMULATORS_RUNNING="${KEEP_SIMULATORS_RUNNING:-0}"

if [[ -z "${DEVELOPER_DIR:-}" && -d "/Applications/Xcode-beta.app/Contents/Developer" ]]; then
	export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"
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
		xcrun simctl shutdown "${PHONE_SIMULATOR_ID:-${PHONE_SIMULATOR_NAME}}" >/dev/null 2>&1 || true
		xcrun simctl shutdown "${IPAD_SIMULATOR_ID:-${IPAD_SIMULATOR_NAME}}" >/dev/null 2>&1 || true
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
		if xcrun simctl list devices >/dev/null 2>&1; then
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
import signal
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

run_suite() {
	local suite="$1"
	local timeout_seconds="$2"
	local simulator_name="$3"
	local simulator_id="$4"
	shift 4
	local selectors=("$@")
	local simulator_ref="${simulator_id:-${simulator_name}}"
	local destination="platform=iOS Simulator,name=${simulator_name}"

	for selector in "${selectors[@]}"; do
		local test_name="${selector##*/}"
		if ! rg -q "func[[:space:]]+${test_name}\\(" CatholicFastingAppUITests; then
			echo "Unknown UI test selector: ${test_name}" >&2
			return 2
		fi
	done

	if [[ -n "${simulator_id}" ]]; then
		destination="platform=iOS Simulator,id=${simulator_id}"
	fi

	for attempt in $(seq 1 "${MAX_ATTEMPTS}"); do
		result_bundle="${RESULT_ROOT}/ui-tests-${suite}-attempt-${attempt}.xcresult"
		rm -rf "${result_bundle}"

		echo "==> [${suite}] Attempt ${attempt}/${MAX_ATTEMPTS}: resetting simulator state"
		xcrun simctl shutdown "${simulator_ref}" || true
		xcrun simctl erase "${simulator_ref}" || true
		xcrun simctl boot "${simulator_ref}" || true
		xcrun simctl bootstatus "${simulator_ref}" -b

		command=(
			xcodebuild
			-project "${PROJECT}"
			-scheme "${SCHEME}"
			-destination "${destination}"
			-derivedDataPath "${DERIVED_DATA}"
			-resultBundlePath "${result_bundle}"
			-parallel-testing-enabled NO
			-collect-test-diagnostics "${COLLECT_TEST_DIAGNOSTICS:-never}"
			-test-timeouts-enabled YES
			-default-test-execution-time-allowance "${TEST_EXECUTION_TIME_ALLOWANCE:-120}"
		)
		command+=("${selectors[@]}")
		command+=(test-without-building)

		echo "==> [${suite}] Running UI tests (result: ${result_bundle})"
		if run_with_timeout "${timeout_seconds}" "${command[@]}"; then
			echo "[${suite}] UI tests passed on attempt ${attempt}."
			return 0
		fi

		echo "[${suite}] UI tests failed or timed out on attempt ${attempt}."
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
	run_suite "release-phone" "${RELEASE_PHONE_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${phone_selectors[@]}"
	run_suite "release-ipad" "${RELEASE_IPAD_TIMEOUT_SECONDS}" "${IPAD_SIMULATOR_NAME}" "${IPAD_SIMULATOR_ID}" "${ipad_selectors[@]}"
}

run_release_phone_suite() {
	local selectors=()
	local selector=""

	while IFS= read -r selector; do
		selectors+=("${selector}")
	done < <(discover_release_tests phone)

	echo "==> Release inventory: ${#selectors[@]} iPhone tests"
	run_suite "release-phone" "${RELEASE_PHONE_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${selectors[@]}"
}

run_release_ipad_suite() {
	local selectors=()
	local selector=""

	while IFS= read -r selector; do
		selectors+=("${selector}")
	done < <(discover_release_tests ipad)

	echo "==> Release inventory: ${#selectors[@]} iPad tests"
	run_suite "release-ipad" "${RELEASE_IPAD_TIMEOUT_SECONDS}" "${IPAD_SIMULATOR_NAME}" "${IPAD_SIMULATOR_ID}" "${selectors[@]}"
}

run_smoke_suite() {
	local selectors=(
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testFreshLaunchIPhoneCanCompleteOnboardingAndReachToday
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeCalendarControlsVisible
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeExportsRequireLegalAcknowledgment
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeGuidanceDestinationOpens
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhonePremiumLockedToolsAndAccountActionsRemainAvailable
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
	xcodebuild \
		-project "${PROJECT}" \
		-scheme "${SCHEME}" \
		-destination "generic/platform=iOS Simulator" \
		-derivedDataPath "${DERIVED_DATA}" \
		build-for-testing
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
all)
	run_release_suite
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
*)
	echo "Unknown TEST_SUITE='${TEST_SUITE}'. Expected smoke, deep, ipad, release, release-phone, release-ipad, or all."
	exit 2
	;;
esac
