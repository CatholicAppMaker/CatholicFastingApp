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
        } else {
            buttonStyle(.borderedProminent)
                .tint(legacyTint)
                .controlSize(.large)
        }
    }

    @ViewBuilder
    func appSecondaryButtonStyle(legacyTint: Color = CatholicTheme.primary) -> some View {
        if #available(iOS 26.0, *) {
            tint(legacyTint)
                .buttonStyle(.glass)
                .controlSize(.large)
        } else {
            buttonStyle(.bordered)
                .tint(legacyTint)
                .controlSize(.large)
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
            glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
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
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(CatholicTheme.accent.opacity(style.tintOpacity))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CatholicTheme.cardBorder.opacity(style.strokeOpacity), lineWidth: 1)
            )
            .shadow(color: CatholicTheme.primary.opacity(style == .primary ? 0.08 : 0.04), radius: style == .primary ? 18 : 10, y: style == .primary ? 10 : 5)
            .appRoundedGlass(cornerRadius: cornerRadius)
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
            subtitle: "Offer each fast in Christ."
        ),
        SacredImageryItem(
            id: "monstrance",
            assetName: "SacredMonstrance",
            title: "Monstrance",
            subtitle: "Let prayer anchor discipline."
        ),
        SacredImageryItem(
            id: "sacred-heart",
            assetName: "SacredSacredHeart",
            title: "Sacred Heart",
            subtitle: "Unite fasting to charity."
        ),
        SacredImageryItem(
            id: "rosary-cross",
            assetName: "SacredRosaryCross",
            title: "Rosary Cross",
            subtitle: "Pray while you abstain."
        ),
        SacredImageryItem(
            id: "cathedral-light",
            assetName: "SacredCathedralLight",
            title: "Cathedral Light",
            subtitle: "Remember the liturgy while you fast."
        ),
        SacredImageryItem(
            id: "ash-wednesday",
            assetName: "SacredAshWednesday",
            title: "Ash Cross",
            subtitle: "Repentance remains the core of fasting."
        ),
        SacredImageryItem(
            id: "desert-pilgrimage",
            assetName: "SacredDesertPilgrimage",
            title: "Desert Pilgrimage",
            subtitle: "Keep your sacrifice steady over time."
        ),
        SacredImageryItem(
            id: "scripture-candle",
            assetName: "SacredScriptureCandle",
            title: "Scripture Candle",
            subtitle: "Anchor discipline in prayer and the Word."
        ),
        SacredImageryItem(
            id: "palm-sunday",
            assetName: "SacredPalmSunday",
            title: "Palm Branch",
            subtitle: "Prepare your heart for Holy Week."
        ),
        SacredImageryItem(
            id: "chalice-vine",
            assetName: "SacredChaliceVine",
            title: "Chalice and Vine",
            subtitle: "Offer fasting in a Eucharistic spirit."
        ),
        SacredImageryItem(
            id: "pantocrator",
            assetName: "HeroSacred",
            title: "Christ Pantocrator",
            subtitle: "Keep your fasting centered on Christ."
        ),
        SacredImageryItem(
            id: "basilica",
            assetName: "GuidanceSacred",
            title: "St. Peter's Basilica",
            subtitle: "Stay rooted in the life and teaching of the Church."
        ),
        SacredImageryItem(
            id: "jerusalem-cross",
            assetName: "SacredJerusalemCross",
            title: "Jerusalem Cross",
            subtitle: "Let your sacrifice witness to the Gospel."
        ),
        SacredImageryItem(
            id: "marian-monogram",
            assetName: "SacredMarianMonogram",
            title: "Marian Monogram",
            subtitle: "Fast with humility and trust in Mary's example."
        ),
        SacredImageryItem(
            id: "concept-chi-rho",
            assetName: "SacredConceptChiRho",
            title: "Chi-Rho Crest",
            subtitle: "Keep each offering centered on Christ."
        ),
        SacredImageryItem(
            id: "concept-rosary",
            assetName: "SacredConceptRosary",
            title: "Rosary Emblem",
            subtitle: "Unite prayer and discipline day by day."
        ),
        SacredImageryItem(
            id: "concept-heart",
            assetName: "SacredConceptHeart",
            title: "Heart of Mercy",
            subtitle: "Let fasting lead to deeper charity."
        ),
        SacredImageryItem(
            id: "monstrance-adoration-night",
            assetName: "SacredMonstrance",
            title: "Adoration Night",
            subtitle: "Anchor discipline in Eucharistic worship."
        ),
        SacredImageryItem(
            id: "scripture-candle-watch",
            assetName: "SacredScriptureCandle",
            title: "Watchful Prayer",
            subtitle: "Keep vigil in prayer while you fast."
        ),
        SacredImageryItem(
            id: "cathedral-light-vestibule",
            assetName: "SacredCathedralLight",
            title: "Church Light",
            subtitle: "Bring fasting into the rhythm of the liturgy."
        ),
        SacredImageryItem(
            id: "palm-branch-procession",
            assetName: "SacredPalmSunday",
            title: "Procession",
            subtitle: "Walk with Christ through discipline and mercy."
        ),
        SacredImageryItem(
            id: "jerusalem-cross-pilgrim",
            assetName: "SacredJerusalemCross",
            title: "Pilgrim Cross",
            subtitle: "Offer each sacrifice for the Church and world."
        ),
        SacredImageryItem(
            id: "marian-monogram-fiat",
            assetName: "SacredMarianMonogram",
            title: "Marian Fiat",
            subtitle: "Practice faithful discipline with humility."
        ),
        SacredImageryItem(
            id: "chi-rho-victory",
            assetName: "SacredConceptChiRho",
            title: "Christ Our Victory",
            subtitle: "Keep every fast ordered to Christ."
        ),
        SacredImageryItem(
            id: "rosary-emblem-perseverance",
            assetName: "SacredConceptRosary",
            title: "Rosary Perseverance",
            subtitle: "Persevere in small sacrifices with prayer."
        ),
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
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                Text(subtitle)
                    .font(.caption)
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
                .stroke(CatholicTheme.cardBorder.opacity(0.72), lineWidth: 1)
        )
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
                    endPoint: .bottomTrailing
                )
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
                            .fill(CatholicTheme.parchment.opacity(0.16))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1)
                    )

                Image(item.assetName)
                    .resizable()
                    .scaledToFit()
                    .padding(14)
            }
            .frame(height: height - 58)
            .appRoundedGlass(cornerRadius: 14)

            Text(item.title)
                .font(.system(.subheadline, design: .serif).weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
                .lineLimit(1)

            Text(item.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
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
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
            Text("\(quote.tradition) • \(quote.source)")
                .font(.caption)
                .foregroundStyle(.secondary)
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
        string: "https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar"
    )!
    static let usccbFastAbstinenceURL = URL(
        string:
        "https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar/lent/catholic-information-on-lenten-fast-and-abstinence"
    )!
    static let cccbKeepingFridayURL = URL(
        string: "https://www.cccb.ca/document/keeping-friday/"
    )!
    static let supportEmail = URL(
        string: "mailto:support@catholicfasting.app?subject=Catholic%20Fasting%20App%20Feedback"
    )!
    static let legalLinks = LegalLinks(
        privacyPolicyURL: URL(string: "https://x.com/CatholicFasting/status/2026354531273945191")!,
        termsOfUseURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!,
        supportURL: URL(string: "https://x.com/CatholicFasting")!
    )
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
            endPoint: .bottomTrailing
        )
    }

    static func palette(seasonModeEnabled: Bool, date: Date) -> Palette {
        guard seasonModeEnabled else {
            return Palette(
                season: .ordinary,
                primary: Color(red: 0.40, green: 0.11, blue: 0.13),
                accent: Color(red: 0.78, green: 0.58, blue: 0.18),
                parchment: Color(red: 0.98, green: 0.95, blue: 0.87),
                parchmentShade: Color(red: 0.90, green: 0.84, blue: 0.73),
                cardBorder: Color(red: 0.70, green: 0.56, blue: 0.29)
            )
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
                cardBorder: Color(red: 0.40, green: 0.44, blue: 0.73)
            )
        case .christmas:
            return Palette(
                season: season,
                primary: Color(red: 0.50, green: 0.29, blue: 0.07),
                accent: Color(red: 0.85, green: 0.65, blue: 0.18),
                parchment: Color(red: 1.00, green: 0.98, blue: 0.92),
                parchmentShade: Color(red: 0.95, green: 0.91, blue: 0.78),
                cardBorder: Color(red: 0.78, green: 0.62, blue: 0.24)
            )
        case .lent:
            return Palette(
                season: season,
                primary: Color(red: 0.30, green: 0.13, blue: 0.45),
                accent: Color(red: 0.61, green: 0.46, blue: 0.72),
                parchment: Color(red: 0.95, green: 0.91, blue: 0.95),
                parchmentShade: Color(red: 0.84, green: 0.79, blue: 0.90),
                cardBorder: Color(red: 0.55, green: 0.42, blue: 0.66)
            )
        case .easter:
            return Palette(
                season: season,
                primary: Color(red: 0.14, green: 0.37, blue: 0.18),
                accent: Color(red: 0.82, green: 0.66, blue: 0.18),
                parchment: Color(red: 0.99, green: 0.98, blue: 0.92),
                parchmentShade: Color(red: 0.89, green: 0.93, blue: 0.80),
                cardBorder: Color(red: 0.46, green: 0.66, blue: 0.40)
            )
        case .ordinary:
            return Palette(
                season: season,
                primary: Color(red: 0.10, green: 0.38, blue: 0.17),
                accent: Color(red: 0.72, green: 0.56, blue: 0.15),
                parchment: Color(red: 0.97, green: 0.96, blue: 0.86),
                parchmentShade: Color(red: 0.86, green: 0.90, blue: 0.76),
                cardBorder: Color(red: 0.38, green: 0.59, blue: 0.34)
            )
        }
    }
}

enum DefaultValues {
    static let birthYear = 0
    static let birthMonth = 0
    static let birthDay = 0
    static let age14OrOlderForAbstinence = true
    static let age18OrOlderForFasting = true
    static let medicalDispensation = false
    static let ascension = RuleSettings.AscensionObservance.sunday
    static let fridayOutsideLent = RuleSettings.FridayOutsideLentMode.substitutePenance
    static let province = RuleSettings.USProvincePreset.otherUSProvince
    static let calendarMode = RuleSettings.CalendarMode.usccb
    static let language = LanguageMode.english
    static let regionProfile = RuleSettings.RegionProfile.us
    static let liturgicalSeasonColorsEnabled = true
    static let dailyReminderSupportEnabled = true
    static let morningReminderEnabled = true
    static let eveningReminderEnabled = false
    static let reminderTier = ReminderTier.balanced
    static let hapticsEnabled = true
    static let supportPremiumSurface = SupportPremiumSurface.upgrade
}

enum StorageKeys {
    static let birthYear = "birth_year"
    static let birthMonth = "birth_month"
    static let birthDay = "birth_day"
    static let age14OrOlderForAbstinence = "age_14_or_older_for_abstinence"
    static let age18OrOlderForFasting = "age_18_or_older_for_fasting"
    static let medicalDispensation = "medical_dispensation"
    static let ascensionObservance = "ascension_observance"
    static let fridayOutsideLentMode = "friday_outside_lent_mode"
    static let usProvincePreset = "us_province_preset"
    static let calendarMode = "calendar_mode"
    static let languageMode = "language_mode"
    static let regionProfile = "region_profile"
    static let didCompleteOnboarding = "did_complete_onboarding"
    static let acceptedLegalNotice = "accepted_legal_notice"
    static let acceptedLegalNoticeAt = "accepted_legal_notice_at"
    static let liturgicalSeasonColorsEnabled = "liturgical_season_colors_enabled"
    static let dailyReminderSupportEnabled = "daily_reminder_support_enabled"
    static let morningReminderEnabled = "morning_reminder_enabled"
    static let eveningReminderEnabled = "evening_reminder_enabled"
    static let reminderTier = "reminder_tier"
    static let hapticsEnabled = "haptics_enabled"
    static let intermittentShowAdvanced = "intermittent_show_advanced"
    static let simplifiedModeEnabled = "simplified_mode_enabled"
    static let voiceSummaryEnabled = "voice_summary_enabled"
    static let fastingDaysShowAllYearDays = "fasting_days_show_all_year_days"
    static let fastingDaysIncludeOptionalDays = "fasting_days_include_optional_days"
    static let fastingDaysIncludeFeastAndHolyDays = "fasting_days_include_feast_and_holy_days"
    static let supportPremiumSurface = "support_premium_surface"
}

enum LanguageMode: String, CaseIterable, Identifiable {
    case english
    case spanish

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .english:
            "English"
        case .spanish:
            "Español"
        }
    }
}

enum HomeSurface: String, CaseIterable, Identifiable {
    case today
    case fastingDays
    case intermittent
    case more

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .today:
            "Today"
        case .fastingDays:
            "Fasting Days"
        case .intermittent:
            "Track Fast"
        case .more:
            "More"
        }
    }

    var iconName: String {
        switch self {
        case .today:
            "house.fill"
        case .fastingDays:
            "calendar"
        case .intermittent:
            "timer"
        case .more:
            "ellipsis.circle.fill"
        }
    }

    static let primarySurfaces: [HomeSurface] = [.today, .fastingDays, .intermittent, .more]
}

enum AppLayoutProfile: String {
    case phone
    case pad

    var usesSplitViewShell: Bool {
        self == .pad
    }
}

enum MoreHubDestination: String, CaseIterable, Identifiable {
    case supportAndPremium
    case setupAndReminders
    case profileAndNorms
    case guidanceAndRules
    case privacyAndData

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .supportAndPremium:
            "Support & Premium"
        case .setupAndReminders:
            "Setup & Reminders"
        case .profileAndNorms:
            "Profile & Norms"
        case .guidanceAndRules:
            "Guidance & Rules"
        case .privacyAndData:
            "Privacy & Data"
        }
    }

    var subtitle: String {
        switch self {
        case .supportAndPremium:
            "Upgrade or open premium tools."
        case .setupAndReminders:
            "Finish setup and manage reminders."
        case .profileAndNorms:
            "Update your profile, norms, and theme."
        case .guidanceAndRules:
            "Open food guidance, norms, and sources."
        case .privacyAndData:
            "Review consent, exports, backups, and reset tools."
        }
    }

    var iconName: String {
        switch self {
        case .supportAndPremium:
            "heart.circle"
        case .setupAndReminders:
            "bell.badge"
        case .profileAndNorms:
            "person.crop.circle"
        case .guidanceAndRules:
            "book.closed"
        case .privacyAndData:
            "lock.shield"
        }
    }
}

enum SupportPremiumSurface: String, CaseIterable, Identifiable {
    case upgrade
    case tools

    var id: String {
        rawValue
    }

    var label: String {
        switch self {
        case .upgrade:
            "Upgrade"
        case .tools:
            "Premium Tools"
        }
    }
}

enum PremiumToolDestination: String, CaseIterable, Identifiable {
    case planner
    case reminders
    case analytics
    case journal
    case export

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .planner:
            "Planner"
        case .reminders:
            "Reminders"
        case .analytics:
            "Analytics"
        case .journal:
            "Journal"
        case .export:
            "Export"
        }
    }

    var subtitle: String {
        switch self {
        case .planner:
            "Build your season plan and rule template."
        case .reminders:
            "Apply smart reminder recommendations."
        case .analytics:
            "Review completion trends and recovery guidance."
        case .journal:
            "Write reflections and log virtue check-ins."
        case .export:
            "Share summaries and household packets."
        }
    }

    var iconName: String {
        switch self {
        case .planner:
            "calendar.badge.clock"
        case .reminders:
            "bell.badge.waveform"
        case .analytics:
            "chart.bar.xaxis"
        case .journal:
            "book.pages"
        case .export:
            "square.and.arrow.up"
        }
    }
}

enum AppLocalizer {
    static func localized(_ key: String, default defaultValue: String, languageCode: String) -> String {
        let resolvedCode = languageCode == LanguageMode.spanish.rawValue ? "es" : "en"
        guard
            let path = Bundle.main.path(forResource: resolvedCode, ofType: "lproj"),
            let bundle = Bundle(path: path)
        else {
            return NSLocalizedString(
                key, tableName: "Localizable", bundle: .main, value: defaultValue, comment: ""
            )
        }

        return NSLocalizedString(
            key, tableName: "Localizable", bundle: bundle, value: defaultValue, comment: ""
        )
    }
}
