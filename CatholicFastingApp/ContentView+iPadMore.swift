import SwiftUI

extension ContentView {
    var ipadMoreWorkspace: some View {
        GeometryReader { geometry in
            let stacked = geometry.size.width < 980

            ScrollView {
                Group {
                    if stacked {
                        VStack(alignment: .leading, spacing: 20) {
                            ipadMoreDestinationRail
                            if let destination = selectedMoreDestination ?? MoreHubDestination.allCases.first {
                                if destination == .supportAndPremium {
                                    ipadPremiumWorkspace
                                } else {
                                    ipadMoreDestinationDetail(for: destination)
                                }
                            }
                        }
                    } else {
                        HStack(alignment: .top, spacing: 20) {
                            ipadMoreDestinationRail
                                .frame(width: 280)

                            Group {
                                if let destination = selectedMoreDestination ?? MoreHubDestination.allCases.first {
                                    if destination == .supportAndPremium {
                                        ipadPremiumWorkspace
                                    } else {
                                        ipadMoreDestinationDetail(for: destination)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .top)
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}
