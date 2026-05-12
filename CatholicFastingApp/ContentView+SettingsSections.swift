import SwiftUI

extension ContentView {
    var quickSetupSection: some View {
        Section(localized("settings.quick.title", default: "Quick Setup")) {
            AppSectionLeadCard(
                eyebrow: localized("settings.quick.title", default: "Quick Setup"),
                title: localizedFormat("settings.quick.progress_format", default: "Setup progress: %d/%d", setupChecklistCompleted, setupChecklistTotal),
                detail: localized("settings.quick.intro", default: "Set these once, then mostly use Today and Fasting Days."),
                style: .utility)

            Toggle(localized("settings.quick.age14", default: "I am 14 or older (abstinence age)"), isOn: $age14OrOlderForAbstinence)
                .accessibilityIdentifier("settings.quick.age14_toggle")
            Toggle(localized("settings.quick.age18", default: "I am 18 or older (fasting age)"), isOn: $age18OrOlderForFasting)
                .accessibilityIdentifier("settings.quick.age18_toggle")

            Picker(localized("settings.quick.region", default: "Region profile"), selection: $regionProfileRaw) {
                ForEach(RuleSettings.RegionProfile.allCases) { option in
                    Text(localizedRegionLabel(option)).tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("settings.quick.region")

            Picker(localized("settings.quick.language", default: "Language"), selection: $languageModeRaw) {
                ForEach(LanguageMode.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("settings.quick.language")

            Toggle(
                localized(
                    "settings.quick.consent_label",
                    default: "I understand this is an independent app, not an official Church authority app"),
                isOn: $acceptedLegalNotice)
                .accessibilityIdentifier("settings.quick.consent")

            Toggle(localized("settings.quick.reminder_support", default: "Enable reminder support"), isOn: $dailyReminderSupportEnabled)
                .accessibilityIdentifier("settings.quick.reminder_support")
            if dailyReminderSupportEnabled {
                Picker(localized("settings.quick.reminder_strategy", default: "Reminder strategy"), selection: $reminderTierRaw) {
                    ForEach(ReminderTier.allCases) { tier in
                        Text("\(localizedReminderTierLabel(tier)) - \(localizedReminderTierSummary(tier))").tag(tier.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings.quick.reminder_tier")
                .onChange(of: reminderTierRaw) { _, newValue in
                    applyReminderTier(ReminderTier(rawValue: newValue) ?? .balanced)
                }
            } else {
                Text(localized("settings.quick.reminder_support_hint", default: "Turn on reminder support to choose a strategy."))
                    .appSupportingTextStyle()
            }

            Toggle(
                localized(
                    "settings.quick.quote_toggle",
                    default: "Daily devotional quote reminder"),
                isOn: $dailyQuoteReminderEnabled)
                .accessibilityIdentifier("settings.quick.quote_toggle")

            if dailyQuoteReminderEnabled {
                DatePicker(
                    localized("settings.quick.quote_time", default: "Quote reminder time"),
                    selection: dailyQuoteReminderTimeBinding,
                    displayedComponents: .hourAndMinute)
                    .accessibilityIdentifier("settings.quick.quote_time")

                Text(
                    localized(
                        "settings.quick.quote_helper",
                        default: "Receive one fasting quote each day from the saints, popes, and Catholic teachers already included in the app."))
                    .appSupportingTextStyle()
            }

            Text(localizedFormat("settings.quick.progress_format", default: "Setup progress: %d/%d", setupChecklistCompleted, setupChecklistTotal))
                .appEyebrowStyle()
                .foregroundStyle(CatholicTheme.primary)
                .accessibilityIdentifier("settings.quick.progress")

            Text(localized("settings.quick.progress_hint", default: "Language, region, consent, and reminders should stay easy to review here."))
                .appSupportingTextStyle()

            if dailyReminderSupportEnabled {
                DisclosureGroup(localized("settings.quick.reminder_actions", default: "Reminder Actions")) {
                    if monetizationStore.premiumUnlocked {
                        Toggle(localized("settings.quick.reminder_morning", default: "Morning check-in (7:00 AM)"), isOn: $morningReminderEnabled)
                            .accessibilityIdentifier("settings.quick.reminder_morning")
                        Toggle(localized("settings.quick.reminder_evening", default: "Evening examen (8:00 PM)"), isOn: $eveningReminderEnabled)
                            .accessibilityIdentifier("settings.quick.reminder_evening")
                    } else {
                        Text(localized("settings.quick.reminder_premium_required", default: "Advanced support reminders require Premium."))
                            .appSupportingTextStyle()
                        Button(localized("settings.quick.unlock_support", default: "Unlock Support Reminders")) {
                            openPremiumUpgrade(focusingOn: .accountability)
                        }
                        .appSecondaryButtonStyle()
                        .accessibilityIdentifier("settings.quick.unlock_support")
                    }

                    Text(notificationStatus)
                        .appSupportingTextStyle()
                        .accessibilityIdentifier("settings.quick.reminder_status")

                    Button(localized("settings.quick.request_permission", default: "Request Notification Permission")) {
                        Task {
                            notificationStatus = await ReminderScheduler.requestPermission()
                        }
                    }
                    .appSecondaryButtonStyle()
                    .disabled(!acceptedLegalNotice)
                    .accessibilityIdentifier("settings.quick.request_permission")
                    .accessibilityHint(localized("settings.quick.permission_hint", default: "Requires consent acknowledgment before reminders are enabled."))

                    Button(localized("settings.quick.schedule_required", default: "Schedule Required-Day Reminders")) {
                        Task {
                            notificationStatus = await ReminderScheduler.schedule(observances: rollingUpcomingObservances)
                        }
                    }
                    .appSecondaryButtonStyle()
                    .disabled(!acceptedLegalNotice)
                    .accessibilityIdentifier("settings.quick.schedule_required")
                    .accessibilityHint(localized("settings.quick.schedule_required_hint", default: "Requires consent acknowledgment before scheduling."))

                    Button(localized("settings.quick.schedule_quote", default: "Schedule Daily Quote Reminder")) {
                        Task {
                            await scheduleDailyQuoteReminderFromCurrentSettings()
                        }
                    }
                    .appSecondaryButtonStyle()
                    .disabled(!acceptedLegalNotice || !dailyQuoteReminderEnabled)
                    .accessibilityIdentifier("settings.quick.schedule_quote")
                    .accessibilityHint(localized("settings.quick.schedule_quote_hint", default: "Schedules one daily fasting quote at the selected time."))

                    Button(localized("settings.quick.schedule_support", default: "Schedule Daily Support Reminders")) {
                        Task {
                            notificationStatus = await ReminderScheduler.scheduleHabitSupport(
                                morning: dailyReminderSupportEnabled && morningReminderEnabled,
                                evening: dailyReminderSupportEnabled && eveningReminderEnabled)
                        }
                    }
                    .appPrimaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
                    .disabled(
                        !acceptedLegalNotice || !dailyReminderSupportEnabled || !monetizationStore.premiumUnlocked)
                    .accessibilityIdentifier("settings.quick.schedule_support")

                    if !monetizationStore.premiumUnlocked {
                        Text(
                            localized(
                                "settings.quick.support_premium_hint",
                                default: "Premium is required for daily support reminders beyond required-day alerts."))
                            .appEyebrowStyle()
                    }

                    Button(localized("settings.quick.refresh_status", default: "Refresh Reminder Status")) {
                        Task {
                            notificationStatus = await ReminderScheduler.notificationSummary()
                        }
                    }
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("settings.quick.refresh_status")
                }
                .accessibilityIdentifier("settings.quick.reminder_actions")
            }

            if !acceptedLegalNotice {
                Text(localized("settings.quick.enable_consent_hint", default: "Enable consent above to request and schedule reminders."))
                    .appEyebrowStyle()
                    .foregroundStyle(CatholicTheme.warningForeground)
            }
        }
    }

    var profileRulesSection: some View {
        Section(localized("settings.personal_profile.title", default: "Personal Profile")) {
            Toggle(
                localized(
                    "settings.personal_profile.dispensation", default: "Medical or pastoral dispensation"),
                isOn: $medicalDispensation)
                .accessibilityHint(
                    localized(
                        "settings.personal_profile.dispensation_hint",
                        default: "Enable when fasting obligations do not bind due to health or pastoral reasons."))

            Picker(
                localized("settings.personal_profile.language", default: "Language"),
                selection: $languageModeRaw)
            {
                ForEach(LanguageMode.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }

            Text(localized("settings.personal_profile.age_eligibility_hint", default: "Age eligibility is managed in Setup & Reminders so it stays easy to review."))
                .appSupportingTextStyle()
        }
    }

    var regionalNormsSection: some View {
        Section(localized("settings.regional_norms.title", default: "Church Norms")) {
            Picker(localized("settings.regional_norms.region_profile", default: "Region Profile"), selection: $regionProfileRaw) {
                ForEach(RuleSettings.RegionProfile.allCases) { option in
                    Text(localizedRegionLabel(option)).tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("settings.region_picker")

            Picker(
                localized("settings.regional_norms.ascension_day", default: "Ascension Day"),
                selection: $ascensionRaw)
            {
                ForEach(RuleSettings.AscensionObservance.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .accessibilityHint(
                localized(
                    "settings.regional_norms.ascension_day_hint",
                    default: "Set whether Ascension is observed on Thursday or Sunday."))

            Picker(
                localized("settings.regional_norms.fridays_outside_lent", default: "Fridays Outside Lent"),
                selection: $fridayModeRaw)
            {
                ForEach(RuleSettings.FridayOutsideLentMode.allCases) { option in
                    Text(localizedFridayModeLabel(option)).tag(option.rawValue)
                }
            }
            .accessibilityHint(
                localized(
                    "settings.regional_norms.fridays_outside_lent_hint",
                    default: "Choose abstinence from meat or another penitential act."))
            Text(
                regionPastoralGuidanceText)
                .appSupportingTextStyle()
        }
    }

    var themeSection: some View {
        Section(localized("settings.theme.title", default: "Liturgical Theme")) {
            Toggle(
                localized(
                    "settings.theme.enable_liturgical_colors", default: "Enable Liturgical Season Colors"),
                isOn: $liturgicalSeasonColorsEnabled)
                .accessibilityIdentifier("settings.liturgical_theme_toggle")
            Text(
                liturgicalSeasonColorsEnabled
                    ? localizedFormat(
                        "settings.theme.active_season_format",
                        default:
                        "Active season: %@. Colors update automatically throughout the liturgical year.",
                        localizedSeasonLabel(currentLiturgicalSeason))
                    : localized(
                        "settings.theme.disabled_hint",
                        default:
                        "Season-based colors are off. Turn this on for Advent, Lent, Easter, and Ordinary Time palettes."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var householdProfilesSection: some View {
        Section(localized("settings.household.title", default: "Household Profiles")) {
            Text(localized("settings.household.intro", default: "Use profiles only if you manage fasting guidance for more than one person on this device."))
                .font(.caption)
                .foregroundStyle(.secondary)
            if householdProfiles.isEmpty {
                Text(localized("settings.household.empty", default: "No profiles yet. Add one if you manage fasting settings for family members."))
                    .foregroundStyle(.secondary)
            } else {
                Picker(localized("settings.household.active", default: "Active Profile"), selection: $activeHouseholdProfileID) {
                    ForEach(householdProfiles) { profile in
                        Text(profile.name).tag(profile.id)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings.household.active")

                if let active = activeHouseholdProfile {
                    Text(
                        localizedFormat(
                            "settings.household.active_summary",
                            default: "Active: %@ • Abstinence: %@ • Fasting: %@",
                            active.name,
                            active.isAge14OrOlderForAbstinence
                                ? localized("settings.household.abstinence_14_plus", default: "14+")
                                : localized("settings.household.abstinence_under_14", default: "Under 14"),
                            active.isAge18OrOlderForFasting
                                ? localized("settings.household.fasting_18_59", default: "18-59")
                                : localized("settings.household.fasting_not_age", default: "Not fasting age")))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button(localized("settings.household.apply", default: "Apply Active Profile")) {
                    applyActiveHouseholdProfile()
                }
                .appSecondaryButtonStyle()
                .accessibilityIdentifier("settings.household.apply")
            }

            TextField(localized("settings.household.new_name", default: "Add profile name"), text: $newHouseholdProfileName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .accessibilityIdentifier("settings.household.new_name")

            Button(localized("settings.household.add", default: "Add Profile")) {
                addHouseholdProfile()
            }
            .appPrimaryButtonStyle()
            .disabled(!canAddHouseholdProfile)
            .accessibilityIdentifier("settings.household.add")

            Text(localized("settings.household.footer", default: "Profiles store local age-eligibility and dispensation settings only."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var planningLayerSection: some View {
        Section(localized("settings.planning.title", default: "Planning")) {
            Text(localized("settings.planning.intro", default: "Optional planning tools for personal goals and seasonal commitments."))
                .font(.caption)
                .foregroundStyle(.secondary)
            DisclosureGroup(localized("settings.planning.disclosure", default: "Show planning options")) {
                Stepper(
                    localizedFormat("settings.planning.required_goal", default: "Year required observance goal: %d", planningData.requiredGoal),
                    value: $planningData.requiredGoal,
                    in: 1 ... 120)
                    .accessibilityIdentifier("settings.plan.required_goal")

                Stepper(
                    localizedFormat("settings.planning.optional_goal", default: "Year optional observance goal: %d", planningData.optionalGoal),
                    value: $planningData.optionalGoal,
                    in: 1 ... 240)
                    .accessibilityIdentifier("settings.plan.optional_goal")

                ProgressView(value: requirementGoalProgress) {
                    Text(localizedFormat("settings.planning.required_progress", default: "Required progress: %d/%d", yearlyRequiredCompletions, planningData.requiredGoal))
                }
                ProgressView(value: optionalGoalProgress) {
                    Text(localizedFormat("settings.planning.optional_progress", default: "Optional progress: %d/%d", yearlyOptionalCompletions, planningData.optionalGoal))
                }

                if !planningData.weeklyIntentions.isEmpty {
                    ForEach(planningData.weeklyIntentions) { intention in
                        Text(localizedFormat("settings.planning.weekday_note", default: "Weekday %d: %@", intention.weekday, intention.note))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if currentSeasonCommitments.isEmpty {
                    Text(localized("settings.planning.empty", default: "No active commitments for this season yet."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                TextField(localized("settings.planning.new_commitment", default: "New commitment for current season"), text: $newSeasonCommitmentTitle)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("settings.plan.new_commitment")

                Button(localized("settings.planning.add_commitment", default: "Add Current Season Commitment")) {
                    addSeasonCommitment()
                }
                .appSecondaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
                .disabled(!canAddSeasonCommitment)
                .accessibilityIdentifier("settings.plan.add_commitment")
            }
            .accessibilityIdentifier("settings.plan.disclosure")
        }
    }

    var accessibilityModeSection: some View {
        Section(localized("settings.accessibility.title", default: "Accessibility")) {
            Toggle(localized("settings.accessibility.simplified_mode", default: "Simplified Mode"), isOn: $simplifiedModeEnabled)
                .accessibilityIdentifier("settings.accessibility.simplified_mode")

            DisclosureGroup(localized("settings.accessibility.advanced", default: "Advanced accessibility options")) {
                Toggle(localized("settings.accessibility.haptics", default: "Haptic Alerts"), isOn: $hapticsEnabled)
                    .accessibilityIdentifier("settings.accessibility.haptics")
            }
            .accessibilityIdentifier("settings.accessibility.advanced")

            Text(
                localized(
                    "settings.accessibility.footer",
                    default: "Simplified mode reduces visual density on Today. Haptic alerts notify when intermittent fasting milestones are reached."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var regionPastoralGuidanceText: String {
        let region = RuleSettings.RegionProfile(rawValue: regionProfileRaw) ?? .us
        switch region {
        case .us:
            return localized(
                "settings.region_guidance.us",
                default:
                "United States profile: Ash Wednesday and Good Friday are fast and abstinence days, Fridays of Lent are abstinence, and Fridays outside Lent are penitential.")
        case .canada:
            return localized(
                "settings.region_guidance.canada",
                default:
                "Canada profile: the app models the national baseline, including Canada-wide holy day obligations " +
                    "and CCCB Friday guidance. Diocesan proper calendars are not included yet.")
        case .other:
            return localized(
                "settings.region_guidance.other",
                default: "Outside U.S./Canada: follow your local bishop conference, parish guidance, and your pastor for binding norms.")
        }
    }

    func localizedRegionLabel(_ option: RuleSettings.RegionProfile) -> String {
        switch option {
        case .us:
            localized("onboarding.region.us", default: option.label)
        case .canada:
            localized("onboarding.region.canada", default: option.label)
        case .other:
            localized("onboarding.region.other", default: option.label)
        }
    }

    func localizedFridayModeLabel(_ option: RuleSettings.FridayOutsideLentMode) -> String {
        switch option {
        case .abstainFromMeat:
            localized("onboarding.friday.abstain", default: option.label)
        case .substitutePenance:
            localized("onboarding.friday.substitute", default: option.label)
        }
    }

    func localizedReminderTierLabel(_ tier: ReminderTier) -> String {
        switch tier {
        case .minimal:
            localized("onboarding.reminder.minimal.label", default: tier.label)
        case .balanced:
            localized("onboarding.reminder.balanced.label", default: tier.label)
        case .guided:
            localized("onboarding.reminder.guided.label", default: tier.label)
        }
    }

    func localizedReminderTierSummary(_ tier: ReminderTier) -> String {
        switch tier {
        case .minimal:
            localized("onboarding.reminder.minimal.summary", default: tier.summary)
        case .balanced:
            localized("onboarding.reminder.balanced.summary", default: tier.summary)
        case .guided:
            localized("onboarding.reminder.guided.summary", default: tier.summary)
        }
    }
}
