import SwiftUI

struct CatholicFastingMacSettingsView: View {
    @ObservedObject var model: CatholicFastingMacModel
    @State private var showingDeleteConfirmation = false

    var body: some View {
        TabView(selection: $model.selectedSettingsPane) {
            profilePane
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                        .accessibilityIdentifier("mac.settings.tab.profile")
                        .macSelectedAccessibility(model.selectedSettingsPane == .profile)
                }
                .tag(CatholicFastingMacSettingsPane.profile)

            remindersPane
                .tabItem {
                    Label("Reminders", systemImage: "bell.badge")
                        .accessibilityIdentifier("mac.settings.tab.reminders")
                        .macSelectedAccessibility(model.selectedSettingsPane == .reminders)
                }
                .tag(CatholicFastingMacSettingsPane.reminders)

            privacyPane
                .tabItem {
                    Label("Privacy", systemImage: "lock.shield")
                        .accessibilityIdentifier("mac.settings.tab.privacy")
                        .macSelectedAccessibility(model.selectedSettingsPane == .privacy)
                }
                .tag(CatholicFastingMacSettingsPane.privacy)
        }
        .frame(minWidth: 560, idealWidth: 680, minHeight: 460, idealHeight: 540)
        .padding(20)
        .accessibilityIdentifier("mac.settings.ready")
    }

    private var profilePane: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile & Norms")
                .font(.title2.weight(.semibold))
                .accessibilityIdentifier("mac.settings.profile.ready")
            Form {
                CatholicFastingMacProfileFields(model: model)
            }
        }
        .formStyle(.grouped)
    }

    private var remindersPane: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reminders")
                .font(.title2.weight(.semibold))
                .accessibilityIdentifier("mac.settings.reminders.ready")
            Form {
                Section("Reminder Strategy") {
                    Picker("Reminder style", selection: $model.reminderTierRaw) {
                        ForEach(ReminderTier.allCases) { tier in
                            Text("\(tier.label) — \(tier.summary)").tag(tier.rawValue)
                        }
                    }
                    .onChange(of: model.reminderTierRaw) { _, newValue in
                        let tier = ReminderTier(rawValue: newValue) ?? .balanced
                        model.applyReminderTier(tier)
                    }

                    Text("Start with required-day coverage, then add support reminders only when your rhythm needs more structure.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if model.monetizationStore.premiumUnlocked {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Smart Premium Recommendation")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text(model.premiumReminderRecommendation.summaryLine)
                            Text(model.premiumReminderRecommendationLine)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Button("Apply Smart Plan") {
                                    model.applyPremiumReminderRecommendation()
                                }
                                .accessibilityIdentifier("mac.settings.reminders.apply_smart")

                                Button("Apply Advanced Rules") {
                                    model.applyPremiumConditionRules()
                                }
                                .accessibilityIdentifier("mac.settings.reminders.apply_rules")
                            }
                        }
                    }
                }

                Section("Required-Day Alerts") {
                    Button("Request Notification Permission") {
                        Task { await model.requestReminderPermission() }
                    }
                    .accessibilityIdentifier("mac.settings.reminders.request_permission")

                    Button("Schedule Required-Day Reminders") {
                        Task { await model.scheduleRequiredDayReminders() }
                    }
                    .accessibilityIdentifier("mac.settings.reminders.schedule_required")

                    Button("Refresh Reminder Status") {
                        Task { await model.refreshReminderStatus() }
                    }
                    .accessibilityIdentifier("mac.settings.reminders.refresh_status")
                }

                Section("Daily Devotional Quote") {
                    Toggle("Daily devotional quote reminder", isOn: $model.dailyQuoteReminderEnabled)
                        .accessibilityIdentifier("mac.settings.reminders.quote")

                    if model.dailyQuoteReminderEnabled {
                        DatePicker("Quote reminder time", selection: model.dailyQuoteReminderTimeBinding, displayedComponents: .hourAndMinute)
                            .accessibilityIdentifier("mac.settings.reminders.quote_time")
                    }

                    Button("Schedule Daily Quote Reminder") {
                        Task { await model.scheduleDailyQuoteReminderFromCurrentSettings() }
                    }
                    .disabled(!model.dailyQuoteReminderEnabled)
                    .accessibilityIdentifier("mac.settings.reminders.schedule_quote")
                }

                Section("Daily Support") {
                    Toggle("Daily support reminders", isOn: $model.dailyReminderSupportEnabled)
                        .accessibilityIdentifier("mac.settings.reminders.support")

                    if model.monetizationStore.premiumUnlocked {
                        Toggle("Morning reminder", isOn: $model.morningReminderEnabled)
                            .accessibilityIdentifier("mac.settings.reminders.morning")
                        Toggle("Evening reminder", isOn: $model.eveningReminderEnabled)
                            .accessibilityIdentifier("mac.settings.reminders.evening")

                        Toggle(
                            "Noon recovery nudge",
                            isOn: Binding(
                                get: { model.premiumCompanion.conditionRules.remindIfUnloggedByNoon },
                                set: { model.premiumCompanion.conditionRules.remindIfUnloggedByNoon = $0 }))
                        Toggle(
                            "Double reminders on required days",
                            isOn: Binding(
                                get: { model.premiumCompanion.conditionRules.requiredDaysDoubleReminder },
                                set: { model.premiumCompanion.conditionRules.requiredDaysDoubleReminder = $0 }))
                        Toggle(
                            "Milestone nudges during active fasts",
                            isOn: Binding(
                                get: { model.premiumCompanion.conditionRules.milestoneNudgesForActiveFast },
                                set: { model.premiumCompanion.conditionRules.milestoneNudgesForActiveFast = $0 }))

                        Button("Schedule Daily Support Reminders") {
                            Task { await model.scheduleDailySupportReminders() }
                        }
                        .accessibilityIdentifier("mac.settings.reminders.schedule_support")
                    } else {
                        Text("Morning/evening support reminders remain a Premium feature on Mac, just as they do in the guided iPhone setup flows.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("mac.settings.reminders.premium_hint")
                        Button("Manage Subscription") {
                            Task { await model.monetizationStore.openManageSubscriptions() }
                        }
                    }
                }

                Text(model.notificationStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var privacyPane: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy & Data")
                .font(.title2.weight(.semibold))
                .accessibilityIdentifier("mac.settings.privacy.ready")
            Form {
                Toggle(
                    "I understand this independent app supplements, but does not replace, pastoral guidance",
                    isOn: $model.acceptedLegalNotice)
                    .accessibilityIdentifier("mac.settings.privacy.legal_notice")

                if model.acceptedLegalNoticeAt.isEmpty {
                    Text("Confirm consent before enabling reminders or exports.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Consent confirmed: \(model.acceptedLegalNoticeAt)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    ShareLink(item: model.exportDataText) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("mac.settings.privacy.export")
                    Button("Copy Export") {
                        model.copyExportToPasteboard()
                    }
                    .accessibilityIdentifier("mac.settings.privacy.copy_export")
                }

                Link("Privacy Policy", destination: UIConstants.privacyPolicyURL)
                    .accessibilityIdentifier("mac.settings.privacy.policy")
                Link("Terms of Use", destination: UIConstants.termsOfUseURL)
                    .accessibilityIdentifier("mac.settings.privacy.terms")
                Link("Support", destination: UIConstants.supportSiteURL)
                    .accessibilityIdentifier("mac.settings.privacy.support")

                Button("Delete All Local Data", role: .destructive) {
                    showingDeleteConfirmation = true
                }
                .accessibilityIdentifier("mac.settings.privacy.delete_all")
                .confirmationDialog("Delete all app data on this Mac?", isPresented: $showingDeleteConfirmation) {
                    Button("Delete Everything", role: .destructive) {
                        model.deleteAllData()
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct CatholicFastingMacOnboardingView: View {
    @ObservedObject var model: CatholicFastingMacModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Welcome to Catholic Fasting")
                .font(.largeTitle.weight(.semibold))
            Text("Set your profile, region, and reminder style once, then keep the desktop app calm and focused.")
                .foregroundStyle(.secondary)

            Form {
                CatholicFastingMacProfileFields(model: model, includeAccessibilityIDs: false)

                Picker("Reminder style", selection: $model.reminderTierRaw) {
                    ForEach(ReminderTier.allCases) { tier in
                        Text("\(tier.label) — \(tier.summary)").tag(tier.rawValue)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()
                Button("Finish Setup") {
                    model.completeOnboarding()
                }
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("mac.onboarding.finish")
            }
        }
        .padding(24)
        .frame(minWidth: 560, idealWidth: 640, minHeight: 460, idealHeight: 540)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("mac.onboarding.ready")
    }
}

private struct CatholicFastingMacProfileFields: View {
    @ObservedObject var model: CatholicFastingMacModel
    let includeAccessibilityIDs: Bool

    init(model: CatholicFastingMacModel, includeAccessibilityIDs: Bool = true) {
        self.model = model
        self.includeAccessibilityIDs = includeAccessibilityIDs
    }

    var body: some View {
        Toggle("I am 14 or older (abstinence age)", isOn: $model.age14OrOlderForAbstinence)
            .applyMacAccessibilityID(includeAccessibilityIDs ? "mac.settings.profile.age14" : nil)
        Toggle("I am 18 or older (fasting age)", isOn: $model.age18OrOlderForFasting)
            .applyMacAccessibilityID(includeAccessibilityIDs ? "mac.settings.profile.age18" : nil)
        Toggle("Health or pastoral dispensation", isOn: $model.medicalDispensation)
            .applyMacAccessibilityID(includeAccessibilityIDs ? "mac.settings.profile.dispensation" : nil)
        if includeAccessibilityIDs {
            Text(model.medicalDispensation ? "Dispensation enabled" : "Dispensation disabled")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier(
                    model.medicalDispensation
                        ? "mac.settings.profile.dispensation_enabled"
                        : "mac.settings.profile.dispensation_disabled")
        }

        Picker("Language", selection: $model.languageModeRaw) {
            ForEach(LanguageMode.allCases) { mode in
                Text(mode.label).tag(mode.rawValue)
            }
        }
        .applyMacAccessibilityID(includeAccessibilityIDs ? "mac.settings.profile.language" : nil)

        Picker("Region", selection: $model.regionProfileRaw) {
            ForEach(RuleSettings.RegionProfile.allCases) { profile in
                Text(profile.label).tag(profile.rawValue)
            }
        }
        .applyMacAccessibilityID(includeAccessibilityIDs ? "mac.settings.profile.region" : nil)

        Picker("Friday practice", selection: $model.fridayModeRaw) {
            ForEach(RuleSettings.FridayOutsideLentMode.allCases) { mode in
                Text(mode.label).tag(mode.rawValue)
            }
        }

        Picker("Calendar mode", selection: $model.calendarModeRaw) {
            ForEach(RuleSettings.CalendarMode.allCases, id: \.rawValue) { mode in
                Text(mode.label).tag(mode.rawValue)
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func applyMacAccessibilityID(_ identifier: String?) -> some View {
        if let identifier {
            accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}
