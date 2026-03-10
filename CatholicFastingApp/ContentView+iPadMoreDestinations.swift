import SwiftUI

extension ContentView {
    var ipadMoreDestinationGroups: [(String, [MoreHubDestination])] {
        [
            ("Core", [.supportAndPremium, .setupAndReminders, .profileAndNorms]),
            ("Guidance", [.guidanceAndRules, .privacyAndData]),
        ]
    }

    var ipadMoreDestinationRail: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                IPadWorkspaceHeader(
                    eyebrow: "More",
                    title: "Tools and settings",
                    detail: "Each destination opens as its own large-screen workspace instead of one long phone-style settings list."
                )
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
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(selectedMoreDestination == destination ? CatholicTheme.primary.opacity(0.12) : CatholicTheme.parchment.opacity(0.85))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(selectedMoreDestination == destination ? CatholicTheme.primary : CatholicTheme.cardBorder.opacity(0.35), lineWidth: 1)
                                )
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
        VStack(alignment: .leading, spacing: 18) {
            IPadWorkspaceHeader(
                eyebrow: "Workspace",
                title: destination.title,
                detail: destination.subtitle
            )
            moreDestinationList(for: destination)
                .appListBackground()
        }
        .padding(18)
        .iPadPaneCard()
    }
}
