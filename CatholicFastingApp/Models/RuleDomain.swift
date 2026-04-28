@preconcurrency import Foundation
import SwiftUI
#if canImport(CryptoKit)
import CryptoKit
#endif

struct RuleSettings: Hashable {
    enum RegionProfile: String, CaseIterable, Identifiable {
        case us
        case canada
        case other

        var id: String {
            rawValue
        }

        var label: String {
            switch self {
            case .us:
                "United States"
            case .canada:
                "Canada"
            case .other:
                "Other"
            }
        }
    }

    enum CalendarMode: String, CaseIterable, Identifiable {
        case usccb
        case traditional1962

        var id: String {
            rawValue
        }

        var label: String {
            switch self {
            case .usccb:
                "USCCB (Ordinary Form)"
            case .traditional1962:
                "Traditional (1962-inspired)"
            }
        }
    }

    enum USProvincePreset: String, CaseIterable, Identifiable {
        case custom
        case boston
        case hartford
        case newYork
        case newark
        case omaha
        case philadelphia
        case otherUSProvince

        var id: String {
            rawValue
        }

        var label: String {
            switch self {
            case .custom:
                "Custom"
            case .boston:
                "Boston"
            case .hartford:
                "Hartford"
            case .newYork:
                "New York"
            case .newark:
                "Newark"
            case .omaha:
                "Omaha"
            case .philadelphia:
                "Philadelphia"
            case .otherUSProvince:
                "Other U.S. Province"
            }
        }

        var suggestedAscension: AscensionObservance? {
            switch self {
            case .custom:
                nil
            case .boston, .hartford, .newYork, .newark, .omaha, .philadelphia:
                .thursday
            case .otherUSProvince:
                .sunday
            }
        }
    }

    enum AscensionObservance: String, CaseIterable, Identifiable {
        case thursday
        case sunday

        var id: String {
            rawValue
        }

        var label: String {
            switch self {
            case .thursday:
                "Thursday (traditional)"
            case .sunday:
                "Sunday (transferred)"
            }
        }
    }

    enum FridayOutsideLentMode: String, CaseIterable, Identifiable {
        case abstainFromMeat
        case substitutePenance

        var id: String {
            rawValue
        }

        var label: String {
            switch self {
            case .abstainFromMeat:
                "Abstain from meat"
            case .substitutePenance:
                "Another penitential act"
            }
        }
    }

    let birthYear: Int
    let birthMonth: Int
    let birthDay: Int
    let isAge14OrOlderForAbstinence: Bool
    let isAge18OrOlderForFasting: Bool
    let hasMedicalDispensation: Bool
    let ascensionObservance: AscensionObservance
    let fridayOutsideLentMode: FridayOutsideLentMode
    let calendarMode: CalendarMode
    let regionProfile: RegionProfile

    init(
        birthYear: Int,
        birthMonth: Int = 0,
        birthDay: Int = 0,
        isAge14OrOlderForAbstinence: Bool = true,
        isAge18OrOlderForFasting: Bool = true,
        hasMedicalDispensation: Bool,
        ascensionObservance: AscensionObservance,
        fridayOutsideLentMode: FridayOutsideLentMode,
        calendarMode: CalendarMode,
        regionProfile: RegionProfile = .us)
    {
        self.birthYear = birthYear
        self.birthMonth = birthMonth
        self.birthDay = birthDay
        self.isAge14OrOlderForAbstinence = isAge14OrOlderForAbstinence
        self.isAge18OrOlderForFasting = isAge18OrOlderForFasting
        self.hasMedicalDispensation = hasMedicalDispensation
        self.ascensionObservance = ascensionObservance
        self.fridayOutsideLentMode = fridayOutsideLentMode
        self.calendarMode = calendarMode
        self.regionProfile = regionProfile
    }

    var hasFullBirthDate: Bool {
        guard birthYear > 0 else { return false }
        guard (1 ... 12).contains(birthMonth) else { return false }
        guard (1 ... 31).contains(birthDay) else { return false }
        return Calendar.gregorian.date(
            from: DateComponents(year: birthYear, month: birthMonth, day: birthDay, hour: 12)) != nil
    }
}

struct RuleBundleMetadata: Hashable {
    let id: String
    let displayName: String
    let version: String
    let effectiveDate: Date
    let reviewedDate: Date
}

struct RuleBundleChange: Hashable, Identifiable {
    let id: String
    let date: Date
    let title: String
    let detail: String
}

struct RuleBundleAudit: Hashable {
    let source: String
    let isVerified: Bool
    let warnings: [String]
}

struct RuleCitation: Hashable {
    enum Authority: String {
        case universalLaw = "Universal Law"
        case usccb = "USCCB"
        case cccb = "CCCB"
        case pastoral = "Pastoral Guidance"
    }

    let authority: Authority
    let title: String
    let shortReference: String
}

struct LiturgicalMonthDayEntry: Hashable {
    let title: String
    let month: Int
    let day: Int
}

enum USCCBYearlyCalendarData {
    enum EntryKind: String, Codable {
        case feastDay
        case memorialDay
    }

    struct Entry: Hashable, Codable {
        let month: Int
        let day: Int
        let title: String
        let kind: EntryKind
        let detail: String
    }

    /// Data sourced from the USCCB "Liturgical Calendar for the Dioceses of the United States of America"
    /// 2026 and 2027 editions (including noted emendations).
    private static let byYear: [Int: [Entry]] = [
        2026: [
            Entry(month: 1, day: 4, title: "Saint Elizabeth Ann Seton, Religious", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 1, day: 5, title: "Saint John Neumann, Bishop", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 1, day: 6, title: "Saint André Bessette, Religious", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 1, day: 23, title: "Saint Marianne Cope, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 3, day: 3, title: "Saint Katharine Drexel, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 5, day: 10, title: "Saint Damien de Veuster, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 5, day: 15, title: "Saint Isidore", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 7, day: 1, title: "Saint Junípero Serra, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 7, day: 5, title: "Saint Elizabeth of Portugal", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 7, day: 14, title: "Saint Kateri Tekakwitha, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 7, day: 18, title: "Saint Camillus de Lellis, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 9, day: 5, title: "Saint Teresa of Calcutta, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day (emendation)."),
            Entry(month: 9, day: 9, title: "Saint Peter Claver, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 10, day: 5, title: "Blessed Francis Xavier Seelos, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 10, day: 6, title: "Blessed Marie Rose Durocher, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 10, day: 9, title: "Saint John Henry Newman, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day (emendation)."),
            Entry(
                month: 10,
                day: 19,
                title: "Saints John de Brébeuf and Isaac Jogues, Priests, and Companions, Martyrs",
                kind: .memorialDay,
                detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 10, day: 20, title: "Saint Paul of the Cross, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 11, day: 13, title: "Saint Frances Xavier Cabrini, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
        ],
        2027: [
            Entry(month: 1, day: 4, title: "Saint Elizabeth Ann Seton, Religious", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 1, day: 5, title: "Saint John Neumann, Bishop", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 1, day: 6, title: "Saint André Bessette, Religious", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 1, day: 23, title: "Saint Marianne Cope, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 3, day: 3, title: "Saint Katharine Drexel, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 5, day: 10, title: "Saint Damien de Veuster, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 5, day: 15, title: "Saint Isidore", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 7, day: 1, title: "Saint Junípero Serra, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 7, day: 5, title: "Saint Elizabeth of Portugal", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 7, day: 14, title: "Saint Kateri Tekakwitha, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 7, day: 18, title: "Saint Camillus de Lellis, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 9, day: 9, title: "Saint Peter Claver, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 10, day: 5, title: "Blessed Francis Xavier Seelos, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 10, day: 6, title: "Blessed Marie Rose Durocher, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 10, day: 9, title: "Saint John Henry Newman, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day (emendation)."),
            Entry(
                month: 10,
                day: 19,
                title: "Saints John de Brébeuf and Isaac Jogues, Priests, and Companions, Martyrs",
                kind: .memorialDay,
                detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 10, day: 20, title: "Saint Paul of the Cross, Priest", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 11, day: 13, title: "Saint Frances Xavier Cabrini, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 11, day: 18, title: "Saint Rose Philippine Duchesne, Virgin", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
            Entry(month: 11, day: 23, title: "Saint Miguel Agustín Pro, Priest and Martyr", kind: .memorialDay, detail: "U.S. Proper Calendar celebration day."),
        ],
    ]

    /// Forward-compatible fallback: until a specific USCCB year file is added,
    /// use the most recent verified U.S. Proper list.
    private static let fallbackYear = 2027

    static func entries(for year: Int) -> [Entry] {
        if let entries = byYear[year] {
            return entries
        }
        if year > fallbackYear, let fallback = byYear[fallbackYear] {
            return fallback
        }
        return []
    }
}

enum USCCBMemorialCatalog {
    static let fixed: [LiturgicalMonthDayEntry] = [
        LiturgicalMonthDayEntry(title: "Saints Basil the Great and Gregory Nazianzen", month: 1, day: 2),
        LiturgicalMonthDayEntry(title: "Saint Anthony, Abbot", month: 1, day: 17),
        LiturgicalMonthDayEntry(title: "Saint Agnes, Virgin and Martyr", month: 1, day: 21),
        LiturgicalMonthDayEntry(title: "Saint Francis de Sales, Bishop and Doctor", month: 1, day: 24),
        LiturgicalMonthDayEntry(title: "Saints Timothy and Titus, Bishops", month: 1, day: 26),
        LiturgicalMonthDayEntry(title: "Saint Thomas Aquinas, Priest and Doctor", month: 1, day: 28),
        LiturgicalMonthDayEntry(title: "Saint John Bosco, Priest", month: 1, day: 31),
        LiturgicalMonthDayEntry(title: "Saint Agatha, Virgin and Martyr", month: 2, day: 5),
        LiturgicalMonthDayEntry(title: "Saints Paul Miki and Companions, Martyrs", month: 2, day: 6),
        LiturgicalMonthDayEntry(title: "Saint Scholastica, Virgin", month: 2, day: 10),
        LiturgicalMonthDayEntry(title: "Saints Cyril, Monk, and Methodius, Bishop", month: 2, day: 14),
        LiturgicalMonthDayEntry(title: "Saint Polycarp, Bishop and Martyr", month: 2, day: 23),
        LiturgicalMonthDayEntry(title: "Saints Perpetua and Felicity, Martyrs", month: 3, day: 7),
        LiturgicalMonthDayEntry(title: "Saint Patrick, Bishop", month: 3, day: 17),
        LiturgicalMonthDayEntry(title: "Saint Catherine of Siena, Virgin and Doctor", month: 4, day: 29),
        LiturgicalMonthDayEntry(title: "Saint Athanasius, Bishop and Doctor", month: 5, day: 2),
        LiturgicalMonthDayEntry(title: "Saint Philip Neri, Priest", month: 5, day: 26),
        LiturgicalMonthDayEntry(title: "Saint Justin, Martyr", month: 6, day: 1),
        LiturgicalMonthDayEntry(title: "Saints Charles Lwanga and Companions, Martyrs", month: 6, day: 3),
        LiturgicalMonthDayEntry(title: "Saint Boniface, Bishop and Martyr", month: 6, day: 5),
        LiturgicalMonthDayEntry(title: "Saint Barnabas, Apostle", month: 6, day: 11),
        LiturgicalMonthDayEntry(title: "Saint Anthony of Padua, Priest and Doctor", month: 6, day: 13),
        LiturgicalMonthDayEntry(title: "Saint Aloysius Gonzaga, Religious", month: 6, day: 21),
        LiturgicalMonthDayEntry(title: "Saint Irenaeus, Bishop and Martyr", month: 6, day: 28),
        LiturgicalMonthDayEntry(title: "Saint Benedict, Abbot", month: 7, day: 11),
        LiturgicalMonthDayEntry(title: "Saint Kateri Tekakwitha, Virgin", month: 7, day: 14),
        LiturgicalMonthDayEntry(title: "Saint Bonaventure, Bishop and Doctor", month: 7, day: 15),
        LiturgicalMonthDayEntry(title: "Saints Joachim and Anne", month: 7, day: 26),
        LiturgicalMonthDayEntry(title: "Saints Martha, Mary, and Lazarus", month: 7, day: 29),
        LiturgicalMonthDayEntry(title: "Saint Ignatius of Loyola, Priest", month: 7, day: 31),
        LiturgicalMonthDayEntry(title: "Saint Alphonsus Liguori, Bishop and Doctor", month: 8, day: 1),
        LiturgicalMonthDayEntry(title: "Saint John Vianney, Priest", month: 8, day: 4),
        LiturgicalMonthDayEntry(title: "Saint Dominic, Priest", month: 8, day: 8),
        LiturgicalMonthDayEntry(title: "Saint Clare, Virgin", month: 8, day: 11),
        LiturgicalMonthDayEntry(title: "Saint Maximilian Kolbe, Priest and Martyr", month: 8, day: 14),
        LiturgicalMonthDayEntry(title: "Saint Bernard, Abbot and Doctor", month: 8, day: 20),
        LiturgicalMonthDayEntry(title: "Saint Pius X, Pope", month: 8, day: 21),
        LiturgicalMonthDayEntry(title: "Queenship of the Blessed Virgin Mary", month: 8, day: 22),
        LiturgicalMonthDayEntry(title: "Saint Monica", month: 8, day: 27),
        LiturgicalMonthDayEntry(title: "Saint Augustine, Bishop and Doctor", month: 8, day: 28),
        LiturgicalMonthDayEntry(title: "The Passion of Saint John the Baptist", month: 8, day: 29),
        LiturgicalMonthDayEntry(title: "Saint Gregory the Great, Pope and Doctor", month: 9, day: 3),
        LiturgicalMonthDayEntry(title: "Saint Peter Claver, Priest", month: 9, day: 9),
        LiturgicalMonthDayEntry(title: "Saint John Chrysostom, Bishop and Doctor", month: 9, day: 13),
        LiturgicalMonthDayEntry(title: "Our Lady of Sorrows", month: 9, day: 15),
        LiturgicalMonthDayEntry(title: "Saints Cornelius, Pope, and Cyprian, Bishop", month: 9, day: 16),
        LiturgicalMonthDayEntry(title: "Saints Andrew Kim Tae-gon, Priest, and Companions, Martyrs", month: 9, day: 20),
        LiturgicalMonthDayEntry(title: "Saint Pius of Pietrelcina, Priest", month: 9, day: 23),
        LiturgicalMonthDayEntry(title: "Saint Vincent de Paul, Priest", month: 9, day: 27),
        LiturgicalMonthDayEntry(title: "Saint Jerome, Priest and Doctor", month: 9, day: 30),
        LiturgicalMonthDayEntry(title: "Saint Therese of the Child Jesus, Virgin and Doctor", month: 10, day: 1),
        LiturgicalMonthDayEntry(title: "The Holy Guardian Angels", month: 10, day: 2),
        LiturgicalMonthDayEntry(title: "Saint Francis of Assisi", month: 10, day: 4),
        LiturgicalMonthDayEntry(title: "Our Lady of the Rosary", month: 10, day: 7),
        LiturgicalMonthDayEntry(title: "Saint Teresa of Jesus, Virgin and Doctor", month: 10, day: 15),
        LiturgicalMonthDayEntry(title: "Saint Ignatius of Antioch, Bishop and Martyr", month: 10, day: 17),
        LiturgicalMonthDayEntry(title: "Saint Charles Borromeo, Bishop", month: 11, day: 4),
        LiturgicalMonthDayEntry(title: "Saint Leo the Great, Pope and Doctor", month: 11, day: 10),
        LiturgicalMonthDayEntry(title: "Saint Martin of Tours, Bishop", month: 11, day: 11),
        LiturgicalMonthDayEntry(title: "Saint Josaphat, Bishop and Martyr", month: 11, day: 12),
        LiturgicalMonthDayEntry(title: "Saint Frances Xavier Cabrini, Virgin", month: 11, day: 13),
        LiturgicalMonthDayEntry(title: "Saint Elizabeth of Hungary, Religious", month: 11, day: 17),
        LiturgicalMonthDayEntry(title: "The Presentation of the Blessed Virgin Mary", month: 11, day: 21),
        LiturgicalMonthDayEntry(title: "Saint Cecilia, Virgin and Martyr", month: 11, day: 22),
        LiturgicalMonthDayEntry(title: "Saint Andrew Dung-Lac, Priest, and Companions, Martyrs", month: 11, day: 24),
        LiturgicalMonthDayEntry(title: "Saint Francis Xavier, Priest", month: 12, day: 3),
        LiturgicalMonthDayEntry(title: "Saint Ambrose, Bishop and Doctor", month: 12, day: 7),
        LiturgicalMonthDayEntry(title: "Saint Lucy, Virgin and Martyr", month: 12, day: 13),
        LiturgicalMonthDayEntry(title: "Saint John of the Cross, Priest and Doctor", month: 12, day: 14),
    ]
}

struct Observance: Identifiable, Hashable {
    enum Kind: String {
        case fastAndAbstinence
        case abstinence
        case fridayPenance
        case holyDay
        case feastDay
        case memorialDay
        case optionalEmber

        var label: String {
            switch self {
            case .fastAndAbstinence:
                "Fast + Abstinence"
            case .abstinence:
                "Abstinence"
            case .fridayPenance:
                "Friday Penance"
            case .holyDay:
                "Holy Day"
            case .feastDay:
                "Feast Day"
            case .memorialDay:
                "Memorial"
            case .optionalEmber:
                "Optional Ember Day"
            }
        }

        var color: Color {
            switch self {
            case .fastAndAbstinence:
                .red
            case .abstinence:
                .orange
            case .fridayPenance:
                .brown
            case .holyDay:
                .indigo
            case .feastDay:
                .blue
            case .memorialDay:
                .teal
            case .optionalEmber:
                .purple
            }
        }
    }

    enum Obligation: String {
        case mandatory
        case optional
        case notApplicable

        var label: String {
            switch self {
            case .mandatory:
                "Required"
            case .optional:
                "Optional"
            case .notApplicable:
                "Not Required"
            }
        }
    }

    let id: String
    let title: String
    let date: Date
    let kind: Kind
    let obligation: Obligation
    let detail: String?
    let rationale: String
    let citations: [RuleCitation]
    let ruleVersion: String

    var dispositionLabel: String {
        switch kind {
        case .feastDay, .memorialDay:
            "Celebrate"
        case .fridayPenance:
            switch obligation {
            case .mandatory:
                "Penance Required"
            case .optional:
                "Penance Optional"
            case .notApplicable:
                "Not Required"
            }
        default:
            obligation.label
        }
    }
}

enum ObservanceFilter: String, CaseIterable, Identifiable {
    case all
    case requiredOnly
    case trackedOnly

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .all:
            "All"
        case .requiredOnly:
            "Required"
        case .trackedOnly:
            "Tracked"
        }
    }
}

enum CalendarWindow: String, CaseIterable, Identifiable {
    case allYear
    case thisMonth
    case next30Days

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .allYear:
            "All Year"
        case .thisMonth:
            "This Month"
        case .next30Days:
            "Next 30 Days"
        }
    }
}

enum ObservanceSortOrder: String, CaseIterable, Identifiable {
    case chronological
    case requiredFirst

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .chronological:
            "By Date"
        case .requiredFirst:
            "Required First"
        }
    }
}
