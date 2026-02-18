#!/usr/bin/env bash
set -euo pipefail

PROJECT="CatholicFastingApp.xcodeproj"
SCHEME="CatholicFastingApp"
DESTINATION="platform=iOS Simulator,name=iPhone 17"
RESULT_ROOT="${RESULT_ROOT:-/tmp/CatholicFastingAppTestResults}"
DERIVED_DATA="${DERIVED_DATA:-/tmp/CatholicFastingAppDerivedData}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-2}"
TEST_TIMEOUT_SECONDS="${TEST_TIMEOUT_SECONDS:-900}"
SMOKE_TIMEOUT_SECONDS="${SMOKE_TIMEOUT_SECONDS:-240}"
DEEP_TIMEOUT_SECONDS="${DEEP_TIMEOUT_SECONDS:-900}"
TEST_SUITE="${TEST_SUITE:-all}"

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
  shift 2
  local selectors=("$@")

  for attempt in $(seq 1 "${MAX_ATTEMPTS}"); do
    result_bundle="${RESULT_ROOT}/ui-tests-${suite}-attempt-${attempt}.xcresult"
    rm -rf "${result_bundle}"

    echo "==> [${suite}] Attempt ${attempt}/${MAX_ATTEMPTS}: resetting simulator state"
    xcrun simctl shutdown all || true
    xcrun simctl erase all || true
    xcrun simctl boot "iPhone 17" || true
    xcrun simctl bootstatus "iPhone 17" -b

    command=(
      xcodebuild
      -project "${PROJECT}"
      -scheme "${SCHEME}"
      -destination "${DESTINATION}"
      -derivedDataPath "${DERIVED_DATA}"
      -resultBundlePath "${result_bundle}"
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

run_smoke_suite() {
  local selectors=(
    -only-testing:CatholicFastingAppUITests/testSmokeOnboardingCanBeCompleted
    -only-testing:CatholicFastingAppUITests/testSmokeCalendarFilterControlsVisible
    -only-testing:CatholicFastingAppUITests/testSmokeExportsRequireLegalAcknowledgment
    -only-testing:CatholicFastingAppUITests/testSmokeGuidanceScenarioControlVisible
    -only-testing:CatholicFastingAppUITests/testSmokePremiumSupportControlsVisible
  )
  run_suite "smoke" "${SMOKE_TIMEOUT_SECONDS}" "${selectors[@]}"
}

run_deep_suite() {
  local selectors=(
    -only-testing:CatholicFastingAppUITests/testDeepCanOpenFridayNotesHistory
    -only-testing:CatholicFastingAppUITests/testDeepLaunchReadinessControlsVisible
    -only-testing:CatholicFastingAppUITests/testDeepDashboardHeroVisible
    -only-testing:CatholicFastingAppUITests/testDeepUnofficialNoticeVisible
    -only-testing:CatholicFastingAppUITests/testDeepDashboardOpenCalendarQuickAction
    -only-testing:CatholicFastingAppUITests/testDeepDashboardFocusRequiredQuickAction
    -only-testing:CatholicFastingAppUITests/testDeepCalendarResetFiltersButtonVisible
    -only-testing:CatholicFastingAppUITests/testDeepRecoveryPlanVisibleWhenMissedSeeded
    -only-testing:CatholicFastingAppUITests/testDeepGuidanceSacredGalleryVisible
    -only-testing:CatholicFastingAppUITests/testDeepTodaySetupCardOpensQuickSetup
    -only-testing:CatholicFastingAppUITests/testDeepQuickSetupConsentIncrementsProgress
    -only-testing:CatholicFastingAppUITests/testDeepQuickSetupReminderActionsVisible
    -only-testing:CatholicFastingAppUITests/testIntermittentCanStartAndCancelFast
    -only-testing:CatholicFastingAppUITests/testIntermittentCanEndFastAndWriteSessionHistory
    -only-testing:CatholicFastingAppUITests/testIntermittentTargetPickerVisible
  )
  run_suite "deep" "${DEEP_TIMEOUT_SECONDS}" "${selectors[@]}"
}

echo "==> Building test artifacts"
xcodebuild \
  -project "${PROJECT}" \
  -scheme "${SCHEME}" \
  -destination "${DESTINATION}" \
  -derivedDataPath "${DERIVED_DATA}" \
  build-for-testing

case "${TEST_SUITE}" in
  smoke)
    run_smoke_suite
    ;;
  deep)
    run_deep_suite
    ;;
  all)
    run_smoke_suite
    run_deep_suite
    ;;
  *)
    echo "Unknown TEST_SUITE='${TEST_SUITE}'. Expected smoke, deep, or all."
    exit 2
    ;;
esac
