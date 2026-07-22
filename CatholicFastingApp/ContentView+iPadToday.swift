import SwiftUI

extension ContentView {
    var ipadTodayWorkspace: some View {
        GeometryReader { geometry in
            let regionContext = RegionalGuidanceContextFactory.generalContext(for: settings)

            ScrollView {
                ipadTodayWorkspaceBody(
                    regionContext: regionContext,
                    width: geometry.size.width)
            }
        }
    }

    private func ipadTodayWorkspaceBody(
        regionContext: RegionalRuleContext,
        width: CGFloat) -> some View
    {
        VStack(alignment: .leading, spacing: 20) {
            companionIPadEditorialLayout(stacked: width < 720 || dynamicTypeSize.isAccessibilitySize)

            if width >= 840, !dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top, spacing: 20) {
                        ipadTodayPlanningCard
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        ipadTodayRecoveryCard
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    ipadTodayTrustCard(regionContext: regionContext)
                }
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    ipadTodayPlanningCard
                    ipadTodayRecoveryCard
                    ipadTodayTrustCard(regionContext: regionContext)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
}
