import SwiftUI

struct CatholicFastingMacRootView: View {
    @ObservedObject var model: CatholicFastingMacModel
    @State private var hasRunStartup = false

    var body: some View {
        NavigationSplitView {
            List(CatholicFastingMacSurface.allCases, id: \.self) { surface in
                Button {
                    model.selectedSurface = surface
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Label(surface.title, systemImage: surface.systemImage)
                        Text(surface.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)
                    .background(surface == model.selectedSurface ? CatholicTheme.primary.opacity(0.12) : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
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
        .task {
            guard !hasRunStartup else { return }
            hasRunStartup = true
            await model.performInitialStartupTasks()
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
