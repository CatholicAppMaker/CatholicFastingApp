#!/bin/zsh
set -euo pipefail

PROJECT="/Users/kevpierce/Desktop/CatholicFastingApp/CatholicFastingApp.xcodeproj"
SCHEME="CatholicFastingApp"
TIMEOUT_SECONDS=180
REQUESTED_SUITE="${1:-}"
SUITE="${SUITE:-${REQUESTED_SUITE:-iphone}}"
DEFAULT_IPHONE_SIMULATOR_NAME="${DEFAULT_IPHONE_SIMULATOR_NAME:-iPhone 17 Pro Max}"
DEFAULT_IPAD_SIMULATOR_NAME="${DEFAULT_IPAD_SIMULATOR_NAME:-iPad Pro 13-inch (M5)}"
SIMULATOR_NAME="${SIMULATOR_NAME:-}"
SIMULATOR_ID="${SIMULATOR_ID:-}"
DESTINATION=""

IPHONE_TESTS=(
  "CatholicFastingAppUITests/testFreshLaunchIPhoneCanCompleteOnboardingAndReachToday"
  "CatholicFastingAppUITests/testSmokeOnboardingCanBeCompleted"
  "CatholicFastingAppUITests/testIPhoneOnboardingSpanishSelectionUpdatesVisibleCopy"
  "CatholicFastingAppUITests/testIPhoneOnboardingFrenchCanadianSelectionUpdatesVisibleCopy"
  "CatholicFastingAppUITests/testDeepCanOpenFridayNotesHistory"
  "CatholicFastingAppUITests/testDeepLaunchReadinessControlsVisible"
  "CatholicFastingAppUITests/testSmokeExportsRequireLegalAcknowledgment"
  "CatholicFastingAppUITests/testSmokeGuidanceScenarioControlVisible"
  "CatholicFastingAppUITests/testDeepDashboardHeroVisible"
  "CatholicFastingAppUITests/testDeepIPhoneMoreDestinationsOpenAndReturn"
  "CatholicFastingAppUITests/testDeepIPhonePremiumScreenShowsPlansTipsAndLegal"
  "CatholicFastingAppUITests/testDeepIPhonePremiumUnlockButtonsExist"
  "CatholicFastingAppUITests/testDeepIPhonePremiumTipsAndLegalStayBelowSubscriptionPlans"
  "CatholicFastingAppUITests/testDeepIPhonePremiumShowsJourneyPreview"
  "CatholicFastingAppUITests/testDeepIPhonePremiumUnlockedShowsCurrentJourneyState"
  "CatholicFastingAppUITests/testIPhoneAccessibilitySettingsDoNotShowVoiceSummary"
  "CatholicFastingAppUITests/testDeepDashboardOpenFastingDaysQuickAction"
  "CatholicFastingAppUITests/testIPhoneCanadaModeCanMoveAcrossTodayFastingDaysAndGuidance"
  "CatholicFastingAppUITests/testSmokeFastingDaysControlsVisible"
  "CatholicFastingAppUITests/testDeepFastingDaysScopePickerVisible"
  "CatholicFastingAppUITests/testDeepDashboardFocusRequiredQuickAction"
  "CatholicFastingAppUITests/testDeepHouseholdProfileCanBeCreatedAndReapplied"
  "CatholicFastingAppUITests/testDeepQuickSetupShowsLanguageSelector"
  "CatholicFastingAppUITests/testIPhoneQuickSetupFrenchCanadianShowsLocalizedSetupCopy"
  "CatholicFastingAppUITests/testIPhoneTodaySpanishShowsLocalizedCoreSections"
  "CatholicFastingAppUITests/testIPhoneFastingDaysSpanishShowsLocalizedPlanningCopy"
  "CatholicFastingAppUITests/testIPhonePremiumSpanishShowsLocalizedJourneyAndSupportCopy"
  "CatholicFastingAppUITests/testIntermittentCanStartAndCancelFast"
  "CatholicFastingAppUITests/testIntermittentCanEndFastAndWriteSessionHistory"
  "CatholicFastingAppUITests/testIntermittentTargetPickerVisible"
  "CatholicFastingAppUITests/testIntermittentDefaultViewPrioritizesLiveStateAndKeepsAdvancedCollapsed"
  "CatholicFastingAppUITests/testIntermittentAdvancedToolsCanExpandFromCollapsedDefault"
)

IPAD_TESTS=(
  "CatholicFastingAppUITests/testFreshLaunchIPadCanCompleteOnboardingAndRenderTodayWorkspace"
  "CatholicFastingAppUITests/testIPadSidebarSwitchesPrimaryWorkspaces"
  "CatholicFastingAppUITests/testIPadSidebarLoopsAcrossAllWorkspacesAfterCanadaFrenchSelection"
  "CatholicFastingAppUITests/testIPadTodayDashboardShowsHeroAndCoreCards"
  "CatholicFastingAppUITests/testIPadFastingDaysSelectionShowsDetail"
  "CatholicFastingAppUITests/testIPadFastingDaysShowsFiltersAndQuickDates"
  "CatholicFastingAppUITests/testIPadFastingDaysFoodGuidanceShortcutOpensMoreGuidance"
  "CatholicFastingAppUITests/testIPadOnboardingShowsRegionSelector"
  "CatholicFastingAppUITests/testIPadOnboardingLanguageSelectionUpdatesVisibleCopy"
  "CatholicFastingAppUITests/testIPadOnboardingFrenchCanadianSelectionUpdatesVisibleCopy"
  "CatholicFastingAppUITests/testIPadMoreProfileDestinationShowsRegionPicker"
  "CatholicFastingAppUITests/testIPadCanadaModeShowsModeledBaselineContext"
  "CatholicFastingAppUITests/testIPadPremiumWorkspaceShowsLegalLinks"
  "CatholicFastingAppUITests/testIPadPremiumWorkspaceShowsJourneyOrPlanContext"
  "CatholicFastingAppUITests/testIPadMoreAllDestinationsOpenWithoutBreakingWorkspace"
  "CatholicFastingAppUITests/testIPadMoreSetupDestinationShowsReminderControls"
  "CatholicFastingAppUITests/testIPadMoreGuidanceDestinationShowsFoodSection"
  "CatholicFastingAppUITests/testIPadGuidanceFrenchCanadianShowsLocalizedSectionTitles"
  "CatholicFastingAppUITests/testIPadPremiumSpanishShowsLocalizedWorkspaceCopy"
  "CatholicFastingAppUITests/testIPadMorePrivacyDestinationShowsDataTools"
  "CatholicFastingAppUITests/testIPadMoreCompactPremiumShowsPlansAndLegal"
  "CatholicFastingAppUITests/testIPadPremiumYearlyAppearsBeforeMonthly"
  "CatholicFastingAppUITests/testIPadMoreDefaultsToPremiumWorkspace"
  "CatholicFastingAppUITests/testIPadPremiumTipsAndLegalStayBelowSubscriptionPlans"
  "CatholicFastingAppUITests/testIPadTrackFastPresetSelectionStaysVisible"
  "CatholicFastingAppUITests/testIPadTodayAndMoreCanBeVisitedRepeatedly"
  "CatholicFastingAppUITests/testIPadTodayQuickActionsOpenTargetWorkspaces"
  "CatholicFastingAppUITests/testIPadTodayQuickActionsRemainResponsiveAcrossRepeatedCycles"
  "CatholicFastingAppUITests/testIPadTodayActionsDoNotShowVoiceSummaryAndRemainResponsive"
  "CatholicFastingAppUITests/testIPadMoreDestinationsRemainResponsiveAcrossRepeatedCycles"
  "CatholicFastingAppUITests/testIPadTrackFastShowsLiveWorkspaceAndControls"
  "CatholicFastingAppUITests/testIPadTrackFastDefaultsToLiveControlsAndCollapsedAdvancedTools"
  "CatholicFastingAppUITests/testIPadTrackFastAdvancedToolsCanExpandWithoutHidingHistory"
)

extract_simulator_id() {
  local device_line="$1"
  print -r -- "${device_line}" | sed -n 's/.*(\([A-F0-9-]\{36\}\)).*/\1/p'
}

resolve_simulator_id() {
  local simulator_name="$1"
  local preferred_line=""
  local fallback_line=""
  local line=""

  while IFS= read -r line; do
    [[ "${line}" == *"${simulator_name} ("* ]] || continue
    [[ "${line}" == *"(unavailable"* ]] && continue

    if [[ -z "${fallback_line}" ]]; then
      fallback_line="${line}"
    fi
    if [[ "${line}" == *"(Booted)"* ]]; then
      preferred_line="${line}"
      break
    fi
  done < <(xcrun simctl list devices available)

  if [[ -n "${preferred_line}" ]]; then
    extract_simulator_id "${preferred_line}"
    return 0
  fi

  if [[ -n "${fallback_line}" ]]; then
    extract_simulator_id "${fallback_line}"
    return 0
  fi

  return 1
}

resolve_destination() {
  local default_name=""

  case "${SUITE}" in
    iphone) default_name="${DEFAULT_IPHONE_SIMULATOR_NAME}" ;;
    ipad) default_name="${DEFAULT_IPAD_SIMULATOR_NAME}" ;;
    *)
      print "Unknown SUITE=${SUITE}. Use iphone or ipad." >&2
      return 1
      ;;
  esac

  if [[ -z "${SIMULATOR_ID}" ]]; then
    if [[ -z "${SIMULATOR_NAME}" ]]; then
      SIMULATOR_NAME="${default_name}"
    fi
    SIMULATOR_ID="$(resolve_simulator_id "${SIMULATOR_NAME}")"
  fi

  if [[ -z "${SIMULATOR_ID}" ]]; then
    print "Unable to resolve simulator for suite ${SUITE}." >&2
    return 1
  fi

  DESTINATION="platform=iOS Simulator,id=${SIMULATOR_ID}"
  print "simulator,${SUITE},${SIMULATOR_ID}" >&2
}

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

    set +e
    wait "${pid}"
    rc=$?
    set -e
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
  local tests_var
  case "${SUITE}" in
    iphone) tests_var=IPHONE_TESTS ;;
    ipad) tests_var=IPAD_TESTS ;;
    *)
      print "Unknown SUITE=${SUITE}. Use iphone or ipad." >&2
      return 1
      ;;
  esac

  resolve_destination
  boot_simulator

  local -a tests
  tests=("${(@P)tests_var}")

  for test_name in "${tests[@]}"; do
    run_one_test "${test_name}"
  done
}

main "$@"
