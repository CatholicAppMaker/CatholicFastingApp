import AppKit
import SwiftUI

@MainActor
extension CatholicFastingMacModel {
    func bringAppToFront() {
        NSApp.activate(ignoringOtherApps: true)
    }

    func openSettingsWindow() {
        bringAppToFront()
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    func openSettings(_ pane: CatholicFastingMacSettingsPane) {
        selectedSettingsPane = pane
        openSettingsWindow()
    }

    func performInitialStartupTasks() async {
        if launchFunnelSnapshot.completedOnboardingAt == nil {
            launchFunnelSnapshot.startedAt = Date()
        }
        launchFunnelSnapshot.selectedRegionRaw = regionProfileRaw
        launchFunnelSnapshot.selectedReminderTierRaw = reminderTierRaw
        ensureSelections()
        persistWidgetSnapshot()
        await monetizationStore.refreshCatalogAndEntitlements()
        guard !isUITestMode else {
            notificationStatus = "UI Test Mode"
            return
        }
        _ = await services.reminders.topUpRequiredReminders(observances: rollingUpcomingObservances)
        await refreshDailyQuoteReminderIfNeeded()
        notificationStatus = await services.reminders.notificationSummary()
        await services.seasonalAppearance.handleSceneDidBecomeActive()
    }

    func completeOnboarding() {
        didCompleteOnboarding = true
        launchFunnelSnapshot.completedOnboardingAt = Date()
        applyReminderTier(reminderTier)
    }

    func requestReminderPermission() async {
        notificationStatus = await services.reminders.requestPermission()
    }

    func applyReminderTier(_ tier: ReminderTier) {
        reminderTierRaw = tier.rawValue
        dailyReminderSupportEnabled = tier.supportEnabled
        morningReminderEnabled = tier.morningEnabled
        eveningReminderEnabled = tier.eveningEnabled
        launchFunnelSnapshot.selectedReminderTierRaw = tier.rawValue
    }

    func syncReminderTierFromCurrentToggleState() {
        let tier = ReminderTier.infer(
            supportEnabled: dailyReminderSupportEnabled,
            morningEnabled: morningReminderEnabled,
            eveningEnabled: eveningReminderEnabled)
        reminderTierRaw = tier.rawValue
        launchFunnelSnapshot.selectedReminderTierRaw = tier.rawValue
    }

    func scheduleRequiredDayReminders() async {
        guard acceptedLegalNotice else {
            notificationStatus = "Confirm privacy consent before scheduling reminders."
            return
        }
        notificationStatus =
            await services.reminders.topUpRequiredReminders(observances: rollingUpcomingObservances)
                ?? "Required-day reminders are already up to date."
    }

    func scheduleDailyQuoteReminderFromCurrentSettings() async {
        guard acceptedLegalNotice else {
            notificationStatus = "Confirm privacy consent before scheduling reminders."
            return
        }
        notificationStatus = await services.reminders.scheduleDailyQuoteReminder(
            enabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            languageMode: languageMode)
        dailyQuoteReminderSignature = dailyQuoteReminderStateSignature(
            isEnabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            locale: languageMode.contentLocale,
            consentAccepted: acceptedLegalNotice,
            notificationsAuthorized: true,
            pendingReminderCount: 0)
    }

    func scheduleDailySupportReminders() async {
        guard acceptedLegalNotice else {
            notificationStatus = "Confirm privacy consent before scheduling reminders."
            return
        }
        guard monetizationStore.premiumUnlocked else {
            notificationStatus = "Premium is required for daily support reminders."
            return
        }
        guard dailyReminderSupportEnabled else {
            notificationStatus = "Enable daily support reminders first."
            return
        }
        notificationStatus = await services.reminders.scheduleHabitSupport(
            morning: morningReminderEnabled,
            evening: eveningReminderEnabled)
    }

    func refreshReminderStatus() async {
        notificationStatus = await services.reminders.notificationSummary()
    }

    func refreshDailyQuoteReminderIfNeeded() async {
        let pendingReminderCount = await services.reminders.pendingDailyQuoteReminderCount()
        let notificationsAuthorized = await services.reminders.notificationsAuthorizedForScheduling()
        let signature = dailyQuoteReminderStateSignature(
            isEnabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            locale: languageMode.contentLocale,
            consentAccepted: acceptedLegalNotice,
            notificationsAuthorized: notificationsAuthorized,
            pendingReminderCount: pendingReminderCount)
        guard signature != dailyQuoteReminderSignature else { return }
        notificationStatus = await services.reminders.scheduleDailyQuoteReminder(
            enabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            languageMode: languageMode)
        dailyQuoteReminderSignature = signature
    }

    func copyExportToPasteboard() {
        services.sharing.copy(exportDataText)
    }

    func copyPremiumSummaryToPasteboard() {
        services.sharing.copy(premiumDirectionSummaryText)
    }

    func copyPremiumHouseholdCodeToPasteboard() {
        guard !premiumHouseholdExportCode.isEmpty else { return }
        services.sharing.copy(premiumHouseholdExportCode)
        premiumCompanionStatus = "Household share code copied."
    }

    func applyPremiumReminderRecommendation() {
        let recommendation = premiumReminderRecommendation
        dailyReminderSupportEnabled = recommendation.shouldEnableDailySupport
        morningReminderEnabled = recommendation.shouldEnableMorning
        eveningReminderEnabled = recommendation.shouldEnableEvening
        syncReminderTierFromCurrentToggleState()
        premiumCoachStatus = recommendation.summaryLine
    }

    func applyPremiumConditionRules() {
        let recommendation = premiumConditionRuleRecommendation
        dailyReminderSupportEnabled = recommendation.shouldEnableDailySupport
        morningReminderEnabled = recommendation.shouldEnableMorning
        eveningReminderEnabled = recommendation.shouldEnableEvening
        syncReminderTierFromCurrentToggleState()
        premiumCompanionStatus = recommendation.summaryLine
    }

    func applyPremiumRuleTemplate(_ template: PremiumRuleTemplate) {
        premiumCompanion.templateRawValue = template.rawValue
        switch template {
        case .beginner:
            premiumCompanion.optionalDisciplinesPerWeek = 1
        case .steady:
            premiumCompanion.optionalDisciplinesPerWeek = 2
        case .disciplined:
            premiumCompanion.optionalDisciplinesPerWeek = 3
        case .traditional:
            premiumCompanion.optionalDisciplinesPerWeek = 4
        case .custom:
            break
        }
        premiumCompanionStatus = "\(template.label) template applied."
    }

    func restartPremiumSeasonProgram() {
        premiumCompanion.seasonProgramStartDate = Date()
        premiumCompanion.completedProgramActions = []
        premiumCompanionStatus = "\(selectedPremiumSeasonProgram.label) restarted."
    }

    func addPremiumVirtueLog(note: String? = nil) {
        let value = (note ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return }
        premiumCompanion.virtueLogs.insert(
            PremiumVirtueLog(
                id: UUID().uuidString,
                createdAt: Date(),
                virtue: selectedVirtue,
                note: value),
            at: 0)
    }

    func deletePremiumVirtueLog(_ log: PremiumVirtueLog) {
        premiumCompanion.virtueLogs.removeAll { $0.id == log.id }
    }

    func generatePremiumHouseholdShareCode() {
        let packet = PremiumHouseholdSharePacket(
            generatedAt: Date(),
            planningData: planningData,
            schedules: intermittentSchedules,
            checklist: premiumChecklist)
        guard let data = try? JSONEncoder().encode(packet) else {
            premiumCompanionStatus = "Could not generate household share code."
            return
        }
        premiumHouseholdExportCode = data.base64EncodedString()
        premiumCompanionStatus = "Household share code generated."
    }

    func importPremiumHouseholdShareCode() {
        let code = premiumHouseholdImportCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty, let data = Data(base64Encoded: code) else {
            premiumCompanionStatus = "Invalid share code."
            return
        }
        guard let packet = try? JSONDecoder().decode(PremiumHouseholdSharePacket.self, from: data) else {
            premiumCompanionStatus = "Could not decode household packet."
            return
        }
        planningData = packet.planningData
        intermittentSchedules = packet.schedules
        premiumChecklist = packet.checklist
        premiumCompanionStatus = "Household packet imported locally."
    }

    func deleteAllData() {
        tracker.clearAll()
        penanceNotes.clearAll()
        intermittentTracker.clearAll()
        LocalFeatureStore.clearAll()
        WidgetSnapshotStore.clear()

        planningData = .default
        intermittentSchedules = LocalFeatureStore.loadSchedules()
        activeIntermittentScheduleID = LocalFeatureStore.loadActiveScheduleID() ?? ""
        householdProfiles = LocalFeatureStore.loadProfiles()
        activeHouseholdProfileID = LocalFeatureStore.loadActiveProfileID() ?? ""
        devotionalFavorites = []
        reflectionEntries = []
        premiumChecklist = LocalFeatureStore.loadChecklist()
        premiumCompanion = LocalFeatureStore.loadPremiumCompanionState()
        launchFunnelSnapshot = .default

        age14OrOlderForAbstinence = DefaultValues.age14OrOlderForAbstinence
        age18OrOlderForFasting = DefaultValues.age18OrOlderForFasting
        medicalDispensation = DefaultValues.medicalDispensation
        ascensionRaw = DefaultValues.ascension.rawValue
        fridayModeRaw = DefaultValues.fridayOutsideLent.rawValue
        provinceRaw = DefaultValues.province.rawValue
        calendarModeRaw = DefaultValues.calendarMode.rawValue
        languageModeRaw = DefaultValues.language.rawValue
        regionProfileRaw = DefaultValues.regionProfile.rawValue
        didCompleteOnboarding = false
        acceptedLegalNotice = false
        acceptedLegalNoticeAt = ""
        liturgicalSeasonColorsEnabled = DefaultValues.liturgicalSeasonColorsEnabled
        dailyReminderSupportEnabled = DefaultValues.dailyReminderSupportEnabled
        morningReminderEnabled = DefaultValues.morningReminderEnabled
        eveningReminderEnabled = DefaultValues.eveningReminderEnabled
        dailyQuoteReminderEnabled = DefaultValues.dailyQuoteReminderEnabled
        dailyQuoteReminderHour = DefaultValues.dailyQuoteReminderHour
        dailyQuoteReminderMinute = DefaultValues.dailyQuoteReminderMinute
        dailyQuoteReminderSignature = DefaultValues.dailyQuoteReminderSignature
        reminderTierRaw = DefaultValues.reminderTier.rawValue
        hapticsEnabled = DefaultValues.hapticsEnabled
        fastingDaysShowAllYearDays = false
        fastingDaysIncludeOptionalDays = false
        fastingDaysIncludeFeastAndHolyDays = false
        supportPremiumSurfaceRaw = DefaultValues.supportPremiumSurface.rawValue
        simplifiedModeEnabled = false

        premiumCoachStatus = ""
        premiumCompanionStatus = ""
        selectedVirtue = "Temperance"
        premiumHouseholdImportCode = ""
        premiumHouseholdExportCode = ""
        notificationStatus = "All local data deleted"
        persistWidgetSnapshot()
    }

    func handleDeepLink(_ target: AppDeepLinkTarget) {
        switch target {
        case .surface(let surface):
            switch surface {
            case .today:
                selectedSurface = .today
                bringAppToFront()
            case .fastingDays:
                selectedSurface = .calendar
                bringAppToFront()
            case .intermittent:
                selectedSurface = .intermittent
                bringAppToFront()
            case .more:
                openSettings(.profile)
            }
        case .settings:
            openSettings(.profile)
        case .premium:
            selectedSurface = .premium
            supportPremiumSurfaceRaw = SupportPremiumSurface.upgrade.rawValue
            bringAppToFront()
        }
    }
}
