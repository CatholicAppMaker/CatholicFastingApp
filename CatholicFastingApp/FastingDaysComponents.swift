import SwiftUI

struct FastingDaysMetricSummary: View {
    let seasonLabel: String
    let observanceCountText: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                season
                Circle()
                    .fill(CatholicTheme.primary)
                    .frame(width: 3, height: 3)
                    .accessibilityHidden(true)
                Text(observanceCountText)
                    .lineLimit(nil)
            }

            VStack(alignment: .leading, spacing: 4) {
                season
                Text(observanceCountText)
                    .lineLimit(nil)
            }
        }
        .font(.footnote)
        .fontWeight(.medium)
        .foregroundStyle(CatholicTheme.primary)
    }

    private var season: some View {
        HStack(spacing: 6) {
            Image(systemName: "calendar")
                .accessibilityHidden(true)
            Text(seasonLabel)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct FastingDaysScopeControl: View {
    @Binding var selection: Int
    let title: String
    let upcomingTitle: String
    let fullYearTitle: String

    var body: some View {
        Picker(title, selection: $selection) {
            Text(upcomingTitle).tag(0)
            Text(fullYearTitle).tag(1)
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("fasting_days.scope_picker")
    }
}

struct FastingDaysNextObservanceCard: View {
    let eyebrow: String
    let title: String
    let date: String
    let systemImage: String
    let dateColor: Color
    let supportingText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: systemImage)
                    .accessibilityHidden(true)
                Text(eyebrow)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .appEyebrowStyle()
            .textCase(.uppercase)
            Text(title)
                .appSectionTitleStyle(serif: true)
            Text(date)
                .font(.headline)
                .foregroundStyle(dateColor)
            if let supportingText {
                Text(supportingText)
                    .appSupportingTextStyle()
            }
        }
        .padding(12)
        .appSurfaceCard(.utility, cornerRadius: 16)
    }
}

struct FastingDaysAgendaSections<Row: View>: View {
    let title: String
    let hint: String
    let emptyText: String
    let groups: [(String, [Observance])]
    let moreText: String?
    @ViewBuilder let row: (Observance) -> Row

    var body: some View {
        Section {
            Text(hint)
                .appSupportingTextStyle()
        } header: {
            Text(title)
        }

        if groups.isEmpty {
            Section {
                Text(emptyText)
                    .foregroundStyle(.secondary)
            }
        } else {
            ForEach(groups, id: \.0) { monthTitle, observances in
                Section(monthTitle) {
                    ForEach(observances) { observance in
                        row(observance)
                    }
                }
            }

            if let moreText {
                Section {
                    Text(moreText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct FastingDaysAgendaRow<Destination: View>: View {
    let observance: Observance
    let title: String
    let detail: String
    let date: String
    let status: CompletionStatus
    let statusLabel: String
    let statusOptionLabel: (CompletionStatus) -> String
    let setStatus: (CompletionStatus) -> Void
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            NavigationLink(destination: destination) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 3)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("fasting_days.detail.\(observance.id)")

            if observance.obligation != .notApplicable {
                Menu {
                    ForEach(CompletionStatus.allCases) { option in
                        Button(statusOptionLabel(option)) {
                            setStatus(option)
                        }
                    }
                } label: {
                    Image(systemName: statusSymbol)
                        .foregroundStyle(statusColor)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(statusLabel)
                .accessibilityValue(statusOptionLabel(status))
                .accessibilityIdentifier("fasting_days.status.\(observance.id)")
            }
        }
    }

    private var statusSymbol: String {
        switch status {
        case .notStarted: "circle"
        case .completed: "checkmark.circle.fill"
        case .substituted: "arrow.triangle.2.circlepath.circle.fill"
        case .dispensed: "cross.case.circle.fill"
        case .missed: "xmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch status {
        case .notStarted: .secondary
        case .completed: .green
        case .substituted: .blue
        case .dispensed: .indigo
        case .missed: .red
        }
    }
}
