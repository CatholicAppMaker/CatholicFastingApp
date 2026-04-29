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
    static let fastingGallery: [SacredImageryItem] = [
        SacredImageryItem(id: "chi-rho", assetName: "SacredChiRho", title: "Chi-Rho", subtitle: "Offer each fast in Christ."),
        SacredImageryItem(id: "monstrance", assetName: "SacredMonstrance", title: "Monstrance", subtitle: "Let prayer anchor discipline."),
        SacredImageryItem(id: "sacred-heart", assetName: "SacredSacredHeart", title: "Sacred Heart", subtitle: "Unite fasting to charity."),
        SacredImageryItem(id: "rosary-cross", assetName: "SacredRosaryCross", title: "Rosary Cross", subtitle: "Pray while you abstain."),
        SacredImageryItem(id: "cathedral-light", assetName: "SacredCathedralLight", title: "Cathedral Light", subtitle: "Remember the liturgy while you fast."),
        SacredImageryItem(id: "ash-wednesday", assetName: "SacredAshWednesday", title: "Ash Cross", subtitle: "Repentance remains the core of fasting."),
        SacredImageryItem(id: "desert-pilgrimage", assetName: "SacredDesertPilgrimage", title: "Desert Pilgrimage", subtitle: "Keep your sacrifice steady over time."),
        SacredImageryItem(id: "prayer-journal", assetName: "SacredScriptureCandle", title: "Prayer Journal", subtitle: "Keep discipline joined to reflection and prayer."),
        SacredImageryItem(id: "palm-sunday", assetName: "SacredPalmSunday", title: "Palm Branch", subtitle: "Prepare your heart for Holy Week."),
        SacredImageryItem(id: "chalice-vine", assetName: "SacredChaliceVine", title: "Chalice and Vine", subtitle: "Offer fasting in a Eucharistic spirit."),
        SacredImageryItem(id: "chapel-altar", assetName: "HeroSacred", title: "Chapel Altar", subtitle: "Keep your fasting quiet, prayerful, and rooted in worship."),
        SacredImageryItem(id: "pastoral-guidance", assetName: "GuidanceSacred", title: "Pastoral Guidance", subtitle: "Apply fasting guidance with clarity, prudence, and peace."),
        SacredImageryItem(id: "jerusalem-cross", assetName: "SacredJerusalemCross", title: "Jerusalem Cross", subtitle: "Let your sacrifice witness to the Gospel."),
        SacredImageryItem(id: "marian-monogram", assetName: "SacredMarianMonogram", title: "Marian Monogram", subtitle: "Fast with humility and trust in Mary's example."),
    ]
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
        }
    }
}

struct SacredSurfaceAnchorCard: View {
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
                        .stroke(CatholicTheme.cardBorder.opacity(0.38), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                if !title.isEmpty {
                    Text(title)
                        .appSectionTitleStyle(serif: true)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                }

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .appSupportingTextStyle()
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(presentation == .standalone ? 12 : 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .modifier(SacredSurfaceAnchorChrome(presentation: presentation, cornerRadius: cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
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
    var width: CGFloat = 168
    var height: CGFloat = 176

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(CatholicTheme.parchment.opacity(0.92))
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
