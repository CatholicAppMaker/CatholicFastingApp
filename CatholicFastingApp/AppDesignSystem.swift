import SwiftUI

enum SacredEditorialTokens {
    static let contentMaxWidth: CGFloat = 760
    static let compactHorizontalInset: CGFloat = 20
    static let regularHorizontalInset: CGFloat = 28
    static let sectionSpacing: CGFloat = 18
    static let hairlineOpacity = 0.16

    static func canvasTop(for colorScheme: ColorScheme) -> Color {
        CatholicTheme.parchment
    }

    static func canvasBottom(for colorScheme: ColorScheme) -> Color {
        CatholicTheme.parchmentShade.opacity(0.58)
    }

    static func raisedSurface(for colorScheme: ColorScheme) -> Color {
        Color(red: 0.995, green: 0.992, blue: 0.978)
    }

    static func quietSurface(for colorScheme: ColorScheme) -> Color {
        CatholicTheme.primary.opacity(0.045)
    }
}

struct SacredEditorialBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.background {
            LinearGradient(
                colors: [
                    SacredEditorialTokens.canvasTop(for: colorScheme),
                    SacredEditorialTokens.canvasBottom(for: colorScheme),
                ],
                startPoint: .top,
                endPoint: .bottom)
                .ignoresSafeArea()
        }
    }
}

struct SacredEditorialListBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background {
                LinearGradient(
                    colors: [
                        SacredEditorialTokens.canvasTop(for: colorScheme),
                        SacredEditorialTokens.canvasBottom(for: colorScheme),
                    ],
                    startPoint: .top,
                    endPoint: .bottom)
                    .ignoresSafeArea()
            }
    }
}

struct SacredEditorialSectionHeader: View {
    let eyebrow: String?
    let title: String
    let detail: String?

    init(eyebrow: String? = nil, title: String, detail: String? = nil) {
        self.eyebrow = eyebrow
        self.title = title
        self.detail = detail
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let eyebrow {
                Text(eyebrow)
                    .appEyebrowStyle()
                    .textCase(.uppercase)
            }
            Text(title)
                .font(.system(.title2, design: .serif).weight(.bold))
                .foregroundStyle(.primary)
            if let detail {
                Text(detail)
                    .appLeadTextStyle()
                    .frame(maxWidth: 620, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct SacredEditorialRule: View {
    var body: some View {
        Rectangle()
            .fill(CatholicTheme.primary.opacity(SacredEditorialTokens.hairlineOpacity))
            .frame(height: 1)
            .accessibilityHidden(true)
    }
}
