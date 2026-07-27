import SwiftUI

extension ContentView {
    var todayFoodDecision: DailyFoodDecision {
        DailyFoodDecisionLocalizer.localized(
            todayRawFoodDecision,
            languageMode: languageModeRaw)
    }

    var todayRawFoodDecision: DailyFoodDecision {
        DailyFoodDecisionEngine.decision(
            for: currentYearObservances,
            settings: settings,
            calendar: liturgicalCalendar)
    }
}
