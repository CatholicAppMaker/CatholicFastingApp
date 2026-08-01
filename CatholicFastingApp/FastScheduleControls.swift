import SwiftUI

struct IntermittentScheduleCopy {
    let sectionTitle: String
    let intro: String
    let empty: String
    let namePlaceholder: String
    let startHourLabel: (Int) -> String
    let weekdaysTitle: String
    let weekdayLabel: (Int) -> String
    let applied: String
    let planSummary: (IntermittentSchedulePlan) -> String
    let hideEditor: String
    let newSchedule: String
    let use: String
    let edit: String
    let delete: String
    let update: String
    let save: String
    let cancelEdit: String
}

struct IntermittentScheduleEditor: View {
    let presentation: IntermittentFastControlPresentation
    let copy: IntermittentScheduleCopy
    let plans: [IntermittentSchedulePlan]
    let activeScheduleID: String
    let isEditing: Bool
    @Binding var showsEditor: Bool
    @Binding var scheduleName: String
    @Binding var startHour: Int
    @Binding var weekdays: Set<Int>
    let notificationStatus: String
    let canSave: Bool
    let toggleWeekday: (Int) -> Void
    let apply: (IntermittentSchedulePlan) -> Void
    let edit: (IntermittentSchedulePlan) -> Void
    let delete: (IntermittentSchedulePlan) -> Void
    let save: () -> Void
    let cancelEditing: () -> Void

    var body: some View {
        header

        if plans.isEmpty {
            emptyState
        } else {
            ForEach(plans) { plan in
                scheduleRow(plan)
            }
        }

        if showsEditor || isEditing {
            editor
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            if presentation == .pad {
                VStack(alignment: .leading, spacing: 4) {
                    Text(copy.sectionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CatholicTheme.primary)
                    Text(copy.intro)
                        .appSupportingTextStyle()
                }
            } else {
                Text(copy.intro)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            editorToggleButton
        }
    }

    @ViewBuilder private var emptyState: some View {
        switch presentation {
        case .phone:
            Text(copy.empty)
                .foregroundStyle(.secondary)
        case .pad:
            Text(copy.empty)
                .appSupportingTextStyle()
        }
    }

    private var editorToggleButton: some View {
        Button(action: toggleEditor) {
            Label(
                showsEditor || isEditing ? copy.hideEditor : copy.newSchedule,
                systemImage: showsEditor || isEditing ? "chevron.up" : "plus")
        }
        .buttonStyle(.bordered)
        .accessibilityIdentifier("intermittent.schedule.toggle_editor")
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            scheduleNameField

            Stepper(
                copy.startHourLabel(startHour),
                value: $startHour,
                in: 0 ... 23)
                .accessibilityIdentifier("intermittent.schedule.start_hour")

            VStack(alignment: .leading, spacing: 8) {
                Text(copy.weekdaysTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    ForEach(1 ... 7, id: \.self) { weekday in
                        let selected = weekdays.contains(weekday)
                        Button(copy.weekdayLabel(weekday)) {
                            toggleWeekday(weekday)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(selected ? CatholicTheme.primary : .gray.opacity(0.35))
                    }
                }
            }
            .accessibilityIdentifier("intermittent.schedule.weekdays")

            if presentation == .phone, !notificationStatus.isEmpty {
                Text(notificationStatus)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            saveControls
        }
    }

    @ViewBuilder private var scheduleNameField: some View {
        switch presentation {
        case .phone:
            TextField(copy.namePlaceholder, text: $scheduleName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .accessibilityIdentifier("intermittent.schedule.name")
        case .pad:
            TextField(copy.namePlaceholder, text: $scheduleName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("intermittent.schedule.name")
        }
    }

    @ViewBuilder private var saveControls: some View {
        if presentation == .phone {
            HStack {
                saveButton
                if isEditing {
                    cancelButton
                }
            }
        } else {
            saveButton
        }
    }

    private var saveButton: some View {
        Button(isEditing ? copy.update : copy.save) {
            save()
            showsEditor = false
        }
        .appPrimaryButtonStyle()
        .disabled(!canSave)
        .accessibilityIdentifier("intermittent.schedule.add")
    }

    private var cancelButton: some View {
        Button(copy.cancelEdit) {
            cancelEditing()
            showsEditor = false
        }
        .appSecondaryButtonStyle()
        .accessibilityIdentifier("intermittent.schedule.cancel_edit")
    }

    private func scheduleRow(_ plan: IntermittentSchedulePlan) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(plan.name)
                        .font(.subheadline.weight(.semibold))
                    if activeScheduleID == plan.id {
                        Text(copy.applied)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(CatholicTheme.primary))
                    }
                }
                Text(copy.planSummary(plan))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Menu {
                Button(copy.use) {
                    apply(plan)
                }
                Button(copy.edit) {
                    edit(plan)
                    showsEditor = true
                }
                Button(copy.delete, role: .destructive) {
                    delete(plan)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(CatholicTheme.primary)
            }
            .accessibilityIdentifier("intermittent.schedule.actions")
        }
        .padding(.vertical, 4)
    }

    private func toggleEditor() {
        if showsEditor || isEditing {
            if isEditing {
                cancelEditing()
            }
            showsEditor = false
        } else {
            showsEditor = true
        }
    }
}
