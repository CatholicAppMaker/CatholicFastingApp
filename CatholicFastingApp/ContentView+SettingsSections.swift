import SwiftUI

extension ContentView {
    var quickSetupSection: some View {
        Section("Quick Setup") {
            Text("Set these once, then mostly use Today and Fasting Days.")
                .appLeadTextStyle()

            Toggle("I am 14 or older (abstinence age)", isOn: $age14OrOlderForAbstinence)
                .accessibilityIdentifier("settings.quick.age14_toggle")
            Toggle("I am 18 or older (fasting age)", isOn: $age18OrOlderForFasting)
                .accessibilityIdentifier("settings.quick.age18_toggle")

            Picker("Region profile", selection: $regionProfileRaw) {
                ForEach(RuleSettings.RegionProfile.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("settings.quick.region")

            Picker("Language", selection: $languageModeRaw) {
                ForEach(LanguageMode.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("settings.quick.language")

            Toggle(
                "I understand this is an independent app, not an official Church authority app",
                isOn: $acceptedLegalNotice
            )
            .accessibilityIdentifier("settings.quick.consent")

            Toggle("Enable reminder support", isOn: $dailyReminderSupportEnabled)
                .accessibilityIdentifier("settings.quick.reminder_support")
            if dailyReminderSupportEnabled {
                Picker("Reminder strategy", selection: $reminderTierRaw) {
                    ForEach(ReminderTier.allCases) { tier in
                        Text("\(tier.label) - \(tier.summary)").tag(tier.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings.quick.reminder_tier")
                .onChange(of: reminderTierRaw) { _, newValue in
                    applyReminderTier(ReminderTier(rawValue: newValue) ?? .balanced)
                }
            } else {
                Text("Turn on reminder support to choose a strategy.")
                    .appSupportingTextStyle()
            }

            Text("Setup progress: \(setupChecklistCompleted)/\(setupChecklistTotal)")
                .appEyebrowStyle()
                .foregroundStyle(CatholicTheme.primary)
                .accessibilityIdentifier("settings.quick.progress")

            if dailyReminderSupportEnabled {
                DisclosureGroup("Reminder Actions") {
                    if monetizationStore.premiumUnlocked {
                        Toggle("Morning check-in (7:00 AM)", isOn: $morningReminderEnabled)
                            .accessibilityIdentifier("settings.quick.reminder_morning")
                        Toggle("Evening examen (8:00 PM)", isOn: $eveningReminderEnabled)
                            .accessibilityIdentifier("settings.quick.reminder_evening")
                    } else {
                        Text("Advanced support reminders require Premium.")
                            .appSupportingTextStyle()
                        Button("Unlock Support Reminders") {
                            openPremiumUpgrade(focusingOn: .accountability)
                        }
                        .appSecondaryButtonStyle()
                        .accessibilityIdentifier("settings.quick.unlock_support")
                    }

                    Text(notificationStatus)
                        .appSupportingTextStyle()
                        .accessibilityIdentifier("settings.quick.reminder_status")

                    Button("Request Notification Permission") {
                        Task {
                            notificationStatus = await ReminderScheduler.requestPermission()
                        }
                    }
                    .appSecondaryButtonStyle()
                    .disabled(!acceptedLegalNotice)
                    .accessibilityIdentifier("settings.quick.request_permission")
                    .accessibilityHint("Requires consent acknowledgment before reminders are enabled.")

                    Button("Schedule Required-Day Reminders") {
                        Task {
                            notificationStatus = await ReminderScheduler.schedule(observances: rollingUpcomingObservances)
                        }
                    }
                    .appSecondaryButtonStyle()
                    .disabled(!acceptedLegalNotice)
                    .accessibilityIdentifier("settings.quick.schedule_required")
                    .accessibilityHint("Requires consent acknowledgment before scheduling.")

                    Button("Schedule Daily Support Reminders") {
                        Task {
                            notificationStatus = await ReminderScheduler.scheduleHabitSupport(
                                morning: dailyReminderSupportEnabled && morningReminderEnabled,
                                evening: dailyReminderSupportEnabled && eveningReminderEnabled
                            )
                        }
                    }
                    .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
                    .disabled(
                        !acceptedLegalNotice || !dailyReminderSupportEnabled || !monetizationStore.premiumUnlocked
                    )
                    .accessibilityIdentifier("settings.quick.schedule_support")

                    if !monetizationStore.premiumUnlocked {
                        Text("Premium is required for daily support reminders beyond required-day alerts.")
                            .appEyebrowStyle()
                    }

                    Button("Refresh Reminder Status") {
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
                Text("Enable consent above to request and schedule reminders.")
                    .appEyebrowStyle()
                    .foregroundStyle(.orange)
            }
        }
    }

    var profileRulesSection: some View {
        Section(localized("settings.personal_profile.title", default: "Personal Profile")) {
            Toggle(
                localized(
                    "settings.personal_profile.dispensation", default: "Medical or pastoral dispensation"
                ),
                isOn: $medicalDispensation
            )
            .accessibilityHint(
                localized(
                    "settings.personal_profile.dispensation_hint",
                    default: "Enable when fasting obligations do not bind due to health or pastoral reasons."
                )
            )

            Picker(
                localized("settings.personal_profile.language", default: "Language"),
                selection: $languageModeRaw
            ) {
                ForEach(LanguageMode.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }

            Text("Age eligibility is managed in Setup & Reminders so it stays easy to review.")
                .appSupportingTextStyle()
        }
    }

    var regionalNormsSection: some View {
        Section(localized("settings.regional_norms.title", default: "Church Norms")) {
            Picker("Region Profile", selection: $regionProfileRaw) {
                ForEach(RuleSettings.RegionProfile.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("settings.region_picker")

            Picker(
                localized("settings.regional_norms.ascension_day", default: "Ascension Day"),
                selection: $ascensionRaw
            ) {
                ForEach(RuleSettings.AscensionObservance.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .accessibilityHint(
                localized(
                    "settings.regional_norms.ascension_day_hint",
                    default: "Set whether Ascension is observed on Thursday or Sunday."
                )
            )

            Picker(
                localized("settings.regional_norms.fridays_outside_lent", default: "Fridays Outside Lent"),
                selection: $fridayModeRaw
            ) {
                ForEach(RuleSettings.FridayOutsideLentMode.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            .accessibilityHint(
                localized(
                    "settings.regional_norms.fridays_outside_lent_hint",
                    default: "Choose abstinence from meat or another penitential act."
                )
            )
            Text(
                regionPastoralGuidanceText
            )
            .appSupportingTextStyle()
        }
    }

    var themeSection: some View {
        Section(localized("settings.theme.title", default: "Liturgical Theme")) {
            Toggle(
                localized(
                    "settings.theme.enable_liturgical_colors", default: "Enable Liturgical Season Colors"
                ),
                isOn: $liturgicalSeasonColorsEnabled
            )
            .accessibilityIdentifier("settings.liturgical_theme_toggle")
            Text(
                liturgicalSeasonColorsEnabled
                    ? localizedFormat(
                        "settings.theme.active_season_format",
                        default:
                        "Active season: %@. Colors update automatically throughout the liturgical year.",
                        CatholicTheme.seasonLabel
                    )
                    : localized(
                        "settings.theme.disabled_hint",
                        default:
                        "Season-based colors are off. Turn this on for Advent, Lent, Easter, and Ordinary Time palettes."
                    )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    var householdProfilesSection: some View {
        Section("Household Profiles") {
            Text("Use profiles only if you manage fasting guidance for more than one person on this device.")
                .font(.caption)
                .foregroundStyle(.secondary)
            if householdProfiles.isEmpty {
                Text("No profiles yet. Add one if you manage fasting settings for family members.")
                    .foregroundStyle(.secondary)
            } else {
                Picker("Active Profile", selection: $activeHouseholdProfileID) {
                    ForEach(householdProfiles) { profile in
                        Text(profile.name).tag(profile.id)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("settings.household.active")

                if let active = activeHouseholdProfile {
                    Text(
                        "Active: \(active.name) • Abstinence: \(active.isAge14OrOlderForAbstinence ? "14+" : "Under 14") • Fasting: \(active.isAge18OrOlderForFasting ? "18-59" : "Not fasting age")"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Button("Apply Active Profile") {
                    applyActiveHouseholdProfile()
                }
                .appSecondaryButtonStyle()
                .accessibilityIdentifier("settings.household.apply")
            }

            TextField("Add profile name", text: $newHouseholdProfileName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .accessibilityIdentifier("settings.household.new_name")

            Button("Add Profile") {
                addHouseholdProfile()
            }
            .appPrimaryButtonStyle()
            .disabled(!canAddHouseholdProfile)
            .accessibilityIdentifier("settings.household.add")

            Text("Profiles store local age-eligibility and dispensation settings only.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    var planningLayerSection: some View {
        Section("Planning") {
            Text("Optional planning tools for personal goals and seasonal commitments.")
                .font(.caption)
                .foregroundStyle(.secondary)
            DisclosureGroup("Show planning options") {
                Stepper(
                    "Year required observance goal: \(planningData.requiredGoal)",
                    value: $planningData.requiredGoal,
                    in: 1 ... 120
                )
                .accessibilityIdentifier("settings.plan.required_goal")

                Stepper(
                    "Year optional observance goal: \(planningData.optionalGoal)",
                    value: $planningData.optionalGoal,
                    in: 1 ... 240
                )
                .accessibilityIdentifier("settings.plan.optional_goal")

                ProgressView(value: requirementGoalProgress) {
                    Text("Required progress: \(yearlyRequiredCompletions)/\(planningData.requiredGoal)")
                }
                ProgressView(value: optionalGoalProgress) {
                    Text("Optional progress: \(yearlyOptionalCompletions)/\(planningData.optionalGoal)")
                }

                if !planningData.weeklyIntentions.isEmpty {
                    ForEach(planningData.weeklyIntentions) { intention in
                        Text("Weekday \(intention.weekday): \(intention.note)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if currentSeasonCommitments.isEmpty {
                    Text("No active commitments for this season yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                TextField("New commitment for current season", text: $newSeasonCommitmentTitle)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("settings.plan.new_commitment")

                Button("Add Current Season Commitment") {
                    addSeasonCommitment()
                }
                .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)
                .disabled(!canAddSeasonCommitment)
                .accessibilityIdentifier("settings.plan.add_commitment")
            }
            .accessibilityIdentifier("settings.plan.disclosure")
        }
    }

    var accessibilityModeSection: some View {
        Section("Accessibility") {
            Toggle("Simplified Mode", isOn: $simplifiedModeEnabled)
                .accessibilityIdentifier("settings.accessibility.simplified_mode")

            DisclosureGroup("Advanced accessibility options") {
                Toggle("Haptic Alerts", isOn: $hapticsEnabled)
                    .accessibilityIdentifier("settings.accessibility.haptics")
            }
            .accessibilityIdentifier("settings.accessibility.advanced")

            Text(
                "Simplified mode reduces visual density on Today. Haptic alerts notify when intermittent fasting milestones are reached."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    var privacySection: some View {
        Section(localized("settings.privacy.title", default: "Privacy & Consent")) {
            Toggle(
                localized(
                    "settings.privacy.legal_ack",
                    default:
                    "I understand this independent app supplements (not replaces) pastoral guidance"
                ),
                isOn: $acceptedLegalNotice
            )
            .accessibilityIdentifier("launch.accept_legal_notice")

            if acceptedLegalNoticeAt.isEmpty {
                Text(
                    localized(
                        "settings.privacy.confirm_consent",
                        default: "Please confirm consent to enable reminders and exports."
                    )
                )
                .foregroundStyle(.orange)
            } else {
                Text(
                    localizedFormat(
                        "settings.privacy.consent_confirmed_format", default: "Consent confirmed: %@",
                        formattedConsentTimestamp(acceptedLegalNoticeAt)
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Text(
                localized(
                    "settings.privacy.data_storage_summary",
                    default:
                    "This app stores only fasting-tracker data you enter, locally on this device."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            NavigationLink {
                DataPrivacyDetailsView(
                    languageCode: languageModeRaw,
                    acceptedLegalNotice: acceptedLegalNotice
                )
            } label: {
                Label(
                    localized("settings.privacy.data_details_link", default: "View Data & Privacy Details"),
                    systemImage: "hand.raised.fill"
                )
            }
            .accessibilityIdentifier("settings.privacy.details")
        }
    }

    var backupsSection: some View {
        Section(localized("settings.backups.title", default: "Support & Backup")) {
            Link(
                localized("settings.backups.usccb_guidance", default: "USCCB Liturgical Year Guidance"),
                destination: UIConstants.legalPolicyURL
            )
            Link(
                localized("settings.backups.send_feedback", default: "Send Feedback"),
                destination: UIConstants.supportEmail
            )
            ShareLink(
                item: exportDataText,
                subject: Text(
                    localized("settings.backups.data_export_subject", default: "Catholic Fasting Data Export")
                ),
                message: Text(
                    localized(
                        "settings.backups.data_export_message", default: "Exported user data for backup/review"
                    )
                )
            ) {
                Label(
                    localized(
                        "settings.backups.export_personal_backup", default: "Export Personal Data Backup"
                    ),
                    systemImage: "square.and.arrow.up"
                )
            }
            .disabled(!acceptedLegalNotice)
            .accessibilityIdentifier("launch.export_data")
            .accessibilityHint(
                localized(
                    "settings.backups.export_personal_hint",
                    default: "Exports your profile settings, observance statuses, and notes."
                )
            )
            if !acceptedLegalNotice {
                Text(
                    localized(
                        "settings.backups.enable_consent_hint", default: "Enable consent above to export data."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    var dataManagementSection: some View {
        Section(localized("settings.data_management.title", default: "Data Management")) {
            Button(role: .destructive) {
                showDeleteDataConfirm = true
            } label: {
                Text(localized("settings.data_management.delete_all", default: "Delete All App Data"))
            }
            .accessibilityIdentifier("launch.delete_all_data")
            .confirmationDialog(
                localized(
                    "settings.data_management.delete_all_confirm",
                    default: "Delete all app data on this device?"
                ), isPresented: $showDeleteDataConfirm,
                titleVisibility: .visible
            ) {
                Button(
                    localized("settings.data_management.delete_everything", default: "Delete Everything"),
                    role: .destructive
                ) {
                    deleteAllData()
                }
                Button(localized("settings.data_management.cancel", default: "Cancel"), role: .cancel) {}
            }
        }
    }

    var regionPastoralGuidanceText: String {
        let region = RuleSettings.RegionProfile(rawValue: regionProfileRaw) ?? .us
        switch region {
        case .us:
            return
                "United States profile: Ash Wednesday and Good Friday are fast and abstinence days, Fridays of Lent are abstinence, and Fridays outside Lent are penitential."
        case .canada:
            return
                "Canada profile: Fridays remain penitential; abstinence is common practice, and local bishop guidance should be followed for particulars."
        case .other:
            return
                "Outside U.S./Canada: follow your local bishop conference, parish guidance, and your pastor for binding norms."
        }
    }

    func formattedConsentTimestamp(_ timestamp: String) -> String {
        guard let date = UIConstants.exportISO8601.date(from: timestamp) else {
            return timestamp
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    var exportDataText: String {
        let payload: [String: Any] = [
            "generated_at": UIConstants.exportISO8601.string(from: Date()),
            "rule_bundle": [
                "id": ruleBundleMetadata.id,
                "name": ruleBundleMetadata.displayName,
                "version": ruleBundleMetadata.version,
                "effective_date": UIConstants.exportISO8601.string(from: ruleBundleMetadata.effectiveDate),
                "reviewed_date": UIConstants.exportISO8601.string(from: ruleBundleMetadata.reviewedDate),
            ],
            "settings": [
                "age_14_or_older_for_abstinence": age14OrOlderForAbstinence,
                "age_18_or_older_for_fasting": age18OrOlderForFasting,
                "medical_dispensation": medicalDispensation,
                "ascension_observance": ascensionRaw,
                "friday_outside_lent_mode": fridayModeRaw,
                "province_preset": provinceRaw,
                "calendar_mode": calendarModeRaw,
                "language_mode": languageModeRaw,
                "region_profile": regionProfileRaw,
                "reminder_tier": reminderTierRaw,
                "accepted_legal_notice": acceptedLegalNotice,
                "accepted_legal_notice_at": acceptedLegalNoticeAt,
                "liturgical_season_colors_enabled": liturgicalSeasonColorsEnabled,
                "daily_reminder_support_enabled": dailyReminderSupportEnabled,
                "morning_reminder_enabled": morningReminderEnabled,
                "evening_reminder_enabled": eveningReminderEnabled,
                "haptics_enabled": hapticsEnabled,
            ],
            "observance_statuses": tracker.exportStatusPayload(),
            "friday_notes": penanceNotes.exportPayload(),
            "intermittent_fast": intermittentTracker.exportPayload(),
            "premium_companion": [
                "template": premiumCompanion.templateRawValue,
                "optional_disciplines_per_week": premiumCompanion.optionalDisciplinesPerWeek,
                "fixed_fast_weekday": premiumCompanion.fixedFastWeekday,
                "protect_feast_days": premiumCompanion.protectFeastDays,
                "condition_rules": [
                    "remind_if_unlogged_by_noon": premiumCompanion.conditionRules.remindIfUnloggedByNoon,
                    "required_days_double_reminder": premiumCompanion.conditionRules.requiredDaysDoubleReminder,
                    "milestone_nudges_for_active_fast": premiumCompanion.conditionRules.milestoneNudgesForActiveFast,
                ],
                "season_program": premiumCompanion.seasonProgramRawValue,
                "season_program_start_at": UIConstants.exportISO8601.string(from: premiumCompanion.seasonProgramStartDate),
                "completed_program_actions": premiumCompanion.completedProgramActions,
                "virtue_logs_count": premiumCompanion.virtueLogs.count,
            ],
            "launch_funnel_snapshot": [
                "started_at": UIConstants.exportISO8601.string(from: launchFunnelSnapshot.startedAt),
                "completed_onboarding_at": launchFunnelSnapshot.completedOnboardingAt.map {
                    UIConstants.exportISO8601.string(from: $0)
                } ?? "",
                "selected_region": launchFunnelSnapshot.selectedRegionRaw,
                "selected_reminder_tier": launchFunnelSnapshot.selectedReminderTierRaw,
                "first_action_completed_at": launchFunnelSnapshot.firstActionCompletedAt.map {
                    UIConstants.exportISO8601.string(from: $0)
                } ?? "",
                "paywall_seen_at": launchFunnelSnapshot.paywallSeenAt.map {
                    UIConstants.exportISO8601.string(from: $0)
                } ?? "",
                "paywall_view_count": launchFunnelSnapshot.paywallViewCount,
                "locked_upgrade_tap_count": launchFunnelSnapshot.lockedUpgradeTapCount,
                "premium_preview_seen_at": launchFunnelSnapshot.premiumPreviewSeenAt.map {
                    UIConstants.exportISO8601.string(from: $0)
                } ?? "",
                "purchase_started_at": launchFunnelSnapshot.purchaseStartedAt.map {
                    UIConstants.exportISO8601.string(from: $0)
                } ?? "",
                "premium_unlocked_at": launchFunnelSnapshot.premiumUnlockedAt.map {
                    UIConstants.exportISO8601.string(from: $0)
                } ?? "",
            ],
        ]
        return jsonString(from: payload, fallback: "{ \"error\": \"Unable to export\" }")
    }

    func deleteAllData() {
        tracker.clearAll()
        penanceNotes.clearAll()
        intermittentTracker.clearAll()
        LocalFeatureStore.clearAll()
        WidgetSnapshotStore.clear()

        planningData = .default
        intermittentSchedules = LocalFeatureStore.loadSchedules()
        activeIntermittentScheduleID = LocalFeatureStore.loadActiveScheduleID() ?? ""
        editingIntermittentScheduleID = ""
        newIntermittentScheduleName = ""
        newIntermittentScheduleStartHour = 20
        newIntermittentScheduleWeekdays = [2, 4, 6]
        lastTargetReachedHapticKey = ""
        lastEatingWindowClosedHapticKey = ""
        householdProfiles = LocalFeatureStore.loadProfiles()
        activeHouseholdProfileID = LocalFeatureStore.loadActiveProfileID() ?? ""
        devotionalFavorites = []
        reflectionEntries = []
        premiumChecklist = LocalFeatureStore.loadChecklist()
        premiumCompanion = LocalFeatureStore.loadPremiumCompanionState()
        newHouseholdProfileName = ""
        newSeasonCommitmentTitle = ""
        newReflectionTitle = ""
        newReflectionBody = ""
        newVirtueNote = ""
        selectedVirtue = "Temperance"
        premiumHouseholdImportCode = ""
        premiumHouseholdExportCode = ""
        premiumCompanionStatus = ""

        age14OrOlderForAbstinence = DefaultValues.age14OrOlderForAbstinence
        age18OrOlderForFasting = DefaultValues.age18OrOlderForFasting
        medicalDispensation = DefaultValues.medicalDispensation
        ascensionRaw = DefaultValues.ascension.rawValue
        fridayModeRaw = DefaultValues.fridayOutsideLent.rawValue
        provinceRaw = DefaultValues.province.rawValue
        calendarModeRaw = DefaultValues.calendarMode.rawValue
        languageModeRaw = DefaultValues.language.rawValue
        regionProfileRaw = DefaultValues.regionProfile.rawValue
        acceptedLegalNotice = false
        acceptedLegalNoticeAt = ""
        liturgicalSeasonColorsEnabled = DefaultValues.liturgicalSeasonColorsEnabled
        dailyReminderSupportEnabled = DefaultValues.dailyReminderSupportEnabled
        morningReminderEnabled = DefaultValues.morningReminderEnabled
        eveningReminderEnabled = DefaultValues.eveningReminderEnabled
        reminderTierRaw = DefaultValues.reminderTier.rawValue
        hapticsEnabled = DefaultValues.hapticsEnabled
        intermittentShowAdvanced = false
        fastingDaysShowAllYearDays = false
        fastingDaysIncludeOptionalDays = false
        fastingDaysIncludeFeastAndHolyDays = false
        supportPremiumSurfaceRaw = DefaultValues.supportPremiumSurface.rawValue
        simplifiedModeEnabled = false
        launchFunnelSnapshot = .default

        notificationStatus = "Not scheduled"
        premiumCoachStatus = ""
        homeSurface = .today
        guidanceScenario = .normalDay

        persistWidgetSnapshot()
    }

    func jsonString(from payload: [String: Any], fallback: String) -> String {
        guard
            let data = try? JSONSerialization.data(
                withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]
            ),
            let text = String(data: data, encoding: .utf8)
        else {
            return fallback
        }
        return text
    }
}

private struct DataPrivacyDetailsView: View {
    let languageCode: String
    let acceptedLegalNotice: Bool

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
    }

    private var consentStateText: String {
        acceptedLegalNotice
            ? localized("settings.shared.confirmed", default: "Confirmed")
            : localized("settings.shared.not_confirmed", default: "Not Confirmed")
    }

    var body: some View {
        List {
            Section {
                Text(
                    localized(
                        "settings.privacy.data_details_intro",
                        default:
                        "Your fasting records remain on your device. The app does not use cloud sync or analytics."
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
            }

            Section(localized("settings.privacy.section_stored_title", default: "Data Stored In App")) {
                dataLine(
                    localized(
                        "settings.privacy.stored_item_profile",
                        default: "Profile and settings (age eligibility toggles, language, fasting preferences)."
                    )
                )
                dataLine(
                    localized(
                        "settings.privacy.stored_item_observances",
                        default: "Observance progress and completion status history."
                    )
                )
                dataLine(
                    localized(
                        "settings.privacy.stored_item_notes",
                        default: "Friday penance notes that you manually enter."
                    )
                )
                dataLine(
                    localized(
                        "settings.privacy.stored_item_intermittent",
                        default: "Intermittent fasting sessions and active timer state."
                    )
                )
                dataLine(
                    localized(
                        "settings.privacy.stored_item_funnel",
                        default: "First-run funnel state (onboarding, paywall seen, reminder tier) stored locally."
                    )
                )
            }

            Section(
                localized("settings.privacy.section_shared_title", default: "Data Shared Or Transmitted")
            ) {
                dataLine(
                    localized(
                        "settings.privacy.shared_item_default",
                        default: "No automatic data upload to the developer."
                    )
                )
                dataLine(
                    localized(
                        "settings.privacy.shared_item_export",
                        default: "Export/share only when you tap an export action."
                    )
                )
                dataLine(
                    localized(
                        "settings.privacy.shared_item_feedback",
                        default: "Feedback email opens your mail app and sends only what you choose."
                    )
                )
            }

            Section(localized("settings.privacy.section_not_collected_title", default: "Not Collected")) {
                dataLine(
                    localized(
                        "settings.privacy.not_collected_tracking",
                        default: "No ad tracking identifiers."
                    )
                )
                dataLine(
                    localized(
                        "settings.privacy.not_collected_third_party",
                        default: "No third-party analytics SDKs in the app."
                    )
                )
            }

            Section(localized("settings.privacy.section_controls_title", default: "Your Controls")) {
                controlRow(
                    title: localized("settings.privacy.control_consent", default: "Consent"),
                    value: consentStateText
                )
            }
        }
        .navigationTitle(localized("settings.privacy.data_details_title", default: "Data & Privacy"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func controlRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func dataLine(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(CatholicTheme.primary.opacity(0.75))
                .padding(.top, 6)
            Text(text)
        }
    }
}
