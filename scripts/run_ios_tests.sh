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
TEST_SUITE="${TEST_SUITE:-all}"
PHONE_SIMULATOR_NAME="${PHONE_SIMULATOR_NAME:-iPhone 17}"
PHONE_SIMULATOR_ID="${PHONE_SIMULATOR_ID:-}"
IPAD_SIMULATOR_NAME="${IPAD_SIMULATOR_NAME:-iPad Pro 13-inch (M5)}"
IPAD_SIMULATOR_ID="${IPAD_SIMULATOR_ID:-}"

if [[ -z "${DEVELOPER_DIR:-}" && -d "/Applications/Xcode-beta.app/Contents/Developer" ]]; then
	export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"
fi

mkdir -p "${RESULT_ROOT}"
mkdir -p "${DERIVED_DATA}"

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
	run_suite "release-phone" "${DEEP_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${phone_selectors[@]}"
	run_suite "release-ipad" "${IPAD_TIMEOUT_SECONDS}" "${IPAD_SIMULATOR_NAME}" "${IPAD_SIMULATOR_ID}" "${ipad_selectors[@]}"
}

run_smoke_suite() {
	local selectors=(
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeOnboardingCanBeCompleted
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeFastingDaysControlsVisible
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeExportsRequireLegalAcknowledgment
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokeGuidanceDestinationOpens
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testSmokePremiumSupportControlsVisible
	)
	run_suite "smoke" "${SMOKE_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${selectors[@]}"
}

run_deep_suite() {
	local selectors=(
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepCanOpenFridayNotesHistory
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepLaunchReadinessControlsVisible
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testTodayShowsDecisionActionAndAuthorityInInitialViewport
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testTodayExposesNextObservanceAndPersonalFastStatusWithoutFormationClutter
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhoneVisibleTabBarSwitchesAllPrimarySurfaces
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPhoneMoreHubRowsOpenExpectedDestinationContent
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepCompanionActiveFastPrimaryActionOpensTrackFast
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepUnofficialNoticeVisible
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepDashboardOpenFastingDaysQuickAction
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepDashboardFocusRequiredQuickAction
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepFastingDaysScopePickerVisible
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepFastingDaysAgendaOpensRuleSourceAndReminderDetail
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepRecoveryPlanVisibleWhenMissedSeeded
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepGuidanceSacredGalleryVisible
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepTodaySetupCardOpensQuickSetup
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepQuickSetupConsentIncrementsProgress
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepQuickSetupReminderActionsVisible
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testDeepHouseholdProfileCanBeCreatedAndReapplied
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIntermittentCanStartAndCancelFast
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIntermittentCanEndFastAndWriteSessionHistory
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIntermittentTargetPickerVisible
	)
	run_suite "deep" "${DEEP_TIMEOUT_SECONDS}" "${PHONE_SIMULATOR_NAME}" "${PHONE_SIMULATOR_ID}" "${selectors[@]}"
}

run_ipad_suite() {
	local selectors=(
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadSidebarSwitchesPrimaryWorkspaces
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadTodayDashboardShowsHeroAndCoreCards
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadTodayShowsDecisionActionsAndContextRail
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadTodayQuickActionsOpenTargetWorkspaces
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadFastingDaysSelectionShowsDetail
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadFastingDaysShowsFiltersAndQuickDates
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadOnboardingShowsRegionSelector
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadMoreProfileDestinationShowsRegionPicker
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadCanadaModeShowsModeledBaselineContext
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadPremiumWorkspaceShowsLegalLinks
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadPremiumPlanChoicePrecedesLegalAndJourney
		-only-testing:CatholicFastingAppUITests/CatholicFastingAppUITests/testIPadTrackFastShowsLiveWorkspaceAndControls
	)
	run_suite "ipad" "${IPAD_TIMEOUT_SECONDS}" "${IPAD_SIMULATOR_NAME}" "${IPAD_SIMULATOR_ID}" "${selectors[@]}"
}

echo "==> Building test artifacts"
xcodebuild \
	-project "${PROJECT}" \
	-scheme "${SCHEME}" \
	-destination "generic/platform=iOS Simulator" \
	-derivedDataPath "${DERIVED_DATA}" \
	build-for-testing

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
*)
	echo "Unknown TEST_SUITE='${TEST_SUITE}'. Expected smoke, deep, ipad, release, or all."
	exit 2
	;;
esac
