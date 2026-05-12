import SwiftUI

struct CatholicFastingMacRootView: View {
    @ObservedObject var model: CatholicFastingMacModel
    let openSettingsService: OpenSettingsPlatformService
    @Environment(\.openSettings) private var openSettings
    @State private var hasRunStartup = false

    var body: some View {
        NavigationSplitView {
            List(CatholicFastingMacSurface.allCases, id: \.self, selection: $model.selectedSurface) { surface in
                CatholicFastingMacSidebarRow(
                    surface: surface,
                    isSelected: model.selectedSurface == surface)
                    .tag(surface)
                    .accessibilityIdentifier("mac.sidebar.\(surface.rawValue)")
            }
            .navigationTitle("Catholic Fasting")
            .listStyle(.sidebar)
            .accessibilityIdentifier("mac.sidebar")
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("mac.root.ready")
        .onAppear {
            MacApplicationActivationCoordinator.activateApp()
        }
        .task {
            guard !hasRunStartup else { return }
            hasRunStartup = true
            MacApplicationActivationCoordinator.activateApp()
            openSettingsService.setAction {
                openSettings()
            }
            await model.performInitialStartupTasks()
            MacApplicationActivationCoordinator.stabilizeLaunchActivationIfNeeded()
        }
        .onOpenURL { url in
            guard let target = AppDeepLinkTarget.parse(url: url) else { return }
            model.handleDeepLink(target)
        }
        .sheet(isPresented: onboardingBinding) {
            CatholicFastingMacOnboardingView(model: model)
        }
        .toolbar {
            ToolbarItem {
                Text(CatholicTheme.seasonToolbarLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CatholicTheme.primary)
            }
            ToolbarItem {
                SettingsLink {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch model.selectedSurface {
        case .today:
            CatholicFastingMacTodayView(model: model)
        case .calendar:
            CatholicFastingMacCalendarView(model: model)
        case .intermittent:
            CatholicFastingMacIntermittentView(model: model)
        case .premium:
            CatholicFastingMacPremiumView(model: model)
        case .guidance:
            CatholicFastingMacGuidanceView(model: model)
        }
    }

    private var onboardingBinding: Binding<Bool> {
        Binding(
            get: { !model.didCompleteOnboarding },
            set: { _ in })
    }
}

private struct CatholicFastingMacSidebarRow: View {
    let surface: CatholicFastingMacSurface
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: surface.systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(surface.title)
                    .lineLimit(1)
                Text(surface.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(surface.title)
        .accessibilityHint(surface.subtitle)
        .macSelectedAccessibility(isSelected)
    }
}
