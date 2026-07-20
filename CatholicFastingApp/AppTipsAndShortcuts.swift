import SwiftUI
#if canImport(AppIntents)
import AppIntents
#endif
#if canImport(TipKit)
import TipKit
#endif

#if canImport(TipKit)
private func tipText(_ key: String, fallback: String) -> Text {
    Text(Bundle.main.localizedString(forKey: key, value: fallback, table: nil))
}

struct FastingDaysFocusTip: Tip {
    var title: Text {
        tipText("tips.fasting_days.title", fallback: "Focus Required Days")
    }

    var message: Text? {
        tipText("tips.fasting_days.message", fallback: "Open Calendar to filter required observances and plan ahead.")
    }

    var image: Image? {
        Image(systemName: "calendar.badge.clock")
    }
}

struct IntermittentTrackerTip: Tip {
    var title: Text {
        tipText("tips.intermittent.title", fallback: "Track Personal Fasts")
    }

    var message: Text? {
        tipText("tips.intermittent.message", fallback: "Use Fast for optional personal disciplines.")
    }

    var image: Image? {
        Image(systemName: "timer")
    }
}

struct MoreToolsTip: Tip {
    var title: Text {
        tipText("tips.more.title", fallback: "Everything Else Is in More")
    }

    var message: Text? {
        tipText("tips.more.message", fallback: "Use More for setup, reminders, premium, and privacy controls.")
    }

    var image: Image? {
        Image(systemName: "ellipsis.circle")
    }
}
#endif

#if canImport(AppIntents)
struct OpenTodayIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Today Plan"
    static let description = IntentDescription("Open the Today tab in Catholic Fasting.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(UIConstants.deepLinkTodayURL))
    }
}

struct OpenFastingDaysIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Calendar"
    static let description = IntentDescription("Open the Church observance calendar.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(UIConstants.deepLinkFastingDaysURL))
    }
}

struct OpenIntermittentTrackerIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Fast"
    static let description = IntentDescription("Open the optional personal fast tracker.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(UIConstants.deepLinkIntermittentURL))
    }
}

struct CatholicFastingAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenTodayIntent(),
            phrases: ["Open \(.applicationName) today"],
            shortTitle: "Today Plan",
            systemImageName: "sun.max")
        AppShortcut(
            intent: OpenFastingDaysIntent(),
            phrases: ["Open \(.applicationName) Calendar", "Open \(.applicationName) fasting days"],
            shortTitle: "Calendar",
            systemImageName: "calendar")
        AppShortcut(
            intent: OpenIntermittentTrackerIntent(),
            phrases: ["Open \(.applicationName) Fast", "Open \(.applicationName) fast tracker"],
            shortTitle: "Fast",
            systemImageName: "timer")
    }
}
#endif
