import SwiftUI
#if canImport(TipKit)
    import TipKit
#endif

extension ContentView {
    var liturgicalCalendar: Calendar {
        .gregorian
    }

    var regionProfile: RuleSettings.RegionProfile {
        RuleSettings.RegionProfile(rawValue: regionProfileRaw) ?? .us
    }

    var activeSeasonalContentPack: SeasonalContentPack {
        let locale: ContentLocale = languageMode == .spanish ? .spanish : .english
        return SeasonalContentPackCatalog.pack(for: currentLiturgicalSeason, locale: locale)
    }

    var dailySeasonalFormationLine: String {
        let lines = activeSeasonalContentPack.formationLines
        guard !lines.isEmpty else { return "Offer today's discipline with prayer and charity." }
        let day = liturgicalCalendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return lines[(day - 1) % lines.count]
    }

    var dailySeasonalQuote: CatholicFastingQuote {
        let quotes = activeSeasonalContentPack.quotes
        guard !quotes.isEmpty else {
            return CatholicFastingQuote(
                id: "fallback-seasonal-quote",
                text: "Fast with fidelity, pray with humility, and give with charity.",
                author: "Catholic Fasting",
                source: "In-app formation",
                tradition: "Pastoral"
            )
        }
        let day = liturgicalCalendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let quote = quotes[(day - 1) % quotes.count]
        return CatholicFastingQuote(
            id: "seasonal-\(currentLiturgicalSeason.rawValue)-\(day)",
            text: quote.text,
            author: quote.author,
            source: quote.source,
            tradition: quote.tradition
        )
    }

    var weeklyFormationRecapFree: String {
        if weeklyActionableObservances.isEmpty {
            return "No fasting obligations logged this week yet. Keep your next required day visible."
        }
        return "This week: \(weeklyCompletedObservancesCount) of \(weeklyActionableObservances.count) discipline days completed."
    }

    var weeklyFormationRecapPremium: String {
        let missed = currentYearObservances.filter { tracker.status(for: $0.id) == .missed }.count
        if missed == 0 {
            return "Premium insight: strong consistency. Keep your reminder cadence steady."
        }
        return "Premium insight: \(missed) missed day(s) this year. Use the Recovery Coach to rebuild quickly."
    }

    var streakResilienceMessage: String {
        if currentStreak >= 7 {
            return "You are in a stable rhythm. Protect tomorrow with a simple plan tonight."
        }
        if tracker.statusesByID.values.contains(.missed) {
            return "Missed days happen. Start a recovery substitute today and continue tomorrow."
        }
        return "Build momentum with one completed discipline day at a time."
    }

    var regionalNormSummaryLine: String {
        switch regionProfile {
        case .us:
            "U.S. profile: Fridays in Lent are abstinence days; Fridays outside Lent remain penitential."
        case .canada:
            "Canada profile: the national baseline keeps Fridays penitential all year and models Canada-wide holy day obligations."
        case .other:
            "Regional guidance varies outside U.S./Canada; always follow local Church authority."
        }
    }

    var activeHouseholdProfile: HouseholdProfile? {
        householdProfiles.first(where: { $0.id == activeHouseholdProfileID })
    }

    var currentSeasonCommitments: [SeasonCommitment] {
        planningData.seasonCommitments.filter { $0.season == currentLiturgicalSeason && $0.isEnabled }
    }

    var monthlyCompletionCount: Int {
        let now = Date()
        let month = liturgicalCalendar.component(.month, from: now)
        let year = liturgicalCalendar.component(.year, from: now)
        return currentYearObservances.filter {
            liturgicalCalendar.component(.month, from: $0.date) == month
                && liturgicalCalendar.component(.year, from: $0.date) == year
                && tracker.status(for: $0.id).countsTowardProgress
        }.count
    }

    var yearlyRequiredCompletions: Int {
        currentYearObservances.filter {
            $0.obligation == .mandatory && tracker.status(for: $0.id).countsTowardProgress
        }.count
    }

    var yearlyOptionalCompletions: Int {
        currentYearObservances.filter {
            $0.obligation == .optional && tracker.status(for: $0.id).countsTowardProgress
        }.count
    }

    var weeklyActionableObservances: [Observance] {
        let weekStart = liturgicalCalendar.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        return currentYearObservances.filter { $0.date >= weekStart && $0.date <= Date() && $0.obligation != .notApplicable }
    }

    var weeklyCompletedObservancesCount: Int {
        weeklyActionableObservances.filter { tracker.status(for: $0.id).countsTowardProgress }.count
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
        let recent = Array(intermittentTracker.sessions.prefix(20))
        guard !recent.isEmpty else { return 0 }
        let hits = recent.filter(\.completedTarget).count
        return Int((Double(hits) / Double(recent.count) * 100).rounded())
    }

    var seasonPlanExportText: String {
        let goalBlock =
            "Goals: required \(planningData.requiredGoal), optional \(planningData.optionalGoal). Progress required \(yearlyRequiredCompletions), optional \(yearlyOptionalCompletions)."
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
        Season: \(currentLiturgicalSeason.label)
        \(goalBlock)

        Current Commitments:
        \(seasonBlock)

        Premium Checklist:
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
                isEnabled: true
            )
        )
        newSeasonCommitmentTitle = ""
    }

    func addOrUpdateIntermittentSchedulePlan() {
        let count = intermittentSchedules.count + 1
        let trimmedName = newIntermittentScheduleName.trimmingCharacters(in: .whitespacesAndNewlines)
        let weekdays = Array(newIntermittentScheduleWeekdays).sorted()
        guard !weekdays.isEmpty else { return }
        let normalizedHour = min(max(newIntermittentScheduleStartHour, 0), 23)

        if let index = intermittentSchedules.firstIndex(where: { $0.id == editingIntermittentScheduleID }) {
            intermittentSchedules[index].name = trimmedName.isEmpty ? "Plan \(index + 1)" : trimmedName
            intermittentSchedules[index].targetHours = intermittentTracker.presetHours
            intermittentSchedules[index].startHour = normalizedHour
            intermittentSchedules[index].weekdays = weekdays
            activeIntermittentScheduleID = intermittentSchedules[index].id
            editingIntermittentScheduleID = ""
        } else {
            let newPlan = IntermittentSchedulePlan(
                id: UUID().uuidString,
                name: trimmedName.isEmpty ? "Plan \(count)" : trimmedName,
                targetHours: intermittentTracker.presetHours,
                startHour: normalizedHour,
                weekdays: weekdays
            )
            intermittentSchedules.append(newPlan)
            activeIntermittentScheduleID = newPlan.id
        }

        newIntermittentScheduleName = ""
        newIntermittentScheduleStartHour = 20
        newIntermittentScheduleWeekdays = [2, 4, 6]
    }

    func startEditingIntermittentSchedule(_ plan: IntermittentSchedulePlan) {
        editingIntermittentScheduleID = plan.id
        newIntermittentScheduleName = plan.name
        newIntermittentScheduleStartHour = plan.startHour
        newIntermittentScheduleWeekdays = Set(plan.weekdays)
        intermittentTracker.setPresetHours(plan.targetHours)
    }

    func cancelEditingIntermittentSchedule() {
        editingIntermittentScheduleID = ""
        newIntermittentScheduleName = ""
        newIntermittentScheduleStartHour = 20
        newIntermittentScheduleWeekdays = [2, 4, 6]
    }

    func deleteIntermittentSchedule(_ plan: IntermittentSchedulePlan) {
        intermittentSchedules.removeAll { $0.id == plan.id }
        if activeIntermittentScheduleID == plan.id {
            activeIntermittentScheduleID = ""
        }
        if editingIntermittentScheduleID == plan.id {
            cancelEditingIntermittentSchedule()
        }
    }

    func applyIntermittentSchedule(_ plan: IntermittentSchedulePlan) async {
        intermittentTracker.setPresetHours(plan.targetHours)
        activeIntermittentScheduleID = plan.id
        if acceptedLegalNotice {
            notificationStatus = await ReminderScheduler.scheduleIntermittentPlan(plan)
        } else {
            notificationStatus =
                "Applied \(plan.name). Enable consent in Privacy & Data to schedule start reminders."
        }
    }

    func addHouseholdProfile() {
        let name = newHouseholdProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let profile = HouseholdProfile(
            id: UUID().uuidString,
            name: name,
            isAge14OrOlderForAbstinence: age14OrOlderForAbstinence,
            isAge18OrOlderForFasting: age18OrOlderForFasting,
            medicalDispensation: medicalDispensation
        )
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

    func performInitialStartupTasks() async {
        #if canImport(TipKit)
            if !didConfigureTips {
                try? Tips.configure([
                    .displayFrequency(.daily),
                ])
                didConfigureTips = true
            }
        #endif
        if launchFunnelSnapshot.completedOnboardingAt == nil {
            launchFunnelSnapshot.startedAt = Date()
        }
        launchFunnelSnapshot.selectedRegionRaw = regionProfileRaw
        launchFunnelSnapshot.selectedReminderTierRaw = reminderTierRaw
        persistWidgetSnapshot()
        await monetizationStore.refreshCatalogAndEntitlements()
        _ = await ReminderScheduler.topUpRequiredReminders(observances: rollingUpcomingObservances)
        notificationStatus = await ReminderScheduler.notificationSummary()
        ensureActiveHouseholdProfileSelection()
    }

    func applyReminderTier(_ tier: ReminderTier) {
        reminderTierRaw = tier.rawValue
        dailyReminderSupportEnabled = tier.supportEnabled
        morningReminderEnabled = tier.morningEnabled
        eveningReminderEnabled = tier.eveningEnabled
        launchFunnelSnapshot.selectedReminderTierRaw = tier.rawValue
    }

    func syncReminderTierFromCurrentToggleState() {
        let inferred = ReminderTier.infer(
            supportEnabled: dailyReminderSupportEnabled,
            morningEnabled: morningReminderEnabled,
            eveningEnabled: eveningReminderEnabled
        )
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
                title: title.isEmpty ? "Reflection" : title,
                body: body
            ),
            at: 0
        )
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
        case let .surface(surface):
            homeSurface = surface
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
        let today = liturgicalCalendar.startOfDay(for: Date())
        let todayObservance = currentYearObservances.first {
            liturgicalCalendar.isDate($0.date, inSameDayAs: today)
        }
        return WidgetSnapshot(
            generatedAt: Date(),
            todayTitle: todayObservance?.title ?? "No observance today",
            todayObligation: todayObservance?.dispositionLabel ?? "No obligation",
            nextRequiredTitle: upcomingMandatoryObservance?.title ?? "No upcoming required observance",
            nextRequiredDate: upcomingMandatoryObservance?.date,
            completionRate: completionRateValue,
            hasActiveIntermittentFast: intermittentTracker.activeStart != nil,
            activeIntermittentFastStart: intermittentTracker.activeStart,
            activeIntermittentTargetHours: intermittentTracker.presetHours,
            premiumMotivationLine: premiumMotivationLine
        )
    }

    func persistWidgetSnapshot() {
        WidgetSnapshotStore.persist(widgetSnapshot)
    }

    func noteBinding(for observanceID: String) -> Binding<String> {
        Binding(
            get: { penanceNotes.note(for: observanceID) },
            set: { penanceNotes.setNote($0, for: observanceID) }
        )
    }

    func focusFastingDaysOnUpcomingRequired() {
        fastingDaysShowAllYearDays = false
        fastingDaysIncludeOptionalDays = false
        homeSurface = .fastingDays
    }

    var observancesForToday: [Observance] {
        currentYearObservances.filter { liturgicalCalendar.isDate($0.date, inSameDayAs: Date()) }
    }

    var rollingUpcomingObservances: [Observance] {
        let currentYear = liturgicalCalendar.component(.year, from: Date())
        let thisYear = ObservanceCalculator.makeCalendar(for: currentYear, settings: settings)
        let nextYear = ObservanceCalculator.makeCalendar(for: currentYear + 1, settings: settings)
        return (thisYear + nextYear).sorted { $0.date < $1.date }
    }

    var upcomingMandatoryObservance: Observance? {
        let today = liturgicalCalendar.startOfDay(for: Date())
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
        currentYearObservances.filter { $0.obligation == .mandatory }.count
    }

    var heroSummaryText: String {
        if let next = upcomingMandatoryObservance {
            return "Next required observance is \(next.title) on \(next.date.formatted(date: .abbreviated, time: .omitted))."
        }
        return "No remaining required observances this year."
    }

    var todayFoodDecision: DailyFoodDecision {
        DailyFoodDecisionEngine.decision(
            for: currentYearObservances,
            settings: settings,
            calendar: liturgicalCalendar
        )
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
            statusesByID: tracker.statusesByID
        )
    }

    var currentLiturgicalSeason: LiturgicalSeason {
        LiturgicalSeasonThemeEngine.season(for: Date())
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

    var intermittentLongestSessionText: String {
        guard let longest = intermittentTracker.sessions.map(\.duration).max() else { return "0h" }
        return durationText(longest)
    }

    var intermittentWindowLabel: String {
        intermittentPlanDescription(intermittentTracker.presetHours)
    }

    var intermittentPresetBinding: Binding<Int> {
        Binding(
            get: { intermittentTracker.presetHours },
            set: { intermittentTracker.setPresetHours($0) }
        )
    }

    func durationText(_ duration: TimeInterval) -> String {
        let totalMinutes = max(0, Int(duration / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02dh %02dm", hours, minutes)
    }

    func countdownText(_ duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration))
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if days > 0 {
            return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func intermittentPlanDescription(_ hours: Int) -> String {
        if hours <= 24 {
            return "\(hours)h fast / \(24 - hours)h eating"
        }
        return "\(hours)h fast target"
    }

    var streakObservances: [Observance] {
        let currentYear = liturgicalCalendar.component(.year, from: Date())
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
            "Complete"
        default:
            status.label
        }
    }

    var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !didCompleteOnboarding },
            set: { newValue in
                if !newValue {
                    didCompleteOnboarding = true
                }
            }
        )
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

    var canSaveIntermittentSchedule: Bool {
        !newIntermittentScheduleWeekdays.isEmpty
    }

    var isEditingIntermittentSchedule: Bool {
        !editingIntermittentScheduleID.isEmpty
    }

    func weekdayListText(_ weekdays: [Int]) -> String {
        let labels =
            weekdays
                .map { weekdayLabel(for: $0) }
                .filter { !$0.isEmpty }
        return labels.isEmpty ? "Custom days" : labels.joined(separator: ", ")
    }

    func weekdayLabel(for value: Int) -> String {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        let index = value - 1
        guard index >= 0, index < symbols.count else { return "" }
        return symbols[index]
    }

    func toggleIntermittentScheduleWeekday(_ weekday: Int) {
        guard (1 ... 7).contains(weekday) else { return }
        if newIntermittentScheduleWeekdays.contains(weekday) {
            newIntermittentScheduleWeekdays.remove(weekday)
        } else {
            newIntermittentScheduleWeekdays.insert(weekday)
        }
    }
}
