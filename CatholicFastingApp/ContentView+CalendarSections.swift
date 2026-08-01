import SwiftUI

struct SacredHeroArtwork {
    let assetName: String
}

enum SacredHeroScene {
    case dashboard
    case fastingDays
    case intermittent
}

enum SacredHeroImageSelector {
    static func anchorArtwork(for scene: SacredHeroScene) -> SacredHeroArtwork {
        switch scene {
        case .dashboard:
            SacredHeroArtwork(assetName: "HeroSacred")
        case .fastingDays:
            SacredHeroArtwork(assetName: "SacredFridayAbstinence")
        case .intermittent:
            SacredHeroArtwork(assetName: "SacredScriptureCandle")
        }
    }
}

extension ContentView {
    var progressSection: some View {
        Section(localized("fasting_days.progress.section", default: "Year rhythm")) {
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
                Button(localized("fasting_days.today.plan_ahead", default: "Open Calendar to Plan Ahead")) {
                    navigationState.homeSurface = .fastingDays
                }
                .appSecondaryButtonStyle()
            } else {
                ForEach(todayItems) { observance in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(localizedObservanceTitle(observance.title))
                                .font(.headline)
                            Text("\(localizedObservanceKindLabel(observance.kind)) • \(localizedObservanceDispositionLabel(observance))")
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
            Text(feedback.notificationStatus)
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
                        feedback.notificationStatus = await ReminderScheduler.requestPermission()
                    }
                }
                .disabled(!acceptedLegalNotice)
                .accessibilityHint(localized("settings.quick.permission_hint", default: "Requires consent acknowledgment before reminders are enabled."))
                Button(localized("settings.quick.schedule_required", default: "Schedule Required-Day Reminders")) {
                    Task {
                        feedback.notificationStatus = await ReminderScheduler.schedule(observances: rollingUpcomingObservances)
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
                        feedback.notificationStatus = await ReminderScheduler.scheduleHabitSupport(
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
                        feedback.notificationStatus = await ReminderScheduler.notificationSummary()
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
}
