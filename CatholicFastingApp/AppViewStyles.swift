import SwiftUI

extension View {
    func appPrimaryButtonStyle(legacyTint: Color = CatholicTheme.primary) -> some View {
        tint(legacyTint)
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .frame(minHeight: 44)
    }

    func appSecondaryButtonStyle(legacyTint: Color = CatholicTheme.primary) -> some View {
        tint(legacyTint)
            .buttonStyle(.glass)
            .controlSize(.large)
            .frame(minHeight: 44)
    }

    func appRootBackground() -> some View {
        background(CatholicTheme.background)
    }

    func appListBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(CatholicTheme.background)
    }

    func appRoundedGlass(cornerRadius: CGFloat) -> some View {
        glassEffect(.regular, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    func appCapsuleGlass() -> some View {
        glassEffect(.regular, in: Capsule())
    }

    func appSurfaceCard(_ style: AppSurfaceCardStyle = .standard, cornerRadius: CGFloat = 18) -> some View {
        modifier(AppSurfaceCardModifier(style: style, cornerRadius: cornerRadius))
    }

    func appEyebrowStyle() -> some View {
        font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    func appSectionTitleStyle(serif: Bool = false) -> some View {
        font(serif ? .system(.title3, design: .serif).weight(.bold) : .system(.title3, design: .rounded).weight(.bold))
            .foregroundStyle(CatholicTheme.primary)
    }

    func appDisplayTitleStyle(serif: Bool = false) -> some View {
        font(serif ? .system(.title2, design: .serif).weight(.bold) : .system(.title2, design: .rounded).weight(.bold))
            .foregroundStyle(CatholicTheme.primary)
    }

    func appLeadTextStyle() -> some View {
        font(.subheadline)
            .foregroundStyle(.secondary)
    }

    func appSupportingTextStyle() -> some View {
        font(.footnote)
            .foregroundStyle(.secondary)
    }

    func appMetricValueStyle() -> some View {
        font(.system(.title3, design: .rounded).weight(.bold))
            .foregroundStyle(CatholicTheme.primary)
    }

    func appInteractiveTileStyle(
        isSelected: Bool = false,
        cornerRadius: CGFloat = 16,
        selectedTint: Color = CatholicTheme.primary) -> some View
    {
        modifier(
            AppInteractiveTileModifier(
                isSelected: isSelected,
                cornerRadius: cornerRadius,
                selectedTint: selectedTint))
    }

    func appSymbolStyle(_ role: AppSymbolRole = .standard) -> some View {
        modifier(AppSymbolModifier(role: role))
    }
}

enum AppSymbolRole {
    case prominent
    case standard
    case subtle

    var font: Font {
        switch self {
        case .prominent:
            .system(size: 18, weight: .semibold)
        case .standard:
            .system(size: 15, weight: .semibold)
        case .subtle:
            .system(size: 13, weight: .medium)
        }
    }

    var color: Color {
        switch self {
        case .prominent, .standard:
            CatholicTheme.primary
        case .subtle:
            .secondary
        }
    }
}

private struct AppSymbolModifier: ViewModifier {
    let role: AppSymbolRole

    func body(content: Content) -> some View {
        content
            .font(role.font)
            .foregroundStyle(role.color)
    }
}

private struct AppInteractiveTileModifier: ViewModifier {
    let isSelected: Bool
    let cornerRadius: CGFloat
    let selectedTint: Color

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isSelected ? selectedTint.opacity(0.12) : CatholicTheme.parchment.opacity(0.88))
                    .allowsHitTesting(false))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isSelected ? selectedTint : CatholicTheme.cardBorder.opacity(0.35), lineWidth: 1)
                    .allowsHitTesting(false))
            .shadow(color: isSelected ? selectedTint.opacity(0.10) : .clear, radius: 10, y: 4)
    }
}

enum AppSurfaceCardStyle {
    case primary
    case standard
    case utility

    var fillOpacity: Double {
        switch self {
        case .primary: 0.96
        case .standard: 0.92
        case .utility: 0.88
        }
    }

    var tintOpacity: Double {
        switch self {
        case .primary: 0.16
        case .standard: 0.08
        case .utility: 0.04
        }
    }

    var strokeOpacity: Double {
        switch self {
        case .primary: 0.62
        case .standard: 0.46
        case .utility: 0.36
        }
    }
}

struct AppSurfaceCardModifier: ViewModifier {
    let style: AppSurfaceCardStyle
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(CatholicTheme.parchment.opacity(style.fillOpacity))
                    .allowsHitTesting(false))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(CatholicTheme.accent.opacity(style.tintOpacity))
                    .allowsHitTesting(false))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(CatholicTheme.cardBorder.opacity(style.strokeOpacity), lineWidth: 1)
                    .allowsHitTesting(false))
            .shadow(color: CatholicTheme.primary.opacity(style == .primary ? 0.08 : 0.04), radius: style == .primary ? 18 : 10, y: style == .primary ? 10 : 5)
    }
}
