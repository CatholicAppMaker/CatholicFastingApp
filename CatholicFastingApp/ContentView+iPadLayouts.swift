import SwiftUI

extension HomeSurface {
    var ipadLayout: IPadWorkspaceLayout {
        switch self {
        case .today:
            .dashboard
        case .fastingDays:
            .planningTriptych
        case .intermittent:
            .controlCenter
        case .more:
            .settingsDetail
        }
    }

    var ipadSubtitle: String {
        switch self {
        case .today:
            AppLocalizer.localizedCurrent(
                "ipad.sidebar.today.subtitle",
                default: "See the day, the next obligation, and your recovery path at a glance.")
        case .fastingDays:
            AppLocalizer.localizedCurrent(
                "ipad.sidebar.fasting_days.subtitle",
                default: "Plan by season, month, and observance without leaving the workspace.")
        case .intermittent:
            AppLocalizer.localizedCurrent(
                "ipad.sidebar.intermittent.subtitle",
                default: "Keep the active fast, schedule, and recent history visible together.")
        case .more:
            AppLocalizer.localizedCurrent(
                "ipad.sidebar.more.subtitle",
                default: "Open focused tools and settings without one long phone-style list.")
        }
    }
}

extension ContentView {
    var ipadRootScaffold: some View {
        NavigationSplitView {
            List {
                Section(AppLocalizer.localizedCurrent("shared.app_title", default: "Catholic Fasting")) {
                    ForEach(HomeSurface.primarySurfaces) { surface in
                        Button {
                            homeSurface = surface
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Label(localizedHomeSurfaceLabel(surface), systemImage: surface.iconName)
                                    .font(.headline)
                                    .foregroundStyle(homeSurface == surface ? CatholicTheme.primary : .primary)
                                Text(surface.ipadSubtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("ipad.sidebar.\(surface.rawValue)")
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle(AppLocalizer.localizedCurrent("shared.app_title", default: "Catholic Fasting"))
            .navigationSplitViewColumnWidth(min: 260, ideal: 290, max: 320)
            .appListBackground()
        } detail: {
            NavigationStack {
                ipadSurfaceWorkspace(for: homeSurface)
            }
            .id(homeSurface)
        }
        .navigationSplitViewStyle(.balanced)
        .tint(CatholicTheme.primary)
    }

    func ipadSurfaceWorkspace(for surface: HomeSurface) -> some View {
        ZStack(alignment: .topLeading) {
            switch surface {
            case .today:
                ipadTodayWorkspace.accessibilityIdentifier("ipad.today.workspace")
            case .fastingDays:
                ipadFastingDaysWorkspace.accessibilityIdentifier("ipad.fasting_days.workspace")
            case .intermittent:
                ipadIntermittentWorkspace.accessibilityIdentifier("ipad.intermittent.workspace")
            case .more:
                ipadMoreWorkspace.accessibilityIdentifier("ipad.more.workspace")
            }

            readinessMarkers
        }
        .appRootBackground()
        .navigationTitle(localizedHomeSurfaceLabel(surface))
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                seasonBadge
            }
        }
    }

    var fastingDaysDisplayObservances: [Observance] {
        var visibleKinds: Set<Observance.Kind> = [.fastAndAbstinence, .abstinence, .fridayPenance, .optionalEmber]
        if fastingDaysIncludeFeastAndHolyDays {
            visibleKinds.formUnion([.holyDay, .feastDay, .memorialDay])
        }
        let source = fastingDaysShowAllYearDays
            ? ObservanceCalculator.makeCalendar(for: year, settings: settings)
            : rollingUpcomingObservances
        let candidates = source.filter { visibleKinds.contains($0.kind) }
        let filtered = candidates.filter { observance in
            switch observance.kind {
            case .holyDay, .feastDay, .memorialDay:
                fastingDaysIncludeFeastAndHolyDays
            case .optionalEmber, .fridayPenance:
                fastingDaysIncludeOptionalDays ? observance.obligation != .notApplicable : observance.obligation == .mandatory
            case .fastAndAbstinence, .abstinence:
                fastingDaysIncludeOptionalDays ? observance.obligation != .notApplicable : observance.obligation == .mandatory
            }
        }
        let sorted = filtered.sorted { lhs, rhs in
            if lhs.date == rhs.date { return lhs.id < rhs.id }
            return lhs.date < rhs.date
        }
        return fastingDaysShowAllYearDays ? sorted : Array(sorted.prefix(36))
    }

    func selectedFastingObservance(from items: [Observance]) -> Observance? {
        if let selected = items.first(where: { $0.id == selectedFastingObservanceID }) {
            return selected
        }
        return items.first
    }

    func selectDefaultFastingObservance(from items: [Observance]) {
        guard !items.isEmpty else {
            selectedFastingObservanceID = ""
            return
        }
        guard !items.contains(where: { $0.id == selectedFastingObservanceID }) else { return }
        selectedFastingObservanceID = items[0].id
    }

    var regionSpecificGuidanceFooter: String {
        RegionalGuidanceContextFactory.generalContext(for: settings).disclosureText
    }
}
