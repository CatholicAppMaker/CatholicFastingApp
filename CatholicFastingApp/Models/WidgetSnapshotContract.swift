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

    var activeIntermittentTargetDate: Date? {
        WidgetActiveFastTiming.targetDate(
            isActive: hasActiveIntermittentFast,
            start: activeIntermittentFastStart,
            targetHours: activeIntermittentTargetHours)
    }

    func hasReachedActiveIntermittentTarget(at date: Date) -> Bool {
        guard let activeIntermittentTargetDate else { return false }
        return date >= activeIntermittentTargetDate
    }

    func isCurrent(at date: Date, calendar: Calendar = .autoupdatingCurrent) -> Bool {
        calendar.isDate(generatedAt, inSameDayAs: date)
    }
}

enum WidgetActiveFastTiming {
    static func targetDate(isActive: Bool, start: Date?, targetHours: Int) -> Date? {
        guard isActive, let start, (1 ... 168).contains(targetHours) else { return nil }
        return start.addingTimeInterval(TimeInterval(targetHours) * 3600)
    }
}

enum WidgetTimelineSchedule {
    static func nextRefreshDate(
        after date: Date,
        activeFastTargetDate: Date?,
        calendar: Calendar = .autoupdatingCurrent) -> Date
    {
        let intervalRefresh = calendar.date(byAdding: .minute, value: 30, to: date)
            ?? date.addingTimeInterval(30 * 60)
        let nextDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: calendar.startOfDay(for: date))

        return [intervalRefresh, nextDay, activeFastTargetDate]
            .compactMap(\.self)
            .filter { $0 > date }
            .min()
            ?? intervalRefresh
    }
}

enum WidgetLocalizationCode {
    private static let supportedCodes: Set<String> = ["en", "es", "fr-CA"]

    static func candidates(for requestedCode: String) -> [String] {
        let trimmed = requestedCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedMode: String = switch trimmed.lowercased() {
        case "english":
            "en"
        case "spanish":
            "es"
        case "frenchcanadian":
            "fr-CA"
        default:
            trimmed.replacingOccurrences(of: "_", with: "-")
        }

        let components = normalizedMode.split(separator: "-", omittingEmptySubsequences: true)
        guard let languageComponent = components.first else { return ["en"] }

        let language = languageComponent.lowercased()
        let region = components.dropFirst().first.map { $0.uppercased() }
        let canonical = region.map { "\(language)-\($0)" } ?? language

        let candidates: [String] = switch language {
        case "fr":
            region == nil ? ["fr-CA", "fr"] : [canonical, "fr-CA", "fr"]
        case "es", "en":
            region == nil ? [language] : [canonical, language]
        default:
            region == nil ? [language] : [canonical, language]
        }

        var seen = Set<String>()
        return candidates.filter { seen.insert($0).inserted }
    }

    static func resolvedSupportedCode(for requestedCode: String) -> String {
        candidates(for: requestedCode).first(where: supportedCodes.contains) ?? "en"
    }
}

enum WidgetSnapshotContract {
    static let appGroupIdentifier = "group.com.kevpierce.CatholicFastingApp"
    static let snapshotKey = "widget_snapshot"
    static let localizationCodeKey = "widget_localization_code"
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
            sharedDefaults.set(snapshot.localizationCode, forKey: WidgetSnapshotContract.localizationCodeKey)
        } else {
            UserDefaults.standard.set(data, forKey: WidgetSnapshotContract.snapshotKey)
            UserDefaults.standard.set(snapshot.localizationCode, forKey: WidgetSnapshotContract.localizationCodeKey)
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

    static func fallbackLocalizationCode() -> String? {
        sharedDefaults?.string(forKey: WidgetSnapshotContract.localizationCodeKey)
            ?? UserDefaults.standard.string(forKey: WidgetSnapshotContract.localizationCodeKey)
    }

    static func clear() {
        sharedDefaults?.removeObject(forKey: WidgetSnapshotContract.snapshotKey)
        sharedDefaults?.removeObject(forKey: WidgetSnapshotContract.localizationCodeKey)
        UserDefaults.standard.removeObject(forKey: WidgetSnapshotContract.snapshotKey)
        UserDefaults.standard.removeObject(forKey: WidgetSnapshotContract.localizationCodeKey)

        #if os(iOS) && canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSnapshotContract.widgetKind)
        #endif
    }
}
