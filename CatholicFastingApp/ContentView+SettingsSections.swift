import SwiftUI

extension ContentView {
  var premiumAndSupportSection: some View {
    Section("Free Core + Premium + Optional Tip") {
      Text("Core Catholic fasting calendar and guidance stay free. Premium unlocks advanced tools.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Label("Free core: USCCB calendar, required fast days, abstinence guidance, daily logging", systemImage: "checkmark.circle")
      Label("Premium: advanced support reminders, custom long-fast controls, full intermittent history", systemImage: "star.circle")
      Label("Optional tip: one-time support, no extra features required", systemImage: "heart.circle")

      if monetizationStore.premiumUnlocked {
        Label("Premium active", systemImage: "checkmark.seal.fill")
          .foregroundStyle(.green)
      } else {
        Label("Premium not active", systemImage: "lock.fill")
          .foregroundStyle(.secondary)
      }

      #if canImport(StoreKit)
        if monetizationStore.isLoading {
          ProgressView("Loading purchases…")
        }

        if !monetizationStore.premiumProducts.isEmpty {
          Text("Premium Plans")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
          ForEach(monetizationStore.premiumProducts, id: \.id) { product in
            Button("Unlock \(product.displayName) • \(product.displayPrice)") {
              Task {
                await monetizationStore.purchase(product)
              }
            }
            .appPrimaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
          }
        } else {
          Text("Premium products are not loaded yet. Confirm product IDs in App Store Connect.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        if !monetizationStore.tipProducts.isEmpty {
          Text("Optional Support Tips")
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
          ForEach(monetizationStore.tipProducts, id: \.id) { product in
            Button("Send Tip • \(product.displayPrice)") {
              Task {
                await monetizationStore.purchase(product)
              }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
          }
        }
      #endif

      Button("Restore Purchases") {
        Task {
          await monetizationStore.restorePurchases()
        }
      }
      .appSecondaryButtonStyle()
      .disabled(monetizationStore.isPurchasing)
      .accessibilityIdentifier("premium.restore")

      Button("Manage Subscription") {
        Task {
          await monetizationStore.openManageSubscriptions()
        }
      }
      .appSecondaryButtonStyle()
      .disabled(monetizationStore.isPurchasing)
      .accessibilityIdentifier("premium.manage")

      if !monetizationStore.subscriptionHealthMessage.isEmpty {
        Text(monetizationStore.subscriptionHealthMessage)
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("premium.subscription_health")
      }

      if !monetizationStore.statusMessage.isEmpty {
        Text(monetizationStore.statusMessage)
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("premium.status")
      }

      if monetizationStore.premiumUnlocked {
        Divider()

        Text("Premium Formation Tools")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
        Label("Seasonal fasting plans", systemImage: "calendar.badge.clock")
        Label("Smart reminder planner", systemImage: "bell.badge.waveform")
        Label("Advanced analytics dashboard", systemImage: "chart.bar.xaxis")
        Label("Daily premium reflection", systemImage: "book.pages")
        Label("Spiritual direction summary export", systemImage: "square.and.arrow.up")

        VStack(alignment: .leading, spacing: 6) {
          Text("Season Plan: \(premiumSeasonPlan.titleLine)")
            .font(.subheadline.weight(.semibold))
          Text(premiumSeasonPlan.focusLine)
            .font(.caption)
            .foregroundStyle(.secondary)
          Text("Intensity: \(premiumSeasonPlan.fastingIntensity)")
            .font(.caption)
            .foregroundStyle(.secondary)
          ForEach(premiumSeasonPlan.practices, id: \.self) { practice in
            Text("• \(practice)")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityIdentifier("premium.season_plan")

        VStack(alignment: .leading, spacing: 6) {
          Text("Smart Reminder Recommendation")
            .font(.subheadline.weight(.semibold))
          Text(premiumReminderRecommendation.summaryLine)
            .font(.caption)
            .foregroundStyle(.secondary)
          Text(
            "Daily support: \(premiumReminderRecommendation.shouldEnableDailySupport ? "On" : "Off") • Morning: \(premiumReminderRecommendation.shouldEnableMorning ? "On" : "Off") • Evening: \(premiumReminderRecommendation.shouldEnableEvening ? "On" : "Off")"
          )
          .font(.caption)
          .foregroundStyle(.secondary)
        }
        .accessibilityIdentifier("premium.smart_reminders")

        Button("Apply Smart Reminder Plan") {
          applyPremiumReminderRecommendation()
        }
        .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
        .accessibilityIdentifier("premium.apply_reminder_plan")

        if !premiumCoachStatus.isEmpty {
          Text(premiumCoachStatus)
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityIdentifier("premium.coach_status")
        }

        VStack(alignment: .leading, spacing: 6) {
          Text("Advanced Analytics")
            .font(.subheadline.weight(.semibold))
          Text("Required completion: \(premiumAnalyticsSummary.requiredCompletionPercent)%")
            .font(.caption)
          Text("Overall completion: \(premiumAnalyticsSummary.overallCompletionPercent)%")
            .font(.caption)
          Text("Missed: \(premiumAnalyticsSummary.missedCount) • Substituted: \(premiumAnalyticsSummary.substitutedCount)")
            .font(.caption)
          Text("Intermittent target hits: \(premiumAnalyticsSummary.intermittentTargetHitPercent)%")
            .font(.caption)
          if !premiumAnalyticsSummary.seasonRows.isEmpty {
            ForEach(premiumAnalyticsSummary.seasonRows) { row in
              Text("\(row.season.label): \(row.completionPercent)% (\(row.completedCount)/\(row.totalCount))")
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
          }
        }
        .accessibilityIdentifier("premium.analytics")

        VStack(alignment: .leading, spacing: 6) {
          Text("Today's Premium Reflection")
            .font(.subheadline.weight(.semibold))
          Text(premiumReflection.title)
            .font(.caption.weight(.semibold))
          Text(premiumReflection.body)
            .font(.caption)
            .foregroundStyle(.secondary)
          Text("Action: \(premiumReflection.action)")
            .font(.caption)
            .foregroundStyle(CatholicTheme.primary)
        }
        .accessibilityIdentifier("premium.reflection")

        ShareLink(
          item: premiumDirectionSummaryText,
          subject: Text("Catholic Fasting Premium Summary"),
          message: Text("Structured premium summary for personal review or spiritual direction.")
        ) {
          Label("Export Premium Summary", systemImage: "square.and.arrow.up")
        }
        .appSecondaryButtonStyle()
        .disabled(!acceptedLegalNotice)
        .accessibilityIdentifier("premium.export_summary")

        if !acceptedLegalNotice {
          Text("Enable consent in Privacy & Data before exporting premium summaries.")
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
      } else {
        Divider()
        Text("Premium unlock includes:")
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)
        Text("• Seasonal fasting plans")
          .font(.caption)
        Text("• Smart reminder planner")
          .font(.caption)
        Text("• Advanced analytics dashboard")
          .font(.caption)
        Text("• Daily premium reflections")
          .font(.caption)
        Text("• Premium summary export")
          .font(.caption)
          .accessibilityIdentifier("premium.locked_feature_preview")
      }
    }
  }

  var quickSetupSection: some View {
    Section("Quick Setup") {
      Text("Use this once, then you can mostly stay in Today and Calendar.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Picker("Birth Year", selection: $birthYear) {
        Text("Not set").tag(0)
        ForEach(
          Array(
            (UIConstants.minBirthYear...Calendar.current.component(.year, from: Date())).reversed()),
          id: \.self
        ) { y in
          Text(String(y)).tag(y)
        }
      }
      .pickerStyle(.menu)
      .accessibilityIdentifier("settings.quick.birth_year")

      Toggle(
        "I understand this is an independent app and not an official Church authority app",
        isOn: $acceptedLegalNotice
      )
      .accessibilityIdentifier("settings.quick.consent")

      Toggle("Enable reminder support", isOn: $dailyReminderSupportEnabled)
        .accessibilityIdentifier("settings.quick.reminder_support")
      if dailyReminderSupportEnabled && monetizationStore.premiumUnlocked {
        Toggle("Morning check-in (7:00 AM)", isOn: $morningReminderEnabled)
          .accessibilityIdentifier("settings.quick.reminder_morning")
        Toggle("Evening examen (8:00 PM)", isOn: $eveningReminderEnabled)
          .accessibilityIdentifier("settings.quick.reminder_evening")
      } else if dailyReminderSupportEnabled {
        Text("Advanced support reminders require Premium.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Text("Completed: \(setupChecklistCompleted)/\(setupChecklistTotal)")
        .font(.caption.weight(.semibold))
        .foregroundStyle(CatholicTheme.primary)
        .accessibilityIdentifier("settings.quick.progress")

      Text("Reminder status: \(notificationStatus)")
        .font(.caption)
        .foregroundStyle(.secondary)
        .accessibilityIdentifier("settings.quick.reminder_status")

      Button("Request Notification Permission") {
        Task {
          notificationStatus = await ReminderScheduler.requestPermission()
          LocalAnalyticsStore.track(.reminderPermissionRequested)
        }
      }
      .appSecondaryButtonStyle()
      .disabled(!acceptedLegalNotice)
      .accessibilityIdentifier("settings.quick.request_permission")
      .accessibilityHint("Requires consent acknowledgment before reminders are enabled.")

      Button("Schedule Required-Day Reminders") {
        Task {
          notificationStatus = await ReminderScheduler.schedule(observances: observances)
          LocalAnalyticsStore.track(.requiredRemindersScheduled)
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
          LocalAnalyticsStore.track(.supportRemindersScheduled)
        }
      }
      .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
      .disabled(!acceptedLegalNotice || !dailyReminderSupportEnabled || !monetizationStore.premiumUnlocked)
      .accessibilityIdentifier("settings.quick.schedule_support")

      Button("Refresh Reminder Status") {
        Task {
          notificationStatus = await ReminderScheduler.notificationSummary()
        }
      }
      .appSecondaryButtonStyle()
      .accessibilityIdentifier("settings.quick.refresh_status")

      if !acceptedLegalNotice {
        Text("Enable consent above to request and schedule reminders.")
          .font(.caption2)
          .foregroundStyle(.orange)
      }
    }
  }

  var profileRulesSection: some View {
    Section(localized("settings.personal_profile.title", default: "Personal Profile")) {
      Picker(
        localized("settings.personal_profile.birth_year", default: "Birth Year"),
        selection: $birthYear
      ) {
        Text(localized("settings.personal_profile.not_set", default: "Not set")).tag(0)
        ForEach(
          Array(
            (UIConstants.minBirthYear...Calendar.current.component(.year, from: Date())).reversed()),
          id: \.self
        ) { y in
          Text(String(y)).tag(y)
        }
      }
      .pickerStyle(.menu)
      if birthYear == 0 {
        Text(
          localized(
            "settings.personal_profile.birth_year_hint",
            default: "Set your birth year so age-based obligations are calculated accurately.")
        )
        .font(.caption)
        .foregroundStyle(.orange)
      }

      Toggle(
        localized(
          "settings.personal_profile.dispensation", default: "Medical or pastoral dispensation"),
        isOn: $medicalDispensation
      )
      .accessibilityHint(
        localized(
          "settings.personal_profile.dispensation_hint",
          default: "Enable when fasting obligations do not bind due to health or pastoral reasons.")
      )

      Picker(
        localized("settings.personal_profile.language", default: "Language"),
        selection: $languageModeRaw
      ) {
        ForEach(LanguageMode.allCases) { option in
          Text(option.label).tag(option.rawValue)
        }
      }
    }
  }

  var regionalNormsSection: some View {
    Section(localized("settings.regional_norms.title", default: "Church Norms")) {
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
          default: "Set whether Ascension is observed on Thursday or Sunday."))

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
          default: "Choose abstinence from meat or another penitential act."))
      Text(
        localized(
          "settings.regional_norms.pastor_note",
          default: "If your parish gives different guidance, follow your pastor and local bishop.")
      )
      .font(.caption)
      .foregroundStyle(.secondary)
    }
  }

  var themeSection: some View {
    Section(localized("settings.theme.title", default: "Liturgical Theme")) {
      Toggle(
        localized(
          "settings.theme.enable_liturgical_colors", default: "Enable Liturgical Season Colors"),
        isOn: $liturgicalSeasonColorsEnabled
      )
      .accessibilityIdentifier("settings.liturgical_theme_toggle")
      Text(
        liturgicalSeasonColorsEnabled
          ? localizedFormat(
            "settings.theme.active_season_format",
            default:
              "Active season: %@. Colors update automatically throughout the liturgical year.",
            CatholicTheme.seasonLabel)
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

  var privacySection: some View {
    Section(localized("settings.privacy.title", default: "Privacy & Consent")) {
      Toggle(
        localized(
          "settings.privacy.legal_ack",
          default:
            "I understand this independent app supplements (not replaces) pastoral guidance"),
        isOn: $acceptedLegalNotice
      )
      .accessibilityIdentifier("launch.accept_legal_notice")
      Toggle(
        localized("settings.privacy.enable_icloud_sync", default: "Enable iCloud Sync"),
        isOn: $allowCloudSync)
      Toggle(
        localized("settings.privacy.local_analytics", default: "Enable anonymous local analytics"),
        isOn: $allowLocalAnalytics
      )
      .accessibilityIdentifier("settings.privacy.local_analytics")
      Text(
        localized(
          "settings.privacy.local_analytics_hint",
          default:
            "When enabled, the app stores anonymous on-device usage counts to improve onboarding and reminder flow."
        )
      )
      .font(.caption)
      .foregroundStyle(.secondary)

      if acceptedLegalNoticeAt.isEmpty {
        Text(
          localized(
            "settings.privacy.confirm_consent",
            default: "Please confirm consent to enable reminders and exports.")
        )
        .foregroundStyle(.orange)
      } else {
        Text(
          localizedFormat(
            "settings.privacy.consent_confirmed_format", default: "Consent confirmed: %@",
            formattedConsentTimestamp(acceptedLegalNoticeAt))
        )
        .font(.caption)
        .foregroundStyle(.secondary)
      }
      Text(
        localized(
          "settings.privacy.data_storage_summary",
          default:
            "This app stores only fasting-tracker data you enter and optional diagnostics you approve."
        )
      )
      .font(.caption)
      .foregroundStyle(.secondary)
      NavigationLink {
        DataPrivacyDetailsView(
          languageCode: languageModeRaw,
          acceptedLegalNotice: acceptedLegalNotice,
          allowCloudSync: allowCloudSync,
          allowLocalAnalytics: allowLocalAnalytics,
          allowDiagnostics: allowDiagnostics,
          syncSnapshot: syncSnapshot
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
    Section(localized("settings.backups.title", default: "Help & Backup")) {
      Link(
        localized("settings.backups.usccb_guidance", default: "USCCB Liturgical Calendar Guidance"),
        destination: UIConstants.legalPolicyURL)
      Link(
        localized("settings.backups.send_feedback", default: "Send Feedback"),
        destination: UIConstants.supportEmail)
      ShareLink(
        item: exportDataText,
        subject: Text(
          localized("settings.backups.data_export_subject", default: "Catholic Fasting Data Export")
        ),
        message: Text(
          localized(
            "settings.backups.data_export_message", default: "Exported user data for backup/review")
        )
      ) {
        Label(
          localized(
            "settings.backups.export_personal_backup", default: "Export Personal Data Backup"),
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
            "settings.backups.enable_consent_hint", default: "Enable consent above to export data.")
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
          default: "Delete all local and synced data?"), isPresented: $showDeleteDataConfirm,
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
        "birth_year": birthYear,
        "medical_dispensation": medicalDispensation,
        "ascension_observance": ascensionRaw,
        "friday_outside_lent_mode": fridayModeRaw,
        "province_preset": provinceRaw,
        "calendar_mode": calendarModeRaw,
        "language_mode": languageModeRaw,
        "accepted_legal_notice": acceptedLegalNotice,
        "accepted_legal_notice_at": acceptedLegalNoticeAt,
        "allow_cloud_sync": allowCloudSync,
        "allow_diagnostics": allowDiagnostics,
        "allow_local_analytics": allowLocalAnalytics,
        "liturgical_season_colors_enabled": liturgicalSeasonColorsEnabled,
        "daily_reminder_support_enabled": dailyReminderSupportEnabled,
        "morning_reminder_enabled": morningReminderEnabled,
        "evening_reminder_enabled": eveningReminderEnabled,
      ],
      "local_analytics": localAnalyticsSnapshot.countsByEvent,
      "observance_statuses": tracker.exportStatusPayload(),
      "friday_notes": penanceNotes.exportPayload(),
      "intermittent_fast": intermittentTracker.exportPayload(),
    ]
    return jsonString(from: payload, fallback: "{ \"error\": \"Unable to export\" }")
  }

  func deleteAllData() {
    tracker.clearAll()
    penanceNotes.clearAll()
    intermittentTracker.clearAll()

    birthYear = DefaultValues.birthYear
    medicalDispensation = DefaultValues.medicalDispensation
    ascensionRaw = DefaultValues.ascension.rawValue
    fridayModeRaw = DefaultValues.fridayOutsideLent.rawValue
    provinceRaw = DefaultValues.province.rawValue
    calendarModeRaw = DefaultValues.calendarMode.rawValue
    languageModeRaw = DefaultValues.language.rawValue
    acceptedLegalNotice = false
    acceptedLegalNoticeAt = ""
    crashReportingEnabled = false
    allowCloudSync = true
    allowDiagnostics = true
    allowLocalAnalytics = DefaultValues.allowLocalAnalytics
    liturgicalSeasonColorsEnabled = DefaultValues.liturgicalSeasonColorsEnabled
    dailyReminderSupportEnabled = DefaultValues.dailyReminderSupportEnabled
    morningReminderEnabled = DefaultValues.morningReminderEnabled
    eveningReminderEnabled = DefaultValues.eveningReminderEnabled
    LocalAnalyticsStore.reset()
  }

  func jsonString(from payload: [String: Any], fallback: String) -> String {
    guard
      let data = try? JSONSerialization.data(
        withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]),
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
  let allowCloudSync: Bool
  let allowLocalAnalytics: Bool
  let allowDiagnostics: Bool
  let syncSnapshot: SyncSnapshot

  private func localized(_ key: String, default defaultValue: String) -> String {
    AppLocalizer.localized(key, default: defaultValue, languageCode: languageCode)
  }

  private func localizedFormat(_ key: String, default defaultFormat: String, _ value: CVarArg)
    -> String
  {
    let format = localized(key, default: defaultFormat)
    return String(format: format, locale: Locale.current, value)
  }

  private var consentStateText: String {
    acceptedLegalNotice
      ? localized("settings.shared.confirmed", default: "Confirmed")
      : localized("settings.shared.not_confirmed", default: "Not Confirmed")
  }

  private var onOffCloudSyncText: String {
    allowCloudSync
      ? localized("settings.shared.on", default: "On")
      : localized("settings.shared.off", default: "Off")
  }

  private var onOffDiagnosticsText: String {
    allowDiagnostics
      ? localized("settings.shared.on", default: "On")
      : localized("settings.shared.off", default: "Off")
  }

  private var onOffLocalAnalyticsText: String {
    allowLocalAnalytics
      ? localized("settings.shared.on", default: "On")
      : localized("settings.shared.off", default: "Off")
  }

  private var lastSyncLabel: String {
    if let lastSyncDate = syncSnapshot.lastSyncDate {
      return localizedFormat(
        "settings.privacy.last_sync_format",
        default: "Last sync: %@",
        lastSyncDate.formatted(date: .abbreviated, time: .shortened)
      )
    }
    return localized("settings.shared.never", default: "Never")
  }

  var body: some View {
    List {
      Section {
        Text(
          localized(
            "settings.privacy.data_details_intro",
            default:
              "Your fasting records remain on your device by default. iCloud sync and data exports happen only when you enable or trigger them."
          )
        )
        .font(.callout)
        .foregroundStyle(.secondary)
      }

      Section(localized("settings.privacy.section_stored_title", default: "Data Stored In App")) {
        dataLine(
          localized(
            "settings.privacy.stored_item_profile",
            default: "Profile and settings (birth year, language, fasting preferences)."))
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
      }

      Section(
        localized("settings.privacy.section_shared_title", default: "Data Shared Or Transmitted")
      ) {
        dataLine(
          localized(
            "settings.privacy.shared_item_default",
            default: "No automatic data upload to the developer."
          ))
        dataLine(
          allowCloudSync
            ? localized(
              "settings.privacy.shared_item_icloud_on",
              default: "iCloud sync is enabled and uses your Apple iCloud account.")
            : localized("settings.privacy.shared_item_icloud_off", default: "iCloud sync is off.")
        )
        dataLine(
          localized(
            "settings.privacy.shared_item_export",
            default: "Export/share only when you tap an export action."
          ))
        dataLine(
          localized(
            "settings.privacy.shared_item_feedback",
            default: "Feedback email opens your mail app and sends only what you choose."
          ))
      }

      Section(localized("settings.privacy.section_not_collected_title", default: "Not Collected")) {
        dataLine(
          localized(
            "settings.privacy.not_collected_tracking",
            default: "No ad tracking identifiers."
          ))
        dataLine(
          localized(
            "settings.privacy.not_collected_third_party",
            default: "No third-party analytics SDKs in the app."
          ))
      }

      Section(localized("settings.privacy.section_controls_title", default: "Your Controls")) {
        controlRow(
          title: localized("settings.privacy.control_consent", default: "Consent"),
          value: consentStateText
        )
        controlRow(
          title: localized("settings.privacy.control_icloud", default: "iCloud Sync"),
          value: onOffCloudSyncText
        )
        controlRow(
          title: localized(
            "settings.privacy.control_diagnostics", default: "Diagnostics In Support Exports"),
          value: onOffDiagnosticsText
        )
        controlRow(
          title: localized(
            "settings.privacy.control_local_analytics", default: "Anonymous Local Analytics"),
          value: onOffLocalAnalyticsText
        )
        controlRow(
          title: localized(
            "settings.privacy.control_icloud_available", default: "iCloud Available On Device"),
          value: syncSnapshot.iCloudAvailable
            ? localized("settings.shared.yes", default: "Yes")
            : localized("settings.shared.no", default: "No")
        )
        controlRow(
          title: localized("settings.privacy.control_last_sync", default: "Last Sync"),
          value: lastSyncLabel
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
