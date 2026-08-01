import SwiftUI

extension ContentView {
    func noteBinding(for observanceID: String) -> Binding<String> {
        Binding(
            get: { penanceNotes.note(for: observanceID) },
            set: { penanceNotes.setNote($0, for: observanceID) })
    }

    func focusFastingDaysOnUpcomingRequired() {
        fastingDaysShowAllYearDays = false
        fastingDaysIncludeOptionalDays = false
        navigationState.homeSurface = .fastingDays
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

    func todayButtonLabel(for status: CompletionStatus) -> String {
        switch status {
        case .notStarted:
            localized("observance.action.complete", default: "Complete")
        default:
            localizedCompletionStatusLabel(status)
        }
    }
}
