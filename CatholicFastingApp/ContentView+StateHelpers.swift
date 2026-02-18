import SwiftUI

extension ContentView {
  func noteBinding(for observanceID: String) -> Binding<String> {
    Binding(
      get: { penanceNotes.note(for: observanceID) },
      set: { penanceNotes.setNote($0, for: observanceID) }
    )
  }

  func focusCalendarOnUpcomingRequired() {
    observanceFilter = .requiredOnly
    observanceQuery = ""
    calendarWindow = .next30Days
    observanceSortOrder = .requiredFirst
    homeSurface = .calendar
    LocalAnalyticsStore.track(.openedCalendarFocus)
  }

  func resetCalendarFilters() {
    observanceFilter = .all
    observanceQuery = ""
    calendarWindow = .allYear
    observanceSortOrder = .chronological
  }

  var observancesForToday: [Observance] {
    observances.filter { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
  }

  var filteredObservances: [Observance] {
    ObservanceQueryEngine.filter(
      observances: observances,
      query: observanceQuery,
      filter: observanceFilter,
      window: calendarWindow,
      sortOrder: observanceSortOrder,
      statusesByID: tracker.statusesByID,
      now: Date()
    )
  }

  var upcomingMandatoryObservance: Observance? {
    let today = Calendar.current.startOfDay(for: Date())
    return observances.first { observance in
      observance.obligation == .mandatory && Calendar.current.startOfDay(for: observance.date) >= today
    }
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
    observances.filter { $0.obligation == .mandatory }.count
  }

  var calendarFilterSummaryText: String {
    let shown = filteredObservances.count
    let total = observances.count
    return "Showing \(shown) of \(total) observances (\(observanceFilter.label), \(calendarWindow.label), \(observanceSortOrder.label))."
  }

  var heroSummaryText: String {
    if let next = upcomingMandatoryObservance {
      return "Next required observance is \(next.title) on \(next.date.formatted(date: .abbreviated, time: .omitted))."
    }
    return "No remaining required observances in the selected year."
  }

  var todayFoodDecision: DailyFoodDecision {
    DailyFoodDecisionEngine.decision(for: observances, settings: settings)
  }

  var localAnalyticsSnapshot: LocalAnalyticsSnapshot {
    LocalAnalyticsStore.snapshot()
  }

  var hasConfiguredBirthYear: Bool {
    birthYear > 0
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
    if hasConfiguredBirthYear { completed += 1 }
    if hasConfiguredConsent { completed += 1 }
    if hasConfiguredReminderPlan { completed += 1 }
    return completed
  }

  var isQuickSetupComplete: Bool {
    setupChecklistCompleted == setupChecklistTotal
  }

  var missedDayRecoveryPlan: MissedDayRecoveryPlan? {
    MissedDayRecoveryEngine.plan(
      observances: observances,
      statusesByID: tracker.statusesByID
    )
  }

  var currentLiturgicalSeason: LiturgicalSeason {
    LiturgicalSeasonThemeEngine.season(for: Date())
  }

  var premiumSeasonPlan: PremiumSeasonPlan {
    PremiumSeasonPlanEngine.plan(for: currentLiturgicalSeason, settings: settings)
  }

  var premiumReminderRecommendation: PremiumReminderRecommendation {
    PremiumReminderPlanner.recommendation(
      observances: observances,
      statusesByID: tracker.statusesByID
    )
  }

  var premiumAnalyticsSummary: PremiumAnalyticsSummary {
    PremiumAnalyticsEngine.summary(
      observances: observances,
      statusesByID: tracker.statusesByID,
      sessions: intermittentTracker.sessions
    )
  }

  var premiumReflection: PremiumReflection {
    PremiumReflectionEngine.reflection(
      season: currentLiturgicalSeason
    )
  }

  var premiumDirectionSummaryText: String {
    PremiumDirectionSummaryEngine.summaryText(
      season: currentLiturgicalSeason,
      analytics: premiumAnalyticsSummary,
      reminder: premiumReminderRecommendation,
      plan: premiumSeasonPlan,
      latestReflection: premiumReflection
    )
  }

  func applyPremiumReminderRecommendation() {
    let recommendation = premiumReminderRecommendation
    dailyReminderSupportEnabled = recommendation.shouldEnableDailySupport
    morningReminderEnabled = recommendation.shouldEnableMorning
    eveningReminderEnabled = recommendation.shouldEnableEvening
    premiumCoachStatus = recommendation.summaryLine
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
    LocalAnalyticsStore.track(.recoverySubstituteLogged)
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

  func intermittentPlanDescription(_ hours: Int) -> String {
    if hours <= 24 {
      return "\(hours)h fast / \(24 - hours)h eating"
    }
    return "\(hours)h fast target"
  }

  var completionDates: [Date] {
    actionableObservances
      .filter { tracker.status(for: $0.id).countsTowardProgress }
      .map { Calendar.current.startOfDay(for: $0.date) }
      .sorted()
  }

  var currentStreak: Int {
    let uniqueDays = Array(Set(completionDates)).sorted(by: >)
    guard !uniqueDays.isEmpty else { return 0 }

    var streak = 0
    var expected = Calendar.current.startOfDay(for: Date())
    for day in uniqueDays {
      if Calendar.current.isDate(day, inSameDayAs: expected) {
        streak += 1
        expected = Calendar.current.date(byAdding: .day, value: -1, to: expected) ?? expected
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
      let diff = Calendar.current.dateComponents([.day], from: prior, to: currentDay).day ?? 0
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
}
