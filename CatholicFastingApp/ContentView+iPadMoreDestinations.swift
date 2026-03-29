import SwiftUI

extension ContentView {
    var ipadMoreDestinationGroups: [(String, [MoreHubDestination])] {
        [
            (localized("more.workspace.group.core", default: "Core"), [.supportAndPremium, .setupAndReminders, .profileAndNorms]),
            (localized("more.workspace.group.guidance", default: "Guidance"), [.guidanceAndRules, .privacyAndData]),
        ]
    }

    var ipadMoreCompactSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localized("more.workspace.choose", default: "Choose a workspace"))
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
                            AppDestinationRowCard(
                                title: localizedMoreDestinationTitle(destination),
                                subtitle: localizedMoreDestinationSubtitle(destination),
                                systemImage: destination.iconName,
                                isSelected: selectedMoreDestination == destination)
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
                                AppDestinationRowCard(
                                    title: localizedMoreDestinationTitle(destination),
                                    subtitle: localizedMoreDestinationSubtitle(destination),
                                    systemImage: destination.iconName,
                                    isSelected: selectedMoreDestination == destination)
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
