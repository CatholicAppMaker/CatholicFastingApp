import SwiftUI

extension ContentView {
    var fastingDaysScopeSelection: Binding<Int> {
        Binding(
            get: { fastingDaysShowAllYearDays ? 1 : 0 },
            set: { newValue in
                if newValue == 0 {
                    fastingDaysShowAllYearDays = false
                    fastingDaysIncludeOptionalDays = false
                } else {
                    fastingDaysShowAllYearDays = true
                    fastingDaysIncludeOptionalDays = true
                }
            })
    }

    var fastingDaysHeroSection: some View {
        Section {
            SacredSurfaceAnchorCard(
                assetName: SacredHeroImageSelector.anchorArtwork(for: .fastingDays).assetName,
                title: localized("ipad.fasting_days.hero.title", default: "Fasting Day Planner"),
                subtitle: localized(
                    "ipad.fasting_days.hero.subtitle",
                    default: "Browse obligation days, optional practices, and celebrations without leaving the workspace."),
                imageHeight: 110,
                cornerRadius: 16,
                accessibilityIdentifier: "fasting_days.hero")
        }
    }

    var fastingDaysOverviewSection: some View {
        Section {
            if let nextRequired = upcomingMandatoryObservance {
                FastingDaysNextObservanceCard(
                    eyebrow: localized("fasting_days.next_required", default: "Next required"),
                    title: localizedObservanceTitle(nextRequired.title),
                    date: localizedAbbreviatedDate(nextRequired.date),
                    systemImage: "calendar.badge.exclamationmark",
                    dateColor: CatholicTheme.dangerForeground,
                    supportingText: nil)
            } else if let nextPotential = upcomingPotentialFastingObservance {
                FastingDaysNextObservanceCard(
                    eyebrow: localized("fasting_days.next_possible", default: "Next possible observance"),
                    title: localizedObservanceTitle(nextPotential.title),
                    date: localizedAbbreviatedDate(nextPotential.date),
                    systemImage: "calendar",
                    dateColor: CatholicTheme.warningForeground,
                    supportingText: localized("fasting_days.confirm_age", default: "Confirm your age-profile toggles in Settings if needed."))
            } else {
                Text(localized("fasting_days.none_upcoming", default: "No upcoming required observance day found in the loaded date range."))
                    .appSupportingTextStyle()
            }

            FastingDaysMetricSummary(
                seasonLabel: localizedSeasonLabel(currentLiturgicalSeason),
                observanceCountText: localizedFormat(
                    "fasting_days.metric.showing_compact_format",
                    default: "%d observances",
                    fastingDaysDisplayObservances.count))

            Text(regionalNormSummaryLine)
                .appSupportingTextStyle()

            FastingDaysScopeControl(
                selection: fastingDaysScopeSelection,
                title: localized("fasting_days.scope.title", default: "Scope"),
                upcomingTitle: localized("fasting_days.scope.upcoming", default: "Upcoming"),
                fullYearTitle: localized("fasting_days.scope.full_year", default: "Full Year"))
        }
    }

    var fastingDaysDisplayOptionsSection: some View {
        Section(localized("fasting_days.filters.section", default: "List Filters")) {
            DisclosureGroup(localized("fasting_days.filters.customize", default: "Customize List")) {
                Toggle(localized("fasting_days.filters.full_year", default: "Show all fasting days in this Catholic calendar year"), isOn: $fastingDaysShowAllYearDays)
                    .accessibilityIdentifier("fasting_days.toggle.full_year")
                Toggle(
                    localized(
                        "fasting_days.filters.optional",
                        default: "Include optional fasting days (Ember days, optional Friday penance)"),
                    isOn: $fastingDaysIncludeOptionalDays)
                    .accessibilityIdentifier("fasting_days.toggle.optional")
                Toggle(localized("fasting_days.filters.celebrations", default: "Include feast, holy, and memorial celebration days"), isOn: $fastingDaysIncludeFeastAndHolyDays)
                    .accessibilityIdentifier("fasting_days.toggle.celebrations")
                Text(localized("fasting_days.filters.celebrations_hint", default: "Celebration days are shown for planning, not obligation."))
                    .appSupportingTextStyle()
            }
            .accessibilityIdentifier("fasting_days.filters.customize")

            Text(localized("fasting_days.filters.helper", default: "Keep these as utility controls: use them to narrow the list, not to replace the day detail."))
                .appSupportingTextStyle()
        }
    }

    var fastingDaysListSection: some View {
        var visibleKinds: Set<Observance.Kind> = [.fastAndAbstinence, .abstinence, .fridayPenance, .optionalEmber]
        if fastingDaysIncludeFeastAndHolyDays {
            visibleKinds.formUnion([.holyDay, .feastDay, .memorialDay])
        }
        let todayStart = liturgicalCalendar.startOfDay(for: AppClock.now())
        let source =
            fastingDaysShowAllYearDays
                ? currentYearObservances
                : rollingUpcomingObservances.filter {
                    liturgicalCalendar.startOfDay(for: $0.date) >= todayStart
                }
        let candidates = source.filter { visibleKinds.contains($0.kind) }
        let filteredByObligation =
            candidates
                .filter { observance in
                    switch observance.kind {
                    case .holyDay, .feastDay, .memorialDay:
                        // Feast/Holy day visibility is controlled by its own toggle.
                        return fastingDaysIncludeFeastAndHolyDays
                    case .optionalEmber, .fridayPenance:
                        if fastingDaysIncludeOptionalDays {
                            return observance.obligation != .notApplicable
                        }
                        return observance.obligation == .mandatory
                    case .fastAndAbstinence, .abstinence:
                        if !hasKnownBirthYearForObligations {
                            // Keep core fasting days visible until age profile is configured.
                            return true
                        }
                        if fastingDaysIncludeOptionalDays {
                            return observance.obligation != .notApplicable
                        }
                        return observance.obligation == .mandatory
                    }
                }
                .sorted { $0.date < $1.date }
        let displayItems = fastingDaysShowAllYearDays ? filteredByObligation : Array(filteredByObligation.prefix(20))
        let baseTitle =
            fastingDaysShowAllYearDays
                ? (
                    fastingDaysIncludeOptionalDays
                        ? localized("fasting_days.list.title.full_year_all", default: "All Discipline Days This Year")
                        : localized("fasting_days.list.title.full_year_required", default: "Required Discipline Days This Year"))
                : (
                    fastingDaysIncludeOptionalDays
                        ? localized("fasting_days.list.title.upcoming_all", default: "Upcoming Discipline Days (Required + Optional)")
                        : localized("fasting_days.list.title.upcoming_required", default: "Upcoming Required Discipline Days"))
        let title = fastingDaysIncludeFeastAndHolyDays ? localizedFormat("fasting_days.list.title.celebrations_format", default: "%@ + Celebration Days", baseTitle) : baseTitle
        let monthGroups = Dictionary(grouping: displayItems) { observance in
            localizedMonthYear(observance.date)
        }
        .map { title, observances in
            (title, observances.sorted { $0.date < $1.date })
        }
        .sorted { lhs, rhs in
            guard let leftDate = lhs.1.first?.date, let rightDate = rhs.1.first?.date else {
                return lhs.0 < rhs.0
            }
            return leftDate < rightDate
        }

        let moreText = !fastingDaysShowAllYearDays && filteredByObligation.count > displayItems.count
            ? localizedFormat(
                "fasting_days.list.more_format",
                default: "Showing next %d observance days. Turn on \"Show full-year observance list\" for the full list.",
                displayItems.count)
            : nil

        return FastingDaysAgendaSections(
            title: title,
            hint: localized("fasting_days.list.agenda_hint", default: "Select an observance to review its rule, regional context, sources, and reminder actions."),
            emptyText: localized("fasting_days.list.empty", default: "No observance days match the current list filters."),
            groups: monthGroups,
            moreText: moreText,
            row: fastingDaysAgendaRow)
    }

    private func fastingDaysAgendaRow(_ observance: Observance) -> some View {
        FastingDaysAgendaRow(
            observance: observance,
            title: localizedObservanceTitle(observance.title),
            detail: "\(localizedObservanceKindLabel(observance.kind)) • \(localizedObservanceDispositionLabel(observance))",
            date: localizedAbbreviatedDate(observance.date),
            status: tracker.status(for: observance.id),
            statusLabel: localized("fasting_days.detail.status", default: "Observance status"),
            statusOptionLabel: localizedCompletionStatusLabel,
            setStatus: { tracker.setStatus($0, for: observance.id) },
            destination: { fastingObservanceDetail(observance) })
    }
}
