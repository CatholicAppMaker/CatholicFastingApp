import SwiftUI

struct MacSurfaceContainer<Content: View>: View {
    let title: String
    let subtitle: String
    let accessibilityID: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.largeTitle.weight(.semibold))
                        .accessibilityIdentifier(accessibilityID)
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                content
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
    }
}

struct MacCard<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder var content: Content

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if !title.isEmpty || subtitle != nil {
                    VStack(alignment: .leading, spacing: 4) {
                        if !title.isEmpty {
                            Text(title)
                                .font(.headline)
                        }
                        if let subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct MacAdaptiveColumns<Leading: View, Trailing: View>: View {
    let spacing: CGFloat
    let leadingMinWidth: CGFloat
    let leadingIdealWidth: CGFloat
    let leadingMaxWidth: CGFloat
    @ViewBuilder var leading: Leading
    @ViewBuilder var trailing: Trailing

    init(
        spacing: CGFloat = 16,
        leadingMinWidth: CGFloat = 280,
        leadingIdealWidth: CGFloat = 340,
        leadingMaxWidth: CGFloat = 420,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing)
    {
        self.spacing = spacing
        self.leadingMinWidth = leadingMinWidth
        self.leadingIdealWidth = leadingIdealWidth
        self.leadingMaxWidth = leadingMaxWidth
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: spacing) {
                leading
                    .frame(
                        minWidth: leadingMinWidth,
                        idealWidth: leadingIdealWidth,
                        maxWidth: leadingMaxWidth)
                trailing
                    .frame(minWidth: 320, maxWidth: .infinity, alignment: .topLeading)
            }

            VStack(alignment: .leading, spacing: spacing) {
                leading
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                trailing
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }
}

extension String {
    func macMenuBarLabel(maxCharacters: Int = 30) -> String {
        guard count > maxCharacters else { return self }
        let end = index(startIndex, offsetBy: maxCharacters - 1)
        return "\(self[..<end])…"
    }
}

extension View {
    @ViewBuilder
    func macSelectedAccessibility(_ isSelected: Bool, includeValue: Bool = true) -> some View {
        if isSelected, includeValue {
            accessibilityAddTraits(.isSelected)
                .accessibilityValue("Selected")
        } else if isSelected {
            accessibilityAddTraits(.isSelected)
        } else {
            self
        }
    }
}
