@preconcurrency import Foundation

enum SeasonalAppIconPolicy {
    static let liturgicalSeasonColorsStorageKey = "liturgical_season_colors_enabled"

    static func targetIconName(now: Date = Date(), userDefaults: UserDefaults, calendar: Calendar = .gregorian) -> String? {
        let seasonModeEnabled =
            userDefaults.object(forKey: liturgicalSeasonColorsStorageKey) as? Bool ?? true
        let season = LiturgicalSeasonThemeEngine.season(for: now, calendar: calendar)
        return iconName(for: seasonModeEnabled ? season : .ordinary)
    }

    static func iconName(for season: LiturgicalSeason) -> String? {
        switch season {
        case .ordinary:
            nil
        case .advent:
            "AppIconAdvent"
        case .christmas:
            "AppIconChristmas"
        case .lent:
            "AppIconLent"
        case .easter:
            "AppIconEaster"
        }
    }
}
