import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SacredImageryItem: Identifiable {
    let id: String
    let assetName: String
    let title: String
    let subtitle: String
}

enum SacredImageryCatalog {
    static var fastingGallery: [SacredImageryItem] {
        [
            SacredImageryItem(
                id: "chapel-altar",
                assetName: "HeroSacred",
                title: AppLocalizer.localizedCurrent("sacred.gallery.chapel_altar.title", default: "Chapel Altar"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.chapel_altar.subtitle",
                    default: "Keep your fasting quiet, prayerful, and rooted in worship.")),
            SacredImageryItem(
                id: "crucifix-altar",
                assetName: "SacredCrucifixAltar",
                title: AppLocalizer.localizedCurrent("sacred.gallery.crucifix_altar.title", default: "Crucifix Altar"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.crucifix_altar.subtitle",
                    default: "Bring sacrifice before Christ with humility.")),
            SacredImageryItem(
                id: "planning-journal",
                assetName: "SacredPlanningJournal",
                title: AppLocalizer.localizedCurrent("sacred.gallery.planning_journal.title", default: "Planning Journal"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.planning_journal.subtitle",
                    default: "Prepare discipline with peace and intention.")),
            SacredImageryItem(
                id: "eucharistic-support",
                assetName: "SacredChaliceVine",
                title: AppLocalizer.localizedCurrent("sacred.gallery.eucharistic_support.title", default: "Eucharistic Support"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.eucharistic_support.subtitle",
                    default: "Let support for discipline remain close to prayer.")),
            SacredImageryItem(
                id: "monstrance",
                assetName: "SacredMonstrance",
                title: AppLocalizer.localizedCurrent("sacred.gallery.monstrance.title", default: "Monstrance"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.monstrance.subtitle",
                    default: "Let prayer anchor discipline.")),
            SacredImageryItem(
                id: "sacred-heart",
                assetName: "SacredSacredHeart",
                title: AppLocalizer.localizedCurrent("sacred.gallery.sacred_heart.title", default: "Sacred Heart"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.sacred_heart.subtitle",
                    default: "Unite fasting to charity.")),
            SacredImageryItem(
                id: "rosary-cross",
                assetName: "SacredRosaryCross",
                title: AppLocalizer.localizedCurrent("sacred.gallery.rosary_cross.title", default: "Rosary Cross"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.rosary_cross.subtitle",
                    default: "Pray while you abstain.")),
            SacredImageryItem(
                id: "chi-rho",
                assetName: "SacredChiRho",
                title: AppLocalizer.localizedCurrent("sacred.gallery.chi_rho.title", default: "Chi-Rho"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.chi_rho.subtitle",
                    default: "Offer each fast in Christ.")),
            SacredImageryItem(
                id: "prayer-journal",
                assetName: "SacredScriptureCandle",
                title: AppLocalizer.localizedCurrent("sacred.gallery.prayer_journal.title", default: "Prayer Journal"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.prayer_journal.subtitle",
                    default: "Keep discipline joined to reflection and prayer.")),
            SacredImageryItem(
                id: "jerusalem-cross",
                assetName: "SacredJerusalemCross",
                title: AppLocalizer.localizedCurrent("sacred.gallery.jerusalem_cross.title", default: "Jerusalem Cross"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.jerusalem_cross.subtitle",
                    default: "Let your sacrifice witness to the Gospel.")),
            SacredImageryItem(
                id: "marian-monogram",
                assetName: "SacredMarianMonogram",
                title: AppLocalizer.localizedCurrent("sacred.gallery.marian_chapel.title", default: "Marian Chapel"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.marian_chapel.subtitle",
                    default: "Fast with humility and trust in Mary's example.")),
            SacredImageryItem(
                id: "advent-wreath",
                assetName: "SacredAdventWreath",
                title: AppLocalizer.localizedCurrent("sacred.gallery.advent_wreath.title", default: "Advent Wreath"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.advent_wreath.subtitle",
                    default: "Wait with steady hope and prayerful preparation.")),
            SacredImageryItem(
                id: "paschal-candle",
                assetName: "SacredPaschalCandle",
                title: AppLocalizer.localizedCurrent("sacred.gallery.paschal_candle.title", default: "Paschal Candle"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.paschal_candle.subtitle",
                    default: "Let Easter light renew your discipline.")),
            SacredImageryItem(
                id: "lenten-path",
                assetName: "SacredLentenPath",
                title: AppLocalizer.localizedCurrent("sacred.gallery.lenten_path.title", default: "Lenten Path"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.lenten_path.subtitle",
                    default: "Walk the penitential road with patience and trust.")),
            SacredImageryItem(
                id: "almsgiving-table",
                assetName: "SacredAlmsgivingTable",
                title: AppLocalizer.localizedCurrent("sacred.gallery.almsgiving.title", default: "Almsgiving"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.almsgiving.subtitle",
                    default: "Join fasting to mercy for your neighbor.")),
            SacredImageryItem(
                id: "ember-days",
                assetName: "SacredEmberDays",
                title: AppLocalizer.localizedCurrent("sacred.gallery.ember_days.title", default: "Ember Days"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.ember_days.subtitle",
                    default: "Offer seasonal gratitude through prayer and restraint.")),
            SacredImageryItem(
                id: "purple-veil",
                assetName: "SacredPurpleVeil",
                title: AppLocalizer.localizedCurrent("sacred.gallery.penitential_veil.title", default: "Penitential Veil"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.penitential_veil.subtitle",
                    default: "Let quiet restraint make room for grace.")),
            SacredImageryItem(
                id: "friday-abstinence",
                assetName: "SacredFridayAbstinence",
                title: AppLocalizer.localizedCurrent("sacred.gallery.friday_abstinence.title", default: "Friday Abstinence"),
                subtitle: AppLocalizer.localizedCurrent(
                    "sacred.gallery.friday_abstinence.subtitle",
                    default: "Keep Friday penance close to the Cross.")),
        ]
    }
}

enum SacredImageAssetResolver {
    static func hasAsset(named assetName: String) -> Bool {
        #if canImport(UIKit)
        UIImage(named: assetName) != nil
        #else
        true
        #endif
    }
}

struct SacredIdentityThumbnail: View {
    @Environment(\.colorScheme) private var colorScheme

    let assetName: String
    let statusSymbol: String
    let statusTint: Color
    var imageSize: CGFloat = 68

    var body: some View {
        let badgeSize = max(20, imageSize * 0.37)

        ZStack(alignment: .bottomTrailing) {
            Group {
                if SacredImageAssetResolver.hasAsset(named: assetName) {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        SacredEditorialTokens.raisedSurface(for: colorScheme)
                        Image(systemName: "cross.fill")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(CatholicTheme.primary)
                    }
                }
            }
            .frame(width: imageSize, height: imageSize)
            .clipShape(RoundedRectangle(cornerRadius: min(15, imageSize * 0.22), style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: min(15, imageSize * 0.22), style: .continuous)
                    .stroke(CatholicTheme.cardBorder.opacity(0.48), lineWidth: 1)
            }

            Image(systemName: statusSymbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(statusTint)
                .frame(width: badgeSize, height: badgeSize)
                .background(SacredEditorialTokens.raisedSurface(for: colorScheme), in: Circle())
                .overlay(Circle().stroke(CatholicTheme.cardBorder.opacity(0.38), lineWidth: 1))
                .offset(x: 4, y: 4)
        }
        .frame(width: imageSize + 6, height: imageSize + 6, alignment: .topLeading)
        .accessibilityHidden(true)
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
                colors: [CatholicTheme.primary.opacity(0.16), Color.clear, Color.black.opacity(0.62)],
                startPoint: .topLeading,
                endPoint: .bottom)

            VStack(alignment: .leading, spacing: 4) {
                if !title.isEmpty {
                    Text(title)
                        .font(.system(.title3, design: .serif).weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.white.opacity(0.92))
                        .lineLimit(3)
                        .minimumScaleFactor(0.9)
                }
            }
            .padding(14)
        }
        .overlay(alignment: .topTrailing) {
            if !SacredImageAssetResolver.hasAsset(named: assetName) {
                Image(systemName: fallbackSymbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .padding(8)
                    .background(Color.black.opacity(0.16), in: Circle())
                    .padding(8)
                    .accessibilityHidden(true)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(CatholicTheme.cardBorder.opacity(0.52), lineWidth: 1))
        .shadow(color: CatholicTheme.primary.opacity(0.08), radius: 12, y: 6)
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
                .accessibilityHidden(true)
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
                    Text(AppLocalizer.localizedCurrent("shared.app_title", default: "Catholic Fasting"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
            }
            .accessibilityHidden(title.isEmpty && subtitle.isEmpty)
        }
    }
}

struct SacredSurfaceAnchorCard: View {
    @Environment(\.colorScheme) private var colorScheme

    enum Presentation {
        case standalone
        case embedded
    }

    let assetName: String
    let title: String
    let subtitle: String
    var imageHeight: CGFloat = 116
    var cornerRadius: CGFloat = 16
    var presentation: Presentation = .standalone
    var accessibilityIdentifier: String?
    var fallbackSymbol: String = "cross.case.fill"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            imageLayer
                .frame(height: imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: min(cornerRadius, 14), style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: min(cornerRadius, 14), style: .continuous)
                        .stroke(CatholicTheme.cardBorder.opacity(0.38), lineWidth: 1)
                        .accessibilityHidden(true))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                if !title.isEmpty {
                    Text(title)
                        .font(.system(.title3, design: .serif).weight(.bold))
                        .foregroundStyle(CatholicTheme.ink)
                        .lineLimit(nil)
                }

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(CatholicTheme.ink)
                        .lineSpacing(1)
                        .lineLimit(nil)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                SacredEditorialTokens.raisedSurface(for: colorScheme)
                    .accessibilityHidden(true))
        }
        .padding(presentation == .standalone ? 12 : 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(SacredSurfaceAnchorChrome(presentation: presentation, cornerRadius: cornerRadius))
        .accessibilityElement(children: .contain)
        .modifier(AccessibilityIDModifier(id: accessibilityIdentifier))
    }

    @ViewBuilder
    private var imageLayer: some View {
        if SacredImageAssetResolver.hasAsset(named: assetName) {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            ZStack {
                LinearGradient(
                    colors: [CatholicTheme.accent.opacity(0.42), CatholicTheme.primary.opacity(0.62)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                Image(systemName: fallbackSymbol)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.88))
            }
        }
    }
}

private struct SacredSurfaceAnchorChrome: ViewModifier {
    let presentation: SacredSurfaceAnchorCard.Presentation
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        switch presentation {
        case .standalone:
            content
                .appSurfaceCard(.standard, cornerRadius: cornerRadius)
        case .embedded:
            content
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
    var width: CGFloat = 206
    var height: CGFloat = 238

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(item.assetName)
                .resizable()
                .scaledToFill()
                .frame(width: width - 20, height: 116)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(CatholicTheme.cardBorder.opacity(0.48), lineWidth: 1))
                .accessibilityHidden(true)

            Text(item.title)
                .appSectionTitleStyle(serif: true)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(item.subtitle)
                .appSupportingTextStyle()
                .lineLimit(3)
                .minimumScaleFactor(0.86)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(width: width, height: height, alignment: .topLeading)
        .appSurfaceCard(.utility, cornerRadius: 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title). \(item.subtitle)")
    }
}

struct CatholicFastingQuoteCard: View {
    enum Presentation {
        case card
        case inline
    }

    let quote: CatholicFastingQuote
    var compact: Bool = false
    var presentation: Presentation = .card

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
        .modifier(CatholicFastingQuotePresentationModifier(presentation: presentation))
        .accessibilityElement(children: .combine)
        .accessibilityLabel([quote.text, quote.author, quote.source].joined(separator: " "))
    }
}

private struct CatholicFastingQuotePresentationModifier: ViewModifier {
    let presentation: CatholicFastingQuoteCard.Presentation

    func body(content: Content) -> some View {
        switch presentation {
        case .card:
            content.appSurfaceCard(.utility, cornerRadius: 12)
        case .inline:
            content
        }
    }
}
