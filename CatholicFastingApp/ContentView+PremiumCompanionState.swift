import SwiftUI

extension ContentView {
    var premiumSeasonPlan: PremiumSeasonPlan {
        PremiumSeasonPlanEngine.plan(for: currentLiturgicalSeason, settings: settings)
    }

    var selectedPremiumTemplate: PremiumRuleTemplate {
        PremiumRuleTemplate(rawValue: premiumCompanion.templateRawValue) ?? .steady
    }

    var selectedPremiumSeasonProgram: PremiumSeasonProgram {
        PremiumSeasonProgram(rawValue: premiumCompanion.seasonProgramRawValue) ?? .liturgicalRhythm
    }

    var premiumProgramWeek: Int {
        let now = AppClock.now()
        let days =
            liturgicalCalendar.dateComponents(
                [.day],
                from: liturgicalCalendar.startOfDay(for: premiumCompanion.seasonProgramStartDate),
                to: liturgicalCalendar.startOfDay(for: now)).day ?? 0
        return max(1, (days / 7) + 1)
    }

    var premiumAdaptivePlan: PremiumAdaptiveRulePlan {
        PremiumAdaptiveRulePlanner.plan(
            season: currentLiturgicalSeason,
            settings: settings,
            template: selectedPremiumTemplate,
            optionalDisciplinesPerWeek: premiumCompanion.optionalDisciplinesPerWeek,
            fixedFastWeekday: premiumCompanion.fixedFastWeekday,
            protectFeastDays: premiumCompanion.protectFeastDays)
    }

    var premiumReminderRecommendation: PremiumReminderRecommendation {
        PremiumReminderPlanner.recommendation(
            observances: currentYearObservances,
            statusesByID: tracker.statusesByID)
    }

    var premiumConditionRuleRecommendation: PremiumReminderRecommendation {
        PremiumConditionReminderAdvisor.applyRules(
            premiumCompanion.conditionRules,
            hasUpcomingRequiredDays: upcomingMandatoryObservance != nil)
    }

    var premiumAnalyticsSummary: PremiumAnalyticsSummary {
        PremiumAnalyticsEngine.summary(
            observances: currentYearObservances,
            statusesByID: tracker.statusesByID,
            sessions: intermittentTracker.sessions)
    }

    var premiumReflection: PremiumReflection {
        PremiumReflectionEngine.reflection(
            season: currentLiturgicalSeason)
    }

    var premiumRecoveryCoachPlan: PremiumRecoveryCoachPlan {
        PremiumRecoveryCoachEngine.plan(
            missedPlan: missedDayRecoveryPlan,
            season: currentLiturgicalSeason)
    }

    var premiumGuidedJourneyWeek: GuidedSeasonalJourneyWeek {
        GuidedSeasonalJourneyEngine.week(
            for: currentLiturgicalSeason,
            program: selectedPremiumSeasonProgram,
            week: premiumProgramWeek)
    }

    var premiumJourneyProgress: GuidedSeasonalJourneyProgress {
        GuidedSeasonalJourneyEngine.progress(
            for: premiumGuidedJourneyWeek,
            completedActionKeys: premiumCompanion.completedProgramActions)
    }

    var premiumGuidedJourneyNextAction: GuidedSeasonalJourneyAction? {
        premiumJourneyProgress.nextAction
    }

    var premiumJourneyCompletionSummary: String {
        premiumJourneyProgress.completionSummary
    }

    var premiumMotivationLine: String {
        PremiumMotivationEngine.line(
            season: currentLiturgicalSeason,
            streak: currentStreak,
            template: selectedPremiumTemplate)
    }

    var premiumDirectionSummaryText: String {
        PremiumDirectionSummaryEngine.summaryText(
            season: currentLiturgicalSeason,
            analytics: premiumAnalyticsSummary,
            reminder: premiumReminderRecommendation,
            plan: premiumSeasonPlan,
            latestReflection: premiumReflection)
    }

    var premiumWeeklySummaryText: String {
        let now = AppClock.now()
        let start = liturgicalCalendar.date(byAdding: .day, value: -6, to: now) ?? now
        let weeklyObservances = currentYearObservances.filter { $0.date >= start && $0.date <= now }
        let completed = weeklyObservances.count(where: { tracker.status(for: $0.id).countsTowardProgress })
        return [
            localized("premium.export.weekly.title", default: "Catholic Fasting Weekly Report"),
            localizedFormat(
                "premium.export.weekly.ending_format",
                default: "Week ending %@",
                localizedAbbreviatedDate(now)),
            "",
            localizedFormat(
                "premium.export.completed_observances_format",
                default: "Completed observances: %d/%d",
                completed,
                weeklyObservances.count),
            localizedFormat(
                "premium.export.current_rhythm_format",
                default: "Current rhythm: %d days",
                currentStreak),
            localizedFormat(
                "premium.export.template_format",
                default: "Template: %@",
                selectedPremiumTemplate.label),
            localizedFormat(
                "premium.export.program_week_format",
                default: "Program: %@ (Week %d)",
                selectedPremiumSeasonProgram.label,
                premiumProgramWeek),
            localizedFormat(
                "premium.export.reflection_format",
                default: "Reflection: %@",
                premiumMotivationLine),
        ].joined(separator: "\n")
    }

    var premiumMonthlySummaryText: String {
        let now = AppClock.now()
        let month = liturgicalCalendar.component(.month, from: now)
        let year = liturgicalCalendar.component(.year, from: now)
        let monthlyObservances = currentYearObservances.filter {
            liturgicalCalendar.component(.month, from: $0.date) == month
                && liturgicalCalendar.component(.year, from: $0.date) == year
        }
        let completed = monthlyObservances.count(where: { tracker.status(for: $0.id).countsTowardProgress })
        return [
            localized("premium.export.monthly.title", default: "Catholic Fasting Monthly Report"),
            localizedFormat(
                "premium.export.monthly.month_format",
                default: "Month: %@",
                localizedMonthYear(now)),
            "",
            localizedFormat(
                "premium.export.completed_observances_format",
                default: "Completed observances: %d/%d",
                completed,
                monthlyObservances.count),
            localizedFormat(
                "premium.analytics.required_format",
                default: "Required completion: %d%%",
                premiumAnalyticsSummary.requiredCompletionPercent),
            localizedFormat(
                "premium.analytics.overall_format",
                default: "Overall completion: %d%%",
                premiumAnalyticsSummary.overallCompletionPercent),
            localizedFormat(
                "premium.analytics.personal_fast_hits_format",
                default: "Personal fast targets met: %d%%",
                premiumAnalyticsSummary.intermittentTargetHitPercent),
            localizedFormat(
                "premium.export.reflection_format",
                default: "Reflection: %@",
                premiumMotivationLine),
        ].joined(separator: "\n")
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
        premiumCompanionStatus = localizedFormat(
            "premium.status.template_applied_format",
            default: "%@ template applied.",
            template.label)
    }

    func togglePremiumSeasonProgramAction(_ action: String) {
        let key = GuidedSeasonalJourneyEngine.actionKey(
            program: selectedPremiumSeasonProgram,
            week: premiumProgramWeek,
            actionID: action)
        if premiumCompanion.completedProgramActions.contains(key) {
            premiumCompanion.completedProgramActions.removeAll { $0 == key }
        } else {
            premiumCompanion.completedProgramActions.append(key)
        }
    }

    func isPremiumSeasonProgramActionCompleted(_ action: String) -> Bool {
        let key = GuidedSeasonalJourneyEngine.actionKey(
            program: selectedPremiumSeasonProgram,
            week: premiumProgramWeek,
            actionID: action)
        return premiumCompanion.completedProgramActions.contains(key)
    }

    func togglePremiumJourneyAction(_ action: GuidedSeasonalJourneyAction) {
        togglePremiumSeasonProgramAction(action.id)
    }

    func isPremiumJourneyActionCompleted(_ action: GuidedSeasonalJourneyAction) -> Bool {
        isPremiumSeasonProgramActionCompleted(action.id)
    }

    func addPremiumVirtueLog() {
        let trimmed = newVirtueNote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        premiumCompanion.virtueLogs.insert(
            PremiumVirtueLog(
                id: UUID().uuidString,
                createdAt: Date(),
                virtue: selectedVirtue,
                note: trimmed),
            at: 0)
        newVirtueNote = ""
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
            premiumCompanionStatus = localized(
                "premium.status.household_export_failed",
                default: "The household share code could not be created.")
            return
        }
        premiumHouseholdExportCode = data.base64EncodedString()
        premiumCompanionStatus = localized(
            "premium.status.household_export_ready",
            default: "Household share code created.")
    }

    func importPremiumHouseholdShareCode() {
        let code = premiumHouseholdImportCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty, let data = Data(base64Encoded: code) else {
            premiumCompanionStatus = localized(
                "premium.status.household_import_invalid",
                default: "Enter a valid household share code.")
            return
        }
        guard let packet = try? JSONDecoder().decode(PremiumHouseholdSharePacket.self, from: data) else {
            premiumCompanionStatus = localized(
                "premium.status.household_import_failed",
                default: "The household share code could not be read.")
            return
        }
        planningData = packet.planningData
        intermittentSchedules = packet.schedules
        premiumChecklist = packet.checklist
        premiumCompanionStatus = localized(
            "premium.status.household_imported",
            default: "Household settings imported on this device.")
    }
}
