import SwiftUI

extension ContentView {
    var ipadIntermittentWorkspace: some View {
        GeometryReader { geometry in
            let compact = geometry.size.width < 1360
            let stacked = geometry.size.width < 1180 || dynamicTypeSize.isAccessibilitySize
            let activeFast = intermittentTracker.activeStart != nil

            ScrollView {
                Group {
                    if stacked {
                        VStack(alignment: .leading, spacing: 20) {
                            if !activeFast {
                                ipadIntermittentHeroBand(compact: true)
                            }
                            ipadIntermittentLiveControlCenter
                            ipadIntermittentQuickPlansCard
                            ipadIntermittentPlanningCard
                            if activeFast {
                                ipadIntermittentHeroBand(compact: true)
                            }
                            ipadIntermittentAdvancedToolsCard
                            ipadIntermittentHistoryCard
                        }
                    } else {
                        HStack(alignment: .top, spacing: 20) {
                            VStack(alignment: .leading, spacing: 20) {
                                if !activeFast {
                                    ipadIntermittentHeroBand(compact: compact)
                                }
                                ipadIntermittentLiveControlCenter
                                ipadIntermittentQuickPlansCard
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .top)

                            VStack(alignment: .leading, spacing: 20) {
                                if activeFast {
                                    ipadIntermittentHeroBand(compact: true)
                                }
                                ipadIntermittentPlanningCard
                                ipadIntermittentAdvancedToolsCard
                                ipadIntermittentHistoryCard
                            }
                            .frame(
                                minWidth: compact ? 320 : 360,
                                idealWidth: compact ? 360 : 430,
                                maxWidth: compact ? 400 : 470,
                                alignment: .top)
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}
