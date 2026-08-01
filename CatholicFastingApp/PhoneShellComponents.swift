import SwiftUI

struct PhoneNavigationTab<Content: View, ToolbarItems: ToolbarContent, MoreView: View, PremiumView: View, HistoryView: View>: View {
    let title: String
    let surface: HomeSurface
    @ViewBuilder let content: Content
    @ToolbarContentBuilder let toolbar: ToolbarItems
    let more: (MoreHubDestination) -> MoreView
    let premium: (PremiumToolDestination) -> PremiumView
    let history: (FastingHistoryArticle) -> HistoryView

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
        }
        .phoneNavigationDestinations(
            more: more,
            premium: premium,
            history: history)
        .phoneTabItem(title: title, surface: surface)
    }
}

struct PhonePathNavigationTab<Content: View, ToolbarItems: ToolbarContent, MoreView: View, PremiumView: View, HistoryView: View>: View {
    let title: String
    let surface: HomeSurface
    @Binding var path: [MoreHubDestination]
    @ViewBuilder let content: Content
    @ToolbarContentBuilder let toolbar: ToolbarItems
    let more: (MoreHubDestination) -> MoreView
    let premium: (PremiumToolDestination) -> PremiumView
    let history: (FastingHistoryArticle) -> HistoryView
    let onAppear: () -> Void

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
                .onAppear(perform: onAppear)
                .phoneNavigationDestinations(
                    more: more,
                    premium: premium,
                    history: history)
        }
        .phoneTabItem(title: title, surface: surface)
    }
}

struct PhoneSeasonBadge: View {
    let localizedSeason: String
    let showsSeasonName: Bool
    let accessibilityLabel: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "cross.case.fill")
                .foregroundStyle(CatholicTheme.seasonAccent)
                .accessibilityHidden(true)
            if showsSeasonName {
                Text(localizedSeason)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(CatholicTheme.seasonAccent)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .allowsHitTesting(false)
        .accessibilityIdentifier("home.season_badge")
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel(accessibilityLabel)
        .appCapsuleGlass()
    }
}

struct PhoneBrandMark: View {
    let accessibilityLabel: String

    var body: some View {
        Image("CFAMark")
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .frame(width: 26, height: 26)
            .foregroundStyle(CatholicTheme.primary)
            .allowsHitTesting(false)
            .accessibilityIdentifier("home.brand_mark")
            .accessibilityLabel(accessibilityLabel)
    }
}

struct PhoneSurfaceList<Sections: View>: View {
    @ViewBuilder let sections: Sections

    var body: some View {
        List {
            sections
        }
        .listStyle(.plain)
        .listSectionSpacing(SacredEditorialTokens.sectionSpacing)
        .appListBackground()
        .phoneTabBarScrollClearance()
    }
}

struct PhoneDestinationSurface<Sections: View>: View {
    let title: String
    @ViewBuilder let sections: Sections

    var body: some View {
        List {
            sections
        }
        .listStyle(.plain)
        .listSectionSpacing(SacredEditorialTokens.sectionSpacing)
        .appListBackground()
        .phoneTabBarScrollClearance()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PremiumToolIntroSection: View {
    let title: String
    let subtitle: String
    let iconName: String

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: iconName)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(CatholicTheme.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
    }
}

struct MoreHubDestinationPresentation: Identifiable {
    let destination: MoreHubDestination
    let title: String
    let subtitle: String

    var id: MoreHubDestination {
        destination
    }
}

struct MoreHubSections<Notice: View>: View {
    let heroTitle: String
    let heroSubtitle: String
    let destinations: [MoreHubDestinationPresentation]
    let quote: CatholicFastingQuote
    let quoteSectionTitle: String
    @ViewBuilder let unofficialNotice: Notice
    let selectDestination: (MoreHubDestination) -> Void

    var body: some View {
        Section {
            SacredSurfaceAnchorCard(
                assetName: "GuidanceSacred",
                title: heroTitle,
                subtitle: heroSubtitle,
                imageHeight: 88,
                cornerRadius: 16,
                accessibilityIdentifier: "more.hub.hero")
        }

        Section {
            ForEach(destinations) { item in
                Button {
                    selectDestination(item.destination)
                } label: {
                    AppDestinationRowCard(
                        title: item.title,
                        subtitle: item.subtitle,
                        systemImage: item.destination.iconName,
                        showsChevron: true,
                        usesPrimarySubtitle: true)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("more.hub.\(item.destination.rawValue)")
            }
        }

        Section(quoteSectionTitle) {
            CatholicFastingQuoteCard(quote: quote, compact: true)
                .accessibilityIdentifier("more.hub.quote")
        }

        unofficialNotice
    }
}

private struct PhoneNavigationDestinationsModifier<MoreView: View, PremiumView: View, HistoryView: View>: ViewModifier {
    let more: (MoreHubDestination) -> MoreView
    let premium: (PremiumToolDestination) -> PremiumView
    let history: (FastingHistoryArticle) -> HistoryView

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: MoreHubDestination.self, destination: more)
            .navigationDestination(for: PremiumToolDestination.self, destination: premium)
            .navigationDestination(for: FastingHistoryArticle.self, destination: history)
    }
}

private extension View {
    func phoneTabItem(title: String, surface: HomeSurface) -> some View {
        tabItem {
            Label(title, systemImage: surface.iconName)
        }
        .tag(surface)
        .accessibilityIdentifier(surface.tabAccessibilityIdentifier)
    }

    func phoneNavigationDestinations(
        more: @escaping (MoreHubDestination) -> some View,
        premium: @escaping (PremiumToolDestination) -> some View,
        history: @escaping (FastingHistoryArticle) -> some View) -> some View
    {
        modifier(
            PhoneNavigationDestinationsModifier(
                more: more,
                premium: premium,
                history: history))
    }
}

private extension HomeSurface {
    var tabAccessibilityIdentifier: String {
        switch self {
        case .today:
            "tab.today"
        case .fastingDays:
            "tab.fasting_days"
        case .intermittent:
            "tab.intermittent"
        case .more:
            "tab.more"
        }
    }
}
