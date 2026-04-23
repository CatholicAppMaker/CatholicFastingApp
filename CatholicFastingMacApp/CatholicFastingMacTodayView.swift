import SwiftUI

struct CatholicFastingMacTodayView: View {
    @ObservedObject var model: CatholicFastingMacModel

    var body: some View {
        MacSurfaceContainer(
            title: "Today",
            subtitle: "Desktop-first overview for your current observance, next required day, and overall progress.",
            accessibilityID: "mac.surface.today.ready")
        {
            MacCard(
                title: model.todayPrimaryObservance.map { model.localizedObservanceTitle($0.title) } ?? "No observance today",
                subtitle: model.todayPrimaryObservance?.dispositionLabel ?? "No obligation")
            {
                if let observance = model.todayPrimaryObservance {
                    Picker("Status", selection: Binding(
                        get: { model.tracker.status(for: observance.id) },
                        set: { model.setStatus($0, for: observance) }))
                    {
                        ForEach(CompletionStatus.allCases) { status in
                            Text(status.label).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("mac.today.status")

                    if observance.kind == .fridayPenance {
                        TextField("Friday penance note", text: model.noteBinding(for: observance.id))
                            .accessibilityIdentifier("mac.today.friday_note")
                    }
                } else {
                    Text("Keep voluntary prayer, almsgiving, or a voluntary penance if helpful.")
                        .foregroundStyle(.secondary)
                }
            }

            HStack(alignment: .top, spacing: 16) {
                MacCard(
                    title: "Next required observance",
                    subtitle: model.upcomingMandatoryObservance.map { model.localizedDate($0.date) } ?? "Nothing upcoming")
                {
                    Text(model.upcomingMandatoryObservance.map { model.localizedObservanceTitle($0.title) } ?? "No upcoming required observance")
                }

                MacCard(title: "Year progress", subtitle: "Completed, substituted, or dispensed") {
                    Text(model.completionRateText)
                        .font(.system(size: 34, weight: .semibold))
                    Text("\(model.completedCount) of \(model.actionableObservances.count) tracked days")
                        .foregroundStyle(.secondary)
                }
            }

            MacCard(title: "Formation line", subtitle: "Current seasonal plan") {
                Text(model.seasonPlan.focusLine)
                ForEach(model.seasonPlan.practices, id: \.self) { practice in
                    Label(practice, systemImage: "checkmark.circle")
                }
            }

            MacCard(title: "Reminders", subtitle: "Current queue status") {
                Text(model.notificationStatus)
                    .accessibilityIdentifier("mac.today.notification_status")
                HStack {
                    Button("Request Permission") {
                        Task { await model.requestReminderPermission() }
                    }
                    .accessibilityIdentifier("mac.today.request_permission")
                    Button("Refresh Status") {
                        Task { await model.performInitialStartupTasks() }
                    }
                    .accessibilityIdentifier("mac.today.refresh_status")
                }
            }
        }
    }
}
