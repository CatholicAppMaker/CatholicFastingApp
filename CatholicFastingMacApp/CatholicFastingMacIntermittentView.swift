import SwiftUI

struct CatholicFastingMacIntermittentView: View {
    @ObservedObject var model: CatholicFastingMacModel
    @State private var scheduleName = ""
    @State private var scheduleStartHour = 20
    @State private var selectedWeekdays: Set<Int> = [2, 4, 6]

    var body: some View {
        MacSurfaceContainer(
            title: "Intermittent Fast",
            subtitle: "Track an active fast, keep recurring schedules, and replace Live Activities with a desktop-native menu bar status.",
            accessibilityID: "mac.surface.intermittent.ready")
        {
            MacCard(title: "Active fast", subtitle: model.menuBarSubtitle) {
                Stepper("Target hours: \(model.intermittentTracker.presetHours)", value: Binding(
                    get: { model.intermittentTracker.presetHours },
                    set: { model.intermittentTracker.setPresetHours($0) }), in: 12 ... 72)
                    .accessibilityIdentifier("mac.intermittent.target")

                HStack {
                    if model.intermittentTracker.activeStart == nil {
                        Button("Start Fast") {
                            model.startFast()
                        }
                        .keyboardShortcut(.space, modifiers: [])
                        .accessibilityIdentifier("mac.intermittent.start")
                    } else {
                        Button("End Fast") {
                            model.endFast()
                        }
                        .accessibilityIdentifier("mac.intermittent.end")
                        Button("Cancel") {
                            model.cancelFast()
                        }
                        .accessibilityIdentifier("mac.intermittent.cancel")
                    }
                }
            }

            HStack(alignment: .top, spacing: 16) {
                MacCard(title: "Schedules", subtitle: "Saved start reminders") {
                    ForEach(model.intermittentSchedules) { plan in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(plan.name)
                                .font(.headline)
                            Text("Starts \(String(format: "%02d:00", plan.startHour)) • \(plan.targetHours)h target")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Button("Apply") {
                                    Task { await model.applySchedule(plan) }
                                }
                                .accessibilityIdentifier("mac.intermittent.apply.\(plan.id)")
                                Button("Delete", role: .destructive) {
                                    model.deleteSchedule(plan)
                                }
                                .accessibilityIdentifier("mac.intermittent.delete.\(plan.id)")
                            }
                        }
                        if plan.id != model.intermittentSchedules.last?.id {
                            Divider()
                        }
                    }
                }

                MacCard(title: "New schedule", subtitle: "Weekly recurring start reminder") {
                    TextField("Schedule name", text: $scheduleName)
                        .accessibilityIdentifier("mac.intermittent.schedule_name")
                    Stepper("Start hour \(String(format: "%02d:00", scheduleStartHour))", value: $scheduleStartHour, in: 0 ... 23)
                        .accessibilityIdentifier("mac.intermittent.schedule_hour")
                    weekdayPicker
                    Button("Save Schedule") {
                        model.addOrUpdateSchedule(name: scheduleName, startHour: scheduleStartHour, weekdays: selectedWeekdays)
                        scheduleName = ""
                        scheduleStartHour = 20
                        selectedWeekdays = [2, 4, 6]
                    }
                    .accessibilityIdentifier("mac.intermittent.save_schedule")
                }
            }

            MacCard(title: "Recent sessions", subtitle: "Most recent first") {
                if model.intermittentTracker.sessions.isEmpty {
                    Text("No completed intermittent fasts yet.")
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("mac.intermittent.history_empty")
                } else {
                    ForEach(Array(model.intermittentTracker.sessions.prefix(10))) { session in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(model.localizedDateTime(session.start))
                                Text("Ended \(model.localizedDateTime(session.end))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(Int((session.duration / 3600).rounded()))h")
                                .font(.headline)
                        }
                        .accessibilityIdentifier("mac.intermittent.session_row")
                        if session.id != model.intermittentTracker.sessions.prefix(10).last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var weekdayPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekdays")
                .font(.caption.weight(.semibold))
            HStack {
                ForEach(Array(1 ... 7), id: \.self) { day in
                    let isSelected = selectedWeekdays.contains(day)
                    Button(String(Calendar.current.weekdaySymbols[day - 1].prefix(3))) {
                        if isSelected {
                            selectedWeekdays.remove(day)
                        } else {
                            selectedWeekdays.insert(day)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isSelected ? CatholicTheme.primary : .gray.opacity(0.4))
                    .accessibilityIdentifier("mac.intermittent.weekday.\(day)")
                }
            }
        }
    }
}
