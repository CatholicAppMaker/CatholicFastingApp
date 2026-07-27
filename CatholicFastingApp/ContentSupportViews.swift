import SwiftUI

struct ObservanceRowView: View {
    let observance: Observance
    let status: CompletionStatus
    let noteBinding: Binding<String>
    let onToggleCompletion: () -> Void
    let onSetStatus: (CompletionStatus) -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(ObservanceTitleLocalizer.localizedCurrent(observance.title))
                    .font(.headline)

                Text(observance.date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted).locale(AppLocalizer.currentLocale())))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    StatusTag(
                        text: ObservancePresentationLocalizer.currentKindLabel(observance.kind),
                        color: observance.kind.color)
                    StatusTag(
                        text: ObservancePresentationLocalizer.currentDispositionLabel(observance),
                        color: obligationColor)
                }

                if let detail = ObservanceContentLocalizer.localizedCurrentDetail(observance.detail) {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(
                    AppLocalizer.localizedCurrentFormat(
                        "observance.why_format",
                        default: "Why: %@",
                        ObservanceContentLocalizer.localizedCurrentRationale(observance)))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !observance.citations.isEmpty {
                    Text(citationSummary)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if observance.kind == .fridayPenance, observance.obligation != .notApplicable {
                    TextField(
                        AppLocalizer.localizedCurrent(
                            "friday_notes.prompt",
                            default: "What penance did you do?"),
                        text: noteBinding)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
            }

            Spacer()

            if observance.obligation == .notApplicable {
                Image(systemName: "minus.circle")
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            } else {
                Menu {
                    ForEach(CompletionStatus.allCases) { statusOption in
                        Button(ObservancePresentationLocalizer.currentCompletionLabel(statusOption)) {
                            onSetStatus(statusOption)
                        }
                    }
                } label: {
                    Image(systemName: statusIcon)
                        .imageScale(.large)
                        .foregroundStyle(statusColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    AppLocalizer.localizedCurrentFormat(
                        "observance.set_status_format",
                        default: "Set status %@",
                        ObservancePresentationLocalizer.currentCompletionLabel(status)))
                .contextMenu {
                    Button(AppLocalizer.localizedCurrent("observance.toggle_complete", default: "Toggle Complete"), action: onToggleCompletion)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
        .background(CatholicTheme.parchment.opacity(0.92), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(rowTint.opacity(0.12)))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rowBorderColor, lineWidth: 1))
    }

    private var statusIcon: String {
        switch status {
        case .notStarted:
            "circle"
        case .completed:
            "checkmark.circle.fill"
        case .substituted:
            "arrow.triangle.2.circlepath.circle.fill"
        case .dispensed:
            "cross.case.circle.fill"
        case .missed:
            "xmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch status {
        case .notStarted:
            .secondary
        case .completed:
            .green
        case .substituted:
            .blue
        case .dispensed:
            .indigo
        case .missed:
            .red
        }
    }

    private var citationSummary: String {
        observance.citations
            .map { "\($0.authority.rawValue): \($0.shortReference)" }
            .joined(separator: " • ")
    }

    private var obligationColor: Color {
        switch observance.obligation {
        case .mandatory:
            .red
        case .optional:
            .blue
        case .notApplicable:
            .gray
        }
    }

    private var rowTint: Color {
        switch observance.obligation {
        case .mandatory:
            .red
        case .optional:
            .blue
        case .notApplicable:
            .gray
        }
    }

    private var rowBorderColor: Color {
        switch observance.obligation {
        case .mandatory:
            Color.red.opacity(0.35)
        case .optional:
            Color.blue.opacity(0.35)
        case .notApplicable:
            CatholicTheme.cardBorder.opacity(0.4)
        }
    }
}

struct StatusTag: View {
    let text: String
    let color: Color
    var font: Font = .caption

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(.primary)
            .lineLimit(nil)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(CatholicTheme.parchment.opacity(0.88))
                    .accessibilityHidden(true))
            .overlay(
                Capsule()
                    .fill(color.opacity(0.16))
                    .accessibilityHidden(true))
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.55), lineWidth: 0.8)
                    .accessibilityHidden(true))
            .accessibilityRepresentation {
                // Keep the visible editorial tag while exposing a native semantic
                // text node whose font follows every Dynamic Type category.
                Text(text)
                    .font(.body)
            }
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    var detail: String?
    var accent: Color?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .appEyebrowStyle()
                .textCase(.uppercase)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(accent ?? tileTint)
            if let detail {
                Text(detail)
                    .appSupportingTextStyle()
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, detail == nil ? 10 : 12)
        .appSurfaceCard(.utility, cornerRadius: 14)
    }

    private var tileTint: Color {
        switch title {
        case "Required":
            .red
        case "Done":
            .green
        case "Streak":
            CatholicTheme.accentForeground
        default:
            CatholicTheme.primary
        }
    }
}

struct AppSectionLeadCard: View {
    let eyebrow: String
    let title: String
    let detail: String
    var serifTitle: Bool = false
    var style: AppSurfaceCardStyle = .utility

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(eyebrow)
                .appEyebrowStyle()
                .textCase(.uppercase)
            Text(title)
                .appSectionTitleStyle(serif: serifTitle)
            Text(detail)
                .appLeadTextStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .appSurfaceCard(style, cornerRadius: 16)
    }
}

struct AppDestinationRowCard: View {
    let title: String
    let subtitle: String
    let systemImage: String
    var isSelected: Bool = false
    var selectedTint: Color = CatholicTheme.primary
    var showsChevron: Bool = true
    var usesPrimarySubtitle = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : selectedTint)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.18) : selectedTint.opacity(0.10))
                        .allowsHitTesting(false)
                        .accessibilityHidden(true))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(
                        isSelected
                            ? Color.white
                            : usesPrimarySubtitle ? Color.primary : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isSelected ? Color.white : CatholicTheme.primary)
                    .padding(.top, 4)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(isSelected ? selectedTint : Color.clear)
                .allowsHitTesting(false)
                .accessibilityHidden(true))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isSelected ? Color.white.opacity(0.16) : Color.clear, lineWidth: 1)
                .allowsHitTesting(false)
                .accessibilityHidden(true))
        .accessibilityElement(children: .combine)
        .appSelectedAccessibility(isSelected)
    }
}

struct FridayNotesHistoryView: View {
    @ObservedObject var notesStore: FridayPenanceNotes
    @State private var searchText = ""

    private var allRecords: [FridayPenanceRecord] {
        notesStore.records()
    }

    private var filteredRecords: [FridayPenanceRecord] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return allRecords
        }

        let query = searchText.lowercased()
        return allRecords.filter { record in
            let dateString = record.date.formatted(date: .abbreviated, time: .omitted).lowercased()
            return record.title.lowercased().contains(query)
                || record.note.lowercased().contains(query)
                || dateString.contains(query)
        }
    }

    private var exportText: String {
        var lines = ["Date,Observance,Note"]
        for record in filteredRecords {
            let date = DateFormatter.localizedString(from: record.date, dateStyle: .medium, timeStyle: .none)
            lines.append("\(csvEscape(date)),\(csvEscape(record.title)),\(csvEscape(record.note))")
        }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        List {
            if filteredRecords.isEmpty {
                ContentUnavailableView(
                    AppLocalizer.localizedCurrent("friday_notes.empty", default: "No notes found"),
                    systemImage: "magnifyingglass")
            } else {
                ForEach(filteredRecords) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(record.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(record.title)
                            .font(.headline)
                        Text(record.note)
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(AppLocalizer.localizedCurrent("friday_notes.title", default: "Friday Notes"))
        .searchable(text: $searchText, prompt: AppLocalizer.localizedCurrent("friday_notes.search", default: "Search notes"))
        .toolbar {
            ShareLink(
                item: exportText,
                subject: Text(AppLocalizer.localizedCurrent("friday_notes.export.subject", default: "Friday Penance Notes Export")),
                message: Text(AppLocalizer.localizedCurrent("friday_notes.export.message", default: "Exported from Catholic Fasting")))
            {
                Label(AppLocalizer.localizedCurrent("shared.export", default: "Export"), systemImage: "square.and.arrow.up")
            }
            .disabled(filteredRecords.isEmpty)
        }
    }

    private func csvEscape(_ raw: String) -> String {
        "\"\(raw.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}

#Preview {
    ContentView()
}
