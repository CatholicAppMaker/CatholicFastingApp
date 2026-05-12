import SwiftUI

struct CatholicFastingMacCalendarView: View {
    @ObservedObject var model: CatholicFastingMacModel

    var body: some View {
        MacSurfaceContainer(
            title: "Fasting Calendar",
            subtitle: "Review the year, filter the list, and record each observance without mobile-only navigation.",
            accessibilityID: "mac.surface.calendar.ready")
        {
            calendarFilters

            MacAdaptiveColumns {
                MacCard(title: "Observances", subtitle: "\(model.visibleCalendarObservances.count) shown") {
                    List(model.visibleCalendarObservances, selection: $model.selectedObservanceID) { observance in
                        let isSelected = model.selectedObservanceID == observance.id

                        VStack(alignment: .leading, spacing: 2) {
                            Text(model.localizedObservanceTitle(observance.title))
                            Text(model.localizedDate(observance.date))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .tag(observance.id)
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(model.localizedObservanceTitle(observance.title))
                        .accessibilityHint(model.localizedDate(observance.date))
                        .macSelectedAccessibility(isSelected)
                    }
                    .frame(minHeight: 420)
                    .accessibilityIdentifier("mac.calendar.list")
                }
            } trailing: {
                MacCard(
                    title: model.selectedObservance.map { model.localizedObservanceTitle($0.title) } ?? "Select an observance",
                    subtitle: model.selectedObservance.map { model.localizedDate($0.date) })
                {
                    if let observance = model.selectedObservance {
                        Picker("Status", selection: Binding(
                            get: { model.tracker.status(for: observance.id) },
                            set: { model.setStatus($0, for: observance) }))
                        {
                            ForEach(CompletionStatus.allCases) { status in
                                Text(status.label).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityIdentifier("mac.calendar.status")
                        .accessibilityValue(model.tracker.status(for: observance.id).label)

                        if let detail = observance.detail {
                            Text(detail)
                                .foregroundStyle(.secondary)
                        }

                        if observance.kind == .fridayPenance {
                            TextEditor(text: model.noteBinding(for: observance.id))
                                .frame(minHeight: 120)
                                .accessibilityIdentifier("mac.calendar.note")
                        }

                        if !observance.citations.isEmpty {
                            Divider()
                            ForEach(observance.citations, id: \.title) { citation in
                                Text("\(citation.title) • \(citation.shortReference)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        Text("Choose a day from the list to review its guidance and record completion.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var calendarFilters: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                filterControls
            }

            VStack(alignment: .leading, spacing: 10) {
                filterControls
            }
        }
    }

    @ViewBuilder
    private var filterControls: some View {
        Stepper("Year \(model.year)", value: $model.year, in: UIConstants.yearRange)
            .accessibilityIdentifier("mac.calendar.year")
        Toggle("Show full year", isOn: $model.fastingDaysShowAllYearDays)
            .accessibilityIdentifier("mac.calendar.full_year")
        Toggle("Include optional days", isOn: $model.fastingDaysIncludeOptionalDays)
            .accessibilityIdentifier("mac.calendar.optional")
        Toggle("Include feast & holy days", isOn: $model.fastingDaysIncludeFeastAndHolyDays)
            .accessibilityIdentifier("mac.calendar.feasts")
    }
}
