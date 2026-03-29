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
        SeasonalContentPackCatalog.pack(for: currentLiturgicalSeason, locale: languageMode.contentLocale)
    }

    var dailySeasonalFormationLine: String {
        let lines = activeSeasonalContentPack.formationLines
        guard !lines.isEmpty else { return "Offer today's discipline with prayer and charity." }
        let day = liturgicalCalendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return lines[(day - 1) % lines.count]
    }

    var dailySeasonalQuote: CatholicFastingQuote {
        CatholicFastingQuoteSelector.seasonalQuote(
            locale: languageMode.contentLocale,
            season: currentLiturgicalSeason,
            date: Date())
    }

    var dailyQuoteReminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                liturgicalCalendar.date(
                    from: DateComponents(
                        hour: dailyQuoteReminderHour,
                        minute: dailyQuoteReminderMinute))
                    ?? liturgicalCalendar.date(from: DateComponents(hour: 12, minute: 0))
                    ?? Date()
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
            now: Date(),
            calendar: liturgicalCalendar)
    }

    var weeklyFormationRecapFree: String {
        if weeklyActionableObservanceCount == 0 {
            return "No fasting obligations logged this week yet. Keep your next required day visible."
        }
        return "This week: \(weeklyCompletedObservancesCount) of \(weeklyActionableObservanceCount) discipline days completed."
    }

    var weeklyFormationRecapPremium: String {
        let missed = currentYearObservances.count(where: { tracker.status(for: $0.id) == .missed })
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
        dashboardMetricsSnapshot.monthlyCompletionCount
    }

    var yearlyRequiredCompletions: Int {
        dashboardMetricsSnapshot.yearlyRequiredCompletions
    }

    var yearlyOptionalCompletions: Int {
        dashboardMetricsSnapshot.yearlyOptionalCompletions
    }

    var weeklyActionableObservances: [Observance] {
        let weekStart = liturgicalCalendar.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        return currentYearObservances.filter { $0.date >= weekStart && $0.date <= Date() && $0.obligation != .notApplicable }
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
        let goalBlock =
            """
            Goals: required \(planningData.requiredGoal), optional \(planningData.optionalGoal). \
            Progress required \(yearlyRequiredCompletions), optional \(yearlyOptionalCompletions).
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
                isEnabled: true))
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
                weekdays: weekdays)
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
        await refreshDailyQuoteReminderIfNeeded()
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
                title: title.isEmpty ? "Reflection" : title,
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
            premiumMotivationLine: premiumMotivationLine)
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
        currentYearObservances.count(where: { $0.obligation == .mandatory })
    }

    var heroSummaryText: String {
        if let next = upcomingMandatoryObservance {
            return "Next required observance is \(next.title) on \(next.date.formatted(date: .abbreviated, time: .omitted))."
        }
        return "No remaining required observances this year."
    }

    var todayFoodDecision: DailyFoodDecision {
        let rawDecision = DailyFoodDecisionEngine.decision(
            for: currentYearObservances,
            settings: settings,
            calendar: liturgicalCalendar)
        return localizedFoodDecision(rawDecision)
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
            set: { intermittentTracker.setPresetHours($0) })
    }

    var intermittentManualStartRange: ClosedRange<Date> {
        let latest = Date()
        let earliest = liturgicalCalendar.date(byAdding: .day, value: -14, to: latest) ?? latest
        return earliest ... latest
    }

    var intermittentActiveStartBinding: Binding<Date> {
        Binding(
            get: { intermittentTracker.activeStart ?? intermittentManualStart },
            set: { newValue in
                intermittentManualStart = newValue
                intermittentTracker.updateActiveStart(to: newValue)
                intermittentManualStart = intermittentTracker.activeStart ?? newValue
            })
    }

    func startIntermittentFastFromSelectedTime() {
        intermittentTracker.startFast(now: intermittentManualStart)
        intermittentManualStart = intermittentTracker.activeStart ?? Date()
    }

    func applyIntermittentManualStartEdit() {
        intermittentTracker.updateActiveStart(to: intermittentManualStart)
        intermittentManualStart = intermittentTracker.activeStart ?? Date()
    }

    func resetIntermittentManualStartToNow() {
        intermittentManualStart = Date()
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

    private func localizedFoodDecision(_ decision: DailyFoodDecision) -> DailyFoodDecision {
        DailyFoodDecision(
            obligationLine: localizedFoodDecisionText(decision.obligationLine),
            allowed: decision.allowed.map(localizedFoodDecisionText),
            avoid: decision.avoid.map(localizedFoodDecisionText),
            rationale: localizedFoodDecisionRationale(decision.rationale),
            sourceLine: localizedFoodDecisionSource(decision.sourceLine))
    }

    private func localizedFoodDecisionText(_ text: String) -> String {
        switch text {
        case "Medical/pastoral dispensation is enabled in your profile.":
            localized("decision.dispensation.obligation", default: text)
        case "Eat what is prudent and medically safe.":
            localized("decision.dispensation.allowed.safe", default: text)
        case "Keep prayer/charity as substitute penance.":
            localized("decision.dispensation.allowed.prayer", default: text)
        case "Avoid self-imposed rigor that harms health.":
            localized("decision.dispensation.avoid", default: text)
        case "Today requires fasting and abstinence.":
            localized("decision.fast_and_abstinence.obligation", default: text)
        case "One full meal with up to two smaller meals.":
            localized("decision.fast_and_abstinence.allowed.meals", default: text)
        case "Fish, eggs, dairy, grains, fruits, and vegetables are generally permitted.":
            localized("decision.fast_and_abstinence.allowed.foods", default: text)
        case "Meat from land animals (beef, pork, poultry).":
            localized("decision.fast_and_abstinence.avoid.meat", default: text)
        case "Eating patterns that effectively become a second full meal.":
            localized("decision.fast_and_abstinence.avoid.second_meal", default: text)
        case "Today requires abstinence from meat.":
            localized("decision.abstinence.obligation", default: text)
        case "Normal meal quantity is generally permitted.":
            localized("decision.abstinence.allowed.quantity", default: text)
        case "Today has a required observance but no mandatory food restriction.":
            localized("decision.required_no_food_restriction.obligation", default: text)
        case "Normal meals are generally permitted.":
            localized("decision.required_no_food_restriction.allowed.meals", default: text)
        case "Keep the day with prayer and Mass obligations.":
            localized("decision.required_no_food_restriction.allowed.prayer", default: text)
        case "Today may include fasting/abstinence obligations (profile incomplete).":
            localized("decision.optional_unknown.obligation", default: text)
        case "Today includes fasting/abstinence observance in your profile, but not mandatory.":
            localized("decision.optional_known.obligation", default: text)
        case "Follow age/health and pastoral guidance for your situation.":
            localized("decision.optional.allowed.guidance", default: text)
        case "If unsure, observe abstinence and a simpler meal pattern.":
            localized("decision.optional.allowed.unsure", default: text)
        case "Do not assume no obligation without confirming your profile.":
            localized("decision.optional.avoid", default: text)
        case "No mandatory food restriction today.":
            localized("decision.none.obligation", default: text)
        case "You may choose a voluntary penance.":
            localized("decision.none.allowed.penance", default: text)
        case "Today calls for Friday penance through abstinence from meat.":
            localized("decision.friday_abstinence.obligation", default: text)
        case "Today calls for Friday penance, not mandatory fasting.":
            localized("decision.friday_penance.obligation", default: text)
        case "Choose a penitential act, especially a work of charity or piety.":
            localized("decision.friday_penance.allowed.act", default: text)
        case "Do not skip Friday penance entirely.":
            localized("decision.friday_penance.avoid", default: text)
        case "Today requires Friday penance through abstinence from meat.":
            localized("decision.friday_abstinence.required_obligation", default: text)
        case "Today requires Friday penance, but not mandatory fasting.":
            localized("decision.friday_penance.required_obligation", default: text)
        case "Choose a penitential act (for example prayer, almsgiving, or another sacrifice).":
            localized("decision.friday_penance.required_act", default: text)
        default:
            text
        }
    }

    private func localizedFoodDecisionRationale(_ rationale: String) -> String {
        if rationale == "Health and pastoral obedience take priority when obligations do not bind." {
            return localized("decision.dispensation.rationale", default: rationale)
        }
        if rationale == "No mandatory fast/abstinence observance appears for today in your current profile." {
            return localized("decision.none.rationale", default: rationale)
        }
        if rationale == "No specific mandatory observance was detected." {
            return localized("decision.observance.none", default: rationale)
        }

        let unknownPrefix = "Review the age eligibility toggles in Settings so the app can determine whether "
        let knownPrefix = "Based on your current profile, "
        let unknownSuffix = " binds you."
        let knownSuffix = " does not strictly bind today."

        if rationale.hasPrefix(unknownPrefix), rationale.hasSuffix(unknownSuffix) {
            let titles = String(rationale.dropFirst(unknownPrefix.count).dropLast(unknownSuffix.count))
            return localizedFormat("decision.optional_unknown.rationale_format", default: "Review the age eligibility toggles in Settings so the app can determine whether %@ binds you.", titles)
        }

        if rationale.hasPrefix(knownPrefix), rationale.hasSuffix(knownSuffix) {
            let titles = String(rationale.dropFirst(knownPrefix.count).dropLast(knownSuffix.count))
            return localizedFormat("decision.optional_known.rationale_format", default: "Based on your current profile, %@ does not strictly bind today.", titles)
        }

        let singlePrefix = "This is based on "
        let singleSuffix = "."
        if rationale.hasPrefix(singlePrefix), rationale.hasSuffix(singleSuffix) {
            let titles = String(rationale.dropFirst(singlePrefix.count).dropLast(singleSuffix.count))
            let key = titles.contains(", ") ? "decision.observance.multi_format" : "decision.observance.single_format"
            return localizedFormat(key, default: "This is based on %@.", titles)
        }

        return rationale
    }

    private func localizedFoodDecisionSource(_ sourceLine: String) -> String {
        switch sourceLine {
        case "Source: USCCB and pastoral guidance.":
            localized("decision.sources.us.general", default: sourceLine)
        case "Source: USCCB Fast & Abstinence norms.":
            localized("decision.sources.us.fasting", default: sourceLine)
        case "Source: USCCB Friday penance norms.":
            localized("decision.sources.us.friday", default: sourceLine)
        case "Source: USCCB liturgical norms.":
            localized("decision.sources.us.holyday", default: sourceLine)
        case "Source: CCCB Friday guidance and universal law.":
            localized("decision.sources.ca.general", default: sourceLine)
        case "Source: universal fast/abstinence law with Canada Friday guidance.":
            localized("decision.sources.ca.fasting", default: sourceLine)
        case "Source: CCCB Friday guidance.":
            localized("decision.sources.ca.friday", default: sourceLine)
        case "Source: universal law and the Canada national baseline.":
            localized("decision.sources.ca.holyday", default: sourceLine)
        case "Source: universal law and local pastoral guidance.":
            localized("decision.sources.other.general", default: sourceLine)
        case "Source: universal fast/abstinence law.":
            localized("decision.sources.other.fasting", default: sourceLine)
        case "Source: local Friday penance guidance.":
            localized("decision.sources.other.friday", default: sourceLine)
        case "Source: local liturgical guidance.":
            localized("decision.sources.other.holyday", default: sourceLine)
        default:
            sourceLine
        }
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
