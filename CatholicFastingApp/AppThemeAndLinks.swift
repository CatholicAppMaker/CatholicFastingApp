import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

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
        let currentYear = Calendar(identifier: .gregorian).component(.year, from: AppClock.now())
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
        case "more":
            .surface(.more)
        case "settings":
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
        palette(seasonModeEnabled: seasonColorsEnabled, date: AppClock.now())
    }

    private static var seasonColorsEnabled: Bool {
        UserDefaults.standard.object(forKey: StorageKeys.liturgicalSeasonColorsEnabled) == nil
            ? true
            : UserDefaults.standard.bool(forKey: StorageKeys.liturgicalSeasonColorsEnabled)
    }

    static var primary: Color {
        #if canImport(UIKit)
        activePalette.primary
        #else
        Color(red: 0.39, green: 0.16, blue: 0.18)
        #endif
    }

    static var accent: Color {
        #if canImport(UIKit)
        activePalette.accent
        #else
        Color(red: 0.64, green: 0.46, blue: 0.16)
        #endif
    }

    static var accentForeground: Color {
        #if canImport(UIKit)
        activePalette.accentForeground
        #else
        Color(red: 0.39, green: 0.28, blue: 0.08)
        #endif
    }

    static var action: Color {
        #if canImport(UIKit)
        activePalette.primary
        #else
        Color(red: 0.39, green: 0.16, blue: 0.18)
        #endif
    }

    static var seasonAccent: Color {
        activePalette.primary
    }

    static var successForeground: Color {
        #if canImport(UIKit)
        adaptiveColor(
            light: UIColor(red: 0.05, green: 0.36, blue: 0.13, alpha: 1),
            dark: UIColor(red: 0.54, green: 0.70, blue: 0.55, alpha: 1))
        #else
        Color(red: 0.05, green: 0.36, blue: 0.13)
        #endif
    }

    static var warningForeground: Color {
        #if canImport(UIKit)
        adaptiveColor(
            light: UIColor(red: 0.56, green: 0.28, blue: 0.03, alpha: 1),
            dark: UIColor(red: 0.80, green: 0.65, blue: 0.38, alpha: 1))
        #else
        Color(red: 0.56, green: 0.28, blue: 0.03)
        #endif
    }

    static var infoForeground: Color {
        #if canImport(UIKit)
        adaptiveColor(
            light: UIColor(red: 0.05, green: 0.28, blue: 0.58, alpha: 1),
            dark: UIColor(red: 0.57, green: 0.67, blue: 0.78, alpha: 1))
        #else
        Color(red: 0.05, green: 0.28, blue: 0.58)
        #endif
    }

    static var dangerForeground: Color {
        #if canImport(UIKit)
        adaptiveColor(
            light: UIColor(red: 0.62, green: 0.08, blue: 0.08, alpha: 1),
            dark: UIColor(red: 0.86, green: 0.56, blue: 0.54, alpha: 1))
        #else
        Color(red: 0.62, green: 0.08, blue: 0.08)
        #endif
    }

    static var parchment: Color {
        activePalette.parchment
    }

    /// The near-black editorial ink used over opaque parchment surfaces.
    static var ink: Color {
        #if canImport(UIKit)
        adaptiveColor(
            light: UIColor(red: 0.09, green: 0.075, blue: 0.06, alpha: 1),
            dark: UIColor(red: 0.09, green: 0.075, blue: 0.06, alpha: 1))
        #else
        Color(red: 0.09, green: 0.075, blue: 0.06)
        #endif
    }

    /// Secondary editorial copy that remains readable over every seasonal parchment.
    static var secondaryInk: Color {
        #if canImport(UIKit)
        adaptiveColor(
            light: UIColor(red: 0.29, green: 0.26, blue: 0.22, alpha: 1),
            dark: UIColor(red: 0.29, green: 0.26, blue: 0.22, alpha: 1))
        #else
        Color(red: 0.29, green: 0.26, blue: 0.22)
        #endif
    }

    static var parchmentShade: Color {
        activePalette.parchmentShade
    }

    static var cardBorder: Color {
        #if canImport(UIKit)
        activePalette.cardBorder
        #else
        Color(red: 0.64, green: 0.56, blue: 0.43)
        #endif
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
            colors: [parchment, parchmentShade.opacity(0.55)],
            startPoint: .top,
            endPoint: .bottom)
    }

    #if canImport(UIKit)
    private static func adaptiveColor(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    #endif

    static func palette(seasonModeEnabled: Bool, date: Date) -> Palette {
        guard seasonModeEnabled else {
            return ordinaryPalette
        }

        let season = LiturgicalSeasonThemeEngine.season(for: date)
        switch season {
        case .advent:
            return Palette(
                season: season,
                primary: Color(red: 0.31, green: 0.22, blue: 0.40),
                accent: Color(red: 0.63, green: 0.45, blue: 0.57),
                accentForeground: Color(red: 0.36, green: 0.20, blue: 0.33),
                parchment: Color(red: 0.985, green: 0.975, blue: 0.965),
                parchmentShade: Color(red: 0.92, green: 0.90, blue: 0.94),
                cardBorder: Color(red: 0.53, green: 0.47, blue: 0.58))
        case .christmas:
            return Palette(
                season: season,
                primary: Color(red: 0.42, green: 0.16, blue: 0.17),
                accent: Color(red: 0.70, green: 0.52, blue: 0.18),
                accentForeground: Color(red: 0.39, green: 0.27, blue: 0.07),
                parchment: Color(red: 0.995, green: 0.985, blue: 0.955),
                parchmentShade: Color(red: 0.95, green: 0.92, blue: 0.84),
                cardBorder: Color(red: 0.60, green: 0.50, blue: 0.32))
        case .lent:
            return Palette(
                season: season,
                primary: Color(red: 0.30, green: 0.19, blue: 0.37),
                accent: Color(red: 0.58, green: 0.45, blue: 0.61),
                accentForeground: Color(red: 0.32, green: 0.20, blue: 0.38),
                parchment: Color(red: 0.985, green: 0.970, blue: 0.970),
                parchmentShade: Color(red: 0.92, green: 0.89, blue: 0.92),
                cardBorder: Color(red: 0.51, green: 0.44, blue: 0.54))
        case .easter:
            return Palette(
                season: season,
                primary: Color(red: 0.43, green: 0.31, blue: 0.10),
                accent: Color(red: 0.75, green: 0.60, blue: 0.20),
                accentForeground: Color(red: 0.38, green: 0.27, blue: 0.08),
                parchment: Color(red: 0.995, green: 0.990, blue: 0.965),
                parchmentShade: Color(red: 0.94, green: 0.93, blue: 0.86),
                cardBorder: Color(red: 0.59, green: 0.53, blue: 0.34))
        case .ordinary:
            return ordinaryPalette
        }
    }

    private static var ordinaryPalette: Palette {
        Palette(
            season: .ordinary,
            primary: Color(red: 0.18, green: 0.34, blue: 0.23),
            accent: Color(red: 0.66, green: 0.49, blue: 0.18),
            accentForeground: Color(red: 0.38, green: 0.27, blue: 0.08),
            parchment: Color(red: 0.985, green: 0.975, blue: 0.945),
            parchmentShade: Color(red: 0.93, green: 0.93, blue: 0.88),
            cardBorder: Color(red: 0.49, green: 0.56, blue: 0.49))
    }
}
