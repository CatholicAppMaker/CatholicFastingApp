import SwiftUI

struct SacredHeroArtwork {
    let assetName: String
    let title: String
    let subtitle: String
}

enum SacredHeroScene {
    case dashboard
    case fastingDays
    case intermittent
    case guidance
}

enum SacredHeroImageSelector {
    private static let dashboardArt: [SacredHeroArtwork] = [
        SacredHeroArtwork(
            assetName: "HeroSacred",
            title: "Christ Pantocrator",
            subtitle: "Let your fasting be prayerful, intentional, and rooted in the Church."),
        SacredHeroArtwork(
            assetName: "SacredMonstrance",
            title: "Eucharistic Devotion",
            subtitle: "Keep your sacrifice oriented to worship and thanksgiving."),
        SacredHeroArtwork(
            assetName: "SacredSacredHeart",
            title: "Sacred Heart",
            subtitle: "Offer discipline with mercy, reparation, and love."),
        SacredHeroArtwork(
            assetName: "SacredCathedralLight",
            title: "Cathedral Light",
            subtitle: "Bring your daily fast into the Church's worship and prayer."),
        SacredHeroArtwork(
            assetName: "SacredAshWednesday",
            title: "Ashes and Repentance",
            subtitle: "Remember conversion of heart as the first work of fasting."),
        SacredHeroArtwork(
            assetName: "SacredPalmSunday",
            title: "Palm Sunday",
            subtitle: "Walk with Christ through sacrifice toward the Paschal mystery."),
        SacredHeroArtwork(
            assetName: "SacredChaliceVine",
            title: "Chalice and Vine",
            subtitle: "Offer fasting in union with the Eucharistic life of the Church."),
        SacredHeroArtwork(
            assetName: "SacredScriptureCandle",
            title: "Scripture Candle",
            subtitle: "Let the Word of God shape your fasting and your charity."),
        SacredHeroArtwork(
            assetName: "SacredJerusalemCross",
            title: "Jerusalem Cross",
            subtitle: "Carry each sacrifice with missionary charity."),
        SacredHeroArtwork(
            assetName: "SacredMarianMonogram",
            title: "Marian Monogram",
            subtitle: "Ask Our Lady to steady your discipline and prayer."),
        SacredHeroArtwork(
            assetName: "SacredConceptChiRho",
            title: "Chi-Rho Crest",
            subtitle: "Keep Christ first in every daily observance."),
        SacredHeroArtwork(
            assetName: "SacredConceptRosary",
            title: "Rosary Emblem",
            subtitle: "Pair fasting with patient, persevering prayer."),
        SacredHeroArtwork(
            assetName: "SacredConceptHeart",
            title: "Heart of Mercy",
            subtitle: "Let fasting deepen mercy toward others."),
    ]

    private static let fastingDaysArt: [SacredHeroArtwork] = [
        SacredHeroArtwork(
            assetName: "SacredAshWednesday",
            title: "Ash Wednesday",
            subtitle: "Fasting begins with repentance, humility, and prayer."),
        SacredHeroArtwork(
            assetName: "SacredPalmSunday",
            title: "Palm Branch",
            subtitle: "Fasting days prepare us to follow Christ to the Cross."),
        SacredHeroArtwork(
            assetName: "SacredMonstrance",
            title: "Eucharistic Focus",
            subtitle: "Let every fast point toward worship and thanksgiving."),
        SacredHeroArtwork(
            assetName: "SacredRosaryCross",
            title: "Rosary and Cross",
            subtitle: "Pair abstinence with prayer for deeper conversion."),
        SacredHeroArtwork(
            assetName: "HeroSacred",
            title: "Christ Pantocrator",
            subtitle: "Keep the Lord at the center of your fasting discipline."),
        SacredHeroArtwork(
            assetName: "SacredCathedralLight",
            title: "Light in the Church",
            subtitle: "Observe fast days within the life of the liturgy."),
        SacredHeroArtwork(
            assetName: "SacredJerusalemCross",
            title: "Jerusalem Cross",
            subtitle: "Stay faithful on required days with a pilgrim spirit."),
        SacredHeroArtwork(
            assetName: "SacredMarianMonogram",
            title: "Marian Discipline",
            subtitle: "Keep fasting days simple, humble, and prayerful."),
        SacredHeroArtwork(
            assetName: "SacredConceptChiRho",
            title: "Christ-Centered Pattern",
            subtitle: "Treat every fasting day as an offering to Christ."),
        SacredHeroArtwork(
            assetName: "SacredConceptRosary",
            title: "Rosary Rhythm",
            subtitle: "Let fasting days follow a stable rhythm of prayer."),
        SacredHeroArtwork(
            assetName: "SacredConceptHeart",
            title: "Merciful Discipline",
            subtitle: "Hold firm discipline with real charity."),
    ]

    private static let intermittentArt: [SacredHeroArtwork] = [
        SacredHeroArtwork(
            assetName: "SacredRosaryCross",
            title: "Rosary Cross",
            subtitle: "Offer this fast with intention: prayer, almsgiving, and conversion."),
        SacredHeroArtwork(
            assetName: "SacredChiRho",
            title: "Chi-Rho",
            subtitle: "Keep each session focused on Christ, not only performance."),
        SacredHeroArtwork(
            assetName: "HeroSacred",
            title: "Daily Discipline",
            subtitle: "Unite your fasting hours to repentance and gratitude."),
        SacredHeroArtwork(
            assetName: "SacredDesertPilgrimage",
            title: "Desert Pilgrimage",
            subtitle: "Persevere in sacrifice with trust, patience, and humility."),
        SacredHeroArtwork(
            assetName: "SacredAshWednesday",
            title: "Discipline and Repentance",
            subtitle: "Use optional fasting as a path of inner conversion."),
        SacredHeroArtwork(
            assetName: "SacredScriptureCandle",
            title: "Prayer and the Word",
            subtitle: "Keep intermittent fasting tied to prayer, not just metrics."),
        SacredHeroArtwork(
            assetName: "SacredMonstrance",
            title: "Adoration",
            subtitle: "Offer sacrifice as worship, gratitude, and reparation."),
        SacredHeroArtwork(
            assetName: "SacredChaliceVine",
            title: "Eucharistic Spirit",
            subtitle: "Let personal discipline strengthen communion and charity."),
        SacredHeroArtwork(
            assetName: "SacredJerusalemCross",
            title: "Pilgrim Endurance",
            subtitle: "Persevere through fasting windows with trust in grace."),
        SacredHeroArtwork(
            assetName: "SacredMarianMonogram",
            title: "Marian Steadiness",
            subtitle: "Practice optional fasting with gentleness and consistency."),
        SacredHeroArtwork(
            assetName: "SacredConceptChiRho",
            title: "Focused Intention",
            subtitle: "Keep optional fasts ordered to prayer and conversion."),
        SacredHeroArtwork(
            assetName: "SacredConceptRosary",
            title: "Prayerful Rhythm",
            subtitle: "Let each fast hour become an hour of recollection."),
    ]

    private static let guidanceArt: [SacredHeroArtwork] = [
        SacredHeroArtwork(
            assetName: "GuidanceSacred",
            title: "St. Peter's Basilica",
            subtitle: "Guidance should always be interpreted with pastoral direction."),
        SacredHeroArtwork(
            assetName: "SacredMonstrance",
            title: "Rule and Reverence",
            subtitle: "Follow Church norms with humility and consistency."),
        SacredHeroArtwork(
            assetName: "SacredSacredHeart",
            title: "Pastoral Prudence",
            subtitle: "Discipline and charity should always move together."),
        SacredHeroArtwork(
            assetName: "SacredScriptureCandle",
            title: "Scripture and Prayer",
            subtitle: "Let guidance be read with prayerful attention and discernment."),
        SacredHeroArtwork(
            assetName: "SacredAshWednesday",
            title: "Penitential Clarity",
            subtitle: "Guidance should always serve conversion, not legalism."),
        SacredHeroArtwork(
            assetName: "SacredPalmSunday",
            title: "Holy Week Orientation",
            subtitle: "Read Church norms in light of Christ's Paschal mystery."),
        SacredHeroArtwork(
            assetName: "SacredCathedralLight",
            title: "Pastoral Context",
            subtitle: "Apply fasting rules with pastoral care and prudence."),
        SacredHeroArtwork(
            assetName: "SacredChaliceVine",
            title: "Sacramental Life",
            subtitle: "Fasting and feasting both belong to the rhythm of the Church."),
        SacredHeroArtwork(
            assetName: "SacredJerusalemCross",
            title: "Gospel Witness",
            subtitle: "Apply guidance with conviction, prudence, and charity."),
        SacredHeroArtwork(
            assetName: "SacredMarianMonogram",
            title: "Marian Prudence",
            subtitle: "Follow norms faithfully with humility and peace."),
        SacredHeroArtwork(
            assetName: "SacredConceptChiRho",
            title: "Christ-Centered Rule",
            subtitle: "Read every fasting norm through the mind of Christ."),
        SacredHeroArtwork(
            assetName: "SacredConceptHeart",
            title: "Mercy and Truth",
            subtitle: "Keep both fidelity to teaching and pastoral tenderness."),
    ]

    private static func pool(for scene: SacredHeroScene) -> [SacredHeroArtwork] {
        switch scene {
        case .dashboard:
            dashboardArt
        case .fastingDays:
            fastingDaysArt
        case .intermittent:
            intermittentArt
        case .guidance:
            guidanceArt
        }
    }

    private static func daySeed(for date: Date) -> Int {
        (Calendar.gregorian.ordinality(of: .day, in: .year, for: date) ?? 1) - 1
    }

    private static func artworkSet(for date: Date) -> [SacredHeroScene: SacredHeroArtwork] {
        let scenes: [SacredHeroScene] = [.dashboard, .fastingDays, .intermittent, .guidance]
        let seed = daySeed(for: date)
        var usedAssetNames: Set<String> = []
        var result: [SacredHeroScene: SacredHeroArtwork] = [:]

        for (sceneOffset, scene) in scenes.enumerated() {
            let pool = pool(for: scene)
            let start = (seed + (sceneOffset * 2)) % pool.count
            var picked = pool[start]

            for indexOffset in 0 ..< pool.count {
                let candidate = pool[(start + indexOffset) % pool.count]
                if !usedAssetNames.contains(candidate.assetName) {
                    picked = candidate
                    break
                }
            }

            usedAssetNames.insert(picked.assetName)
            result[scene] = picked
        }

        return result
    }

    static func artwork(for scene: SacredHeroScene, date: Date = Date()) -> SacredHeroArtwork {
        artworkSet(for: date)[scene] ?? pool(for: scene)[0]
    }
}

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

    var fastingDaysFilterTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                StatusTag(
                    text: fastingDaysShowAllYearDays ? "Full Year" : "Upcoming",
                    color: fastingDaysShowAllYearDays ? CatholicTheme.primary : CatholicTheme.accent)
                StatusTag(
                    text: fastingDaysIncludeOptionalDays ? "Required + Optional" : "Required Only",
                    color: fastingDaysIncludeOptionalDays ? .orange : .red)
                if fastingDaysIncludeFeastAndHolyDays {
                    StatusTag(text: "Celebrations Included", color: .green)
                }
            }
            .padding(.vertical, 2)
        }
        .accessibilityIdentifier("fasting_days.filter_tags")
    }

    var fastingDaysHeroSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                SacredHeroCard(
                    assetName: fastingDaysHeroArtwork.assetName,
                    title: fastingDaysHeroArtwork.title,
                    subtitle: fastingDaysHeroArtwork.subtitle,
                    height: 132,
                    cornerRadius: 16)

                CatholicFastingQuoteCard(quote: fastingDaysFastingQuote, compact: true)
                    .accessibilityIdentifier("fasting_days.quote")
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(fastingDaysHeroArtwork.title). \(fastingDaysHeroArtwork.subtitle)")
            .accessibilityIdentifier("fasting_days.hero")
        }
    }

    var fastingDaysOverviewSection: some View {
        Section {
            if let nextRequired = upcomingMandatoryObservance {
                VStack(alignment: .leading, spacing: 10) {
                    Label(localized("fasting_days.next_required", default: "Next required"), systemImage: "calendar.badge.exclamationmark")
                        .appEyebrowStyle()
                        .textCase(.uppercase)

                    Text(nextRequired.title)
                        .appSectionTitleStyle(serif: true)

                    Text(nextRequired.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                        .foregroundStyle(.red)
                }
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)
            } else if let nextPotential = upcomingPotentialFastingObservance {
                VStack(alignment: .leading, spacing: 10) {
                    Label(localized("fasting_days.next_possible", default: "Next possible observance"), systemImage: "calendar")
                        .appEyebrowStyle()
                        .textCase(.uppercase)

                    Text(nextPotential.title)
                        .appSectionTitleStyle(serif: true)

                    Text(nextPotential.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.headline)
                        .foregroundStyle(.orange)

                    Text(localized("fasting_days.confirm_age", default: "Confirm your age-profile toggles in Settings if needed."))
                        .appSupportingTextStyle()
                }
                .padding(12)
                .appSurfaceCard(.utility, cornerRadius: 16)
            } else {
                Text(localized("fasting_days.none_upcoming", default: "No upcoming required observance day found in the loaded date range."))
                    .appSupportingTextStyle()
            }

            Text(regionalNormSummaryLine)
                .appSupportingTextStyle()

            fastingDaysFilterTags

            Picker(localized("fasting_days.scope.title", default: "Scope"), selection: fastingDaysScopeSelection) {
                Text(localized("fasting_days.scope.upcoming", default: "Upcoming")).tag(0)
                Text(localized("fasting_days.scope.full_year", default: "Full Year")).tag(1)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("fasting_days.scope_picker")

            Text(fastingDaysDisplaySummaryText)
                .appSupportingTextStyle()
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

            Text(localized("fasting_days.filters.helper", default: "Keep these as utility controls: use them to narrow the list, not to replace the day detail."))
                .appSupportingTextStyle()
        }
    }

    var fastingDaysListSection: some View {
        var visibleKinds: Set<Observance.Kind> = [.fastAndAbstinence, .abstinence, .fridayPenance, .optionalEmber]
        if fastingDaysIncludeFeastAndHolyDays {
            visibleKinds.formUnion([.holyDay, .feastDay, .memorialDay])
        }
        let todayStart = liturgicalCalendar.startOfDay(for: Date())
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

        return Section(title) {
            if displayItems.isEmpty {
                Text(localized("fasting_days.list.empty", default: "No observance days match the current list filters."))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(displayItems) { observance in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(observance.title)
                                .font(.headline)
                            Text("\(observance.kind.label) • \(observanceDispositionLabel(for: observance))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(observance.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if observance.obligation != .notApplicable {
                            Menu {
                                ForEach(CompletionStatus.allCases) { statusOption in
                                    Button(statusOption.label) {
                                        tracker.setStatus(statusOption, for: observance.id)
                                    }
                                }
                            } label: {
                                Image(systemName: statusSymbol(for: tracker.status(for: observance.id)))
                                    .foregroundStyle(statusColor(for: tracker.status(for: observance.id)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }

                if !fastingDaysShowAllYearDays, filteredByObligation.count > displayItems.count {
                    Text(
                        localizedFormat(
                            "fasting_days.list.more_format",
                            default: "Showing next %d observance days. Turn on \"Show full-year observance list\" for the full list.",
                            displayItems.count))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    var progressSection: some View {
        Section(localized("fasting_days.progress.section", default: "Progress")) {
            Text(localizedFormat("fasting_days.progress.format", default: "Completed %d of %d required/optional observances", completedCount, actionableObservances.count))
                .font(.subheadline)
        }
    }

    var todaySection: some View {
        let todayItems = observancesForToday
        return Section(localized("fasting_days.today.section", default: "Today")) {
            if todayItems.isEmpty {
                Text(localized("fasting_days.today.empty", default: "No listed observances today."))
                    .foregroundStyle(.secondary)
                Button(localized("fasting_days.today.plan_ahead", default: "Open Fasting Days to Plan Ahead")) {
                    homeSurface = .fastingDays
                }
                .appSecondaryButtonStyle()
            } else {
                ForEach(todayItems) { observance in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(observance.title)
                                .font(.headline)
                            Text("\(observance.kind.label) • \(observanceDispositionLabel(for: observance))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if observance.obligation != .notApplicable {
                            Button(todayButtonLabel(for: tracker.status(for: observance.id))) {
                                tracker.toggle(observance.id)
                            }
                            .appSecondaryButtonStyle()
                        }
                    }
                }
            }
        }
    }

    var analyticsSection: some View {
        Section(localized("fasting_days.analytics.section", default: "Streaks and Completion")) {
            Text(localizedFormat("fasting_days.analytics.completion_format", default: "Completion Rate: %@", completionRateText))
                .accessibilityIdentifier("today.analytics.completion_rate")
            Text(localizedFormat("fasting_days.analytics.current_streak_format", default: "Current Streak: %d day(s)", currentStreak))
                .accessibilityIdentifier("today.analytics.current_streak")
            Text(localizedFormat("fasting_days.analytics.best_streak_format", default: "Best Streak: %d day(s)", bestStreak))
                .accessibilityIdentifier("today.analytics.best_streak")
        }
    }

    var notificationsSection: some View {
        Section(localized("fasting_days.reminders.section", default: "Reminder Center")) {
            Text(notificationStatus)
                .foregroundStyle(.secondary)
            Text(localized("fasting_days.reminders.intro", default: "Use Quick Setup for the normal plan. Open advanced controls only when you need to tune reminders."))
                .font(.caption)
                .foregroundStyle(.secondary)

            DisclosureGroup(localized("fasting_days.reminders.advanced", default: "Advanced Reminder Controls")) {
                Toggle(localized("settings.quick.reminder_support", default: "Enable reminder support"), isOn: $dailyReminderSupportEnabled)
                    .accessibilityIdentifier("settings.reminders.support_toggle")
                Picker(localized("settings.quick.reminder_strategy", default: "Reminder strategy"), selection: $reminderTierRaw) {
                    ForEach(ReminderTier.allCases) { tier in
                        Text("\(localizedReminderTierLabel(tier)) - \(localizedReminderTierSummary(tier))").tag(tier.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings.reminders.tier")
                .onChange(of: reminderTierRaw) { _, newValue in
                    applyReminderTier(ReminderTier(rawValue: newValue) ?? .balanced)
                }
                Toggle(localized("settings.quick.quote_toggle", default: "Daily devotional quote reminder"), isOn: $dailyQuoteReminderEnabled)
                    .accessibilityIdentifier("settings.reminders.quote_toggle")
                if dailyQuoteReminderEnabled {
                    DatePicker(
                        localized("settings.quick.quote_time", default: "Quote reminder time"),
                        selection: dailyQuoteReminderTimeBinding,
                        displayedComponents: .hourAndMinute)
                        .accessibilityIdentifier("settings.reminders.quote_time")
                    Text(
                        localized(
                            "settings.quick.quote_helper",
                            default: "Receive one fasting quote each day from the saints, popes, and Catholic teachers already included in the app."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if monetizationStore.premiumUnlocked {
                    Toggle(localized("settings.quick.reminder_morning", default: "Morning check-in (7:00 AM)"), isOn: $morningReminderEnabled)
                        .accessibilityIdentifier("settings.reminders.morning_toggle")
                        .disabled(!dailyReminderSupportEnabled)
                    Toggle(localized("settings.quick.reminder_evening", default: "Evening examen (8:00 PM)"), isOn: $eveningReminderEnabled)
                        .accessibilityIdentifier("settings.reminders.evening_toggle")
                        .disabled(!dailyReminderSupportEnabled)
                } else if dailyReminderSupportEnabled {
                    Text(localized("fasting_days.reminders.premium_feature", default: "Morning/evening support reminders are a Premium feature."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button(localized("settings.quick.unlock_support", default: "Unlock Support Reminders")) {
                        openPremiumUpgrade(focusingOn: .accountability)
                    }
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("settings.reminders.unlock_support")
                }
                Button(localized("settings.quick.request_permission", default: "Request Notification Permission")) {
                    Task {
                        notificationStatus = await ReminderScheduler.requestPermission()
                    }
                }
                .disabled(!acceptedLegalNotice)
                .accessibilityHint(localized("settings.quick.permission_hint", default: "Requires consent acknowledgment before reminders are enabled."))
                Button(localized("settings.quick.schedule_required", default: "Schedule Required-Day Reminders")) {
                    Task {
                        notificationStatus = await ReminderScheduler.schedule(observances: rollingUpcomingObservances)
                    }
                }
                .disabled(!acceptedLegalNotice)
                .accessibilityHint(localized("settings.quick.schedule_required_hint", default: "Requires consent acknowledgment before scheduling."))

                Button(localized("settings.quick.schedule_quote", default: "Schedule Daily Quote Reminder")) {
                    Task {
                        await scheduleDailyQuoteReminderFromCurrentSettings()
                    }
                }
                .disabled(!acceptedLegalNotice || !dailyQuoteReminderEnabled)
                .accessibilityIdentifier("settings.reminders.schedule_quote")
                .accessibilityHint(localized("settings.quick.schedule_quote_hint", default: "Schedules one daily fasting quote at the selected time."))

                Button(localized("settings.quick.schedule_support", default: "Schedule Daily Support Reminders")) {
                    Task {
                        notificationStatus = await ReminderScheduler.scheduleHabitSupport(
                            morning: dailyReminderSupportEnabled && morningReminderEnabled,
                            evening: dailyReminderSupportEnabled && eveningReminderEnabled)
                    }
                }
                .disabled(!acceptedLegalNotice || !dailyReminderSupportEnabled || !monetizationStore.premiumUnlocked)
                .accessibilityIdentifier("settings.reminders.schedule_support")
                .accessibilityHint(localized("fasting_days.reminders.schedule_support_hint", default: "Schedules daily habit reminders when support is enabled."))

                if dailyReminderSupportEnabled, !monetizationStore.premiumUnlocked {
                    Text(
                        localized(
                            "settings.quick.support_premium_hint",
                            default: "Premium is required to schedule daily support reminders and apply morning/evening habit support."))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Button(localized("settings.quick.refresh_status", default: "Refresh Reminder Status")) {
                    Task {
                        notificationStatus = await ReminderScheduler.notificationSummary()
                    }
                }
                .appSecondaryButtonStyle()
            }
        }
    }

    var notesSection: some View {
        Section(localized("fasting_days.notes.section", default: "Friday Notes")) {
            NavigationLink(localized("fasting_days.notes.history", default: "Friday Notes History")) {
                FridayNotesHistoryView(notesStore: penanceNotes)
            }
        }
    }

    private func statusSymbol(for status: CompletionStatus) -> String {
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

    private func statusColor(for status: CompletionStatus) -> Color {
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

    private func observanceDispositionLabel(for observance: Observance) -> String {
        observance.dispositionLabel
    }

    private var fastingDaysDisplaySummaryText: String {
        var parts: [String] = [
            fastingDaysShowAllYearDays
                ? localized("fasting_days.summary.full_year", default: "Full-year list")
                : localized("fasting_days.summary.upcoming", default: "Upcoming list"),
            fastingDaysIncludeOptionalDays
                ? localized("fasting_days.summary.optional", default: "optional days included")
                : localized("fasting_days.summary.required_only", default: "required days only"),
        ]
        if fastingDaysIncludeFeastAndHolyDays {
            parts.append(localized("fasting_days.summary.celebrations", default: "celebration days included"))
        }
        return parts.joined(separator: " • ")
    }
}
