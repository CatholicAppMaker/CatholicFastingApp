import SwiftUI

extension ContentView {
    func handleDeepLink(_ url: URL) {
        guard let target = AppDeepLinkTarget.parse(url: url) else { return }
        switch target {
        case .surface(let surface):
            if surface == .more {
                navigationState.morePath = []
                navigationState.pendingPhoneNavigationPath = []
            }
            navigationState.homeSurface = surface
        case .settings:
            navigateToMoreDestination(.setupAndReminders)
        case .premium:
            supportPremiumSurfaceRaw = SupportPremiumSurface.upgrade.rawValue
            navigateToMoreDestination(.supportAndPremium)
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
}
