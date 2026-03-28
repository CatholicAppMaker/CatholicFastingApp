import SwiftUI

extension ContentView {
    var privacySection: some View {
        Section(localized("settings.privacy.title", default: "Privacy & Consent")) {
            AppSectionLeadCard(
                eyebrow: localized("settings.privacy.title", default: "Privacy & Consent"),
                title: localized("settings.privacy.data_details_link", default: "View Data & Privacy Details"),
                detail: localized("settings.privacy.data_storage_summary", default: "This app stores only fasting-tracker data you enter, locally on this device."),
                style: .utility)

            Toggle(
                localized(
                    "settings.privacy.legal_ack",
                    default:
                    "I understand this independent app supplements (not replaces) pastoral guidance"),
                isOn: $acceptedLegalNotice)
                .accessibilityIdentifier("launch.accept_legal_notice")

            if acceptedLegalNoticeAt.isEmpty {
                Text(
                    localized(
                        "settings.privacy.confirm_consent",
                        default: "Please confirm consent to enable reminders and exports."))
                    .foregroundStyle(.orange)
            } else {
                Text(
                    localizedFormat(
                        "settings.privacy.consent_confirmed_format",
                        default: "Consent confirmed: %@",
                        formattedConsentTimestamp(acceptedLegalNoticeAt)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            NavigationLink {
                DataPrivacyDetailsView(
                    languageCode: languageModeRaw,
                    acceptedLegalNotice: acceptedLegalNotice)
            } label: {
                Label(
                    localized("settings.privacy.data_details_link", default: "View Data & Privacy Details"),
                    systemImage: "hand.raised.fill")
            }
            .accessibilityIdentifier("settings.privacy.details")
        }
    }

    var backupsSection: some View {
        Section(localized("settings.backups.title", default: "Support & Backup")) {
            AppSectionLeadCard(
                eyebrow: localized("settings.backups.title", default: "Support & Backup"),
                title: localized("settings.backups.export_personal_backup", default: "Export Personal Data Backup"),
                detail: localized("settings.backups.section_summary", default: "Keep feedback, source guidance, and personal backup tools together in one calm place."),
                style: .utility)

            Link(
                localized("settings.backups.usccb_guidance", default: "USCCB Liturgical Year Guidance"),
                destination: UIConstants.legalPolicyURL)
            Link(
                localized("settings.backups.send_feedback", default: "Send Feedback"),
                destination: UIConstants.supportEmail)
            ShareLink(
                item: exportDataText,
                subject: Text(
                    localized("settings.backups.data_export_subject", default: "Catholic Fasting Data Export")),
                message: Text(
                    localized(
                        "settings.backups.data_export_message",
                        default: "Exported user data for backup/review")))
            {
                Label(
                    localized(
                        "settings.backups.export_personal_backup",
                        default: "Export Personal Data Backup"),
                    systemImage: "square.and.arrow.up")
            }
            .disabled(!acceptedLegalNotice)
            .accessibilityIdentifier("launch.export_data")
            .accessibilityHint(
                localized(
                    "settings.backups.export_personal_hint",
                    default: "Exports your profile settings, observance statuses, and notes."))

            if !acceptedLegalNotice {
                Text(
                    localized(
                        "settings.backups.enable_consent_hint",
                        default: "Enable consent above to export data."))
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
                    default: "Delete all app data on this device?"),
                isPresented: $showDeleteDataConfirm,
                titleVisibility: .visible)
            {
                Button(
                    localized("settings.data_management.delete_everything", default: "Delete Everything"),
                    role: .destructive)
                {
                    deleteAllData()
                }
                Button(localized("settings.data_management.cancel", default: "Cancel"), role: .cancel) {}
            }
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
                withJSONObject: payload,
                options: [.prettyPrinted, .sortedKeys]),
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
                        "Your fasting records remain on your device. The app does not use cloud sync or analytics."))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Section(localized("settings.privacy.section_stored_title", default: "Data Stored In App")) {
                dataLine(
                    localized(
                        "settings.privacy.stored_item_profile",
                        default: "Profile and settings (age eligibility toggles, language, fasting preferences)."))
                dataLine(
                    localized(
                        "settings.privacy.stored_item_observances",
                        default: "Observance progress and completion status history."))
                dataLine(
                    localized(
                        "settings.privacy.stored_item_notes",
                        default: "Friday penance notes that you manually enter."))
                dataLine(
                    localized(
                        "settings.privacy.stored_item_intermittent",
                        default: "Intermittent fasting sessions and active timer state."))
                dataLine(
                    localized(
                        "settings.privacy.stored_item_funnel",
                        default: "First-run funnel state (onboarding, paywall seen, reminder tier) stored locally."))
            }

            Section(localized("settings.privacy.section_shared_title", default: "Data Shared Or Transmitted")) {
                dataLine(
                    localized(
                        "settings.privacy.shared_item_default",
                        default: "No automatic data upload to the developer."))
                dataLine(
                    localized(
                        "settings.privacy.shared_item_export",
                        default: "Export/share only when you tap an export action."))
                dataLine(
                    localized(
                        "settings.privacy.shared_item_feedback",
                        default: "Feedback email opens your mail app and sends only what you choose."))
            }

            Section(localized("settings.privacy.section_not_collected_title", default: "Not Collected")) {
                dataLine(
                    localized(
                        "settings.privacy.not_collected_tracking",
                        default: "No ad tracking identifiers."))
                dataLine(
                    localized(
                        "settings.privacy.not_collected_third_party",
                        default: "No third-party analytics SDKs in the app."))
            }

            Section(localized("settings.privacy.section_controls_title", default: "Your Controls")) {
                controlRow(
                    title: localized("settings.privacy.control_consent", default: "Consent"),
                    value: consentStateText)
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
