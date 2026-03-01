import SwiftUI
#if canImport(TipKit)
  import TipKit
#endif

extension ContentView {
  var liturgicalCalendar: Calendar {
    .gregorian
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

  var voiceSummaryText: String {
    let nextRequired = upcomingMandatoryObservance?.title ?? "No required observance soon"
    return "Today completion is \(completionRateText). Current streak is \(currentStreak) days. Next required observance is \(nextRequired)."
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

  func saveCurrentFastingDaysPreset() {
    let timestamp = Date().formatted(date: .abbreviated, time: .shortened)
    let preset = SavedCalendarPreset(
      id: UUID().uuidString,
      name: "\(observanceFilter.label) • \(fastingDaysWindow.label) • \(timestamp)",
      query: observanceQuery,
      filterRawValue: observanceFilter.rawValue,
      windowRawValue: fastingDaysWindow.rawValue,
      sortRawValue: observanceSortOrder.rawValue
    )
    savedFastingDaysPresets.insert(preset, at: 0)
    selectedFastingDaysPresetID = preset.id
  }

  func applySelectedFastingDaysPreset() {
    guard let preset = savedFastingDaysPresets.first(where: { $0.id == selectedFastingDaysPresetID }) else { return }
    observanceQuery = preset.query
    observanceFilter = ObservanceFilter(rawValue: preset.filterRawValue) ?? .all
    fastingDaysWindow = CalendarWindow(rawValue: preset.windowRawValue) ?? .allYear
    observanceSortOrder = ObservanceSortOrder(rawValue: preset.sortRawValue) ?? .chronological
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
      birthYear: birthYear,
      birthMonth: birthMonth,
      birthDay: birthDay,
      medicalDispensation: medicalDispensation
    )
    householdProfiles.append(profile)
    activeHouseholdProfileID = profile.id
    newHouseholdProfileName = ""
  }

  func applyActiveHouseholdProfile() {
    guard let profile = activeHouseholdProfile else { return }
    birthYear = profile.birthYear
    birthMonth = profile.birthMonth
    birthDay = profile.birthDay
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
          .displayFrequency(.daily)
        ])
        didConfigureTips = true
      }
    #endif
    // Privacy: the app now uses age-eligibility toggles instead of DOB.
    birthYear = DefaultValues.birthYear
    birthMonth = DefaultValues.birthMonth
    birthDay = DefaultValues.birthDay
    persistWidgetSnapshot()
    await monetizationStore.refreshCatalogAndEntitlements()
    _ = await ReminderScheduler.topUpRequiredReminders(observances: rollingUpcomingObservances)
    notificationStatus = await ReminderScheduler.notificationSummary()
    ensureActiveHouseholdProfileSelection()
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
      todayObligation: todayObservance?.obligation.label ?? "No obligation",
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
    observanceFilter = .requiredOnly
    observanceQuery = ""
    fastingDaysWindow = .next30Days
    observanceSortOrder = .requiredFirst
    homeSurface = .fastingDays
  }

  func resetFastingDaysFilters() {
    observanceFilter = .all
    observanceQuery = ""
    fastingDaysWindow = .allYear
    observanceSortOrder = .chronological
  }

  var observancesForToday: [Observance] {
    currentYearObservances.filter { liturgicalCalendar.isDate($0.date, inSameDayAs: Date()) }
  }

  var filteredObservances: [Observance] {
    ObservanceQueryEngine.filter(
      observances: observances,
      query: observanceQuery,
      filter: observanceFilter,
      window: fastingDaysWindow,
      sortOrder: observanceSortOrder,
      statusesByID: tracker.statusesByID,
      now: Date(),
      calendar: liturgicalCalendar
    )
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

  var fastingDaysFilterSummaryText: String {
    let shown = filteredObservances.count
    let total = observances.count
    return "Showing \(shown) of \(total) observances (\(observanceFilter.label), \(fastingDaysWindow.label), \(observanceSortOrder.label))."
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

  var hasConfiguredBirthDate: Bool {
    // Privacy-first setup: age is handled by explicit toggles instead of DOB collection.
    true
  }

  var hasConfiguredConsent: Bool {
    acceptedLegalNotice
  }

  var hasConfiguredReminderPlan: Bool {
    guard dailyReminderSupportEnabled else { return true }
    return morningReminderEnabled || eveningReminderEnabled
  }

  var setupChecklistTotal: Int {
    2
  }

  var setupChecklistCompleted: Int {
    var completed = 0
    if hasConfiguredConsent { completed += 1 }
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
    for index in 1..<uniqueDays.count {
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
      return "Complete"
    default:
      return status.label
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
    guard index >= 0 && index < symbols.count else { return "" }
    return symbols[index]
  }

  func toggleIntermittentScheduleWeekday(_ weekday: Int) {
    guard (1...7).contains(weekday) else { return }
    if newIntermittentScheduleWeekdays.contains(weekday) {
      newIntermittentScheduleWeekdays.remove(weekday)
    } else {
      newIntermittentScheduleWeekdays.insert(weekday)
    }
  }
}
