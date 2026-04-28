import SwiftUI

extension ContentView {
    func ipadFastingDaysSummaryCards(for items: [Observance]) -> some View {
        let requiredCount = items.count(where: { $0.obligation == .mandatory })
        let optionalCount = items.count(where: { $0.obligation == .optional })
        let celebrationCount = items.count(where: { [.holyDay, .feastDay, .memorialDay].contains($0.kind) })

        return LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 150), spacing: 12, alignment: .top)],
            alignment: .leading,
            spacing: 12)
        {
            IPadSummaryMetricCard(
                title: localized("ipad.fasting_days.summary.required", default: "Required"),
                value: "\(requiredCount)",
                subtitle: fastingDaysShowAllYearDays
                    ? localized("ipad.fasting_days.summary.required_in_view", default: "days in view")
                    : localized("ipad.fasting_days.summary.required_upcoming", default: "upcoming days"))
            IPadSummaryMetricCard(
                title: localized("ipad.fasting_days.summary.optional", default: "Optional"),
                value: "\(optionalCount)",
                subtitle: fastingDaysIncludeOptionalDays
                    ? localized("ipad.fasting_days.summary.optional_included", default: "included now")
                    : localized("ipad.fasting_days.summary.optional_hidden", default: "hidden from list"),
                tint: CatholicTheme.accent)
            IPadSummaryMetricCard(
                title: localized("ipad.fasting_days.summary.celebrations", default: "Celebrations"),
                value: "\(celebrationCount)",
                subtitle: fastingDaysIncludeFeastAndHolyDays
                    ? localized("ipad.fasting_days.summary.celebrations_shown", default: "shown now")
                    : localized("ipad.fasting_days.summary.celebrations_hidden", default: "hidden from list"),
                tint: .orange)
        }
        .accessibilityIdentifier("ipad.fasting_days.summary_cards")
    }

    var ipadFastingDaysFilterRail: some View {
        let regionContext = RegionalGuidanceContextFactory.generalContext(for: settings)

        return ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 14) {
                    IPadWorkspaceHeader(
                        eyebrow: localized("ipad.fasting_days.filters.eyebrow", default: "Filters"),
                        title: localized("ipad.fasting_days.filters.title", default: "Refine the list"),
                        detail: localized("ipad.fasting_days.filters.detail", default: "Keep these utility controls secondary to the selected day and next required observance."))

                    Picker(
                        localized("ipad.fasting_days.filters.scope", default: "Scope"),
                        selection: Binding(
                            get: { fastingDaysShowAllYearDays ? 1 : 0 },
                            set: { fastingDaysShowAllYearDays = $0 == 1 }))
                    {
                        Text(localized("ipad.fasting_days.filters.scope_upcoming", default: "Upcoming")).tag(0)
                        Text(localized("ipad.fasting_days.filters.scope_full_year", default: "Full Year")).tag(1)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("ipad.fasting_days.scope")

                    Toggle(
                        localized("ipad.fasting_days.filters.include_optional", default: "Include optional fasting days"),
                        isOn: $fastingDaysIncludeOptionalDays)
                        .accessibilityIdentifier("ipad.fasting_days.optional_toggle")
                    Toggle(
                        localized("ipad.fasting_days.filters.include_celebrations", default: "Include feast, holy, and memorial days"),
                        isOn: $fastingDaysIncludeFeastAndHolyDays)
                        .accessibilityIdentifier("ipad.fasting_days.feast_toggle")

                    Picker(localized("ipad.fasting_days.filters.year", default: "Calendar year"), selection: $year) {
                        ForEach(Array(UIConstants.yearRange), id: \.self) { yearOption in
                            Text("\(yearOption)").tag(yearOption)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("ipad.fasting_days.year")
                }
                .padding(18)
                .iPadPaneCard()

                VStack(alignment: .leading, spacing: 12) {
                    IPadWorkspaceHeader(
                        eyebrow: localized("ipad.fasting_days.region.eyebrow", default: "Region"),
                        title: regionContext.classificationLabel,
                        detail: regionalNormSummaryLine)
                    IPadContextBadge(text: regionContext.supportLevel.label, supportLevel: regionContext.supportLevel)
                    DisclosureGroup(localized("ipad.fasting_days.region.notes", default: "Region notes")) {
                        Text(regionContext.disclosureText)
                            .appSupportingTextStyle()
                            .padding(.top, 4)
                    }
                    if let url = regionContext.sourceURL {
                        Link(
                            regionContext.regionProfile == .canada
                                ? localized("ipad.fasting_days.region.cccb_link", default: "Read CCCB Friday guidance")
                                : localized("ipad.fasting_days.region.official_link", default: "Read official guidance"),
                            destination: url)
                            .font(.footnote.weight(.semibold))
                    }
                }
                .padding(18)
                .iPadPaneCard()
            }
        }
        .accessibilityIdentifier("ipad.fasting_days.filters")
    }

    func ipadFastingDaysHeroBand(compact: Bool) -> some View {
        let regionContext = RegionalGuidanceContextFactory.generalContext(for: settings)
        return IPadWorkspaceHeroBand(
            assetName: fastingDaysHeroArtwork.assetName,
            seasonLabel: localizedSeasonLabel(currentLiturgicalSeason),
            seasonContextLabel: localizedFormat("ipad.hero.season_label", default: "Liturgical Season: %@", localizedSeasonLabel(currentLiturgicalSeason)),
            title: localized("ipad.fasting_days.hero.title", default: "Fasting Day Planner"),
            subtitle: localized("ipad.fasting_days.hero.subtitle", default: "Browse obligation days, optional practices, and celebrations without leaving the workspace."),
            quote: fastingDaysFastingQuote,
            regionContext: regionContext,
            compact: compact,
            accessibilityIdentifier: "ipad.fasting_days.hero")
    }

    func ipadFastingDaysQuickDateStrip(from items: [Observance]) -> some View {
        let quickFocus = ipadQuickFocusObservances(from: items)
        return Group {
            if quickFocus.isEmpty {
                EmptyView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(quickFocus) { observance in
                            IPadKeyDateChip(
                                title: localizedObservanceTitle(observance.title),
                                subtitle: localizedAbbreviatedDate(observance.date),
                                isSelected: selectedFastingObservanceID == observance.id)
                            {
                                selectedFastingObservanceID = observance.id
                            }
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .accessibilityIdentifier("ipad.fasting_days.quick_dates")
    }

    func ipadFastingDaysGroupedList(groups: [(String, [Observance])]) -> some View {
        LazyVStack(alignment: .leading, spacing: 18) {
            ForEach(groups, id: \.0) { title, observances in
                VStack(alignment: .leading, spacing: 12) {
                    IPadWorkspaceHeader(
                        eyebrow: localized("ipad.fasting_days.period.eyebrow", default: "Period"),
                        title: title,
                        detail: localizedFormat("ipad.fasting_days.period.detail", default: "%d observance%@", observances.count, observances.count == 1 ? "" : "s"))
                    ForEach(observances) { observance in
                        let context = RegionalGuidanceContextFactory.presentationContext(for: observance, settings: settings)
                        Button {
                            selectedFastingObservanceID = observance.id
                        } label: {
                            IPadObservanceSelectionRow(
                                context: context,
                                isSelected: selectedFastingObservanceID == observance.id)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("ipad.fasting_days.row.\(observance.id)")
                        Divider()
                    }
                }
                .padding(18)
                .iPadPaneCard()
            }
        }
        .accessibilityIdentifier("ipad.fasting_days.center_list")
    }

    func ipadFastingDaysDetailPane(selected: Observance?, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            if let selected {
                let context = RegionalGuidanceContextFactory.presentationContext(for: selected, settings: settings)
                VStack(alignment: .leading, spacing: 14) {
                    IPadWorkspaceHeader(
                        eyebrow: context.regionalContext.classificationLabel,
                        title: localizedObservanceTitle(selected.title),
                        detail: localizedCompleteDate(selected.date))
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            StatusTag(text: selected.kind.label, color: selected.kind.color)
                            StatusTag(text: selected.dispositionLabel, color: selected.obligation == .mandatory ? .red : .blue)
                            IPadContextBadge(text: context.regionalContext.supportLevel.label, supportLevel: context.regionalContext.supportLevel)
                        }
                        if let detail = selected.detail {
                            Text(detail)
                                .appSupportingTextStyle()
                        }
                        Text(context.nextActionText)
                            .appLeadTextStyle()
                            .foregroundStyle(CatholicTheme.primary)

                        if [.fastAndAbstinence, .abstinence, .fridayPenance].contains(selected.kind) {
                            Button {
                                selectedMoreDestination = .guidanceAndRules
                                homeSurface = .more
                            } label: {
                                Label(localized("ipad.fasting_days.detail.open_guidance", default: "Open full food guidance"), systemImage: "book.closed")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .appSecondaryButtonStyle()
                            .accessibilityIdentifier("ipad.fasting_days.open_food_guidance")
                        }
                    }
                }
                .padding(18)
                .iPadPaneCard()
                .accessibilityIdentifier("ipad.fasting_days.detail")

                VStack(alignment: .leading, spacing: 12) {
                    IPadWorkspaceHeader(
                        eyebrow: localized("ipad.fasting_days.log.eyebrow", default: "Log"),
                        title: localized("ipad.fasting_days.log.title", default: "Mark today clearly"),
                        detail: localized("ipad.fasting_days.log.detail", default: "Keep status and notes together without leaving this detail pane."))
                    if compact {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                Button(localized("ipad.fasting_days.log.complete", default: "Complete")) { tracker.setStatus(.completed, for: selected.id) }
                                    .appPrimaryButtonStyle()
                                Button(localized("ipad.fasting_days.log.substitute", default: "Substitute")) { tracker.setStatus(.substituted, for: selected.id) }
                                    .appSecondaryButtonStyle()
                            }
                            HStack(spacing: 10) {
                                Button(localized("ipad.fasting_days.log.missed", default: "Missed")) { tracker.setStatus(.missed, for: selected.id) }
                                    .appSecondaryButtonStyle(legacyTint: .orange)
                                Button(localized("ipad.fasting_days.log.reset", default: "Reset")) { tracker.setStatus(.notStarted, for: selected.id) }
                                    .appSecondaryButtonStyle(legacyTint: .gray)
                            }
                        }
                    } else {
                        HStack(spacing: 10) {
                            Button(localized("ipad.fasting_days.log.complete", default: "Complete")) { tracker.setStatus(.completed, for: selected.id) }
                                .appPrimaryButtonStyle()
                            Button(localized("ipad.fasting_days.log.substitute", default: "Substitute")) { tracker.setStatus(.substituted, for: selected.id) }
                                .appSecondaryButtonStyle()
                            Button(localized("ipad.fasting_days.log.missed", default: "Missed")) { tracker.setStatus(.missed, for: selected.id) }
                                .appSecondaryButtonStyle(legacyTint: .orange)
                        }
                        Button(localized("ipad.fasting_days.log.reset", default: "Reset")) { tracker.setStatus(.notStarted, for: selected.id) }
                            .appSecondaryButtonStyle(legacyTint: .gray)
                    }

                    TextField(localized("ipad.fasting_days.log.note", default: "Add a note for this day"), text: noteBinding(for: selected.id), axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3, reservesSpace: true)
                        .accessibilityIdentifier("ipad.fasting_days.note")
                }
                .padding(18)
                .iPadPaneCard()

                DisclosureGroup(localized("ipad.fasting_days.sources.title", default: "Sources and transparency")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(context.sourceSummary)
                            .appSupportingTextStyle()
                        ForEach(context.regionalContext.citations, id: \.self) { citation in
                            Text("• \(citation.authority.rawValue): \(citation.title) (\(citation.shortReference))")
                                .appSupportingTextStyle()
                        }
                        if let url = context.regionalContext.sourceURL {
                            Link(localized("ipad.fasting_days.sources.open", default: "Open source guidance"), destination: url)
                                .font(.footnote.weight(.semibold))
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(18)
                .iPadPaneCard()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text(localized("ipad.fasting_days.empty.title", default: "Choose an observance"))
                        .appSectionTitleStyle(serif: true)
                    Text(localized("ipad.fasting_days.empty.detail", default: "Pick a day to review its obligation and log it."))
                        .appLeadTextStyle()
                }
                .padding(18)
                .iPadPaneCard()
            }
        }
        .accessibilityIdentifier("ipad.fasting_days.detail_pane")
    }

    func ipadQuickFocusObservances(from items: [Observance]) -> [Observance] {
        let orderedTitles = [
            "Ash Wednesday",
            "Good Friday",
            "Friday of Lent",
            "Ember Day",
            "Christmas",
            "Ascension",
        ]
        var selected: [Observance] = []
        for title in orderedTitles {
            if let match = items.first(where: { $0.title.contains(title) }) {
                selected.append(match)
            }
        }
        return Array(selected.prefix(6))
    }

    func ipadFastingDayGroups(from items: [Observance]) -> [(String, [Observance])] {
        let grouped = Dictionary(grouping: items) { observance in
            localizedMonthYear(observance.date)
        }
        return grouped
            .map { key, value in
                (key, value.sorted { $0.date < $1.date })
            }
            .sorted { lhs, rhs in
                guard let leftDate = lhs.1.first?.date, let rightDate = rhs.1.first?.date else { return lhs.0 < rhs.0 }
                return leftDate < rightDate
            }
    }
}
