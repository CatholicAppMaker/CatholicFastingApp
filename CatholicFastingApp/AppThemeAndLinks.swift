import Foundation
import SwiftUI

enum AppURLFactory {
    static func make(_ rawValue: String) -> URL {
        guard let url = URL(string: rawValue) else {
            assertionFailure("Invalid static URL: \(rawValue)")
            return URL(fileURLWithPath: "/")
        }
        return url
    }
}

enum UIConstants {
    struct LegalLinks {
        let privacyPolicyURL: URL
        let termsOfUseURL: URL
        let supportURL: URL
    }

    static var yearRange: ClosedRange<Int> {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (currentYear - 5) ... (currentYear + 15)
    }

    static let minBirthYear = 1900
    static let legalPolicyURL = AppURLFactory.make("https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar")
    static let usccbFastAbstinenceURL = AppURLFactory.make("https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar/lent/catholic-information-on-lenten-fast-and-abstinence")
    static let cccbKeepingFridayURL = AppURLFactory.make("https://www.cccb.ca/document/keeping-friday/")
    static let supportEmail = AppURLFactory.make("mailto:support@catholicfasting.app?subject=Catholic%20Fasting%20App%20Feedback")
    static let legalLinks = LegalLinks(
        privacyPolicyURL: AppURLFactory.make("https://x.com/CatholicFasting/status/2026354531273945191"),
        termsOfUseURL: AppURLFactory.make("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"),
        supportURL: AppURLFactory.make("https://x.com/CatholicFasting"))
    static let privacyPolicyURL = legalLinks.privacyPolicyURL
    static let termsOfUseURL = legalLinks.termsOfUseURL
    static let supportSiteURL = legalLinks.supportURL
    static let manageSubscriptionsURL = AppURLFactory.make("https://apps.apple.com/account/subscriptions")
    static let deepLinkTodayURL = AppURLFactory.make("catholicfasting://today")
    static let deepLinkFastingDaysURL = AppURLFactory.make("catholicfasting://fasting-days")
    static let deepLinkIntermittentURL = AppURLFactory.make("catholicfasting://intermittent")
    static let deepLinkMoreURL = AppURLFactory.make("catholicfasting://more")
    static let deepLinkSettingsURL = AppURLFactory.make("catholicfasting://settings")
    static let deepLinkPremiumURL = AppURLFactory.make("catholicfasting://premium")
    static var exportISO8601: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }
}

enum AppDeepLinkTarget: Equatable {
    case surface(HomeSurface)
    case settings
    case premium

    static func parse(url: URL) -> AppDeepLinkTarget? {
        guard let scheme = url.scheme?.lowercased(), scheme == "catholicfasting" else {
            return nil
        }

        let route = (url.host ?? "").isEmpty ? url.pathComponents.dropFirst().first ?? "" : (url.host ?? "")
        return switch route.lowercased() {
        case "today":
            .surface(.today)
        case "calendar", "fasting-days", "fastingdays":
            .surface(.fastingDays)
        case "track", "intermittent", "fast":
            .surface(.intermittent)
        case "premium", "support-premium", "support", "toolkit":
            .premium
        case "more", "settings":
            .settings
        default:
            nil
        }
    }
}

enum CatholicTheme {
    struct Palette {
        let season: LiturgicalSeason
        let primary: Color
        let accent: Color
        let accentForeground: Color
        let parchment: Color
        let parchmentShade: Color
        let cardBorder: Color
    }

    static var activePalette: Palette {
        let enabled =
            UserDefaults.standard.object(forKey: StorageKeys.liturgicalSeasonColorsEnabled) == nil
                ? true
                : UserDefaults.standard.bool(forKey: StorageKeys.liturgicalSeasonColorsEnabled)
        return palette(seasonModeEnabled: enabled, date: Date())
    }

    static var primary: Color {
        activePalette.primary
    }

    static var accent: Color {
        activePalette.accent
    }

    static var accentForeground: Color {
        activePalette.accentForeground
    }

    static var successForeground: Color {
        Color(red: 0.05, green: 0.36, blue: 0.13)
    }

    static var warningForeground: Color {
        Color(red: 0.56, green: 0.28, blue: 0.03)
    }

    static var infoForeground: Color {
        Color(red: 0.05, green: 0.28, blue: 0.58)
    }

    static var dangerForeground: Color {
        Color(red: 0.62, green: 0.08, blue: 0.08)
    }

    static var parchment: Color {
        activePalette.parchment
    }

    static var parchmentShade: Color {
        activePalette.parchmentShade
    }

    static var cardBorder: Color {
        activePalette.cardBorder
    }

    static var seasonLabel: String {
        activePalette.season.label
    }

    static var seasonToolbarLabel: String {
        switch activePalette.season {
        case .ordinary: "Ordinary"
        case .advent: "Advent"
        case .christmas: "Christmas"
        case .lent: "Lent"
        case .easter: "Easter"
        }
    }

    static var background: LinearGradient {
        LinearGradient(
            colors: [parchment, accent.opacity(0.22), parchmentShade],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
    }

    static func palette(seasonModeEnabled: Bool, date: Date) -> Palette {
        guard seasonModeEnabled else {
            return Palette(
                season: .ordinary,
                primary: Color(red: 0.40, green: 0.11, blue: 0.13),
                accent: Color(red: 0.78, green: 0.58, blue: 0.18),
                accentForeground: Color(red: 0.40, green: 0.11, blue: 0.13),
                parchment: Color(red: 0.98, green: 0.95, blue: 0.87),
                parchmentShade: Color(red: 0.90, green: 0.84, blue: 0.73),
                cardBorder: Color(red: 0.70, green: 0.56, blue: 0.29))
        }

        let season = LiturgicalSeasonThemeEngine.season(for: date)
        switch season {
        case .advent:
            return Palette(
                season: season,
                primary: Color(red: 0.11, green: 0.20, blue: 0.49),
                accent: Color(red: 0.72, green: 0.33, blue: 0.58),
                accentForeground: Color(red: 0.47, green: 0.12, blue: 0.35),
                parchment: Color(red: 0.95, green: 0.95, blue: 0.99),
                parchmentShade: Color(red: 0.84, green: 0.86, blue: 0.96),
                cardBorder: Color(red: 0.40, green: 0.44, blue: 0.73))
        case .christmas:
            return Palette(
                season: season,
                primary: Color(red: 0.50, green: 0.29, blue: 0.07),
                accent: Color(red: 0.85, green: 0.65, blue: 0.18),
                accentForeground: Color(red: 0.50, green: 0.29, blue: 0.07),
                parchment: Color(red: 1.00, green: 0.98, blue: 0.92),
                parchmentShade: Color(red: 0.95, green: 0.91, blue: 0.78),
                cardBorder: Color(red: 0.78, green: 0.62, blue: 0.24))
        case .lent:
            return Palette(
                season: season,
                primary: Color(red: 0.30, green: 0.13, blue: 0.45),
                accent: Color(red: 0.61, green: 0.46, blue: 0.72),
                accentForeground: Color(red: 0.30, green: 0.13, blue: 0.45),
                parchment: Color(red: 0.95, green: 0.91, blue: 0.95),
                parchmentShade: Color(red: 0.84, green: 0.79, blue: 0.90),
                cardBorder: Color(red: 0.55, green: 0.42, blue: 0.66))
        case .easter:
            return Palette(
                season: season,
                primary: Color(red: 0.14, green: 0.37, blue: 0.18),
                accent: Color(red: 0.82, green: 0.66, blue: 0.18),
                accentForeground: Color(red: 0.14, green: 0.37, blue: 0.18),
                parchment: Color(red: 0.99, green: 0.98, blue: 0.92),
                parchmentShade: Color(red: 0.89, green: 0.93, blue: 0.80),
                cardBorder: Color(red: 0.46, green: 0.66, blue: 0.40))
        case .ordinary:
            return Palette(
                season: season,
                primary: Color(red: 0.10, green: 0.38, blue: 0.17),
                accent: Color(red: 0.72, green: 0.56, blue: 0.15),
                accentForeground: Color(red: 0.10, green: 0.38, blue: 0.17),
                parchment: Color(red: 0.97, green: 0.96, blue: 0.86),
                parchmentShade: Color(red: 0.86, green: 0.90, blue: 0.76),
                cardBorder: Color(red: 0.38, green: 0.59, blue: 0.34))
        }
    }
}
