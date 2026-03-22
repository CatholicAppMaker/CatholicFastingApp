import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension View {
    @ViewBuilder
    func appPrimaryButtonStyle(legacyTint: Color = CatholicTheme.primary) -> some View {
        if #available(iOS 26.0, *) {
            tint(legacyTint)
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .frame(minHeight: 44)
        } else {
            buttonStyle(.borderedProminent)
                .tint(legacyTint)
                .controlSize(.large)
                .frame(minHeight: 44)
        }
    }

    @ViewBuilder
    func appSecondaryButtonStyle(legacyTint: Color = CatholicTheme.primary) -> some View {
        if #available(iOS 26.0, *) {
            tint(legacyTint)
                .buttonStyle(.glass)
                .controlSize(.large)
                .frame(minHeight: 44)
        } else {
            buttonStyle(.bordered)
                .tint(legacyTint)
                .controlSize(.large)
                .frame(minHeight: 44)
        }
    }

    func appRootBackground() -> some View {
        background(CatholicTheme.background)
    }

    func appListBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(CatholicTheme.background)
    }

    @ViewBuilder
    func appRoundedGlass(cornerRadius: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            self
        }
    }

    @ViewBuilder
    func appCapsuleGlass() -> some View {
        if #available(iOS 26.0, *) {
            glassEffect(in: Capsule())
        } else {
            self
        }
    }

    func appSurfaceCard(_ style: AppSurfaceCardStyle = .standard, cornerRadius: CGFloat = 18) -> some View {
        modifier(AppSurfaceCardModifier(style: style, cornerRadius: cornerRadius))
    }

    func appEyebrowStyle() -> some View {
        font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    func appSectionTitleStyle(serif: Bool = false) -> some View {
        font(serif ? .system(.title3, design: .serif).weight(.bold) : .system(.title3, design: .rounded).weight(.bold))
            .foregroundStyle(CatholicTheme.primary)
    }

    func appDisplayTitleStyle(serif: Bool = false) -> some View {
        font(serif ? .system(.title2, design: .serif).weight(.bold) : .system(.title2, design: .rounded).weight(.bold))
            .foregroundStyle(CatholicTheme.primary)
    }

    func appLeadTextStyle() -> some View {
        font(.subheadline)
            .foregroundStyle(.secondary)
    }

    func appSupportingTextStyle() -> some View {
        font(.footnote)
            .foregroundStyle(.secondary)
    }

    func appMetricValueStyle() -> some View {
        font(.system(.title3, design: .rounded).weight(.bold))
            .foregroundStyle(CatholicTheme.primary)
    }

    func appInteractiveTileStyle(
        isSelected: Bool = false,
        cornerRadius: CGFloat = 16,
        selectedTint: Color = CatholicTheme.primary) -> some View
    {
        modifier(
            AppInteractiveTileModifier(
                isSelected: isSelected,
                cornerRadius: cornerRadius,
                selectedTint: selectedTint))
    }

    func appSymbolStyle(_ role: AppSymbolRole = .standard) -> some View {
        modifier(AppSymbolModifier(role: role))
    }
}

enum AppSymbolRole {
    case prominent
    case standard
    case subtle

    var font: Font {
        switch self {
        case .prominent:
            .system(size: 18, weight: .semibold)
        case .standard:
            .system(size: 15, weight: .semibold)
        case .subtle:
            .system(size: 13, weight: .medium)
        }
    }

    var color: Color {
        switch self {
        case .prominent, .standard:
            CatholicTheme.primary
        case .subtle:
            .secondary
        }
    }
}

private struct AppSymbolModifier: ViewModifier {
    let role: AppSymbolRole

    func body(content: Content) -> some View {
        content
            .font(role.font)
            .foregroundStyle(role.color)
    }
}

private struct AppInteractiveTileModifier: ViewModifier {
    let isSelected: Bool
    let cornerRadius: CGFloat
    let selectedTint: Color

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isSelected ? selectedTint.opacity(0.12) : CatholicTheme.parchment.opacity(0.88))
                    .allowsHitTesting(false))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isSelected ? selectedTint : CatholicTheme.cardBorder.opacity(0.35), lineWidth: 1)
                    .allowsHitTesting(false))
            .shadow(color: isSelected ? selectedTint.opacity(0.10) : .clear, radius: 10, y: 4)
    }
}

enum AppSurfaceCardStyle {
    case primary
    case standard
    case utility

    var fillOpacity: Double {
        switch self {
        case .primary:
            0.96
        case .standard:
            0.92
        case .utility:
            0.88
        }
    }

    var tintOpacity: Double {
        switch self {
        case .primary:
            0.16
        case .standard:
            0.08
        case .utility:
            0.04
        }
    }

    var strokeOpacity: Double {
        switch self {
        case .primary:
            0.62
        case .standard:
            0.46
        case .utility:
            0.36
        }
    }
}

struct AppSurfaceCardModifier: ViewModifier {
    let style: AppSurfaceCardStyle
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(CatholicTheme.parchment.opacity(style.fillOpacity))
                    .allowsHitTesting(false))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(CatholicTheme.accent.opacity(style.tintOpacity))
                    .allowsHitTesting(false))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CatholicTheme.cardBorder.opacity(style.strokeOpacity), lineWidth: 1)
                    .allowsHitTesting(false))
            .shadow(color: CatholicTheme.primary.opacity(style == .primary ? 0.08 : 0.04), radius: style == .primary ? 18 : 10, y: style == .primary ? 10 : 5)
    }
}

struct SacredImageryItem: Identifiable {
    let id: String
    let assetName: String
    let title: String
    let subtitle: String
}

enum SacredImageryCatalog {
    static let fastingGallery: [SacredImageryItem] = [
        SacredImageryItem(
            id: "chi-rho",
            assetName: "SacredChiRho",
            title: "Chi-Rho",
            subtitle: "Offer each fast in Christ."),
        SacredImageryItem(
            id: "monstrance",
            assetName: "SacredMonstrance",
            title: "Monstrance",
            subtitle: "Let prayer anchor discipline."),
        SacredImageryItem(
            id: "sacred-heart",
            assetName: "SacredSacredHeart",
            title: "Sacred Heart",
            subtitle: "Unite fasting to charity."),
        SacredImageryItem(
            id: "rosary-cross",
            assetName: "SacredRosaryCross",
            title: "Rosary Cross",
            subtitle: "Pray while you abstain."),
        SacredImageryItem(
            id: "cathedral-light",
            assetName: "SacredCathedralLight",
            title: "Cathedral Light",
            subtitle: "Remember the liturgy while you fast."),
        SacredImageryItem(
            id: "ash-wednesday",
            assetName: "SacredAshWednesday",
            title: "Ash Cross",
            subtitle: "Repentance remains the core of fasting."),
        SacredImageryItem(
            id: "desert-pilgrimage",
            assetName: "SacredDesertPilgrimage",
            title: "Desert Pilgrimage",
            subtitle: "Keep your sacrifice steady over time."),
        SacredImageryItem(
            id: "scripture-candle",
            assetName: "SacredScriptureCandle",
            title: "Scripture Candle",
            subtitle: "Anchor discipline in prayer and the Word."),
        SacredImageryItem(
            id: "palm-sunday",
            assetName: "SacredPalmSunday",
            title: "Palm Branch",
            subtitle: "Prepare your heart for Holy Week."),
        SacredImageryItem(
            id: "chalice-vine",
            assetName: "SacredChaliceVine",
            title: "Chalice and Vine",
            subtitle: "Offer fasting in a Eucharistic spirit."),
        SacredImageryItem(
            id: "pantocrator",
            assetName: "HeroSacred",
            title: "Christ Pantocrator",
            subtitle: "Keep your fasting centered on Christ."),
        SacredImageryItem(
            id: "basilica",
            assetName: "GuidanceSacred",
            title: "St. Peter's Basilica",
            subtitle: "Stay rooted in the life and teaching of the Church."),
        SacredImageryItem(
            id: "jerusalem-cross",
            assetName: "SacredJerusalemCross",
            title: "Jerusalem Cross",
            subtitle: "Let your sacrifice witness to the Gospel."),
        SacredImageryItem(
            id: "marian-monogram",
            assetName: "SacredMarianMonogram",
            title: "Marian Monogram",
            subtitle: "Fast with humility and trust in Mary's example."),
        SacredImageryItem(
            id: "concept-chi-rho",
            assetName: "SacredConceptChiRho",
            title: "Chi-Rho Crest",
            subtitle: "Keep each offering centered on Christ."),
        SacredImageryItem(
            id: "concept-rosary",
            assetName: "SacredConceptRosary",
            title: "Rosary Emblem",
            subtitle: "Unite prayer and discipline day by day."),
        SacredImageryItem(
            id: "concept-heart",
            assetName: "SacredConceptHeart",
            title: "Heart of Mercy",
            subtitle: "Let fasting lead to deeper charity."),
        SacredImageryItem(
            id: "monstrance-adoration-night",
            assetName: "SacredMonstrance",
            title: "Adoration Night",
            subtitle: "Anchor discipline in Eucharistic worship."),
        SacredImageryItem(
            id: "scripture-candle-watch",
            assetName: "SacredScriptureCandle",
            title: "Watchful Prayer",
            subtitle: "Keep vigil in prayer while you fast."),
        SacredImageryItem(
            id: "cathedral-light-vestibule",
            assetName: "SacredCathedralLight",
            title: "Church Light",
            subtitle: "Bring fasting into the rhythm of the liturgy."),
        SacredImageryItem(
            id: "palm-branch-procession",
            assetName: "SacredPalmSunday",
            title: "Procession",
            subtitle: "Walk with Christ through discipline and mercy."),
        SacredImageryItem(
            id: "jerusalem-cross-pilgrim",
            assetName: "SacredJerusalemCross",
            title: "Pilgrim Cross",
            subtitle: "Offer each sacrifice for the Church and world."),
        SacredImageryItem(
            id: "marian-monogram-fiat",
            assetName: "SacredMarianMonogram",
            title: "Marian Fiat",
            subtitle: "Practice faithful discipline with humility."),
        SacredImageryItem(
            id: "chi-rho-victory",
            assetName: "SacredConceptChiRho",
            title: "Christ Our Victory",
            subtitle: "Keep every fast ordered to Christ."),
        SacredImageryItem(
            id: "rosary-emblem-perseverance",
            assetName: "SacredConceptRosary",
            title: "Rosary Perseverance",
            subtitle: "Persevere in small sacrifices with prayer."),
    ]
}

enum SacredImageAssetResolver {
    static func hasAsset(named assetName: String) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: assetName) != nil
        #else
        return true
        #endif
    }
}

struct SacredHeroCard: View {
    let assetName: String
    let title: String
    let subtitle: String
    var height: CGFloat = 160
    var cornerRadius: CGFloat = 14
    var accessibilityIdentifier: String?
    var fallbackSymbol: String = "cross.case.fill"

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            heroMediaLayer

            LinearGradient(
                colors: [CatholicTheme.primary.opacity(0.20), Color.clear, Color.black.opacity(0.70)],
                startPoint: .topLeading,
                endPoint: .bottom)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.title3, design: .serif).weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.92))
                    .lineLimit(3)
                    .minimumScaleFactor(0.9)
            }
            .padding(12)
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: fallbackSymbol)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.78))
                .padding(8)
                .background(Color.black.opacity(0.16), in: Circle())
                .padding(8)
                .accessibilityHidden(true)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(CatholicTheme.cardBorder.opacity(0.72), lineWidth: 1))
        .shadow(color: CatholicTheme.primary.opacity(0.14), radius: 18, y: 8)
        .appRoundedGlass(cornerRadius: cornerRadius)
        .modifier(AccessibilityIDModifier(id: accessibilityIdentifier))
    }

    @ViewBuilder
    private var heroMediaLayer: some View {
        if SacredImageAssetResolver.hasAsset(named: assetName) {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            ZStack {
                LinearGradient(
                    colors: [CatholicTheme.accent.opacity(0.55), CatholicTheme.primary.opacity(0.75)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                VStack(spacing: 10) {
                    Image(systemName: fallbackSymbol)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                    Text("Catholic Fasting")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
            }
        }
    }
}

private struct AccessibilityIDModifier: ViewModifier {
    let id: String?

    func body(content: Content) -> some View {
        if let id {
            content.accessibilityIdentifier(id)
        } else {
            content
        }
    }
}

struct SacredImageryCard: View {
    let item: SacredImageryItem
    var width: CGFloat = 168
    var height: CGFloat = 176

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(CatholicTheme.parchment.opacity(0.16)))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1))

                Image(item.assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(14)
            }
            .frame(height: height - 58)
            .appRoundedGlass(cornerRadius: 14)

            Text(item.title)
                .appSectionTitleStyle(serif: true)
                .lineLimit(1)

            Text(item.subtitle)
                .appSupportingTextStyle()
                .lineLimit(2)
        }
        .frame(width: width, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title). \(item.subtitle)")
    }
}

struct CatholicFastingQuoteCard: View {
    let quote: CatholicFastingQuote
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("“\(quote.text)”")
                .font(.system(compact ? .footnote : .body, design: .serif))
                .italic()
                .foregroundStyle(CatholicTheme.primary)
            Text("— \(quote.author)")
                .font(.headline.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
            Text("\(quote.tradition) • \(quote.source)")
                .appSupportingTextStyle()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(.utility, cornerRadius: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(quote.text). \(quote.author). \(quote.source).")
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
    static let legalPolicyURL = URL(
        string: "https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar")!
    static let usccbFastAbstinenceURL = URL(
        string:
        "https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar/lent/catholic-information-on-lenten-fast-and-abstinence")!
    static let cccbKeepingFridayURL = URL(
        string: "https://www.cccb.ca/document/keeping-friday/")!
    static let supportEmail = URL(
        string: "mailto:support@catholicfasting.app?subject=Catholic%20Fasting%20App%20Feedback")!
    static let legalLinks = LegalLinks(
        privacyPolicyURL: URL(string: "https://x.com/CatholicFasting/status/2026354531273945191")!,
        termsOfUseURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!,
        supportURL: URL(string: "https://x.com/CatholicFasting")!)
    static let privacyPolicyURL = legalLinks.privacyPolicyURL
    static let termsOfUseURL = legalLinks.termsOfUseURL
    static let supportSiteURL = legalLinks.supportURL
    static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!
    static let deepLinkTodayURL = URL(string: "catholicfasting://today")!
    static let deepLinkFastingDaysURL = URL(string: "catholicfasting://fasting-days")!
    static let deepLinkIntermittentURL = URL(string: "catholicfasting://intermittent")!
    static let deepLinkMoreURL = URL(string: "catholicfasting://more")!
    static let exportISO8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

enum AppDeepLinkTarget: Equatable {
    case surface(HomeSurface)

    static func parse(url: URL) -> AppDeepLinkTarget? {
        guard let scheme = url.scheme?.lowercased(), scheme == "catholicfasting" else {
            return nil
        }

        let route = (url.host ?? "").isEmpty ? url.pathComponents.dropFirst().first ?? "" : (url.host ?? "")
        switch route.lowercased() {
        case "today":
            return .surface(.today)
        case "calendar", "fasting-days", "fastingdays":
            return .surface(.fastingDays)
        case "track", "intermittent", "fast":
            return .surface(.intermittent)
        case "more", "settings":
            return .surface(.more)
        default:
            return nil
        }
    }
}

enum CatholicTheme {
    struct Palette {
        let season: LiturgicalSeason
        let primary: Color
        let accent: Color
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
        case .ordinary:
            "Ordinary"
        case .advent:
            "Advent"
        case .christmas:
            "Christmas"
        case .lent:
            "Lent"
        case .easter:
            "Easter"
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
                parchment: Color(red: 0.95, green: 0.95, blue: 0.99),
                parchmentShade: Color(red: 0.84, green: 0.86, blue: 0.96),
                cardBorder: Color(red: 0.40, green: 0.44, blue: 0.73))
        case .christmas:
            return Palette(
                season: season,
                primary: Color(red: 0.50, green: 0.29, blue: 0.07),
                accent: Color(red: 0.85, green: 0.65, blue: 0.18),
                parchment: Color(red: 1.00, green: 0.98, blue: 0.92),
                parchmentShade: Color(red: 0.95, green: 0.91, blue: 0.78),
                cardBorder: Color(red: 0.78, green: 0.62, blue: 0.24))
        case .lent:
            return Palette(
                season: season,
                primary: Color(red: 0.30, green: 0.13, blue: 0.45),
                accent: Color(red: 0.61, green: 0.46, blue: 0.72),
                parchment: Color(red: 0.95, green: 0.91, blue: 0.95),
                parchmentShade: Color(red: 0.84, green: 0.79, blue: 0.90),
                cardBorder: Color(red: 0.55, green: 0.42, blue: 0.66))
        case .easter:
            return Palette(
                season: season,
                primary: Color(red: 0.14, green: 0.37, blue: 0.18),
                accent: Color(red: 0.82, green: 0.66, blue: 0.18),
                parchment: Color(red: 0.99, green: 0.98, blue: 0.92),
                parchmentShade: Color(red: 0.89, green: 0.93, blue: 0.80),
                cardBorder: Color(red: 0.46, green: 0.66, blue: 0.40))
        case .ordinary:
            return Palette(
                season: season,
                primary: Color(red: 0.10, green: 0.38, blue: 0.17),
                accent: Color(red: 0.72, green: 0.56, blue: 0.15),
                parchment: Color(red: 0.97, green: 0.96, blue: 0.86),
                parchmentShade: Color(red: 0.86, green: 0.90, blue: 0.76),
                cardBorder: Color(red: 0.38, green: 0.59, blue: 0.34))
        }
    }
}
