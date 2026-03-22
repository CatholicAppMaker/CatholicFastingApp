@preconcurrency import Foundation

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
        premiumMotivationLine: String = "Stay faithful in small daily disciplines.")
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
    }
}

enum PremiumRuleTemplate: String, Codable, CaseIterable, Identifiable {
    case beginner
    case steady
    case disciplined
    case traditional
    case custom

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .beginner: "Beginner"
        case .steady: "Steady"
        case .disciplined: "Disciplined"
        case .traditional: "Traditional"
        case .custom: "Custom"
        }
    }

    var summary: String {
        switch self {
        case .beginner:
            "One optional discipline per week with consistency focus."
        case .steady:
            "Two optional disciplines weekly with stable reminders."
        case .disciplined:
            "Three disciplined practices weekly plus review."
        case .traditional:
            "Stronger penitential rhythm with clear safeguards."
        case .custom:
            "Fully user-adjusted rhythm."
        }
    }
}

struct PremiumConditionRules: Codable, Equatable {
    var remindIfUnloggedByNoon: Bool
    var requiredDaysDoubleReminder: Bool
    var milestoneNudgesForActiveFast: Bool

    static let `default` = PremiumConditionRules(
        remindIfUnloggedByNoon: true,
        requiredDaysDoubleReminder: true,
        milestoneNudgesForActiveFast: true)
}

enum PremiumSeasonProgram: String, Codable, CaseIterable, Identifiable {
    case liturgicalRhythm
    case lentDeepen
    case adventWatch
    case fridayFidelity

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .liturgicalRhythm: "Liturgical Rhythm"
        case .lentDeepen: "Lenten Deepen"
        case .adventWatch: "Advent Watch"
        case .fridayFidelity: "Friday Fidelity"
        }
    }
}

struct PremiumVirtueLog: Codable, Equatable, Identifiable {
    let id: String
    let createdAt: Date
    var virtue: String
    var note: String
}

struct PremiumCompanionState: Codable, Equatable {
    var templateRawValue: String
    var optionalDisciplinesPerWeek: Int
    var fixedFastWeekday: Int
    var protectFeastDays: Bool
    var conditionRules: PremiumConditionRules
    var seasonProgramRawValue: String
    var seasonProgramStartDate: Date
    var completedProgramActions: [String]
    var virtueLogs: [PremiumVirtueLog]

    static let `default` = PremiumCompanionState(
        templateRawValue: PremiumRuleTemplate.steady.rawValue,
        optionalDisciplinesPerWeek: 2,
        fixedFastWeekday: 6,
        protectFeastDays: true,
        conditionRules: .default,
        seasonProgramRawValue: PremiumSeasonProgram.liturgicalRhythm.rawValue,
        seasonProgramStartDate: Date(),
        completedProgramActions: [],
        virtueLogs: [])
}

struct PremiumHouseholdSharePacket: Codable, Equatable {
    let generatedAt: Date
    let planningData: FastingPlanningData
    let schedules: [IntermittentSchedulePlan]
    let checklist: [PremiumChecklistItem]
}

enum WidgetSnapshotStore {
    private static let key = "widget_snapshot"
    private static let appGroupIdentifier = "group.com.kevpierce.CatholicFastingApp"

    static func persist(_ snapshot: WidgetSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.set(data, forKey: key)
        } else {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> WidgetSnapshot? {
        let data: Data? = if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.data(forKey: key)
        } else {
            UserDefaults.standard.data(forKey: key)
        }
        guard let data else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    static func clear() {
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.removeObject(forKey: key)
        }
        UserDefaults.standard.removeObject(forKey: key)
    }
}

struct WeeklyIntention: Codable, Equatable, Identifiable {
    let id: String
    var weekday: Int
    var note: String
}

struct SeasonCommitment: Codable, Equatable, Identifiable {
    let id: String
    var season: LiturgicalSeason
    var title: String
    var isEnabled: Bool
}

struct FastingPlanningData: Codable, Equatable {
    var requiredGoal: Int
    var optionalGoal: Int
    var weeklyIntentions: [WeeklyIntention]
    var seasonCommitments: [SeasonCommitment]

    static let `default` = FastingPlanningData(
        requiredGoal: 20,
        optionalGoal: 40,
        weeklyIntentions: [
            WeeklyIntention(id: UUID().uuidString, weekday: 1, note: "Mass and examen"),
            WeeklyIntention(id: UUID().uuidString, weekday: 5, note: "Friday penance with almsgiving"),
        ],
        seasonCommitments: [
            SeasonCommitment(id: UUID().uuidString, season: .advent, title: "Simplify one meal weekly", isEnabled: true),
            SeasonCommitment(id: UUID().uuidString, season: .lent, title: "Fast with daily Rosary", isEnabled: true),
            SeasonCommitment(id: UUID().uuidString, season: .easter, title: "Add thanksgiving prayer at meals", isEnabled: true),
            SeasonCommitment(id: UUID().uuidString, season: .ordinary, title: "Friday abstinence or substitute penance", isEnabled: true),
        ])
}

struct IntermittentSchedulePlan: Codable, Equatable, Identifiable {
    let id: String
    var name: String
    var targetHours: Int
    var startHour: Int
    var weekdays: [Int]
}

struct HouseholdProfile: Codable, Equatable, Identifiable {
    let id: String
    var name: String
    var isAge14OrOlderForAbstinence: Bool
    var isAge18OrOlderForFasting: Bool
    var medicalDispensation: Bool

    init(
        id: String,
        name: String,
        isAge14OrOlderForAbstinence: Bool,
        isAge18OrOlderForFasting: Bool,
        medicalDispensation: Bool)
    {
        self.id = id
        self.name = name
        self.isAge14OrOlderForAbstinence = isAge14OrOlderForAbstinence
        self.isAge18OrOlderForFasting = isAge18OrOlderForFasting
        self.medicalDispensation = medicalDispensation
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isAge14OrOlderForAbstinence
        case isAge18OrOlderForFasting
        case medicalDispensation
        case birthYear
        case birthMonth
        case birthDay
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        medicalDispensation =
            try container.decodeIfPresent(Bool.self, forKey: .medicalDispensation)
                ?? false

        if let abstinence = try container.decodeIfPresent(
            Bool.self,
            forKey: .isAge14OrOlderForAbstinence),
            let fasting = try container.decodeIfPresent(Bool.self, forKey: .isAge18OrOlderForFasting)
        {
            isAge14OrOlderForAbstinence = abstinence
            isAge18OrOlderForFasting = fasting
            return
        }

        let birthYear = try container.decodeIfPresent(Int.self, forKey: .birthYear) ?? 0
        let birthMonth = try container.decodeIfPresent(Int.self, forKey: .birthMonth) ?? 0
        let birthDay = try container.decodeIfPresent(Int.self, forKey: .birthDay) ?? 0
        let legacyAge = Self.legacyAge(
            birthYear: birthYear,
            birthMonth: birthMonth,
            birthDay: birthDay)
        isAge14OrOlderForAbstinence = legacyAge.map { $0 >= 14 } ?? true
        isAge18OrOlderForFasting = legacyAge.map { (18 ..< 60).contains($0) } ?? true
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isAge14OrOlderForAbstinence, forKey: .isAge14OrOlderForAbstinence)
        try container.encode(isAge18OrOlderForFasting, forKey: .isAge18OrOlderForFasting)
        try container.encode(medicalDispensation, forKey: .medicalDispensation)
    }

    private static func legacyAge(birthYear: Int, birthMonth: Int, birthDay: Int) -> Int? {
        guard birthYear >= 1900 else { return nil }
        let calendar = Calendar.gregorian
        let now = Date()
        let currentYear = calendar.component(.year, from: now)

        guard (1 ... 12).contains(birthMonth), (1 ... 31).contains(birthDay) else {
            return max(0, currentYear - birthYear)
        }

        guard
            let birthDate = calendar.date(
                from: DateComponents(year: birthYear, month: birthMonth, day: birthDay, hour: 12))
        else {
            return max(0, currentYear - birthYear)
        }

        var age = currentYear - birthYear
        if let anniversary = calendar.date(byAdding: .year, value: age, to: birthDate) {
            if calendar.startOfDay(for: now) < calendar.startOfDay(for: anniversary) {
                age -= 1
            }
        }
        return max(0, age)
    }
}

struct ReflectionJournalEntry: Codable, Equatable, Identifiable {
    let id: String
    var createdAt: Date
    var title: String
    var body: String
}

struct PremiumChecklistItem: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var isDone: Bool
}

struct DevotionalEntry: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let prayer: String
    let context: String
    let season: LiturgicalSeason?
}

enum DevotionalPack {
    static let entries: [DevotionalEntry] = [
        DevotionalEntry(
            id: "offertory-fast",
            title: "Morning Offering for Fasting",
            prayer: "Lord Jesus, receive this fast in union with Your sacrifice, for conversion and charity.",
            context: "Use at the start of a fast day.",
            season: nil),
        DevotionalEntry(
            id: "advent-watch",
            title: "Advent Watchfulness",
            prayer: "Come, Lord Jesus. Purify my desires and make my discipline an act of hope.",
            context: "Advent preparation.",
            season: .advent),
        DevotionalEntry(
            id: "lent-penitence",
            title: "Lenten Penitence",
            prayer: "Merciful Father, let prayer, fasting, and almsgiving shape my heart to Christ.",
            context: "Lenten discipline.",
            season: .lent),
        DevotionalEntry(
            id: "friday-mercy",
            title: "Friday Act of Mercy",
            prayer: "Lord, unite this Friday penance to works of mercy for those in need.",
            context: "Friday abstinence or substitute penance.",
            season: nil),
    ]
}

enum LocalFeatureStore {
    private static let planningKey = "planning_data_v1"
    private static let schedulesKey = "intermittent_schedules_v1"
    private static let activeScheduleKey = "intermittent_active_schedule_v1"
    private static let profilesKey = "household_profiles_v1"
    private static let activeProfileKey = "household_active_profile_v1"
    private static let reflectionsKey = "reflection_journal_v1"
    private static let checklistKey = "premium_checklist_v1"
    private static let premiumCompanionKey = "premium_companion_v1"
    private static let devotionFavoritesKey = "devotional_favorites_v1"
    private static let launchFunnelSnapshotKey = "launch_funnel_snapshot_v1"

    static func loadPlanningData() -> FastingPlanningData {
        load(FastingPlanningData.self, key: planningKey) ?? .default
    }

    static func savePlanningData(_ value: FastingPlanningData) {
        save(value, key: planningKey)
    }

    static func loadSchedules() -> [IntermittentSchedulePlan] {
        load([IntermittentSchedulePlan].self, key: schedulesKey)
            ?? [IntermittentSchedulePlan(id: UUID().uuidString, name: "Mon/Wed/Fri 16h", targetHours: 16, startHour: 20, weekdays: [2, 4, 6])]
    }

    static func saveSchedules(_ value: [IntermittentSchedulePlan]) {
        save(value, key: schedulesKey)
    }

    static func loadActiveScheduleID() -> String? {
        UserDefaults.standard.string(forKey: activeScheduleKey)
    }

    static func saveActiveScheduleID(_ value: String?) {
        UserDefaults.standard.set(value, forKey: activeScheduleKey)
    }

    static func loadProfiles() -> [HouseholdProfile] {
        load([HouseholdProfile].self, key: profilesKey)
            ?? [
                HouseholdProfile(
                    id: UUID().uuidString,
                    name: "My Profile",
                    isAge14OrOlderForAbstinence: true,
                    isAge18OrOlderForFasting: true,
                    medicalDispensation: false),
            ]
    }

    static func saveProfiles(_ value: [HouseholdProfile]) {
        save(value, key: profilesKey)
    }

    static func loadActiveProfileID() -> String? {
        UserDefaults.standard.string(forKey: activeProfileKey)
    }

    static func saveActiveProfileID(_ value: String?) {
        UserDefaults.standard.set(value, forKey: activeProfileKey)
    }

    static func loadReflections() -> [ReflectionJournalEntry] {
        load([ReflectionJournalEntry].self, key: reflectionsKey) ?? []
    }

    static func saveReflections(_ value: [ReflectionJournalEntry]) {
        save(value, key: reflectionsKey)
    }

    static func loadChecklist() -> [PremiumChecklistItem] {
        load([PremiumChecklistItem].self, key: checklistKey)
            ?? [
                PremiumChecklistItem(id: UUID().uuidString, title: "Plan Friday penance for this week", isDone: false),
                PremiumChecklistItem(id: UUID().uuidString, title: "Set reminder cadence for next liturgical season", isDone: false),
            ]
    }

    static func saveChecklist(_ value: [PremiumChecklistItem]) {
        save(value, key: checklistKey)
    }

    static func loadPremiumCompanionState() -> PremiumCompanionState {
        load(PremiumCompanionState.self, key: premiumCompanionKey) ?? .default
    }

    static func savePremiumCompanionState(_ value: PremiumCompanionState) {
        save(value, key: premiumCompanionKey)
    }

    static func loadDevotionalFavorites() -> Set<String> {
        Set(UserDefaults.standard.array(forKey: devotionFavoritesKey) as? [String] ?? [])
    }

    static func saveDevotionalFavorites(_ value: Set<String>) {
        UserDefaults.standard.set(Array(value).sorted(), forKey: devotionFavoritesKey)
    }

    static func loadLaunchFunnelSnapshot() -> LaunchFunnelSnapshot {
        load(LaunchFunnelSnapshot.self, key: launchFunnelSnapshotKey) ?? .default
    }

    static func saveLaunchFunnelSnapshot(_ value: LaunchFunnelSnapshot) {
        save(value, key: launchFunnelSnapshotKey)
    }

    static func clearAll() {
        let defaults = UserDefaults.standard
        [
            planningKey,
            schedulesKey,
            activeScheduleKey,
            profilesKey,
            activeProfileKey,
            reflectionsKey,
            checklistKey,
            premiumCompanionKey,
            devotionFavoritesKey,
            launchFunnelSnapshotKey,
        ].forEach { defaults.removeObject(forKey: $0) }
    }

    private static func load<T: Decodable>(_: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func save(_ value: some Encodable, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
