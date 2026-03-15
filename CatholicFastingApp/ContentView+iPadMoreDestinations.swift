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
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
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
                                    .font(.subheadline.weight(.semibold))
                                    .frame(width: 18)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(destination.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text(destination.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(selectedMoreDestination == destination ? Color.white.opacity(0.85) : .secondary)
                                        .lineLimit(1)
                                }
                                Spacer(minLength: 0)
                            }
                            .foregroundStyle(selectedMoreDestination == destination ? .white : CatholicTheme.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(selectedMoreDestination == destination ? CatholicTheme.primary : CatholicTheme.parchment.opacity(0.92))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(selectedMoreDestination == destination ? CatholicTheme.primary : CatholicTheme.cardBorder.opacity(0.35), lineWidth: 1)
                            )
                            .shadow(color: selectedMoreDestination == destination ? CatholicTheme.primary.opacity(0.10) : .clear, radius: 10, y: 4)
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
        moreDestinationList(for: destination)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .appListBackground()
            .padding(18)
            .iPadPaneCard()
    }
}
