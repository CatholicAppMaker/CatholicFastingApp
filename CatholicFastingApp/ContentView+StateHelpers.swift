import SwiftUI

extension ContentView {
    func localizedObservanceTitle(_ title: String) -> String {
        ObservanceContentLocalizer.localizedTitle(title, languageCode: languageModeRaw)
    }

    func localizedObservanceDetail(_ observance: Observance) -> String? {
        ObservanceContentLocalizer.localizedDetail(observance.detail, languageCode: languageModeRaw)
    }

    func localizedObservanceRationale(_ observance: Observance) -> String {
        ObservanceContentLocalizer.localizedRationale(observance, languageCode: languageModeRaw)
    }

    func localizedObservanceKindLabel(_ kind: Observance.Kind) -> String {
        ObservancePresentationLocalizer.kindLabel(kind, languageCode: languageModeRaw)
    }

    func localizedObservanceDispositionLabel(_ observance: Observance) -> String {
        ObservancePresentationLocalizer.dispositionLabel(observance, languageCode: languageModeRaw)
    }

    func localizedCompletionStatusLabel(_ status: CompletionStatus) -> String {
        ObservancePresentationLocalizer.completionLabel(status, languageCode: languageModeRaw)
    }

    var liturgicalCalendar: Calendar {
        .gregorian
    }

    var contentLocale: Locale {
        AppLocalizer.currentLocale()
    }

    func localizedAbbreviatedDate(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(date: .abbreviated, time: .omitted)
                .locale(contentLocale))
    }

    func localizedCompleteDate(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(date: .complete, time: .omitted)
                .locale(contentLocale))
    }

    func localizedAbbreviatedDateTime(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(date: .abbreviated, time: .shortened)
                .locale(contentLocale))
    }

    func localizedMonthYear(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle()
                .month(.wide)
                .year()
                .locale(contentLocale))
    }

    var regionProfile: RuleSettings.RegionProfile {
        RuleSettings.RegionProfile(rawValue: regionProfileRaw) ?? .us
    }

    var activeSeasonalContentPack: SeasonalContentPack {
        SeasonalContentPackCatalog.pack(for: currentLiturgicalSeason, locale: languageMode.contentLocale)
    }

    var dailySeasonalFormationLine: String {
        let lines = activeSeasonalContentPack.formationLines
        guard !lines.isEmpty else {
            return localized(
                "seasonal.formation.fallback",
                default: "Offer today’s discipline with prayer and charity.")
        }
        let day = liturgicalCalendar.ordinality(of: .day, in: .year, for: AppClock.now()) ?? 1
        return lines[(day - 1) % lines.count]
    }

    var dailySeasonalQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.seasonalQuote(
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: AppClock.now())
    }

    var dailyQuoteReminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                liturgicalCalendar.date(
                    from: DateComponents(
                        hour: dailyQuoteReminderHour,
                        minute: dailyQuoteReminderMinute))
                    ?? liturgicalCalendar.date(from: DateComponents(hour: 12, minute: 0))
                    ?? AppClock.now()
            },
            set: { newValue in
                let components = liturgicalCalendar.dateComponents([.hour, .minute], from: newValue)
                dailyQuoteReminderHour = components.hour ?? DefaultValues.dailyQuoteReminderHour
                dailyQuoteReminderMinute = components.minute ?? DefaultValues.dailyQuoteReminderMinute
            })
    }

    var dailyQuoteReminderRefreshState: DailyQuoteReminderRefreshState {
        DailyQuoteReminderRefreshState(
            isEnabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            locale: languageMode.contentLocale,
            consentAccepted: acceptedLegalNotice,
            notificationsAuthorized: true,
            pendingReminderCount: 0)
    }

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

    var activeHouseholdProfile: HouseholdProfile? {
        householdProfiles.first(where: { $0.id == activeHouseholdProfileID })
    }

    var currentSeasonCommitments: [SeasonCommitment] {
        planningData.seasonCommitments.filter { $0.season == currentLiturgicalSeason && $0.isEnabled }
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

    var weeklyActionableObservances: [Observance] {
        let now = AppClock.now()
        let weekStart = liturgicalCalendar.date(byAdding: .day, value: -6, to: now) ?? now
        return currentYearObservances.filter { $0.date >= weekStart && $0.date <= now && $0.obligation != .notApplicable }
    }

    var weeklyActionableObservanceCount: Int {
        dashboardMetricsSnapshot.weeklyActionableCount
    }

    var weeklyCompletedObservancesCount: Int {
        dashboardMetricsSnapshot.weeklyCompletedCount
    }

    var requirementGoalProgress: Double {
        guard planningData.requiredGoal > 0 else { return 0 }
        return min(1.0, Double(yearlyRequiredCompletions) / Double(planningData.requiredGoal))
    }

    var optionalGoalProgress: Double {
        guard planningData.optionalGoal > 0 else { return 0 }
        return min(1.0, Double(yearlyOptionalCompletions) / Double(planningData.optionalGoal))
    }

    var intermittentHitRatePercent: Int {
        dashboardMetricsSnapshot.intermittentHitRatePercent
    }

    var seasonPlanExportText: String {
        let goalBlock = [
            localizedFormat(
                "premium.season_export.goals_format",
                default: "Goals: required %d, optional %d.",
                planningData.requiredGoal,
                planningData.optionalGoal),
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
            premiumChecklist.isEmpty
                ? localized(
                    "premium.season_export.no_checklist",
                    default: "No checklist items set.")
                : premiumChecklist.map { "\($0.isDone ? "✓" : "○") \($0.title)" }.joined(separator: "\n")
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

    func addSeasonCommitment() {
        let title = newSeasonCommitmentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        planningData.seasonCommitments.append(
            SeasonCommitment(
                id: UUID().uuidString,
                season: currentLiturgicalSeason,
                title: title,
                isEnabled: true))
        newSeasonCommitmentTitle = ""
    }

    func addHouseholdProfile() {
        let name = newHouseholdProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let profile = HouseholdProfile(
            id: UUID().uuidString,
            name: name,
            isAge14OrOlderForAbstinence: age14OrOlderForAbstinence,
            isAge18OrOlderForFasting: age18OrOlderForFasting,
            medicalDispensation: medicalDispensation)
        householdProfiles.append(profile)
        activeHouseholdProfileID = profile.id
        newHouseholdProfileName = ""
    }

    func applyActiveHouseholdProfile() {
        guard let profile = activeHouseholdProfile else { return }
        age14OrOlderForAbstinence = profile.isAge14OrOlderForAbstinence
        age18OrOlderForFasting = profile.isAge18OrOlderForFasting
        medicalDispensation = profile.medicalDispensation
    }

    func ensureActiveHouseholdProfileSelection() {
        guard activeHouseholdProfileID.isEmpty else { return }
        if let firstProfile = householdProfiles.first {
            activeHouseholdProfileID = firstProfile.id
        } else {
            activeHouseholdProfileID = ""
        }
    }

    func applyReminderTier(_ tier: ReminderTier) {
        reminderTierRaw = tier.rawValue
        dailyReminderSupportEnabled = tier.supportEnabled
        morningReminderEnabled = tier.morningEnabled
        eveningReminderEnabled = tier.eveningEnabled
        launchFunnelSnapshot.selectedReminderTierRaw = tier.rawValue
    }

    func scheduleDailyQuoteReminderFromCurrentSettings() async {
        let refreshState = dailyQuoteReminderRefreshState
        notificationStatus = await ReminderScheduler.scheduleDailyQuoteReminder(
            enabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            languageMode: languageMode)
        dailyQuoteReminderSignature = refreshState.signature
    }

    func refreshDailyQuoteReminderIfNeeded() async {
        let pendingReminderCount = await ReminderScheduler.pendingDailyQuoteReminderCount()
        let notificationsAuthorized = await ReminderScheduler.notificationsAuthorizedForScheduling()
        let refreshState = DailyQuoteReminderRefreshState(
            isEnabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            locale: languageMode.contentLocale,
            consentAccepted: acceptedLegalNotice,
            notificationsAuthorized: notificationsAuthorized,
            pendingReminderCount: pendingReminderCount)

        guard refreshState.shouldRefresh(storedSignature: dailyQuoteReminderSignature) else {
            return
        }

        notificationStatus = await ReminderScheduler.scheduleDailyQuoteReminder(
            enabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            languageMode: languageMode)
        dailyQuoteReminderSignature = refreshState.signature
    }

    func syncReminderTierFromCurrentToggleState() {
        let inferred = ReminderTier.infer(
            supportEnabled: dailyReminderSupportEnabled,
            morningEnabled: morningReminderEnabled,
            eveningEnabled: eveningReminderEnabled)
        if reminderTierRaw != inferred.rawValue {
            reminderTierRaw = inferred.rawValue
        }
        launchFunnelSnapshot.selectedReminderTierRaw = reminderTierRaw
    }

    func addReflectionEntry() {
        let title = newReflectionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = newReflectionBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty || !body.isEmpty else { return }
        reflectionEntries.insert(
            ReflectionJournalEntry(
                id: UUID().uuidString,
                createdAt: Date(),
                title: title.isEmpty
                    ? localized("premium.journal.default_title", default: "Reflection")
                    : title,
                body: body),
            at: 0)
        newReflectionTitle = ""
        newReflectionBody = ""
    }

    func toggleChecklistItem(_ itemID: String) {
        guard let index = premiumChecklist.firstIndex(where: { $0.id == itemID }) else { return }
        premiumChecklist[index].isDone.toggle()
    }

    func handleDeepLink(_ url: URL) {
        guard let target = AppDeepLinkTarget.parse(url: url) else { return }
        switch target {
        case .surface(let surface):
            homeSurface = surface
        case .settings:
            navigateToMoreDestination(.setupAndReminders)
        case .premium:
            supportPremiumSurfaceRaw = SupportPremiumSurface.upgrade.rawValue
            navigateToMoreDestination(.supportAndPremium)
        }
    }

    func deepLinkURL(for surface: HomeSurface) -> URL {
        switch surface {
        case .today:
            UIConstants.deepLinkTodayURL
        case .fastingDays:
            UIConstants.deepLinkFastingDaysURL
        case .intermittent:
            UIConstants.deepLinkIntermittentURL
        case .more:
            UIConstants.deepLinkMoreURL
        }
    }

    var widgetSnapshot: WidgetSnapshot {
        let now = AppClock.now()
        let today = liturgicalCalendar.startOfDay(for: now)
        let todayObservance = currentYearObservances.first {
            liturgicalCalendar.isDate($0.date, inSameDayAs: today)
        }
        return WidgetSnapshot(
            generatedAt: now,
            todayTitle: todayObservance.map { localizedObservanceTitle($0.title) }
                ?? CoreLocalizer.localizedCurrent("widget.fallback.today.title", default: "No observance today"),
            todayObligation: todayObservance.map(localizedObservanceDispositionLabel)
                ?? CoreLocalizer.localizedCurrent("widget.fallback.today.obligation", default: "No obligation"),
            nextRequiredTitle: upcomingMandatoryObservance.map { localizedObservanceTitle($0.title) }
                ?? CoreLocalizer.localizedCurrent(
                    "widget.fallback.next_required", default: "No upcoming required observance"),
            nextRequiredDate: upcomingMandatoryObservance?.date,
            completionRate: completionRateValue,
            hasActiveIntermittentFast: intermittentTracker.activeStart != nil,
            activeIntermittentFastStart: intermittentTracker.activeStart,
            activeIntermittentTargetHours: intermittentTracker.presetHours,
            premiumMotivationLine: premiumMotivationLine,
            localizationCode: CoreLocalizer.currentLocalizationCode())
    }

    func persistWidgetSnapshot() {
        WidgetSnapshotStore.persist(widgetSnapshot)
    }

    func noteBinding(for observanceID: String) -> Binding<String> {
        Binding(
            get: { penanceNotes.note(for: observanceID) },
            set: { penanceNotes.setNote($0, for: observanceID) })
    }

    func focusFastingDaysOnUpcomingRequired() {
        fastingDaysShowAllYearDays = false
        fastingDaysIncludeOptionalDays = false
        homeSurface = .fastingDays
    }

    var observancesForToday: [Observance] {
        currentYearObservances.filter { liturgicalCalendar.isDate($0.date, inSameDayAs: AppClock.now()) }
    }

    var rollingUpcomingObservances: [Observance] {
        let today = liturgicalCalendar.startOfDay(for: AppClock.now())
        let currentYear = liturgicalCalendar.component(.year, from: today)
        let thisYear = ObservanceCalculator.makeCalendar(for: currentYear, settings: settings)
        let nextYear = ObservanceCalculator.makeCalendar(for: currentYear + 1, settings: settings)
        return (thisYear + nextYear)
            .filter { liturgicalCalendar.startOfDay(for: $0.date) >= today }
            .sorted { $0.date < $1.date }
    }

    var upcomingMandatoryObservance: Observance? {
        let today = liturgicalCalendar.startOfDay(for: AppClock.now())
        return rollingUpcomingObservances.first { observance in
            observance.obligation == .mandatory
                && liturgicalCalendar.startOfDay(for: observance.date) > today
        }
    }

    var hasKnownBirthYearForObligations: Bool {
        true
    }

    var upcomingPotentialFastingObservance: Observance? {
        nil
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

    var mandatoryObservanceCount: Int {
        currentYearObservances.count(where: { $0.obligation == .mandatory })
    }

    var heroSummaryText: String {
        if let next = upcomingMandatoryObservance {
            return localizedFormat(
                "today.hero.next_required_summary_format",
                default: "Next required observance is %@ on %@.",
                localizedObservanceTitle(next.title),
                localizedAbbreviatedDate(next.date))
        }
        return localized("today.hero.none_remaining", default: "No remaining required observances this year.")
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

    var missedDayRecoveryPlan: MissedDayRecoveryPlan? {
        MissedDayRecoveryEngine.plan(
            observances: rollingUpcomingObservances,
            statusesByID: tracker.statusesByID)
    }

    var currentLiturgicalSeason: LiturgicalSeason {
        LiturgicalSeasonThemeEngine.season(for: AppClock.now())
    }

    var todayActionableObservances: [Observance] {
        observancesForToday.filter { $0.obligation != .notApplicable }
    }

    var canLogRecoverySubstituteToday: Bool {
        todayActionableObservances.contains { tracker.status(for: $0.id) == .notStarted }
    }

    func logRecoverySubstituteForToday() {
        guard let target = todayActionableObservances.first(where: { tracker.status(for: $0.id) == .notStarted }) else {
            return
        }
        tracker.setStatus(.substituted, for: target.id)
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

    func todayButtonLabel(for status: CompletionStatus) -> String {
        switch status {
        case .notStarted:
            localized("observance.action.complete", default: "Complete")
        default:
            localizedCompletionStatusLabel(status)
        }
    }

    var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !didCompleteOnboarding },
            set: { newValue in
                if !newValue {
                    didCompleteOnboarding = true
                }
            })
    }

    var canAddHouseholdProfile: Bool {
        !newHouseholdProfileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canAddSeasonCommitment: Bool {
        !newSeasonCommitmentTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canSaveReflection: Bool {
        !newReflectionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !newReflectionBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
