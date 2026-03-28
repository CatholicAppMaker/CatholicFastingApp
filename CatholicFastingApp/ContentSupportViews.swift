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
                Text(observance.title)
                    .font(.headline)

                Text(observance.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    StatusTag(text: observance.kind.label, color: observance.kind.color)
                    StatusTag(text: observance.dispositionLabel, color: obligationColor)
                }

                if let detail = observance.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("Why: \(observance.rationale)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !observance.citations.isEmpty {
                    Text(citationSummary)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if observance.kind == .fridayPenance, observance.obligation != .notApplicable {
                    TextField("What penance did you do?", text: noteBinding)
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
                        Button(statusOption.label) {
                            onSetStatus(statusOption)
                        }
                    }
                } label: {
                    Image(systemName: statusIcon)
                        .imageScale(.large)
                        .foregroundStyle(statusColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Set status \(status.label)")
                .contextMenu {
                    Button("Toggle Complete", action: onToggleCompletion)
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
        .appRoundedGlass(cornerRadius: 12)
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

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(CatholicTheme.parchment.opacity(0.88), in: Capsule())
            .overlay(
                Capsule()
                    .fill(color.opacity(0.16)))
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.55), lineWidth: 0.8))
            .appCapsuleGlass()
    }
}

struct MetricTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .appEyebrowStyle()
                .textCase(.uppercase)
            Text(value)
                .appMetricValueStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(CatholicTheme.parchment.opacity(0.92)))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tileTint.opacity(0.08)))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CatholicTheme.cardBorder.opacity(0.45), lineWidth: 1))
        .shadow(color: tileTint.opacity(0.08), radius: 10, y: 4)
        .appRoundedGlass(cornerRadius: 14)
    }

    private var tileTint: Color {
        switch title {
        case "Required":
            .red
        case "Done":
            .green
        case "Streak":
            CatholicTheme.accent
        default:
            CatholicTheme.primary
        }
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
                ContentUnavailableView("No notes found", systemImage: "magnifyingglass")
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
        .navigationTitle("Friday Notes")
        .searchable(text: $searchText, prompt: "Search notes")
        .toolbar {
            ShareLink(
                item: exportText,
                subject: Text("Friday Penance Notes Export"),
                message: Text("Exported from Catholic Fasting"))
            {
                Label("Export", systemImage: "square.and.arrow.up")
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
