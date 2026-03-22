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
        let days =
            liturgicalCalendar.dateComponents(
                [.day],
                from: liturgicalCalendar.startOfDay(for: premiumCompanion.seasonProgramStartDate),
                to: liturgicalCalendar.startOfDay(for: Date())).day ?? 0
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

    var premiumSeasonProgramActions: [String] {
        PremiumSeasonProgramEngine.actions(
            for: selectedPremiumSeasonProgram,
            week: premiumProgramWeek)
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

    var premiumJourneyCompletedCount: Int {
        premiumJourneyProgress.completedCount
    }

    var premiumGuidedJourneyNextAction: GuidedSeasonalJourneyAction? {
        premiumJourneyProgress.nextAction
    }

    var premiumJourneyCompletionSummary: String {
        premiumJourneyProgress.completionSummary
    }

    var premiumPrepAndRefeedGuidance: [String] {
        PremiumFastPrepGuidanceEngine.prepAndRefeed(
            targetHours: intermittentTracker.presetHours,
            hasMedicalDispensation: settings.hasMedicalDispensation)
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
        let start = liturgicalCalendar.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        let weeklyObservances = currentYearObservances.filter { $0.date >= start && $0.date <= Date() }
        let completed = weeklyObservances.count(where: { tracker.status(for: $0.id).countsTowardProgress })
        return [
            "Catholic Fasting Weekly Report",
            "Week ending \(Date().formatted(date: .abbreviated, time: .omitted))",
            "",
            "Completed observances: \(completed)/\(weeklyObservances.count)",
            "Current streak: \(currentStreak) day(s)",
            "Template: \(selectedPremiumTemplate.label)",
            "Program: \(selectedPremiumSeasonProgram.label) (Week \(premiumProgramWeek))",
            "Motivation: \(premiumMotivationLine)",
        ].joined(separator: "\n")
    }

    var premiumMonthlySummaryText: String {
        let month = liturgicalCalendar.component(.month, from: Date())
        let year = liturgicalCalendar.component(.year, from: Date())
        let monthlyObservances = currentYearObservances.filter {
            liturgicalCalendar.component(.month, from: $0.date) == month
                && liturgicalCalendar.component(.year, from: $0.date) == year
        }
        let completed = monthlyObservances.count(where: { tracker.status(for: $0.id).countsTowardProgress })
        return [
            "Catholic Fasting Monthly Report",
            "Month: \(Date().formatted(.dateTime.month(.wide).year()))",
            "",
            "Completed observances: \(completed)/\(monthlyObservances.count)",
            "Required completion: \(premiumAnalyticsSummary.requiredCompletionPercent)%",
            "Overall completion: \(premiumAnalyticsSummary.overallCompletionPercent)%",
            "Intermittent target hit rate: \(premiumAnalyticsSummary.intermittentTargetHitPercent)%",
            "Motivation: \(premiumMotivationLine)",
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
        premiumCompanionStatus = "\(template.label) template applied."
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

    func restartPremiumSeasonProgram() {
        premiumCompanion.seasonProgramStartDate = Date()
        premiumCompanion.completedProgramActions = []
        premiumCompanionStatus = "\(selectedPremiumSeasonProgram.label) restarted."
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
}
