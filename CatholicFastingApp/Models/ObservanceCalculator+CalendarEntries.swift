@preconcurrency import Foundation

extension ObservanceCalculator {
    struct FixedHolyDayDefinition {
        let title: String
        let month: Int
        let day: Int
    }

    static func holyDaysOfObligation(
        for year: Int,
        ascension: Date,
        settings: RuleSettings) -> [HolyDayEntry]
    {
        var holyDays: [HolyDayEntry] = []

        if settings.regionProfile == .canada {
            let canadaFixed = [
                FixedHolyDayDefinition(title: "Mary, Mother of God", month: 1, day: 1),
                FixedHolyDayDefinition(title: "Christmas", month: 12, day: 25),
            ]

            for item in canadaFixed {
                if let date = canonicalDate(year: year, month: item.month, day: item.day) {
                    let detail = holyDayDetail(title: item.title, date: date, transferred: false, settings: settings)
                    holyDays.append(HolyDayEntry(title: item.title, date: date, detail: detail))
                }
            }

            return holyDays
        }

        let fixed = [
            FixedHolyDayDefinition(title: "Mary, Mother of God", month: 1, day: 1),
            FixedHolyDayDefinition(title: "Assumption of the Blessed Virgin Mary", month: 8, day: 15),
            FixedHolyDayDefinition(title: "All Saints", month: 11, day: 1),
            FixedHolyDayDefinition(title: "Christmas", month: 12, day: 25),
        ]

        for item in fixed {
            if let date = canonicalDate(year: year, month: item.month, day: item.day) {
                let detail = holyDayDetail(title: item.title, date: date, transferred: false, settings: settings)
                holyDays.append(HolyDayEntry(title: item.title, date: date, detail: detail))
            }
        }

        if let dec8 = canonicalDate(year: year, month: 12, day: 8) {
            if Calendar.gregorian.component(.weekday, from: dec8) == 1 {
                let dec9 = dateByAdding(days: 1, to: dec8)
                holyDays.append(
                    HolyDayEntry(
                        title: "Immaculate Conception (Transferred)",
                        date: dec9,
                        detail: holyDayDetail(title: "Immaculate Conception", date: dec9, transferred: true, settings: settings)))
            } else {
                holyDays.append(
                    HolyDayEntry(
                        title: "Immaculate Conception",
                        date: dec8,
                        detail: holyDayDetail(title: "Immaculate Conception", date: dec8, transferred: false, settings: settings)))
            }
        }

        let ascensionDetail = switch settings.regionProfile {
        case .us:
            "Observed on Thursday or transferred to Sunday by province; obligation depends on local observance rules."
        case .canada:
            [
                "Ascension observance in Canada depends on the liturgical calendar in force locally.",
                "This release treats the day as informational unless a fully modeled local obligation is known.",
            ].joined(separator: " ")
        case .other:
            "Ascension observance varies by conference and local law. This release treats the day as informational outside the U.S. profile."
        }
        holyDays.append(HolyDayEntry(title: "Ascension", date: ascension, detail: ascensionDetail))

        return holyDays
    }

    static func holyDayDetail(title: String, date: Date, transferred: Bool, settings: RuleSettings) -> String {
        if settings.regionProfile == .canada {
            return switch title {
            case "Mary, Mother of God", "Christmas":
                "Holy Day of Obligation in the Canada national baseline. The app models the Canada-wide obligation and keeps diocesan proper calendars separate."
            default:
                "Celebration included for Canada-wide planning in the national baseline. It is not treated as a separate weekday holy day obligation here."
            }
        }

        if settings.regionProfile == .other {
            return "Listed for planning context. Holy day obligations vary by episcopal conference and local law outside the U.S. profile."
        }

        let weekday = Calendar.gregorian.component(.weekday, from: date)
        let isSaturdayOrMonday = weekday == 7 || weekday == 2

        switch title {
        case "Mary, Mother of God", "Assumption of the Blessed Virgin Mary", "All Saints":
            if isSaturdayOrMonday {
                return "In U.S. norms, obligation may be abrogated this year because this holy day falls on Saturday or Monday."
            }
            return "Holy Day of Obligation in the U.S., subject to local episcopal conference directives."
        case "Immaculate Conception":
            if transferred {
                return "Transferred from Sunday, December 8. In U.S. usage, the Mass obligation does not transfer to Monday."
            }
            return "Holy Day of Obligation in the U.S."
        case "Christmas":
            return "Holy Day of Obligation in the U.S."
        default:
            return "Holy Day of Obligation in the U.S., subject to local episcopal conference directives."
        }
    }

    static func holyDayObligation(title: String, date: Date, settings: RuleSettings) -> Observance.Obligation {
        switch settings.regionProfile {
        case .other:
            return .optional
        case .canada, .us:
            break
        }

        switch liturgicalObligationAgeStatus(on: date, settings: settings) {
        case .underSeven:
            return .notApplicable
        case .unknown:
            return .optional
        case .sevenOrOlder:
            break
        }

        if settings.regionProfile == .canada {
            if title == "Mary, Mother of God" || title == "Christmas" {
                return .mandatory
            }
            return .optional
        }

        let weekday = Calendar.gregorian.component(.weekday, from: date)
        let isSaturdayOrMonday = weekday == 7 || weekday == 2

        if title == "Mary, Mother of God" || title == "Assumption of the Blessed Virgin Mary" || title == "All Saints" {
            return isSaturdayOrMonday ? .optional : .mandatory
        }

        if title.contains("Immaculate Conception") {
            return title.contains("(Transferred)") ? .optional : .mandatory
        }

        if title == "Christmas" || title == "Ascension" {
            return .mandatory
        }

        return .optional
    }

    static func feastAndSolemnityDays(
        for year: Int,
        dates: LiturgicalDates,
        settings: RuleSettings) -> [CalendarEntry]
    {
        var entries: [CalendarEntry] = []

        func append(_ title: String, _ date: Date, detail: String? = nil) {
            let defaultDetail = switch settings.regionProfile {
            case .us:
                "Included from the liturgical calendar used for U.S. devotional planning."
            case .canada:
                "Included for Canada-wide devotional planning in the national baseline. Diocesan proper calendars may add local celebrations."
            case .other:
                "Shown for Catholic devotional planning. Local calendars may add or vary celebrations."
            }
            entries.append(CalendarEntry(title: title, date: date, detail: detail ?? defaultDetail))
        }

        if let epiphany = epiphanySunday(for: year) {
            append("Epiphany of the Lord", epiphany)
            append("The Baptism of the Lord", nextWeekday(after: epiphany, weekday: 1))
        }

        if let presentation = canonicalDate(year: year, month: 2, day: 2) {
            append("The Presentation of the Lord", presentation)
        }
        if let joseph = canonicalDate(year: year, month: 3, day: 19) {
            append("Saint Joseph, Spouse of the Blessed Virgin Mary", joseph)
        }
        if let annunciation = canonicalDate(year: year, month: 3, day: 25) {
            append("The Annunciation of the Lord", annunciation)
        }

        append("Palm Sunday of the Passion of the Lord", dateByAdding(days: -7, to: dates.easter))
        append("Holy Thursday (Evening Mass of the Lord's Supper)", dateByAdding(days: -3, to: dates.easter))
        append("Easter Sunday", dates.easter)
        append("Pentecost", dates.pentecost)

        if settings.regionProfile == .canada {
            append(
                "Ascension",
                dates.ascension,
                detail: "Observed on Sunday in the Canada national baseline and shown here as a celebration rather than a separate weekday holy day obligation.")
        }

        let trinity = dateByAdding(days: 56, to: dates.easter)
        append("The Most Holy Trinity", trinity)
        append("The Most Holy Body and Blood of Christ", dateByAdding(days: 63, to: dates.easter))
        append("The Most Sacred Heart of Jesus", dateByAdding(days: 68, to: dates.easter))

        if let john = canonicalDate(year: year, month: 6, day: 24) {
            append("The Nativity of Saint John the Baptist", john)
        }
        if let peterPaul = canonicalDate(year: year, month: 6, day: 29) {
            append("Saints Peter and Paul, Apostles", peterPaul)
        }
        if let transfiguration = canonicalDate(year: year, month: 8, day: 6) {
            append("The Transfiguration of the Lord", transfiguration)
        }
        if let exaltation = canonicalDate(year: year, month: 9, day: 14) {
            append("The Exaltation of the Holy Cross", exaltation)
        }
        if let guadalupe = canonicalDate(year: year, month: 12, day: 12) {
            append("Our Lady of Guadalupe", guadalupe)
        }

        append("Our Lord Jesus Christ, King of the Universe", dateByAdding(days: -7, to: firstSundayOfAdvent(year: year)))
        if let holyFamily = holyFamilyDate(for: year) {
            append("The Holy Family of Jesus, Mary, and Joseph", holyFamily)
        }

        if settings.regionProfile == .us {
            for dataEntry in USCCBYearlyCalendarData.entries(for: year) where dataEntry.kind == .feastDay {
                if let date = canonicalDate(year: year, month: dataEntry.month, day: dataEntry.day) {
                    append(dataEntry.title, date, detail: dataEntry.detail)
                }
            }
        }

        return deduplicatedEntries(entries)
    }

    static func memorialDays(
        for year: Int,
        dates: LiturgicalDates,
        settings: RuleSettings) -> [CalendarEntry]
    {
        var items: [CalendarEntry] = []
        let defaultDetail = switch settings.regionProfile {
        case .us:
            "Memorial included for liturgical awareness in the U.S. calendar profile."
        case .canada:
            "Memorial included for Canada-wide liturgical awareness in the national baseline. Diocesan proper calendars may differ."
        case .other:
            "Memorial included for liturgical awareness. Local calendars may differ."
        }

        for entry in USCCBMemorialCatalog.fixed {
            if let date = canonicalDate(year: year, month: entry.month, day: entry.day) {
                items.append(CalendarEntry(title: entry.title, date: date, detail: defaultDetail))
            }
        }

        let motherChurch = dateByAdding(days: 50, to: dates.easter)
        items.append(CalendarEntry(title: "Blessed Virgin Mary, Mother of the Church", date: motherChurch, detail: defaultDetail))
        let immaculateHeart = dateByAdding(days: 69, to: dates.easter)
        items.append(CalendarEntry(title: "The Immaculate Heart of the Blessed Virgin Mary", date: immaculateHeart, detail: defaultDetail))

        if settings.regionProfile == .us {
            for dataEntry in USCCBYearlyCalendarData.entries(for: year) where dataEntry.kind == .memorialDay {
                if let date = canonicalDate(year: year, month: dataEntry.month, day: dataEntry.day) {
                    items.append(CalendarEntry(title: dataEntry.title, date: date, detail: dataEntry.detail))
                }
            }
        }

        return deduplicatedEntries(items)
    }

    static func deduplicatedEntries(_ entries: [CalendarEntry]) -> [CalendarEntry] {
        var seen = Set<String>()
        return entries.filter { entry in
            let key = "\(DateFormatter.dayKey.string(from: entry.date))|\(entry.title)"
            if seen.contains(key) {
                return false
            }
            seen.insert(key)
            return true
        }
    }

    static func makeObservance(
        _ title: String,
        _ date: Date,
        _ kind: Observance.Kind,
        _ obligation: Observance.Obligation,
        _ detail: String?,
        settings: RuleSettings) -> Observance
    {
        let dayKey = DateFormatter.dayKey.string(from: date)
        let citations = defaultCitations(for: title, kind: kind, settings: settings)
        let rationale = defaultRationale(for: title, kind: kind, obligation: obligation, settings: settings)
        return Observance(
            id: "\(dayKey)|\(title)|\(kind.rawValue)",
            title: title,
            date: date,
            kind: kind,
            obligation: obligation,
            detail: detail,
            rationale: rationale,
            citations: citations,
            ruleVersion: ruleBundleMetadata().version)
    }

    static func defaultRationale(
        for title: String,
        kind: Observance.Kind,
        obligation: Observance.Obligation,
        settings: RuleSettings) -> String
    {
        switch kind {
        case .fastAndAbstinence:
            return obligation == .mandatory
                ? "\(title) is a universal fast/abstinence day for the Latin Church in this profile."
                : "\(title) is listed, but your profile indicates the obligation does not strictly bind."
        case .abstinence:
            if title == "Ash Wednesday" || title == "Good Friday" {
                return "\(title) requires abstinence for those bound by age and health norms."
            }
            return "Fridays in Lent are days of abstinence for those bound by age and health norms."
        case .fridayPenance:
            switch settings.regionProfile {
            case .us:
                return "Outside Lent Friday penance follows your selected U.S. profile mode."
            case .canada:
                return "Outside Lent Friday penance follows CCCB guidance: Friday remains penitential, with abstinence or another act of charity or piety."
            case .other:
                return "Outside Lent Friday penance depends on local episcopal law and pastoral guidance."
            }
        case .holyDay:
            switch settings.regionProfile {
            case .us:
                return "Holy day obligation may vary by universal, national, and local norms."
            case .canada:
                return "Holy day obligation is modeled for the Canada national baseline. Diocesan proper calendars are not included in this release."
            case .other:
                return "Holy day listing is informational outside the U.S. profile unless local law is known."
            }
        case .feastDay:
            return "Celebrate this feast day; it is not a fasting obligation."
        case .memorialDay:
            return "Celebrate this memorial day; it is not a fasting obligation."
        case .optionalEmber:
            return "Ember days are optional in this mode and offered as devotional practice."
        }
    }

    static func defaultCitations(for title: String, kind: Observance.Kind, settings: RuleSettings) -> [RuleCitation] {
        switch kind {
        case .fastAndAbstinence, .abstinence:
            var citations = [
                RuleCitation(authority: .universalLaw, title: "Code of Canon Law", shortReference: "Can. 1249-1253"),
            ]
            switch settings.regionProfile {
            case .us:
                citations.append(RuleCitation(authority: .usccb, title: "Pastoral Statement on Penance and Abstinence", shortReference: "USCCB 1966"))
            case .canada:
                citations.append(RuleCitation(authority: .cccb, title: "Keeping Friday", shortReference: "CCCB Friday guidance"))
            case .other:
                citations.append(RuleCitation(authority: .pastoral, title: "Local Catholic Guidance", shortReference: "Consult local conference norms"))
            }
            return citations
        case .fridayPenance:
            switch settings.regionProfile {
            case .us:
                return [
                    RuleCitation(authority: .usccb, title: "Penance and Abstinence Guidance", shortReference: "USCCB Norms"),
                    RuleCitation(authority: .pastoral, title: "Pastoral Direction", shortReference: "Consult pastor for substitutions"),
                ]
            case .canada:
                return [
                    RuleCitation(authority: .cccb, title: "Keeping Friday", shortReference: "Friday remains penitential"),
                    RuleCitation(authority: .pastoral, title: "Pastoral Direction", shortReference: "Choose abstinence or another penitential work"),
                ]
            case .other:
                return [
                    RuleCitation(authority: .pastoral, title: "Local Conference Guidance", shortReference: "Friday practice varies"),
                    RuleCitation(authority: .pastoral, title: "Pastoral Direction", shortReference: "Consult local Church authority"),
                ]
            }
        case .holyDay:
            var citations = [
                RuleCitation(authority: .universalLaw, title: "Code of Canon Law", shortReference: "Can. 1246-1248"),
            ]
            switch settings.regionProfile {
            case .us:
                citations.append(RuleCitation(authority: .usccb, title: "U.S. Holy Days", shortReference: "USCCB Liturgical Norms"))
            case .canada:
                break
            case .other:
                citations.append(RuleCitation(authority: .pastoral, title: "Conference and Local Law", shortReference: "Review local obligation law"))
            }
            if settings.regionProfile == .us, title.contains("Ascension") || title.contains("Immaculate") {
                citations.append(RuleCitation(authority: .pastoral, title: "Particular Law", shortReference: "Province dependent"))
            }
            return citations
        case .feastDay:
            return [
                RuleCitation(authority: .pastoral, title: "Liturgical Calendar", shortReference: "Devotional observance"),
            ]
        case .memorialDay:
            return [
                RuleCitation(authority: .pastoral, title: "Liturgical Calendar", shortReference: "Memorial observance"),
            ]
        case .optionalEmber:
            return [
                RuleCitation(authority: .pastoral, title: "Traditional Ember Practice", shortReference: "Optional in U.S. usage"),
            ]
        }
    }

    static func fastDetail(settings: RuleSettings) -> String {
        if settings.hasMedicalDispensation {
            return "Dispensation enabled in your profile. Follow your pastor and medical guidance."
        }
        return "For ages 18-59: one full meal and two smaller meals (not equal to a second full meal)."
    }

    static func fridayPenanceDetail(
        mode: RuleSettings.FridayOutsideLentMode,
        settings: RuleSettings) -> String
    {
        if settings.regionProfile == .canada {
            return switch mode {
            case .abstainFromMeat:
                "In Canada, Friday remains penitential throughout the year. You chose abstinence from meat for your Friday practice."
            case .substitutePenance:
                "In Canada, Friday remains penitential throughout the year. You chose another act of charity or piety for your Friday practice."
            }
        }

        if settings.regionProfile == .other {
            return "Friday remains penitential outside Lent, but the exact practice depends on local Church law."
        }

        return switch mode {
        case .abstainFromMeat:
            "Outside Lent: abstain from meat as your Friday penance."
        case .substitutePenance:
            "Outside Lent: choose a penitential act (e.g., extra prayer, charity, or another sacrifice)."
        }
    }

    static func ageDispensationDetail(settings: RuleSettings) -> String {
        if settings.hasMedicalDispensation {
            return "Not required due to medical dispensation setting."
        }
        return "Not required for your age eligibility toggle settings."
    }
}
