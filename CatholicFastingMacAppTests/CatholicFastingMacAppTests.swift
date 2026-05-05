@testable import CatholicFastingMacApp
import XCTest

@MainActor
final class CatholicFastingMacAppTests: XCTestCase {
    private var defaults: UserDefaults!
    private var defaultsSuiteName = ""
    private var reminderService: TestReminderPlatformService!
    private var sharingService: TestSharePayloadPlatformService!
    private var seasonalService: TestSeasonalAppearancePlatformService!
    private var settingsOpeningService: TestSettingsOpeningPlatformService!

    override func setUp() {
        super.setUp()
        defaultsSuiteName = "CatholicFastingMacAppTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: defaultsSuiteName)
        reminderService = TestReminderPlatformService()
        sharingService = TestSharePayloadPlatformService()
        seasonalService = TestSeasonalAppearancePlatformService()
        settingsOpeningService = TestSettingsOpeningPlatformService()
        LocalFeatureStore.clearAll()
        WidgetSnapshotStore.clear()
    }

    override func tearDown() {
        defaults?.removePersistentDomain(forName: defaultsSuiteName)
        LocalFeatureStore.clearAll()
        WidgetSnapshotStore.clear()
        reminderService = nil
        sharingService = nil
        seasonalService = nil
        settingsOpeningService = nil
        defaults = nil
        defaultsSuiteName = ""
        super.tearDown()
    }

    func testPerformInitialStartupTasksInUITestModeSkipsLiveSideEffects() async {
        let model = makeModel(isUITestMode: true)

        await model.performInitialStartupTasks()

        XCTAssertEqual(model.notificationStatus, "UI Test Mode")
        XCTAssertEqual(reminderService.topUpRequiredRemindersCalls, 0)
        XCTAssertEqual(reminderService.scheduleDailyQuoteReminderCalls, 0)
        XCTAssertEqual(seasonalService.handleSceneDidBecomeActiveCalls, 0)
    }

    func testCompleteOnboardingMarksStateAndTimestamp() {
        let model = makeModel()

        model.completeOnboarding()

        XCTAssertTrue(model.didCompleteOnboarding)
        XCTAssertNotNil(model.launchFunnelSnapshot.completedOnboardingAt)
        XCTAssertEqual(model.launchFunnelSnapshot.selectedReminderTierRaw, model.reminderTierRaw)
    }

    func testHandleDeepLinkMapsDesktopSurfacesAndNativeMacDestinations() {
        let model = makeModel()

        model.handleDeepLink(.surface(.fastingDays))
        XCTAssertEqual(model.selectedSurface, .calendar)

        model.handleDeepLink(.surface(.intermittent))
        XCTAssertEqual(model.selectedSurface, .intermittent)

        model.handleDeepLink(.surface(.more))
        XCTAssertEqual(model.selectedSettingsPane, .profile)
        XCTAssertEqual(settingsOpeningService.openSettingsCalls, 1)

        model.handleDeepLink(.settings)
        XCTAssertEqual(model.selectedSettingsPane, .profile)
        XCTAssertEqual(settingsOpeningService.openSettingsCalls, 2)

        model.handleDeepLink(.premium)
        XCTAssertEqual(model.selectedSurface, .premium)
        XCTAssertEqual(model.supportPremiumSurfaceRaw, SupportPremiumSurface.upgrade.rawValue)
    }

    func testDeepLinkParserIncludesMacSettingsAndPremiumTargets() throws {
        XCTAssertEqual(AppDeepLinkTarget.parse(url: UIConstants.deepLinkSettingsURL), .settings)
        XCTAssertEqual(AppDeepLinkTarget.parse(url: UIConstants.deepLinkPremiumURL), .premium)
        XCTAssertEqual(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "catholicfasting://more"))), .settings)
        XCTAssertEqual(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "catholicfasting://toolkit"))), .premium)
    }

    func testOpenSettingsSelectsPaneAndInvokesSettingsOpener() {
        let model = makeModel()

        model.openSettings(.privacy)

        XCTAssertEqual(model.selectedSettingsPane, .privacy)
        XCTAssertEqual(settingsOpeningService.openSettingsCalls, 1)
    }

    func testDeepLinkParserAcceptsDesktopRouteAliasesAndRejectsUnknownSchemes() throws {
        XCTAssertEqual(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "catholicfasting://calendar"))), .surface(.fastingDays))
        XCTAssertEqual(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "catholicfasting://fastingdays"))), .surface(.fastingDays))
        XCTAssertEqual(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "catholicfasting://track"))), .surface(.intermittent))
        XCTAssertEqual(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "catholicfasting://fast"))), .surface(.intermittent))
        XCTAssertEqual(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "catholicfasting://support-premium"))), .premium)
        XCTAssertEqual(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "catholicfasting://support"))), .premium)
        XCTAssertNil(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "https://example.com/today"))))
        XCTAssertNil(try AppDeepLinkTarget.parse(url: XCTUnwrap(URL(string: "catholicfasting://unknown"))))
    }

    func testApplyScheduleSchedulesReminderWhenConsentIsAccepted() async {
        let model = makeModel()
        let plan = IntermittentSchedulePlan(
            id: "schedule-1",
            name: "Weeknight 16h",
            targetHours: 16,
            startHour: 20,
            weekdays: [2, 4, 6])
        model.acceptedLegalNotice = true

        await model.applySchedule(plan)

        XCTAssertEqual(model.activeIntermittentScheduleID, plan.id)
        XCTAssertEqual(model.intermittentTracker.presetHours, plan.targetHours)
        XCTAssertEqual(reminderService.scheduledPlan?.id, plan.id)
        XCTAssertEqual(model.notificationStatus, "scheduled \(plan.name)")
    }

    func testApplyScheduleFallsBackToConsentMessageWhenNoticeIsMissing() async {
        let model = makeModel()
        let plan = IntermittentSchedulePlan(
            id: "schedule-2",
            name: "Office Fast",
            targetHours: 18,
            startHour: 19,
            weekdays: [1, 3, 5])

        await model.applySchedule(plan)

        XCTAssertNil(reminderService.scheduledPlan)
        XCTAssertTrue(model.notificationStatus.contains("Confirm privacy consent"))
    }

    func testRefreshDailyQuoteReminderUpdatesSignatureWhenInputsChange() async {
        let model = makeModel()
        model.acceptedLegalNotice = true
        model.dailyQuoteReminderEnabled = true
        reminderService.notificationsAuthorized = true
        reminderService.pendingDailyQuoteReminderCountValue = 0

        await model.refreshDailyQuoteReminderIfNeeded()

        XCTAssertEqual(reminderService.scheduleDailyQuoteReminderCalls, 1)
        XCTAssertEqual(model.dailyQuoteReminderSignature, "enabled|12|0|en|consented|authorized|0")
    }

    func testScheduleRequiredDayRemindersUsesReminderServiceWhenConsentAccepted() async {
        let model = makeModel()
        model.acceptedLegalNotice = true
        reminderService.topUpRequiredRemindersMessage = "Required reminders scheduled"

        await model.scheduleRequiredDayReminders()

        XCTAssertEqual(reminderService.topUpRequiredRemindersCalls, 1)
        XCTAssertEqual(model.notificationStatus, "Required reminders scheduled")
    }

    func testScheduleDailySupportRemindersRespectsPremiumGate() async {
        let model = makeModel()
        model.acceptedLegalNotice = true
        model.dailyReminderSupportEnabled = true
        model.morningReminderEnabled = true

        await model.scheduleDailySupportReminders()

        XCTAssertEqual(reminderService.scheduleHabitSupportCalls, 0)
        XCTAssertEqual(model.notificationStatus, "Premium is required for daily support reminders.")
    }

    func testScheduleDailySupportRemindersRequiresConsentEvenWhenPremiumIsUnlocked() async {
        let model = makeModel()
        model.monetizationStore.premiumUnlocked = true
        model.dailyReminderSupportEnabled = true
        model.morningReminderEnabled = true

        await model.scheduleDailySupportReminders()

        XCTAssertEqual(reminderService.scheduleHabitSupportCalls, 0)
        XCTAssertEqual(model.notificationStatus, "Confirm privacy consent before scheduling reminders.")
    }

    func testScheduleDailySupportRemindersRunsWhenPremiumConsentAndToggleAreEnabled() async {
        let model = makeModel()
        model.monetizationStore.premiumUnlocked = true
        model.acceptedLegalNotice = true
        model.dailyReminderSupportEnabled = true
        model.morningReminderEnabled = true
        model.eveningReminderEnabled = true

        await model.scheduleDailySupportReminders()

        XCTAssertEqual(reminderService.scheduleHabitSupportCalls, 1)
        XCTAssertEqual(model.notificationStatus, "support reminders scheduled")
    }

    func testScheduleDailySupportRemindersRequiresSupportToggle() async {
        let model = makeModel()
        model.monetizationStore.premiumUnlocked = true
        model.acceptedLegalNotice = true
        model.dailyReminderSupportEnabled = false

        await model.scheduleDailySupportReminders()

        XCTAssertEqual(reminderService.scheduleHabitSupportCalls, 0)
        XCTAssertEqual(model.notificationStatus, "Enable daily support reminders first.")
    }

    func testRequestReminderPermissionUpdatesNotificationStatus() async {
        let model = makeModel()

        await model.requestReminderPermission()

        XCTAssertEqual(model.notificationStatus, "granted")
        XCTAssertEqual(reminderService.requestPermissionCalls, 1)
    }

    func testRefreshReminderStatusUsesReminderSummary() async {
        let model = makeModel()

        await model.refreshReminderStatus()

        XCTAssertEqual(model.notificationStatus, "summary")
        XCTAssertEqual(reminderService.notificationSummaryCalls, 1)
    }

    func testScheduleDailyQuoteReminderFromSettingsRequiresConsent() async {
        let model = makeModel()
        model.dailyQuoteReminderEnabled = true

        await model.scheduleDailyQuoteReminderFromCurrentSettings()

        XCTAssertEqual(reminderService.scheduleDailyQuoteReminderCalls, 0)
        XCTAssertEqual(model.notificationStatus, "Confirm privacy consent before scheduling reminders.")
    }

    func testScheduleDailyQuoteReminderFromSettingsUpdatesSignatureWhenConsented() async {
        let model = makeModel()
        model.acceptedLegalNotice = true
        model.dailyQuoteReminderEnabled = true
        model.dailyQuoteReminderHour = 7
        model.dailyQuoteReminderMinute = 30

        await model.scheduleDailyQuoteReminderFromCurrentSettings()

        XCTAssertEqual(reminderService.scheduleDailyQuoteReminderCalls, 1)
        XCTAssertEqual(model.notificationStatus, "quote scheduled")
        XCTAssertEqual(model.dailyQuoteReminderSignature, "enabled|7|30|en|consented|authorized|0")
    }

    func testAddReflectionPrependsTrimmedEntry() {
        let model = makeModel()

        model.addReflection(title: "  Evening examen  ", body: "  Stayed disciplined today.  ")

        XCTAssertEqual(model.reflectionEntries.count, 1)
        XCTAssertEqual(model.reflectionEntries[0].title, "Evening examen")
        XCTAssertEqual(model.reflectionEntries[0].body, "Stayed disciplined today.")
    }

    func testCopyExportUsesShareService() {
        let model = makeModel()

        model.copyExportToPasteboard()

        XCTAssertNotNil(sharingService.lastCopiedText)
        XCTAssertTrue(sharingService.lastCopiedText?.contains("generated_at") == true)
    }

    func testCopyPremiumSummaryUsesShareServiceAndIncludesPremiumSections() {
        let model = makeModel()

        model.copyPremiumSummaryToPasteboard()

        XCTAssertNotNil(sharingService.lastCopiedText)
        XCTAssertTrue(sharingService.lastCopiedText?.contains("Required completion") == true)
        XCTAssertTrue(sharingService.lastCopiedText?.contains("Reminder Strategy") == true)
    }

    func testProfileDispensationPersistsAcrossModelReinitialization() {
        let initialModel = makeModel()
        XCTAssertFalse(initialModel.medicalDispensation)

        initialModel.medicalDispensation = true
        XCTAssertEqual(defaults.object(forKey: StorageKeys.medicalDispensation) as? Bool, true)

        let relaunchedModel = makeModel()
        XCTAssertTrue(relaunchedModel.medicalDispensation)
    }

    func testLanguageRegionAndReminderChoicesPersistAcrossModelReinitialization() {
        let initialModel = makeModel()
        initialModel.languageModeRaw = LanguageMode.spanish.rawValue
        initialModel.regionProfileRaw = RuleSettings.RegionProfile.canada.rawValue
        initialModel.reminderTierRaw = ReminderTier.minimal.rawValue
        initialModel.dailyReminderSupportEnabled = false
        initialModel.morningReminderEnabled = false
        initialModel.eveningReminderEnabled = true

        let relaunchedModel = makeModel()

        XCTAssertEqual(relaunchedModel.languageMode, .spanish)
        XCTAssertEqual(relaunchedModel.regionProfile, .canada)
        XCTAssertEqual(relaunchedModel.reminderTier, .minimal)
        XCTAssertFalse(relaunchedModel.dailyReminderSupportEnabled)
        XCTAssertFalse(relaunchedModel.morningReminderEnabled)
        XCTAssertTrue(relaunchedModel.eveningReminderEnabled)
    }

    func testWidgetSnapshotPersistsForActiveAndInactiveIntermittentFast() {
        let model = makeModel()

        model.startFast()
        let activeSnapshot = WidgetSnapshotStore.load()
        XCTAssertEqual(activeSnapshot?.hasActiveIntermittentFast, true)
        XCTAssertEqual(activeSnapshot?.activeIntermittentTargetHours, model.intermittentTracker.presetHours)

        model.endFast()
        let endedSnapshot = WidgetSnapshotStore.load()
        XCTAssertEqual(endedSnapshot?.hasActiveIntermittentFast, false)
    }

    func testMenuBarStringsReflectActiveFastState() {
        let model = makeModel()

        XCTAssertEqual(model.menuBarTitle, "Catholic Fasting")
        XCTAssertEqual(model.menuBarSubtitle, "No active intermittent fast")

        model.startFast()

        XCTAssertEqual(model.menuBarTitle, "Fast Active")
        XCTAssertTrue(model.menuBarSubtitle.contains("of \(model.intermittentTracker.presetHours)h goal"))
    }

    func testIntermittentScheduleCreateUpdateDeletePersistsAcrossModelReinitialization() throws {
        let initialModel = makeModel()
        let startingCount = initialModel.intermittentSchedules.count

        initialModel.addOrUpdateSchedule(name: "Desk Fast", startHour: 25, weekdays: [2, 4, 8])

        XCTAssertEqual(initialModel.intermittentSchedules.count, startingCount + 1)
        let created = initialModel.intermittentSchedules.last
        XCTAssertEqual(created?.name, "Desk Fast")
        XCTAssertEqual(created?.startHour, 23)
        XCTAssertEqual(created?.weekdays, [2, 4])
        XCTAssertEqual(initialModel.activeIntermittentScheduleID, created?.id)

        let relaunchedModel = makeModel()
        guard let createdAfterRelaunch = relaunchedModel.intermittentSchedules.first(where: { $0.name == "Desk Fast" }) else {
            XCTFail("Expected created schedule to persist across model reinitialization")
            return
        }

        relaunchedModel.addOrUpdateSchedule(name: "", startHour: -4, weekdays: [1, 3], editingID: createdAfterRelaunch.id)
        let updated = relaunchedModel.intermittentSchedules.first(where: { $0.id == createdAfterRelaunch.id })
        XCTAssertEqual(updated?.name, "Desk Fast")
        XCTAssertEqual(updated?.startHour, 0)
        XCTAssertEqual(updated?.weekdays, [1, 3])

        try relaunchedModel.deleteSchedule(XCTUnwrap(updated))
        XCTAssertNil(relaunchedModel.intermittentSchedules.first(where: { $0.id == createdAfterRelaunch.id }))
        XCTAssertNotEqual(relaunchedModel.activeIntermittentScheduleID, createdAfterRelaunch.id)
    }

    func testIntermittentCompletedSessionImprovesPremiumAnalytics() {
        let model = makeModel()
        model.intermittentTracker.setPresetHours(16)
        model.intermittentTracker.startFast(now: Date().addingTimeInterval(-17 * 3600))

        model.endFast()

        XCTAssertEqual(model.intermittentTracker.sessions.count, 1)
        XCTAssertEqual(model.premiumAnalyticsSummary.intermittentTargetHitPercent, 100)
    }

    func testApplyPremiumRuleTemplateUpdatesPlannerState() {
        let model = makeModel()

        model.applyPremiumRuleTemplate(.traditional)

        XCTAssertEqual(model.selectedPremiumTemplate, .traditional)
        XCTAssertEqual(model.premiumCompanion.optionalDisciplinesPerWeek, 4)
        XCTAssertEqual(model.premiumCompanionStatus, "Traditional template applied.")
    }

    func testApplyPremiumReminderRecommendationAdjustsReminderTogglesAndTier() {
        let model = makeModel()

        model.applyPremiumReminderRecommendation()

        XCTAssertTrue(model.dailyReminderSupportEnabled)
        XCTAssertFalse(model.reminderTierRaw.isEmpty)
        XCTAssertFalse(model.premiumCoachStatus.isEmpty)
    }

    func testApplyPremiumConditionRulesUsesAdvancedReminderAdvisor() {
        let model = makeModel()
        model.premiumCompanion.conditionRules.remindIfUnloggedByNoon = false
        model.premiumCompanion.conditionRules.requiredDaysDoubleReminder = true
        model.premiumCompanion.conditionRules.milestoneNudgesForActiveFast = false

        model.applyPremiumConditionRules()

        XCTAssertTrue(model.dailyReminderSupportEnabled)
        XCTAssertFalse(model.premiumCompanionStatus.isEmpty)
    }

    func testRestartPremiumSeasonProgramClearsCompletedActions() {
        let model = makeModel()
        let firstAction = model.journeyWeek.actions[0]

        model.toggleJourneyAction(firstAction.id)
        XCTAssertTrue(model.isJourneyActionCompleted(firstAction.id))

        model.restartPremiumSeasonProgram()

        XCTAssertFalse(model.isJourneyActionCompleted(firstAction.id))
        XCTAssertTrue(model.premiumCompanionStatus.contains("restarted"))
    }

    func testPremiumChecklistTogglePersistsAcrossModelReinitialization() {
        let initialModel = makeModel()
        initialModel.premiumChecklist = [
            PremiumChecklistItem(id: "mac-check", title: "Review Friday plan", isDone: false),
        ]

        initialModel.toggleChecklistItem(initialModel.premiumChecklist[0])

        let relaunchedModel = makeModel()
        XCTAssertEqual(relaunchedModel.premiumChecklist.first?.title, "Review Friday plan")
        XCTAssertEqual(relaunchedModel.premiumChecklist.first?.isDone, true)
    }

    func testPremiumAnalyticsCountsCompletedMissedAndSubstitutedObservances() {
        let model = makeModel()
        let required = model.currentYearObservances.filter { $0.obligation == .mandatory }
        XCTAssertGreaterThanOrEqual(required.count, 3)

        model.setStatus(.completed, for: required[0])
        model.setStatus(.substituted, for: required[1])
        model.setStatus(.missed, for: required[2])

        XCTAssertGreaterThan(model.premiumAnalyticsSummary.requiredCompletionPercent, 0)
        XCTAssertEqual(model.premiumAnalyticsSummary.substitutedCount, 1)
        XCTAssertEqual(model.premiumAnalyticsSummary.missedCount, 1)
        XCTAssertFalse(model.premiumAnalyticsSummary.seasonRows.isEmpty)
    }

    func testVirtueLogsCanBeAddedAndDeleted() {
        let model = makeModel()
        model.selectedVirtue = "Patience"

        model.addPremiumVirtueLog(note: "Stayed steady during Friday hunger.")

        XCTAssertEqual(model.premiumCompanion.virtueLogs.count, 1)
        XCTAssertEqual(model.premiumCompanion.virtueLogs[0].virtue, "Patience")

        let log = model.premiumCompanion.virtueLogs[0]
        model.deletePremiumVirtueLog(log)

        XCTAssertTrue(model.premiumCompanion.virtueLogs.isEmpty)
    }

    func testHouseholdShareCodeRoundTripsPlanningScheduleAndChecklist() {
        let source = makeModel()
        source.planningData.requiredGoal = 18
        source.premiumChecklist = [
            PremiumChecklistItem(id: "check-1", title: "Plan Friday penance", isDone: false),
        ]
        source.intermittentSchedules = [
            IntermittentSchedulePlan(id: "schedule-1", name: "Weekday", targetHours: 16, startHour: 19, weekdays: [2, 4, 6]),
        ]

        source.generatePremiumHouseholdShareCode()
        XCTAssertFalse(source.premiumHouseholdExportCode.isEmpty)

        let target = makeModel()
        target.premiumHouseholdImportCode = source.premiumHouseholdExportCode

        target.importPremiumHouseholdShareCode()

        XCTAssertEqual(target.planningData.requiredGoal, 18)
        XCTAssertEqual(target.premiumChecklist.first?.title, "Plan Friday penance")
        XCTAssertEqual(target.intermittentSchedules.first?.name, "Weekday")
        XCTAssertEqual(target.premiumCompanionStatus, "Household packet imported locally.")
    }

    func testInvalidHouseholdShareCodeDoesNotOverwriteLocalState() {
        let model = makeModel()
        model.planningData.requiredGoal = 33
        model.premiumChecklist = [
            PremiumChecklistItem(id: "local-check", title: "Keep local plan", isDone: false),
        ]
        model.premiumHouseholdImportCode = "not valid base64"

        model.importPremiumHouseholdShareCode()

        XCTAssertEqual(model.planningData.requiredGoal, 33)
        XCTAssertEqual(model.premiumChecklist.first?.title, "Keep local plan")
        XCTAssertEqual(model.premiumCompanionStatus, "Invalid share code.")
    }

    func testGeneratedHouseholdShareCodeCanBeCopied() {
        let model = makeModel()

        model.copyPremiumHouseholdCodeToPasteboard()
        XCTAssertNil(sharingService.lastCopiedText)

        model.generatePremiumHouseholdShareCode()
        model.copyPremiumHouseholdCodeToPasteboard()

        XCTAssertEqual(sharingService.lastCopiedText, model.premiumHouseholdExportCode)
        XCTAssertEqual(model.premiumCompanionStatus, "Household share code copied.")
    }

    func testGuidanceAndCalendarOutputsReflectCanadaRegionProfile() {
        let model = makeModel()
        model.regionProfileRaw = RuleSettings.RegionProfile.canada.rawValue

        XCTAssertEqual(model.regionProfile, .canada)
        XCTAssertFalse(model.generalRegionalContext.classificationLabel.isEmpty)
        XCTAssertFalse(model.visibleCalendarObservances.isEmpty)
    }

    func testRuntimeBundleUsesReleaseVersionAndUniversalAppIdentifier() {
        #if DEBUG
        XCTAssertEqual(Bundle.main.bundleIdentifier, "com.kevpierce.CatholicFastingApp.macdebug")
        #else
        XCTAssertEqual(Bundle.main.bundleIdentifier, "com.kevpierce.CatholicFastingApp")
        #endif
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, "4.2")
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String, "15")
    }

    func testDeleteAllDataResetsDefaultsAndLocalStores() {
        let model = makeModel()
        model.acceptedLegalNotice = true
        model.didCompleteOnboarding = true
        model.languageModeRaw = LanguageMode.spanish.rawValue
        model.regionProfileRaw = RuleSettings.RegionProfile.canada.rawValue
        model.dailyQuoteReminderEnabled = true
        model.addReflection(title: "Journal", body: "Entry")
        model.startFast()
        XCTAssertFalse(model.reflectionEntries.isEmpty)
        XCTAssertNotNil(WidgetSnapshotStore.load())

        model.deleteAllData()

        XCTAssertFalse(model.acceptedLegalNotice)
        XCTAssertFalse(model.didCompleteOnboarding)
        XCTAssertEqual(model.languageModeRaw, DefaultValues.language.rawValue)
        XCTAssertEqual(model.regionProfileRaw, DefaultValues.regionProfile.rawValue)
        XCTAssertFalse(model.dailyQuoteReminderEnabled)
        XCTAssertTrue(model.reflectionEntries.isEmpty)
        XCTAssertNil(model.intermittentTracker.activeStart)
        XCTAssertEqual(model.notificationStatus, "All local data deleted")
        XCTAssertNotNil(WidgetSnapshotStore.load())
    }

    private func makeModel(isUITestMode: Bool = false) -> CatholicFastingMacModel {
        CatholicFastingMacModel(
            defaults: defaults,
            services: CatholicFastingMacPlatformServices(
                reminders: reminderService,
                sharing: sharingService,
                activeFastStatus: DefaultActiveFastStatusSurfaceService(),
                seasonalAppearance: seasonalService,
                settingsOpening: settingsOpeningService),
            isUITestMode: isUITestMode)
    }
}

@MainActor
private final class TestReminderPlatformService: ReminderPlatformServicing {
    private(set) var scheduledPlan: IntermittentSchedulePlan?
    private(set) var requestPermissionCalls = 0
    private(set) var notificationSummaryCalls = 0
    private(set) var topUpRequiredRemindersCalls = 0
    private(set) var scheduleDailyQuoteReminderCalls = 0
    private(set) var scheduleHabitSupportCalls = 0
    var topUpRequiredRemindersMessage = "required reminders ready"
    var notificationsAuthorized = true
    var pendingDailyQuoteReminderCountValue = 0

    func requestPermission() async -> String {
        requestPermissionCalls += 1
        return "granted"
    }

    func topUpRequiredReminders(observances _: [Observance]) async -> String? {
        topUpRequiredRemindersCalls += 1
        return topUpRequiredRemindersMessage
    }

    func notificationSummary() async -> String {
        notificationSummaryCalls += 1
        return "summary"
    }

    func scheduleHabitSupport(morning _: Bool, evening _: Bool) async -> String {
        scheduleHabitSupportCalls += 1
        return "support reminders scheduled"
    }

    func scheduleDailyQuoteReminder(
        enabled _: Bool,
        hour _: Int,
        minute _: Int,
        languageMode _: LanguageMode) async -> String
    {
        scheduleDailyQuoteReminderCalls += 1
        return "quote scheduled"
    }

    func scheduleIntermittentPlan(_ plan: IntermittentSchedulePlan) async -> String {
        scheduledPlan = plan
        return "scheduled \(plan.name)"
    }

    func notificationsAuthorizedForScheduling() async -> Bool {
        notificationsAuthorized
    }

    func pendingDailyQuoteReminderCount() async -> Int {
        pendingDailyQuoteReminderCountValue
    }
}

@MainActor
private final class TestSharePayloadPlatformService: SharePayloadPlatformServicing {
    private(set) var lastCopiedText: String?

    func copy(_ text: String) {
        lastCopiedText = text
    }
}

@MainActor
private final class TestSeasonalAppearancePlatformService: SeasonalAppearancePlatformServicing {
    private(set) var handleSceneDidBecomeActiveCalls = 0

    func handleSceneDidBecomeActive() async {
        handleSceneDidBecomeActiveCalls += 1
    }
}

@MainActor
private final class TestSettingsOpeningPlatformService: SettingsOpeningPlatformServicing {
    private(set) var openSettingsCalls = 0

    func openSettings() {
        openSettingsCalls += 1
    }
}
