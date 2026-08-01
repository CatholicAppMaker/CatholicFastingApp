import SwiftUI

struct SettingsQuickSetupSection: View {
    let languageCode: String
    let setupChecklistCompleted: Int
    let setupChecklistTotal: Int
    let premiumUnlocked: Bool
    let dailyQuoteReminderTime: Binding<Date>
    let regionLabel: (RuleSettings.RegionProfile) -> String
    let reminderTierLabel: (ReminderTier) -> String
    let reminderTierSummary: (ReminderTier) -> String
    let applyReminderTier: (ReminderTier) -> Void
    let openPremiumUpgrade: () -> Void
    let requestNotificationPermission: () async -> String
    let scheduleRequiredDayReminders: () async -> String
    let scheduleDailyQuoteReminder: () async -> Void
    let scheduleDailySupportReminders: () async -> String
    let refreshReminderStatus: () async -> String

    @Binding var age14OrOlderForAbstinence: Bool
    @Binding var age18OrOlderForFasting: Bool
    @Binding var regionProfileRaw: String
    @Binding var languageModeRaw: String
    @Binding var acceptedLegalNotice: Bool
    @Binding var dailyReminderSupportEnabled: Bool
    @Binding var reminderTierRaw: String
    @Binding var dailyQuoteReminderEnabled: Bool
    @Binding var morningReminderEnabled: Bool
    @Binding var eveningReminderEnabled: Bool
    @Binding var notificationStatus: String

    var body: some View {
        Section(localized("settings.quick.title", default: "Quick Setup")) {
            AppSectionLeadCard(
                eyebrow: localized("settings.quick.title", default: "Quick Setup"),
                title: localizedFormat(
                    "settings.quick.progress_format",
                    default: "Setup checklist: %d/%d",
                    setupChecklistCompleted,
                    setupChecklistTotal),
                detail: localized(
                    "settings.quick.intro",
                    default: "Set these once, then mostly use Today and Calendar."),
                style: .utility)

            Toggle(
                localized("settings.quick.age14", default: "I am 14 or older (abstinence age)"),
                isOn: $age14OrOlderForAbstinence)
                .accessibilityIdentifier("settings.quick.age14_toggle")
            Toggle(
                localized("settings.quick.age18", default: "I am between 18 and 59 (fasting age)"),
                isOn: $age18OrOlderForFasting)
                .accessibilityIdentifier("settings.quick.age18_toggle")

            Text(localized(
                "settings.quick.age_helper",
                default: "People 60 and older should leave the fasting-age option off while keeping abstinence eligibility on."))
                .appSupportingTextStyle()

            Picker(
                localized("settings.quick.region", default: "Region profile"),
                selection: $regionProfileRaw)
            {
                ForEach(RuleSettings.RegionProfile.allCases) { option in
                    Text(regionLabel(option)).tag(option.rawValue)
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
                    default: "I understand that this is an independent devotional app, not an official app of the Catholic Church"),
                isOn: $acceptedLegalNotice)
                .accessibilityIdentifier("settings.quick.consent")

            reminderPreferences
            setupProgress

            if dailyReminderSupportEnabled {
                reminderActions
            }

            if !acceptedLegalNotice {
                Text(localized(
                    "settings.quick.enable_consent_hint",
                    default: "Enable consent above to request and schedule reminders."))
                    .appEyebrowStyle()
                    .foregroundStyle(CatholicTheme.warningForeground)
            }
        }
    }

    @ViewBuilder
    private var reminderPreferences: some View {
        Toggle(
            localized("settings.quick.reminder_support", default: "Enable reminder support"),
            isOn: $dailyReminderSupportEnabled)
            .accessibilityIdentifier("settings.quick.reminder_support")

        if dailyReminderSupportEnabled {
            Picker(
                localized("settings.quick.reminder_strategy", default: "Reminder strategy"),
                selection: $reminderTierRaw)
            {
                ForEach(ReminderTier.allCases) { tier in
                    Text("\(reminderTierLabel(tier)) - \(reminderTierSummary(tier))").tag(tier.rawValue)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("settings.quick.reminder_tier")
            .onChange(of: reminderTierRaw) { _, newValue in
                applyReminderTier(ReminderTier(rawValue: newValue) ?? .balanced)
            }
        } else {
            Text(localized(
                "settings.quick.reminder_support_hint",
                default: "Turn on reminder support to choose a strategy."))
                .appSupportingTextStyle()
        }

        Toggle(
            localized("settings.quick.quote_toggle", default: "Daily devotional quote reminder"),
            isOn: $dailyQuoteReminderEnabled)
            .accessibilityIdentifier("settings.quick.quote_toggle")

        if dailyQuoteReminderEnabled {
            DatePicker(
                localized("settings.quick.quote_time", default: "Quote reminder time"),
                selection: dailyQuoteReminderTime,
                displayedComponents: .hourAndMinute)
                .accessibilityIdentifier("settings.quick.quote_time")

            Text(localized(
                "settings.quick.quote_helper",
                default: "Receive one fasting quote each day from the saints, popes, and Catholic teachers already included in the app."))
                .appSupportingTextStyle()
        }
    }

    @ViewBuilder
    private var setupProgress: some View {
        Text(localizedFormat(
            "settings.quick.progress_format",
            default: "Setup checklist: %d/%d",
            setupChecklistCompleted,
            setupChecklistTotal))
            .appEyebrowStyle()
            .foregroundStyle(CatholicTheme.primary)
            .accessibilityIdentifier("settings.quick.progress")

        Text(localized(
            "settings.quick.progress_hint",
            default: "Language, region, consent, and reminders should stay easy to review here."))
            .appSupportingTextStyle()
    }

    private var reminderActions: some View {
        DisclosureGroup {
            if premiumUnlocked {
                Toggle(
                    localized("settings.quick.reminder_morning", default: "Morning check-in (7:00 AM)"),
                    isOn: $morningReminderEnabled)
                    .accessibilityIdentifier("settings.quick.reminder_morning")
                Toggle(
                    localized("settings.quick.reminder_evening", default: "Evening examen (8:00 PM)"),
                    isOn: $eveningReminderEnabled)
                    .accessibilityIdentifier("settings.quick.reminder_evening")
            } else {
                Text(localized(
                    "settings.quick.reminder_premium_required",
                    default: "Advanced support reminders require Premium."))
                    .appSupportingTextStyle()
                Button(
                    localized("settings.quick.unlock_support", default: "Unlock Support Reminders"),
                    action: openPremiumUpgrade)
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("settings.quick.unlock_support")
            }

            Text(notificationStatus)
                .appSupportingTextStyle()
                .accessibilityIdentifier("settings.quick.reminder_status")

            Button(localized("settings.quick.request_permission", default: "Request Notification Permission")) {
                Task { notificationStatus = await requestNotificationPermission() }
            }
            .appSecondaryButtonStyle()
            .disabled(!acceptedLegalNotice)
            .accessibilityIdentifier("settings.quick.request_permission")
            .accessibilityHint(localized(
                "settings.quick.permission_hint",
                default: "Requires consent acknowledgment before reminders are enabled."))

            Button(localized("settings.quick.schedule_required", default: "Schedule Required-Day Reminders")) {
                Task { notificationStatus = await scheduleRequiredDayReminders() }
            }
            .appSecondaryButtonStyle()
            .disabled(!acceptedLegalNotice)
            .accessibilityIdentifier("settings.quick.schedule_required")
            .accessibilityHint(localized(
                "settings.quick.schedule_required_hint",
                default: "Requires consent acknowledgment before scheduling."))

            Button(localized("settings.quick.schedule_quote", default: "Schedule Daily Quote Reminder")) {
                Task { await scheduleDailyQuoteReminder() }
            }
            .appSecondaryButtonStyle()
            .disabled(!acceptedLegalNotice || !dailyQuoteReminderEnabled)
            .accessibilityIdentifier("settings.quick.schedule_quote")
            .accessibilityHint(localized(
                "settings.quick.schedule_quote_hint",
                default: "Schedules one daily fasting quote at the selected time."))

            Button(localized("settings.quick.schedule_support", default: "Schedule Daily Support Reminders")) {
                Task { notificationStatus = await scheduleDailySupportReminders() }
            }
            .appPrimaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
            .disabled(!acceptedLegalNotice || !dailyReminderSupportEnabled || !premiumUnlocked)
            .accessibilityIdentifier("settings.quick.schedule_support")

            if !premiumUnlocked {
                Text(localized(
                    "settings.quick.support_premium_hint",
                    default: "Premium is required for daily support reminders beyond required-day alerts."))
                    .appEyebrowStyle()
            }

            Button(localized("settings.quick.refresh_status", default: "Refresh Reminder Status")) {
                Task { notificationStatus = await refreshReminderStatus() }
            }
            .appSecondaryButtonStyle()
            .accessibilityIdentifier("settings.quick.refresh_status")
        } label: {
            Text(localized("settings.quick.reminder_actions", default: "Reminder Actions"))
                .font(.headline)
        }
        .accessibilityIdentifier("settings.quick.reminder_actions")
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }

    private func localizedFormat(_ key: String, default defaultValue: String, _ arguments: CVarArg...) -> String {
        let format = localized(key, default: defaultValue)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}

struct SettingsProfileRulesSection: View {
    let languageCode: String
    @Binding var medicalDispensation: Bool
    @Binding var languageModeRaw: String

    var body: some View {
        Section(localized("settings.personal_profile.title", default: "Personal Profile")) {
            Toggle(
                localized("settings.personal_profile.dispensation", default: "Medical or pastoral dispensation"),
                isOn: $medicalDispensation)
                .accessibilityHint(localized(
                    "settings.personal_profile.dispensation_hint",
                    default: "Enable when fasting obligations do not bind due to health or pastoral reasons."))

            Picker(localized("settings.personal_profile.language", default: "Language"), selection: $languageModeRaw) {
                ForEach(LanguageMode.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }

            Text(localized(
                "settings.personal_profile.age_eligibility_hint",
                default: "Age eligibility is managed in Setup & Reminders so it stays easy to review."))
                .appSupportingTextStyle()
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

struct SettingsRegionalNormsSection: View {
    let languageCode: String
    let pastoralGuidance: String
    let regionLabel: (RuleSettings.RegionProfile) -> String
    let fridayModeLabel: (RuleSettings.FridayOutsideLentMode) -> String
    @Binding var regionProfileRaw: String
    @Binding var ascensionRaw: String
    @Binding var fridayModeRaw: String

    var body: some View {
        Section(localized("settings.regional_norms.title", default: "Church Norms")) {
            Picker(
                localized("settings.regional_norms.region_profile", default: "Region Profile"),
                selection: $regionProfileRaw)
            {
                ForEach(RuleSettings.RegionProfile.allCases) { option in
                    Text(regionLabel(option)).tag(option.rawValue)
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
            .accessibilityHint(localized(
                "settings.regional_norms.ascension_day_hint",
                default: "Set whether Ascension is observed on Thursday or Sunday."))

            Picker(
                localized("settings.regional_norms.fridays_outside_lent", default: "Fridays Outside Lent"),
                selection: $fridayModeRaw)
            {
                ForEach(RuleSettings.FridayOutsideLentMode.allCases) { option in
                    Text(fridayModeLabel(option)).tag(option.rawValue)
                }
            }
            .accessibilityHint(localized(
                "settings.regional_norms.fridays_outside_lent_hint",
                default: "Choose abstinence from meat or another penitential act."))

            Text(pastoralGuidance)
                .appSupportingTextStyle()
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}

struct SettingsLiturgicalThemeSection: View {
    let languageCode: String
    let currentSeasonLabel: String
    @Binding var liturgicalSeasonColorsEnabled: Bool

    var body: some View {
        Section(localized("settings.theme.title", default: "Liturgical Theme")) {
            Toggle(
                localized("settings.theme.enable_liturgical_colors", default: "Enable Liturgical Season Colors"),
                isOn: $liturgicalSeasonColorsEnabled)
                .accessibilityIdentifier("settings.liturgical_theme_toggle")
            Text(
                liturgicalSeasonColorsEnabled
                    ? localizedFormat(
                        "settings.theme.active_season_format",
                        default: "Active season: %@. Colors update automatically throughout the liturgical year.",
                        currentSeasonLabel)
                    : localized(
                        "settings.theme.disabled_hint",
                        default: "Season-based colors are off. The Ordinary Time palette will stay in use year-round."))
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("settings.liturgical_theme_context")
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }

    private func localizedFormat(_ key: String, default defaultValue: String, _ arguments: CVarArg...) -> String {
        let format = localized(key, default: defaultValue)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}

struct SettingsHouseholdProfilesSection: View {
    let languageCode: String
    let profiles: [HouseholdProfile]
    let activeProfile: HouseholdProfile?
    let canAddProfile: Bool
    let applyActiveProfile: () -> Void
    let addProfile: () -> Void
    @Binding var activeProfileID: String
    @Binding var newProfileName: String

    var body: some View {
        Section(localized("settings.household.title", default: "Household Profiles")) {
            Text(localized(
                "settings.household.intro",
                default: "Use profiles only if you manage fasting guidance for more than one person on this device."))
                .font(.caption)
                .foregroundStyle(.secondary)

            if profiles.isEmpty {
                Text(localized(
                    "settings.household.empty",
                    default: "No profiles yet. Add one if you manage fasting settings for family members."))
                    .foregroundStyle(.secondary)
            } else {
                Picker(
                    localized("settings.household.active", default: "Active Profile"),
                    selection: $activeProfileID)
                {
                    ForEach(profiles) { profile in
                        Text(profile.name).tag(profile.id)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings.household.active")

                if let activeProfile {
                    Text(activeProfileSummary(activeProfile))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button(
                    localized("settings.household.apply", default: "Apply Active Profile"),
                    action: applyActiveProfile)
                    .appSecondaryButtonStyle()
                    .accessibilityIdentifier("settings.household.apply")
            }

            TextField(
                localized("settings.household.new_name", default: "Add profile name"),
                text: $newProfileName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .accessibilityIdentifier("settings.household.new_name")

            Button(localized("settings.household.add", default: "Add Profile"), action: addProfile)
                .appPrimaryButtonStyle()
                .disabled(!canAddProfile)
                .accessibilityIdentifier("settings.household.add")

            Text(localized(
                "settings.household.footer",
                default: "Profiles store local age-eligibility and dispensation settings only."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func activeProfileSummary(_ profile: HouseholdProfile) -> String {
        localizedFormat(
            "settings.household.active_summary",
            default: "Active: %@ • Abstinence: %@ • Fasting: %@",
            profile.name,
            profile.isAge14OrOlderForAbstinence
                ? localized("settings.household.abstinence_14_plus", default: "14+")
                : localized("settings.household.abstinence_under_14", default: "Under 14"),
            profile.isAge18OrOlderForFasting
                ? localized("settings.household.fasting_18_59", default: "18-59")
                : localized("settings.household.fasting_not_age", default: "Not fasting age"))
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }

    private func localizedFormat(_ key: String, default defaultValue: String, _ arguments: CVarArg...) -> String {
        let format = localized(key, default: defaultValue)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}

struct SettingsPlanningSection: View {
    let languageCode: String
    let requiredProgress: Double
    let optionalProgress: Double
    let yearlyRequiredCompletions: Int
    let yearlyOptionalCompletions: Int
    let currentSeasonCommitments: [SeasonCommitment]
    let canAddCommitment: Bool
    let addCommitment: () -> Void
    @Binding var planningData: FastingPlanningData
    @Binding var newCommitmentTitle: String

    var body: some View {
        Section(localized("settings.planning.title", default: "Planning")) {
            Text(localized(
                "settings.planning.intro",
                default: "Optional planning tools for personal goals and seasonal commitments."))
                .font(.caption)
                .foregroundStyle(.secondary)

            DisclosureGroup(localized("settings.planning.disclosure", default: "Show planning options")) {
                Stepper(
                    localizedFormat(
                        "settings.planning.required_goal",
                        default: "Year required observance goal: %d",
                        planningData.requiredGoal),
                    value: $planningData.requiredGoal,
                    in: 1 ... 120)
                    .accessibilityIdentifier("settings.plan.required_goal")

                Stepper(
                    localizedFormat(
                        "settings.planning.optional_goal",
                        default: "Year optional observance goal: %d",
                        planningData.optionalGoal),
                    value: $planningData.optionalGoal,
                    in: 1 ... 240)
                    .accessibilityIdentifier("settings.plan.optional_goal")

                ProgressView(value: requiredProgress) {
                    Text(localizedFormat(
                        "settings.planning.required_progress",
                        default: "Required rhythm: %d/%d",
                        yearlyRequiredCompletions,
                        planningData.requiredGoal))
                }
                ProgressView(value: optionalProgress) {
                    Text(localizedFormat(
                        "settings.planning.optional_progress",
                        default: "Optional rhythm: %d/%d",
                        yearlyOptionalCompletions,
                        planningData.optionalGoal))
                }

                if !planningData.weeklyIntentions.isEmpty {
                    ForEach(planningData.weeklyIntentions) { intention in
                        Text(localizedFormat(
                            "settings.planning.weekday_note",
                            default: "Weekday %d: %@",
                            intention.weekday,
                            intention.note))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if currentSeasonCommitments.isEmpty {
                    Text(localized(
                        "settings.planning.empty",
                        default: "No active commitments for this season yet."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                TextField(
                    localized(
                        "settings.planning.new_commitment",
                        default: "New commitment for current season"),
                    text: $newCommitmentTitle)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("settings.plan.new_commitment")

                Button(
                    localized(
                        "settings.planning.add_commitment",
                        default: "Add Current Season Commitment"),
                    action: addCommitment)
                    .appSecondaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
                    .disabled(!canAddCommitment)
                    .accessibilityIdentifier("settings.plan.add_commitment")
            }
            .accessibilityIdentifier("settings.plan.disclosure")
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }

    private func localizedFormat(_ key: String, default defaultValue: String, _ arguments: CVarArg...) -> String {
        let format = localized(key, default: defaultValue)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}

struct SettingsAccessibilitySection: View {
    let languageCode: String
    @Binding var simplifiedModeEnabled: Bool
    @Binding var hapticsEnabled: Bool

    var body: some View {
        Section(localized("settings.accessibility.title", default: "Accessibility")) {
            Toggle(
                localized("settings.accessibility.simplified_mode", default: "Simplified Mode"),
                isOn: $simplifiedModeEnabled)
                .accessibilityIdentifier("settings.accessibility.simplified_mode")

            DisclosureGroup(localized("settings.accessibility.advanced", default: "Advanced accessibility options")) {
                Toggle(
                    localized("settings.accessibility.haptics", default: "Haptic Alerts"),
                    isOn: $hapticsEnabled)
                    .accessibilityIdentifier("settings.accessibility.haptics")
            }
            .accessibilityIdentifier("settings.accessibility.advanced")

            Text(localized(
                "settings.accessibility.footer",
                default: "Simplified mode reduces visual density on Today. Haptic alerts notify when intermittent fasting milestones are reached."))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }
}
