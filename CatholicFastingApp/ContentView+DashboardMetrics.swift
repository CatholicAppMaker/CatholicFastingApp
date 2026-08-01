import Foundation

extension ContentView {
    var dashboardMetricsSnapshot: DashboardMetricsSnapshot {
        DashboardMetricsSnapshot.build(
            observances: currentYearObservances,
            statusesByID: tracker.statusesByID,
            sessions: intermittentTracker.sessions,
            now: AppClock.now(),
            calendar: liturgicalCalendar)
    }

    var weeklyFormationRecapFree: String {
        if weeklyActionableObservanceCount == 0 {
            return localized(
                "weekly.recap.empty",
                default: "No fasting obligations logged this week yet. Keep your next required day visible.")
        }
        return localizedFormat(
            "weekly.recap.completed_format",
            default: "This week: %d of %d discipline days completed.",
            weeklyCompletedObservancesCount,
            weeklyActionableObservanceCount)
    }

    var weeklyFormationRecapPremium: String {
        let missed = currentYearObservances.count(where: { tracker.status(for: $0.id) == .missed })
        if missed == 0 {
            return localized(
                "weekly.premium.consistent",
                default: "Premium insight: strong consistency. Keep your reminder cadence steady.")
        }
        return localizedFormat(
            "weekly.premium.missed_format",
            default: "Premium insight: %d missed day(s) this year. Use the Recovery Coach to rebuild quickly.",
            missed)
    }

    var streakResilienceMessage: String {
        if currentStreak >= 7 {
            return localized(
                "weekly.resilience.stable",
                default: "You are in a stable rhythm. Protect tomorrow with a simple plan tonight.")
        }
        if tracker.statusesByID.values.contains(.missed) {
            return localized(
                "weekly.resilience.recovery",
                default: "Missed days happen. Start a recovery substitute today and continue tomorrow.")
        }
        return localized(
            "weekly.resilience.momentum",
            default: "Build momentum with one completed discipline day at a time.")
    }

    var regionalNormSummaryLine: String {
        switch regionProfile {
        case .us:
            localized(
                "regional.summary.us",
                default: "U.S. profile: Fridays in Lent are abstinence days; Fridays outside Lent remain penitential.")
        case .canada:
            localized(
                "regional.summary.canada",
                default: "Canada profile: the national baseline keeps Fridays penitential all year and models Canada-wide holy day obligations.")
        case .other:
            localized(
                "regional.summary.other",
                default: "Regional guidance varies outside U.S./Canada; always follow local Church authority.")
        }
    }

    var monthlyCompletionCount: Int {
        dashboardMetricsSnapshot.monthlyCompletionCount
    }

    var yearlyRequiredCompletions: Int {
        dashboardMetricsSnapshot.yearlyRequiredCompletions
    }

    var yearlyOptionalCompletions: Int {
        dashboardMetricsSnapshot.yearlyOptionalCompletions
    }

    var weeklyActionableObservanceCount: Int {
        dashboardMetricsSnapshot.weeklyActionableCount
    }

    var weeklyCompletedObservancesCount: Int {
        dashboardMetricsSnapshot.weeklyCompletedCount
    }

    var requirementGoalProgress: Double {
        guard planningSession.data.requiredGoal > 0 else { return 0 }
        return min(1.0, Double(yearlyRequiredCompletions) / Double(planningSession.data.requiredGoal))
    }

    var optionalGoalProgress: Double {
        guard planningSession.data.optionalGoal > 0 else { return 0 }
        return min(1.0, Double(yearlyOptionalCompletions) / Double(planningSession.data.optionalGoal))
    }

    var intermittentHitRatePercent: Int {
        dashboardMetricsSnapshot.intermittentHitRatePercent
    }

    var seasonPlanExportText: String {
        let goalBlock = [
            localizedFormat(
                "premium.season_export.goals_format",
                default: "Goals: required %d, optional %d.",
                planningSession.data.requiredGoal,
                planningSession.data.optionalGoal),
            localizedFormat(
                "premium.season_export.year_rhythm_format",
                default: "Year rhythm required %d, optional %d.",
                yearlyRequiredCompletions,
                yearlyOptionalCompletions),
        ].joined(separator: "\n")
        let seasonBlock =
            currentSeasonCommitments.isEmpty
                ? localized(
                    "premium.season_export.no_commitments",
                    default: "No current season commitments set.")
                : currentSeasonCommitments.map { "• \($0.title)" }.joined(separator: "\n")
        let checklistBlock =
            premiumSession.checklist.isEmpty
                ? localized(
                    "premium.season_export.no_checklist",
                    default: "No checklist items set.")
                : premiumSession.checklist.map { "\($0.isDone ? "✓" : "○") \($0.title)" }.joined(separator: "\n")
        return """
        \(localized("premium.season_export.title", default: "Catholic Fasting Plan"))
        \(localizedFormat(
            "premium.season_export.season_format",
            default: "Season: %@",
            localizedSeasonLabel(currentLiturgicalSeason)))
        \(goalBlock)

        \(localized("premium.season_export.commitments_heading", default: "Current Commitments:"))
        \(seasonBlock)

        \(localized("premium.season_export.checklist_heading", default: "Premium Checklist:"))
        \(checklistBlock)
        """
    }

    var completionRateText: String {
        guard !actionableObservances.isEmpty else { return "0%" }
        let rate = (Double(completedCount) / Double(actionableObservances.count)) * 100
        return "\(Int(rate.rounded()))%"
    }

    var completionRateValue: Double {
        guard !actionableObservances.isEmpty else { return 0 }
        return Double(completedCount) / Double(actionableObservances.count)
    }

    var hasConfiguredRegionProfile: Bool {
        RuleSettings.RegionProfile(rawValue: regionProfileRaw) != nil
    }

    var hasConfiguredConsent: Bool {
        acceptedLegalNotice
    }

    var hasConfiguredReminderPlan: Bool {
        guard dailyReminderSupportEnabled else { return true }
        return morningReminderEnabled || eveningReminderEnabled
    }

    var setupChecklistTotal: Int {
        3
    }

    var setupChecklistCompleted: Int {
        var completed = 0
        if hasConfiguredConsent { completed += 1 }
        if hasConfiguredRegionProfile { completed += 1 }
        if hasConfiguredReminderPlan { completed += 1 }
        return completed
    }

    var isQuickSetupComplete: Bool {
        setupChecklistCompleted == setupChecklistTotal
    }

    var streakObservances: [Observance] {
        let currentYear = liturgicalCalendar.component(.year, from: AppClock.now())
        let previousYear = currentYear - 1
        let previous = ObservanceCalculator.makeCalendar(for: previousYear, settings: settings)
        return previous + currentYearObservances
    }

    var completionDates: [Date] {
        streakObservances
            .filter { $0.obligation != .notApplicable }
            .filter { tracker.status(for: $0.id).countsTowardProgress }
            .map { liturgicalCalendar.startOfDay(for: $0.date) }
            .sorted()
    }

    var currentStreak: Int {
        let uniqueDays = Array(Set(completionDates)).sorted(by: >)
        guard !uniqueDays.isEmpty else { return 0 }

        var streak = 0
        var expected = liturgicalCalendar.startOfDay(for: AppClock.now())
        for day in uniqueDays {
            if liturgicalCalendar.isDate(day, inSameDayAs: expected) {
                streak += 1
                expected = liturgicalCalendar.date(byAdding: .day, value: -1, to: expected) ?? expected
            } else if day < expected {
                break
            }
        }
        return streak
    }

    var bestStreak: Int {
        let uniqueDays = Array(Set(completionDates)).sorted()
        guard !uniqueDays.isEmpty else { return 0 }
        var best = 1
        var current = 1
        for index in 1 ..< uniqueDays.count {
            let prior = uniqueDays[index - 1]
            let currentDay = uniqueDays[index]
            let diff = liturgicalCalendar.dateComponents([.day], from: prior, to: currentDay).day ?? 0
            if diff == 1 {
                current += 1
                best = max(best, current)
            } else {
                current = 1
            }
        }
        return best
    }
}
