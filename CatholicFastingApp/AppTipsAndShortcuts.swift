import SwiftUI
#if canImport(AppIntents)
import AppIntents
#endif
#if canImport(TipKit)
import TipKit
#endif

#if canImport(TipKit)
struct FastingDaysFocusTip: Tip {
    var title: Text {
        Text("Focus Required Days")
    }

    var message: Text? {
        Text("Open Fasting Days to filter required observances and plan ahead.")
    }

    var image: Image? {
        Image(systemName: "calendar.badge.clock")
    }
}

struct IntermittentTrackerTip: Tip {
    var title: Text {
        Text("Track Personal Fasts")
    }

    var message: Text? {
        Text("Use Track Fast for optional intermittent disciplines.")
    }

    var image: Image? {
        Image(systemName: "timer")
    }
}

struct MoreToolsTip: Tip {
    var title: Text {
        Text("Everything Else Is in More")
    }

    var message: Text? {
        Text("Use More for setup, reminders, premium, and privacy controls.")
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
    static let title: LocalizedStringResource = "Open Fasting Days"
    static let description = IntentDescription("Open the fasting days list.")
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & OpensIntent {
        .result(opensIntent: OpenURLIntent(UIConstants.deepLinkFastingDaysURL))
    }
}

struct OpenIntermittentTrackerIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Fast Tracker"
    static let description = IntentDescription("Open the intermittent fasting tracker.")
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
            phrases: ["Open \(.applicationName) fasting days"],
            shortTitle: "Fasting Days",
            systemImageName: "calendar")
        AppShortcut(
            intent: OpenIntermittentTrackerIntent(),
            phrases: ["Open \(.applicationName) fast tracker"],
            shortTitle: "Track Fast",
            systemImageName: "timer")
    }
}
#endif
