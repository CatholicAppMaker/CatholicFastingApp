@preconcurrency import Foundation

enum ObservanceCalculator {
    static let minimumSupportedBirthYear = 1900
    private static let cacheLock = NSLock()
    private nonisolated(unsafe) static var calendarCache: [CalendarCacheKey: [Observance]] = [:]

    struct CalendarCacheKey: Hashable {
        let year: Int
        let settings: RuleSettings
        let timeZoneIdentifier: String
    }

    struct LiturgicalDates {
        let easter: Date
        let ashWednesday: Date
        let goodFriday: Date
        let easterVigil: Date
        let pentecost: Date
        let ascension: Date
    }

    struct HolyDayEntry: Hashable {
        let title: String
        let date: Date
        let detail: String?
    }

    struct CalendarEntry: Hashable {
        let title: String
        let date: Date
        let detail: String?
    }

    static func ruleBundleMetadata() -> RuleBundleMetadata {
        RuleBundleRepository.snapshot().metadata
    }

    static func ruleBundleChanges() -> [RuleBundleChange] {
        RuleBundleRepository.snapshot().changes
    }

    static func ruleBundleAudit() -> RuleBundleAudit {
        RuleBundleRepository.snapshot().audit
    }

    static func makeCalendar(for year: Int, settings: RuleSettings) -> [Observance] {
        let cacheKey = CalendarCacheKey(
            year: year,
            settings: settings,
            timeZoneIdentifier: Calendar.gregorian.timeZone.identifier)
        if let cached = cachedCalendar(for: cacheKey) {
            return cached
        }

        var items: [Observance] = []
        let dates = liturgicalDates(for: year, settings: settings)

        items.append(fastAndAbstinenceObservance(title: "Ash Wednesday", date: dates.ashWednesday, settings: settings))
        items.append(fastAndAbstinenceObservance(title: "Good Friday", date: dates.goodFriday, settings: settings))

        for friday in lentFridays(from: dates.ashWednesday, through: dates.easterVigil) {
            if Calendar.gregorian.isDate(friday, inSameDayAs: dates.goodFriday) {
                continue
            }
            let required = isAbstinenceRequired(on: friday, settings: settings)
            items.append(
                makeObservance(
                    "Friday of Lent",
                    friday,
                    .abstinence,
                    required ? .mandatory : .notApplicable,
                    required ? "No meat from mammals or poultry." : ageDispensationDetail(settings: settings),
                    settings: settings))
        }

        for friday in fridaysOutsideLent(for: year, lentStart: dates.ashWednesday, lentEnd: dates.easterVigil) {
            let required = isAbstinenceRequired(on: friday, settings: settings)
            let detail = fridayPenanceDetail(mode: settings.fridayOutsideLentMode, settings: settings)
            items.append(
                makeObservance(
                    "Friday Penance (Outside Lent)",
                    friday,
                    .fridayPenance,
                    required ? .mandatory : .notApplicable,
                    required ? detail : ageDispensationDetail(settings: settings),
                    settings: settings))
        }

        for holyDay in holyDaysOfObligation(for: year, ascension: dates.ascension, settings: settings) {
            let obligation = holyDayObligation(title: holyDay.title, date: holyDay.date, settings: settings)
            items.append(makeObservance(holyDay.title, holyDay.date, .holyDay, obligation, holyDay.detail, settings: settings))
        }

        for feast in feastAndSolemnityDays(for: year, dates: dates, settings: settings) {
            items.append(makeObservance(feast.title, feast.date, .feastDay, .notApplicable, feast.detail, settings: settings))
        }
        for memorial in memorialDays(for: year, dates: dates, settings: settings) {
            items.append(makeObservance(memorial.title, memorial.date, .memorialDay, .notApplicable, memorial.detail, settings: settings))
        }

        let emberDetail = if settings.calendarMode == .traditional1962 {
            "Traditional calendar mode: Ember day of prayer, fasting, and abstinence."
        } else {
            "Optional observance in U.S. profile mode."
        }
        for emberDate in emberDays(for: year, ashWednesday: dates.ashWednesday, pentecost: dates.pentecost) {
            items.append(makeObservance("Ember Day", emberDate, .optionalEmber, .optional, emberDetail, settings: settings))
        }

        let generated = items.sorted { $0.date < $1.date }
        storeCalendar(generated, for: cacheKey)
        return generated
    }

    static func resetCacheForTesting() {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        calendarCache.removeAll()
    }

    static func cachedCalendar(for key: CalendarCacheKey) -> [Observance]? {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return calendarCache[key]
    }

    static func storeCalendar(_ observances: [Observance], for key: CalendarCacheKey) {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        calendarCache[key] = observances
    }

    static func liturgicalDates(for year: Int, settings: RuleSettings) -> LiturgicalDates {
        let easter = easterSunday(year: year)
        let ashWednesday = dateByAdding(days: -46, to: easter)
        let goodFriday = dateByAdding(days: -2, to: easter)
        let easterVigil = dateByAdding(days: -1, to: easter)
        let pentecost = dateByAdding(days: 49, to: easter)
        let ascension = switch settings.regionProfile {
        case .canada:
            dateByAdding(days: 42, to: easter)
        case .us, .other:
            switch settings.ascensionObservance {
            case .sunday:
                dateByAdding(days: 42, to: easter)
            case .thursday:
                dateByAdding(days: 39, to: easter)
            }
        }
        return LiturgicalDates(
            easter: easter,
            ashWednesday: ashWednesday,
            goodFriday: goodFriday,
            easterVigil: easterVigil,
            pentecost: pentecost,
            ascension: ascension)
    }

    static func fastAndAbstinenceObservance(title: String, date: Date, settings: RuleSettings) -> Observance {
        let fastRequired = isFastRequired(on: date, settings: settings)
        let abstinenceRequired = isAbstinenceRequired(on: date, settings: settings)

        if fastRequired, abstinenceRequired {
            return makeObservance(
                title,
                date,
                .fastAndAbstinence,
                .mandatory,
                fastDetail(settings: settings),
                settings: settings)
        }

        if abstinenceRequired {
            return makeObservance(
                title,
                date,
                .abstinence,
                .mandatory,
                "Abstinence from meat is required. Fasting does not bind for your age profile.",
                settings: settings)
        }

        return makeObservance(
            title,
            date,
            .fastAndAbstinence,
            .notApplicable,
            ageDispensationDetail(settings: settings),
            settings: settings)
    }
}
