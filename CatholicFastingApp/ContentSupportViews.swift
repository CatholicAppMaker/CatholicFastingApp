import SwiftUI

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
