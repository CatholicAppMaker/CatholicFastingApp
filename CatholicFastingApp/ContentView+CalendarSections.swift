import SwiftUI

extension ContentView {
  var yearSection: some View {
    Section("Year") {
      HStack {
        Button {
          year = max(UIConstants.yearRange.lowerBound, year - 1)
        } label: {
          Label("Previous", systemImage: "chevron.left")
        }
        .accessibilityIdentifier("calendar.year.previous")
        .appSecondaryButtonStyle()

        Spacer()

        Button("Current Year") {
          year = Calendar.current.component(.year, from: Date())
        }
        .accessibilityIdentifier("calendar.year.current")
        .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)

        Spacer()

        Button {
          year = min(UIConstants.yearRange.upperBound, year + 1)
        } label: {
          Label("Next", systemImage: "chevron.right")
        }
        .accessibilityIdentifier("calendar.year.next")
        .appSecondaryButtonStyle()
      }

      Picker("Calendar Year", selection: $year) {
        ForEach(UIConstants.yearRange, id: \.self) { y in
          Text(String(y)).tag(y)
        }
      }
      .pickerStyle(.menu)
    }
  }

  var observanceControlsSection: some View {
    Section("Calendar Filters") {
      Picker("Show", selection: $observanceFilter) {
        ForEach(ObservanceFilter.allCases) { filter in
          Text(filter.label).tag(filter)
        }
      }
      .pickerStyle(.segmented)
      .accessibilityIdentifier("calendar.filter_picker")
      TextField("Search observances", text: $observanceQuery)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .submitLabel(.search)
        .accessibilityIdentifier("calendar.search_field")
      Picker("Window", selection: $calendarWindow) {
        ForEach(CalendarWindow.allCases) { window in
          Text(window.label).tag(window)
        }
      }
      .pickerStyle(.menu)
      .accessibilityIdentifier("calendar.window_picker")
      Picker("Sort", selection: $observanceSortOrder) {
        ForEach(ObservanceSortOrder.allCases) { order in
          Text(order.label).tag(order)
        }
      }
      .pickerStyle(.menu)
      .accessibilityIdentifier("calendar.sort_picker")
      Button("Reset Calendar Filters") {
        resetCalendarFilters()
      }
      .accessibilityIdentifier("calendar.reset_filters")
      .appSecondaryButtonStyle()

      Button("Show Required in Next 30 Days") {
        observanceFilter = .requiredOnly
        observanceQuery = ""
        calendarWindow = .next30Days
        observanceSortOrder = .requiredFirst
      }
      .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)
    }
  }

  var calendarInsightsSection: some View {
    Section("Calendar Insights") {
      Text(calendarFilterSummaryText)
        .font(.subheadline)
        .foregroundStyle(CatholicTheme.primary.opacity(0.9))
        .accessibilityIdentifier("calendar.filter_summary")
      if let nextRequired = filteredObservances.first(where: { $0.obligation == .mandatory }) {
        Text("Next required in results: \(nextRequired.title) • \(nextRequired.date.formatted(date: .abbreviated, time: .omitted))")
          .font(.subheadline)
          .foregroundStyle(.red.opacity(0.85))
      }
      if filteredObservances.isEmpty {
        Button("Clear Filters to Show All") {
          resetCalendarFilters()
        }
        .accessibilityIdentifier("calendar.clear_filters_cta")
        .appPrimaryButtonStyle()
      }
    }
  }

  var observanceLegendSection: some View {
    Section("Legend") {
      HStack(spacing: 8) {
        StatusTag(text: Observance.Kind.fastAndAbstinence.label, color: Observance.Kind.fastAndAbstinence.color)
        StatusTag(text: Observance.Obligation.mandatory.label, color: .red)
      }
      HStack(spacing: 8) {
        StatusTag(text: Observance.Kind.fridayPenance.label, color: Observance.Kind.fridayPenance.color)
        StatusTag(text: Observance.Obligation.optional.label, color: .blue)
      }
      Text("Use filters to focus on required observances or your tracked history.")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }

  var progressSection: some View {
    Section("Progress") {
      Text("Completed \(completedCount) of \(actionableObservances.count) required/optional observances")
        .font(.subheadline)
    }
  }

  var todaySection: some View {
    let todayItems = observancesForToday
    return Section("Today") {
      if todayItems.isEmpty {
        Text("No listed observances today.")
          .foregroundStyle(.secondary)
        Button("Open Calendar to Plan Ahead") {
          homeSurface = .calendar
        }
        .appSecondaryButtonStyle()
      } else {
        ForEach(todayItems) { observance in
          HStack {
            VStack(alignment: .leading) {
              Text(observance.title)
                .font(.headline)
              Text("\(observance.kind.label) • \(observance.obligation.label)")
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
    let analytics = localAnalyticsSnapshot
    return Section("Streaks and Completion") {
      Text("Completion Rate: \(completionRateText)")
        .accessibilityIdentifier("today.analytics.completion_rate")
      Text("Current Streak: \(currentStreak) day(s)")
        .accessibilityIdentifier("today.analytics.current_streak")
      Text("Best Streak: \(bestStreak) day(s)")
        .accessibilityIdentifier("today.analytics.best_streak")

      if analytics.isEnabled {
        Text("Anonymous local analytics: \(analytics.totalEvents) tracked action(s)")
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("today.analytics.local_enabled")
        if analytics.totalEvents > 0 {
          Text(
            "Funnel: launches \(analytics.count(for: .appLaunch)) • onboarding \(analytics.count(for: .onboardingCompleted)) • reminders \(analytics.count(for: .requiredRemindersScheduled) + analytics.count(for: .supportRemindersScheduled)) • recovery \(analytics.count(for: .recoverySubstituteLogged))"
          )
          .font(.caption2)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("today.analytics.funnel")
        }
      } else {
        Text("Anonymous local analytics is off.")
          .font(.caption)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("today.analytics.local_disabled")
      }
    }
  }

  var notificationsSection: some View {
    Section("Reminders") {
      Text("Status: \(notificationStatus)")
        .foregroundStyle(.secondary)
      Toggle("Enable reminder support", isOn: $dailyReminderSupportEnabled)
        .accessibilityIdentifier("settings.reminders.support_toggle")
      if monetizationStore.premiumUnlocked {
        Toggle("Morning check-in (7:00 AM)", isOn: $morningReminderEnabled)
          .accessibilityIdentifier("settings.reminders.morning_toggle")
          .disabled(!dailyReminderSupportEnabled)
        Toggle("Evening examen (8:00 PM)", isOn: $eveningReminderEnabled)
          .accessibilityIdentifier("settings.reminders.evening_toggle")
          .disabled(!dailyReminderSupportEnabled)
      } else if dailyReminderSupportEnabled {
        Text("Morning/evening support reminders are a Premium feature.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Button("Request Notification Permission") {
        Task {
          notificationStatus = await ReminderScheduler.requestPermission()
          LocalAnalyticsStore.track(.reminderPermissionRequested)
        }
      }
      .disabled(!acceptedLegalNotice)
      .accessibilityHint("Requires consent acknowledgment before reminders are enabled.")
      Button("Schedule Required-Day Reminders") {
        Task {
          notificationStatus = await ReminderScheduler.schedule(observances: observances)
          LocalAnalyticsStore.track(.requiredRemindersScheduled)
        }
      }
      .disabled(!acceptedLegalNotice)
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
      .disabled(!acceptedLegalNotice || !dailyReminderSupportEnabled || !monetizationStore.premiumUnlocked)
      .accessibilityIdentifier("settings.reminders.schedule_support")
      .accessibilityHint("Schedules daily habit reminders when support is enabled.")

      Button("Refresh Reminder Status") {
        Task {
          notificationStatus = await ReminderScheduler.notificationSummary()
        }
      }
      .appSecondaryButtonStyle()
    }
  }

  var notesSection: some View {
    Section("Notes") {
      NavigationLink("Friday Notes History") {
        FridayNotesHistoryView(notesStore: penanceNotes)
      }
    }
  }

  var observancesSection: some View {
    Section("Observances") {
      if filteredObservances.isEmpty {
        Text("No observances match your filters.")
          .foregroundStyle(.secondary)
      }
      ForEach(filteredObservances) { observance in
        ObservanceRowView(
          observance: observance,
          status: tracker.status(for: observance.id),
          noteBinding: noteBinding(for: observance.id),
          onToggleCompletion: { tracker.toggle(observance.id) },
          onSetStatus: { status in
            tracker.setStatus(status, for: observance.id)
          }
        )
      }
    }
  }
}
