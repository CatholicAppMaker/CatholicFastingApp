import SwiftUI

extension ContentView {
    var ipadTodayWorkspace: some View {
        GeometryReader { geometry in
            let regionContext = RegionalGuidanceContextFactory.generalContext(for: settings)
            let compact = geometry.size.width < 1280

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    IPadWorkspaceHeroBand(
                        assetName: activeSeasonalContentPack.heroAssetNames.first ?? dashboardHeroArtwork.assetName,
                        seasonLabel: currentLiturgicalSeason.label,
                        title: activeSeasonalContentPack.campaignTitle,
                        subtitle: dailySeasonalFormationLine,
                        quote: dailySeasonalQuote,
                        regionContext: regionContext,
                        compact: compact,
                        accessibilityIdentifier: "ipad.today.hero")

                    if geometry.size.width < 1040 {
                        VStack(alignment: .leading, spacing: 20) {
                            ipadTodayPrimaryGuidanceCard
                            ipadTodayMetricsCard
                            ipadTodayQuickActionsCard
                            ipadTodayPlanningCard
                            ipadTodayRecoveryCard
                            ipadTodaySeasonCard
                            ipadTodayTrustCard(regionContext: regionContext)
                        }
                    } else {
                        HStack(alignment: .top, spacing: 20) {
                            VStack(alignment: .leading, spacing: 20) {
                                ipadTodayPrimaryGuidanceCard
                                ipadTodayMetricsCard
                                ipadTodayQuickActionsCard
                            }
                            .frame(maxWidth: .infinity, alignment: .top)

                            VStack(alignment: .leading, spacing: 20) {
                                ipadTodayPlanningCard
                                ipadTodayRecoveryCard
                                ipadTodaySeasonCard
                                ipadTodayTrustCard(regionContext: regionContext)
                            }
                            .frame(width: compact ? 320 : 360, alignment: .top)
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}
