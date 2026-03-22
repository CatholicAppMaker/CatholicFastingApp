import SwiftUI

extension ContentView {
    var ipadMoreDestinationGroups: [(String, [MoreHubDestination])] {
        [
            ("Core", [.supportAndPremium, .setupAndReminders, .profileAndNorms]),
            ("Guidance", [.guidanceAndRules, .privacyAndData]),
        ]
    }

    var ipadMoreCompactSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose a workspace")
                .appEyebrowStyle()
                .textCase(.uppercase)

            ForEach(ipadMoreDestinationGroups, id: \.0) { groupTitle, destinations in
                VStack(alignment: .leading, spacing: 8) {
                    Text(groupTitle.uppercased())
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach(destinations) { destination in
                        Button {
                            selectedMoreDestination = destination
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: destination.iconName)
                                    .appSymbolStyle(.standard)
                                    .frame(width: 18)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(destination.title)
                                        .font(.headline.weight(.semibold))
                                    Text(destination.subtitle)
                                        .appSupportingTextStyle()
                                        .foregroundStyle(selectedMoreDestination == destination ? Color.white.opacity(0.85) : .secondary)
                                        .lineLimit(1)
                                }
                                Spacer(minLength: 0)
                            }
                            .foregroundStyle(selectedMoreDestination == destination ? .white : CatholicTheme.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appInteractiveTileStyle(
                                isSelected: selectedMoreDestination == destination,
                                cornerRadius: 18
                            )
                            .background(
                                Group {
                                    if selectedMoreDestination == destination {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(CatholicTheme.primary)
                                            .allowsHitTesting(false)
                                    }
                                }
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("ipad.more.compact.\(destination.rawValue)")
                    }
                }
            }
        }
        .padding(18)
        .iPadPaneCard()
    }

    var ipadMoreDestinationRail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(ipadMoreDestinationGroups, id: \.0) { groupTitle, destinations in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(groupTitle.uppercased())
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        ForEach(destinations) { destination in
                            Button {
                                selectedMoreDestination = destination
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Label(destination.title, systemImage: destination.iconName)
                                        .font(.headline)
                                        .foregroundStyle(selectedMoreDestination == destination ? CatholicTheme.primary : .primary)
                                    Text(destination.subtitle)
                                        .appSupportingTextStyle()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .appInteractiveTileStyle(isSelected: selectedMoreDestination == destination)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("ipad.more.destination.\(destination.rawValue)")
                        }
                    }
                }
                .padding(18)
                .iPadPaneCard()
            }
        }
    }

    func ipadMoreDestinationDetail(for destination: MoreHubDestination) -> some View {
        moreDestinationList(for: destination)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .appListBackground()
            .padding(18)
            .iPadPaneCard()
    }
}
