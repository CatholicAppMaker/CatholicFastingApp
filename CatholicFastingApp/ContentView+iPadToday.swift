import SwiftUI

extension ContentView {
    var ipadTodayWorkspace: some View {
        GeometryReader { geometry in
            let regionContext = RegionalGuidanceContextFactory.generalContext(for: settings)
            let compact = geometry.size.width < 1280

            ScrollView {
                ipadTodayWorkspaceBody(
                    regionContext: regionContext,
                    width: geometry.size.width,
                    compact: compact)
            }
        }
    }

    private func ipadTodayWorkspaceBody(
        regionContext: RegionalRuleContext,
        width: CGFloat,
        compact: Bool) -> some View
    {
        VStack(alignment: .leading, spacing: 20) {
            uiTestMarker("ipad.today.hero")
            uiTestMarker("ipad.today.primary_card")
            uiTestMarker("ipad.today.metrics")
            uiTestMarker("ipad.today.actions")
            companionIPadEditorialLayout(stacked: width < 960 || dynamicTypeSize.isAccessibilitySize)

            if width < 1040 {
                VStack(alignment: .leading, spacing: 20) {
                    ipadTodayPlanningCard
                    ipadTodayRecoveryCard
                    ipadTodayTrustCard(regionContext: regionContext)
                }
            } else {
                HStack(alignment: .top, spacing: 24) {
                    ipadTodayPlanningCard
                    ipadTodayRecoveryCard
                    ipadTodayTrustCard(regionContext: regionContext)
                }
            }
        }
        .padding(28)
    }

    private func ipadTodayHeroBand(regionContext: RegionalRuleContext, compact: Bool) -> some View {
        IPadWorkspaceHeroBand(
            assetName: dashboardHeroArtwork.assetName,
            seasonLabel: localizedSeasonLabel(currentLiturgicalSeason),
            seasonContextLabel: localizedFormat("ipad.hero.season_label", default: "Liturgical Season: %@", localizedSeasonLabel(currentLiturgicalSeason)),
            title: activeSeasonalContentPack.campaignTitle,
            subtitle: dailySeasonalFormationLine,
            quote: dailySeasonalQuote,
            regionContext: regionContext,
            compact: compact,
            accessibilityIdentifier: "ipad.today.hero")
    }

    @ViewBuilder
    private func ipadTodayWorkspaceColumns(
        regionContext: RegionalRuleContext,
        width: CGFloat,
        compact: Bool) -> some View
    {
        if width < 1040 {
            ipadTodayCompactColumn(regionContext: regionContext)
        } else {
            HStack(alignment: .top, spacing: 20) {
                ipadTodayPrimaryColumn
                    .frame(maxWidth: .infinity, alignment: .top)

                ipadTodaySupportColumn(regionContext: regionContext)
                    .frame(width: compact ? 320 : 360, alignment: .top)
            }
        }
    }

    private func ipadTodayCompactColumn(regionContext: RegionalRuleContext) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ipadTodayPrimaryGuidanceCard
            ipadTodayMetricsCard
            ipadTodayQuickActionsCard
            ipadTodayPlanningCard
            ipadTodayRecoveryCard
            ipadTodaySeasonCard
            ipadTodayTrustCard(regionContext: regionContext)
        }
    }

    private var ipadTodayPrimaryColumn: some View {
        VStack(alignment: .leading, spacing: 20) {
            ipadTodayPrimaryGuidanceCard
            ipadTodayMetricsCard
            ipadTodayQuickActionsCard
        }
    }

    private func ipadTodaySupportColumn(regionContext: RegionalRuleContext) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            ipadTodayPlanningCard
            ipadTodayRecoveryCard
            ipadTodaySeasonCard
            ipadTodayTrustCard(regionContext: regionContext)
        }
    }
}
