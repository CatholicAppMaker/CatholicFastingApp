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
        .padding(.horizontal, 28)
        .padding(.top, 12)
        .padding(.bottom, 28)
    }
}
