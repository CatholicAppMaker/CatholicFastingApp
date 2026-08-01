import SwiftUI
#if canImport(AppIntents)
import AppIntents
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
