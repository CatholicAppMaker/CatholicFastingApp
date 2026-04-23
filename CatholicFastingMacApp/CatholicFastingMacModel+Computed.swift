import SwiftUI

@MainActor
extension CatholicFastingMacModel {
    var liturgicalCalendar: Calendar {
        .gregorian
    }

    var languageMode: LanguageMode {
        LanguageMode(rawValue: languageModeRaw) ?? .english
    }

    var reminderTier: ReminderTier {
        ReminderTier(rawValue: reminderTierRaw) ?? .balanced
    }

    var regionProfile: RuleSettings.RegionProfile {
        RuleSettings.RegionProfile(rawValue: regionProfileRaw) ?? .us
    }

    var settings: RuleSettings {
        RuleSettings(
            birthYear: 0,
            birthMonth: 0,
            birthDay: 0,
            isAge14OrOlderForAbstinence: age14OrOlderForAbstinence,
            isAge18OrOlderForFasting: age18OrOlderForFasting,
            hasMedicalDispensation: medicalDispensation,
            ascensionObservance: RuleSettings.AscensionObservance(rawValue: ascensionRaw) ?? .sunday,
            fridayOutsideLentMode: RuleSettings.FridayOutsideLentMode(rawValue: fridayModeRaw) ?? .substitutePenance,
            calendarMode: RuleSettings.CalendarMode(rawValue: calendarModeRaw) ?? .usccb,
            regionProfile: regionProfile)
    }

    var currentLiturgicalSeason: LiturgicalSeason {
        LiturgicalSeasonThemeEngine.season(for: Date())
    }

    var currentYearObservances: [Observance] {
        ObservanceCalculator.makeCalendar(for: year, settings: settings)
    }

    var rollingUpcomingObservances: [Observance] {
        let currentYear = liturgicalCalendar.component(.year, from: Date())
        let thisYear = ObservanceCalculator.makeCalendar(for: currentYear, settings: settings)
        let nextYear = ObservanceCalculator.makeCalendar(for: currentYear + 1, settings: settings)
        return (thisYear + nextYear).sorted { $0.date < $1.date }
    }

    var todayObservances: [Observance] {
        let today = Date()
        return currentYearObservances.filter { liturgicalCalendar.isDate($0.date, inSameDayAs: today) }
    }

    var todayPrimaryObservance: Observance? {
        todayObservances.sorted { lhs, rhs in
            lhs.obligation.rawValue > rhs.obligation.rawValue
        }.first
    }

    var upcomingMandatoryObservance: Observance? {
        let today = liturgicalCalendar.startOfDay(for: Date())
        return rollingUpcomingObservances.first {
            $0.obligation == .mandatory && liturgicalCalendar.startOfDay(for: $0.date) > today
        }
    }

    var actionableObservances: [Observance] {
        currentYearObservances.filter { $0.obligation != .notApplicable }
    }

    var completedCount: Int {
        actionableObservances.count(where: { tracker.status(for: $0.id).countsTowardProgress })
    }

    var completionRateValue: Double {
        guard !actionableObservances.isEmpty else { return 0 }
        return Double(completedCount) / Double(actionableObservances.count)
    }

    var completionRateText: String {
        "\(Int((completionRateValue * 100).rounded()))%"
    }

    var guidanceDecision: DailyFoodDecision {
        DailyFoodDecisionEngine.decision(for: currentYearObservances, settings: settings)
    }

    var generalRegionalContext: RegionalRuleContext {
        RegionalGuidanceContextFactory.generalContext(for: settings)
    }

    var seasonPlan: PremiumSeasonPlan {
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
        PremiumReflectionEngine.reflection(season: currentLiturgicalSeason)
    }

    var missedDayRecoveryPlan: MissedDayRecoveryPlan? {
        MissedDayRecoveryEngine.plan(
            observances: rollingUpcomingObservances,
            statusesByID: tracker.statusesByID)
    }

    var premiumRecoveryCoachPlan: PremiumRecoveryCoachPlan {
        PremiumRecoveryCoachEngine.plan(
            missedPlan: missedDayRecoveryPlan,
            season: currentLiturgicalSeason)
    }

    var journeyWeek: GuidedSeasonalJourneyWeek {
        GuidedSeasonalJourneyEngine.week(
            for: currentLiturgicalSeason,
            program: selectedPremiumSeasonProgram,
            week: premiumProgramWeek)
    }

    var journeyProgress: GuidedSeasonalJourneyProgress {
        GuidedSeasonalJourneyEngine.progress(
            for: journeyWeek,
            completedActionKeys: premiumCompanion.completedProgramActions)
    }

    var currentPresentationContext: ObservancePresentationContext? {
        let sourceObservance = todayPrimaryObservance ?? upcomingMandatoryObservance
        guard let sourceObservance else { return nil }
        return RegionalGuidanceContextFactory.presentationContext(for: sourceObservance, settings: settings)
    }

    var visibleCalendarObservances: [Observance] {
        let source = fastingDaysShowAllYearDays ? currentYearObservances : rollingUpcomingObservances
        let filtered = source.filter { observance in
            switch observance.kind {
            case .fastAndAbstinence, .abstinence:
                fastingDaysIncludeOptionalDays ? observance.obligation != .notApplicable : observance.obligation == .mandatory
            case .fridayPenance, .optionalEmber:
                fastingDaysIncludeOptionalDays ? observance.obligation != .notApplicable : observance.obligation == .mandatory
            case .holyDay, .feastDay, .memorialDay:
                fastingDaysIncludeFeastAndHolyDays
            }
        }
        let sorted = filtered.sorted {
            if $0.date == $1.date {
                return $0.id < $1.id
            }
            return $0.date < $1.date
        }
        return fastingDaysShowAllYearDays ? sorted : Array(sorted.prefix(48))
    }

    var selectedObservance: Observance? {
        visibleCalendarObservances.first(where: { $0.id == selectedObservanceID }) ?? visibleCalendarObservances.first
    }

    var menuBarTitle: String {
        services.activeFastStatus.menuBarTitle(for: intermittentTracker)
    }

    var menuBarSubtitle: String {
        services.activeFastStatus.menuBarSubtitle(for: intermittentTracker, locale: AppLocalizer.currentLocale())
    }

    var widgetSnapshot: WidgetSnapshot {
        WidgetSnapshot(
            generatedAt: Date(),
            todayTitle: todayPrimaryObservance.map { localizedObservanceTitle($0.title) } ?? "No observance today",
            todayObligation: todayPrimaryObservance?.dispositionLabel ?? "No obligation",
            nextRequiredTitle: upcomingMandatoryObservance.map { localizedObservanceTitle($0.title) } ?? "No upcoming required observance",
            nextRequiredDate: upcomingMandatoryObservance?.date,
            completionRate: completionRateValue,
            hasActiveIntermittentFast: intermittentTracker.activeStart != nil,
            activeIntermittentFastStart: intermittentTracker.activeStart,
            activeIntermittentTargetHours: intermittentTracker.presetHours,
            premiumMotivationLine: journeyProgress.completionSummary)
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
        var expected = liturgicalCalendar.startOfDay(for: Date())
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

    var premiumMotivationLine: String {
        PremiumMotivationEngine.line(
            season: currentLiturgicalSeason,
            streak: currentStreak,
            template: selectedPremiumTemplate)
    }

    var seasonPlanExportText: String {
        let currentSeasonCommitments = planningData.seasonCommitments
            .filter { $0.season == currentLiturgicalSeason && $0.isEnabled }
        let goalBlock =
            """
            Goals: required \(planningData.requiredGoal), optional \(planningData.optionalGoal). \
            Progress required \(completedCount), optional \(premiumAnalyticsSummary.substitutedCount).
            """
        let seasonBlock =
            currentSeasonCommitments.isEmpty
                ? "No current season commitments set."
                : currentSeasonCommitments.map { "• \($0.title)" }.joined(separator: "\n")
        let checklistBlock =
            premiumChecklist.isEmpty
                ? "No checklist items set."
                : premiumChecklist.map { "\($0.isDone ? "✓" : "○") \($0.title)" }.joined(separator: "\n")
        return """
        Catholic Fasting Plan
        Season: \(localizedSeasonLabel(currentLiturgicalSeason))
        \(goalBlock)

        Current Commitments:
        \(seasonBlock)

        Premium Checklist:
        \(checklistBlock)
        """
    }

    var premiumDirectionSummaryText: String {
        PremiumDirectionSummaryEngine.summaryText(
            season: currentLiturgicalSeason,
            analytics: premiumAnalyticsSummary,
            reminder: premiumReminderRecommendation,
            plan: seasonPlan,
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
        let calendarYear = liturgicalCalendar.component(.year, from: Date())
        let monthlyObservances = currentYearObservances.filter {
            liturgicalCalendar.component(.month, from: $0.date) == month
                && liturgicalCalendar.component(.year, from: $0.date) == calendarYear
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

    var premiumReminderRecommendationLine: String {
        let enabledText = localized("shared.on", default: "On")
        let disabledText = localized("shared.off", default: "Off")
        let segments = [
            "\(localized("premium.reminders.daily_support", default: "Daily support")): \(premiumReminderRecommendation.shouldEnableDailySupport ? enabledText : disabledText)",
            "\(localized("premium.reminders.morning", default: "Morning")): \(premiumReminderRecommendation.shouldEnableMorning ? enabledText : disabledText)",
            "\(localized("premium.reminders.evening", default: "Evening")): \(premiumReminderRecommendation.shouldEnableEvening ? enabledText : disabledText)",
        ]
        return segments.joined(separator: " • ")
    }

    var regionPastoralGuidanceText: String {
        switch regionProfile {
        case .us:
            localized(
                "settings.region_guidance.us",
                default: "United States profile: Ash Wednesday and Good Friday are fast and abstinence days, Fridays of Lent are abstinence, and Fridays outside Lent are penitential.")
        case .canada:
            localized(
                "settings.region_guidance.canada",
                default: "Canada profile: the app models the national baseline, including Canada-wide holy day obligations and CCCB Friday guidance. Diocesan proper calendars are not included yet.")
        case .other:
            localized(
                "settings.region_guidance.other",
                default: "Outside U.S./Canada: follow your local bishop conference, parish guidance, and your pastor for binding norms.")
        }
    }

    var exportDataText: String {
        let payload: [String: Any] = [
            "generated_at": UIConstants.exportISO8601.string(from: Date()),
            "settings": [
                "age_14_or_older_for_abstinence": age14OrOlderForAbstinence,
                "age_18_or_older_for_fasting": age18OrOlderForFasting,
                "medical_dispensation": medicalDispensation,
                "ascension_observance": ascensionRaw,
                "friday_outside_lent_mode": fridayModeRaw,
                "province_preset": provinceRaw,
                "calendar_mode": calendarModeRaw,
                "language_mode": languageModeRaw,
                "region_profile": regionProfileRaw,
                "reminder_tier": reminderTierRaw,
                "accepted_legal_notice": acceptedLegalNotice,
                "accepted_legal_notice_at": acceptedLegalNoticeAt,
            ],
            "observance_statuses": tracker.exportStatusPayload(),
            "friday_notes": penanceNotes.exportPayload(),
            "intermittent_fast": intermittentTracker.exportPayload(),
            "premium_companion": premiumCompanion.templateRawValue,
            "launch_funnel": [
                "started_at": UIConstants.exportISO8601.string(from: launchFunnelSnapshot.startedAt),
                "completed_onboarding_at": launchFunnelSnapshot.completedOnboardingAt.map {
                    UIConstants.exportISO8601.string(from: $0)
                } ?? "",
            ],
        ]
        return jsonString(from: payload, fallback: "{ \"error\": \"Unable to export\" }")
    }

    var dailyQuoteReminderTimeBinding: Binding<Date> {
        Binding(
            get: { [weak self] in
                guard let self else { return Date() }
                return liturgicalCalendar.date(
                    from: DateComponents(hour: dailyQuoteReminderHour, minute: dailyQuoteReminderMinute))
                    ?? Date()
            },
            set: { [weak self] newValue in
                guard let self else { return }
                let components = liturgicalCalendar.dateComponents([.hour, .minute], from: newValue)
                dailyQuoteReminderHour = components.hour ?? DefaultValues.dailyQuoteReminderHour
                dailyQuoteReminderMinute = components.minute ?? DefaultValues.dailyQuoteReminderMinute
            })
    }

    func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageModeRaw)
    }

    func localizedSeasonLabel(_ season: LiturgicalSeason) -> String {
        switch season {
        case .advent:
            localized("season.advent", default: season.label)
        case .christmas:
            localized("season.christmas", default: season.label)
        case .lent:
            localized("season.lent", default: season.label)
        case .easter:
            localized("season.easter", default: season.label)
        case .ordinary:
            localized("season.ordinary", default: season.label)
        }
    }

    func localizedObservanceTitle(_ title: String) -> String {
        ObservanceTitleLocalizer.localizedCurrent(title)
    }

    func localizedRegionLabel(_ profile: RuleSettings.RegionProfile) -> String {
        switch profile {
        case .us:
            localized("onboarding.region.us", default: profile.label)
        case .canada:
            localized("onboarding.region.canada", default: profile.label)
        case .other:
            localized("onboarding.region.other", default: profile.label)
        }
    }

    func localizedDate(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted).locale(AppLocalizer.currentLocale()))
    }

    func localizedDateTime(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened).locale(AppLocalizer.currentLocale()))
    }

    func weekdayLabel(for value: Int) -> String {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        let index = value - 1
        guard index >= 0, index < symbols.count else { return "" }
        return symbols[index]
    }

    private var streakObservances: [Observance] {
        let currentCalendarYear = liturgicalCalendar.component(.year, from: Date())
        let previousYear = currentCalendarYear - 1
        let previous = ObservanceCalculator.makeCalendar(for: previousYear, settings: settings)
        return previous + currentYearObservances
    }
}
