import Foundation

#if os(iOS) && canImport(WidgetKit)
import WidgetKit
#endif

struct WidgetSnapshot: Codable, Equatable {
    let generatedAt: Date
    let todayTitle: String
    let todayObligation: String
    let nextRequiredTitle: String
    let nextRequiredDate: Date?
    let completionRate: Double
    let hasActiveIntermittentFast: Bool
    let activeIntermittentFastStart: Date?
    let activeIntermittentTargetHours: Int
    let premiumMotivationLine: String
    let localizationCode: String

    enum CodingKeys: String, CodingKey {
        case generatedAt
        case todayTitle
        case todayObligation
        case nextRequiredTitle
        case nextRequiredDate
        case completionRate
        case hasActiveIntermittentFast
        case activeIntermittentFastStart
        case activeIntermittentTargetHours
        case premiumMotivationLine
        case localizationCode
    }

    init(
        generatedAt: Date,
        todayTitle: String,
        todayObligation: String,
        nextRequiredTitle: String,
        nextRequiredDate: Date?,
        completionRate: Double,
        hasActiveIntermittentFast: Bool,
        activeIntermittentFastStart: Date?,
        activeIntermittentTargetHours: Int,
        premiumMotivationLine: String = "Stay faithful in small daily disciplines.",
        localizationCode: String = "en")
    {
        self.generatedAt = generatedAt
        self.todayTitle = todayTitle
        self.todayObligation = todayObligation
        self.nextRequiredTitle = nextRequiredTitle
        self.nextRequiredDate = nextRequiredDate
        self.completionRate = completionRate
        self.hasActiveIntermittentFast = hasActiveIntermittentFast
        self.activeIntermittentFastStart = activeIntermittentFastStart
        self.activeIntermittentTargetHours = activeIntermittentTargetHours
        self.premiumMotivationLine = premiumMotivationLine
        self.localizationCode = localizationCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        generatedAt = try container.decode(Date.self, forKey: .generatedAt)
        todayTitle = try container.decode(String.self, forKey: .todayTitle)
        todayObligation = try container.decode(String.self, forKey: .todayObligation)
        nextRequiredTitle = try container.decode(String.self, forKey: .nextRequiredTitle)
        nextRequiredDate = try container.decodeIfPresent(Date.self, forKey: .nextRequiredDate)
        completionRate = try container.decode(Double.self, forKey: .completionRate)
        hasActiveIntermittentFast = try container.decode(Bool.self, forKey: .hasActiveIntermittentFast)
        activeIntermittentFastStart = try container.decodeIfPresent(Date.self, forKey: .activeIntermittentFastStart)
        activeIntermittentTargetHours = try container.decode(Int.self, forKey: .activeIntermittentTargetHours)
        premiumMotivationLine =
            try container.decodeIfPresent(String.self, forKey: .premiumMotivationLine)
                ?? "Stay faithful in small daily disciplines."
        localizationCode = try container.decodeIfPresent(String.self, forKey: .localizationCode) ?? "en"
    }
}

enum WidgetSnapshotContract {
    static let appGroupIdentifier = "group.com.kevpierce.CatholicFastingApp"
    static let snapshotKey = "widget_snapshot"
    static let widgetKind = "CatholicFastingWidget"
}

enum WidgetSnapshotStore {
    private static var prefersLocalOnlyStorage: Bool {
        let processInfo = ProcessInfo.processInfo
        let arguments = processInfo.arguments
        let environment = processInfo.environment
        return environment["UITEST_MODE"] == "1"
            || environment["DISABLE_APP_GROUP_STORAGE"] == "1"
            || arguments.contains("-uitest-reset")
            || arguments.contains("-uitest-skip-onboarding")
            || arguments.contains("-uitest-seed-deterministic")
            || arguments.contains("-uitest-seed-missed")
    }

    private static var sharedDefaults: UserDefaults? {
        guard !prefersLocalOnlyStorage else { return nil }
        return UserDefaults(suiteName: WidgetSnapshotContract.appGroupIdentifier)
    }

    static func persist(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        if let sharedDefaults {
            sharedDefaults.set(data, forKey: WidgetSnapshotContract.snapshotKey)
        } else {
            UserDefaults.standard.set(data, forKey: WidgetSnapshotContract.snapshotKey)
        }

        #if os(iOS) && canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotContract.widgetKind)
        #endif
    }

    static func load() -> WidgetSnapshot? {
        let data = sharedDefaults?.data(forKey: WidgetSnapshotContract.snapshotKey)
            ?? UserDefaults.standard.data(forKey: WidgetSnapshotContract.snapshotKey)
        guard let data else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    static func clear() {
        sharedDefaults?.removeObject(forKey: WidgetSnapshotContract.snapshotKey)
        UserDefaults.standard.removeObject(forKey: WidgetSnapshotContract.snapshotKey)

        #if os(iOS) && canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotContract.widgetKind)
        #endif
    }
}
