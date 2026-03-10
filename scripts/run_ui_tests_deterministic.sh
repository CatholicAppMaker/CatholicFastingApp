#!/bin/zsh
set -euo pipefail

PROJECT="/Users/kevpierce/Desktop/CatholicFastingApp/CatholicFastingApp.xcodeproj"
SCHEME="CatholicFastingApp"
SIMULATOR_ID="04B1BAC6-9C7F-4C37-BE47-46ED42DF2871"
DESTINATION="platform=iOS Simulator,id=${SIMULATOR_ID}"
TIMEOUT_SECONDS=180

TESTS=(
  "CatholicFastingAppUITests/testSmokeOnboardingCanBeCompleted"
  "CatholicFastingAppUITests/testDeepCanOpenFridayNotesHistory"
  "CatholicFastingAppUITests/testDeepLaunchReadinessControlsVisible"
  "CatholicFastingAppUITests/testSmokeExportsRequireLegalAcknowledgment"
  "CatholicFastingAppUITests/testSmokeGuidanceScenarioControlVisible"
  "CatholicFastingAppUITests/testDeepDashboardHeroVisible"
  "CatholicFastingAppUITests/testDeepDashboardOpenFastingDaysQuickAction"
  "CatholicFastingAppUITests/testSmokeFastingDaysControlsVisible"
  "CatholicFastingAppUITests/testDeepFastingDaysScopePickerVisible"
  "CatholicFastingAppUITests/testDeepDashboardFocusRequiredQuickAction"
  "CatholicFastingAppUITests/testDeepHouseholdProfileCanBeCreatedAndReapplied"
  "CatholicFastingAppUITests/testIntermittentCanStartAndCancelFast"
  "CatholicFastingAppUITests/testIntermittentCanEndFastAndWriteSessionHistory"
  "CatholicFastingAppUITests/testIntermittentTargetPickerVisible"
)

boot_simulator() {
  xcrun simctl boot "${SIMULATOR_ID}" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "${SIMULATOR_ID}" -b >/dev/null
}

restart_simulator() {
  xcrun simctl shutdown "${SIMULATOR_ID}" >/dev/null 2>&1 || true
  xcrun simctl boot "${SIMULATOR_ID}" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "${SIMULATOR_ID}" -b >/dev/null
}

run_one_test() {
  local test_name="$1"
  local log_path
  local start end duration elapsed rc attempt
  start=$(date +%s)

  for attempt in 1 2; do
    log_path="/tmp/ui_test_${test_name//\//_}_attempt_${attempt}.log"

    xcodebuild -quiet \
      -project "${PROJECT}" \
      -scheme "${SCHEME}" \
      -destination "${DESTINATION}" \
      -parallel-testing-enabled NO \
      -only-testing:"${test_name}" \
      test >"${log_path}" 2>&1 &
    local pid=$!
    elapsed=0

    while kill -0 "${pid}" >/dev/null 2>&1; do
      sleep 1
      elapsed=$((elapsed + 1))
      if [[ "${elapsed}" -ge "${TIMEOUT_SECONDS}" ]]; then
        kill -9 "${pid}" >/dev/null 2>&1 || true
        if [[ "${attempt}" -eq 1 ]]; then
          print "${test_name},RETRY,${elapsed}"
          print "Timeout reached. Restarting simulator and retrying once."
          restart_simulator
          continue 2
        fi
        print "${test_name},TIMEOUT,${elapsed}"
        print "Last log lines:"
        tail -n 60 "${log_path}" || true
        return 1
      fi
    done

    wait "${pid}"
    rc=$?
    if [[ "${rc}" -eq 0 ]]; then
      end=$(date +%s)
      duration=$((end - start))
      print "${test_name},PASS,${duration}"
      return 0
    fi

    if grep -qiE "invalid device state|server died|coresimulator\\.simerror|mach error -308" "${log_path}" && [[ "${attempt}" -eq 1 ]]; then
      print "${test_name},RETRY,${elapsed}"
      print "Simulator transport issue detected. Restarting simulator and retrying once."
      restart_simulator
      continue
    fi

    end=$(date +%s)
    duration=$((end - start))
    print "${test_name},FAIL,${duration}"
    print "Last log lines:"
    tail -n 80 "${log_path}" || true
    return 1
  done

  return 1
}

main() {
  print "test,status,seconds"
  boot_simulator
  for test_name in "${TESTS[@]}"; do
    run_one_test "${test_name}"
  done
}

main "$@"
