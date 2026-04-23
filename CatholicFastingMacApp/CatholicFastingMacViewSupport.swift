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
            .padding(24)
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
