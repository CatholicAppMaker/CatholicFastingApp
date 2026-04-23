import SwiftUI

@MainActor
extension CatholicFastingMacModel {
    func setStatus(_ status: CompletionStatus, for observance: Observance) {
        tracker.setStatus(status, for: observance.id)
    }

    func noteBinding(for observanceID: String) -> Binding<String> {
        Binding(
            get: { self.penanceNotes.note(for: observanceID) },
            set: { self.penanceNotes.setNote($0, for: observanceID) })
    }

    func addOrUpdateSchedule(name: String, startHour: Int, weekdays: Set<Int>, editingID: String? = nil) {
        let normalizedHour = min(max(startHour, 0), 23)
        let normalizedWeekdays = Array(weekdays).sorted().filter { (1 ... 7).contains($0) }
        guard !normalizedWeekdays.isEmpty else { return }

        if let editingID, let index = intermittentSchedules.firstIndex(where: { $0.id == editingID }) {
            intermittentSchedules[index].name = name.isEmpty ? intermittentSchedules[index].name : name
            intermittentSchedules[index].startHour = normalizedHour
            intermittentSchedules[index].targetHours = intermittentTracker.presetHours
            intermittentSchedules[index].weekdays = normalizedWeekdays
            activeIntermittentScheduleID = intermittentSchedules[index].id
            return
        }

        let plan = IntermittentSchedulePlan(
            id: UUID().uuidString,
            name: name.isEmpty ? "Schedule \(intermittentSchedules.count + 1)" : name,
            targetHours: intermittentTracker.presetHours,
            startHour: normalizedHour,
            weekdays: normalizedWeekdays)
        intermittentSchedules.append(plan)
        activeIntermittentScheduleID = plan.id
    }

    func deleteSchedule(_ plan: IntermittentSchedulePlan) {
        intermittentSchedules.removeAll { $0.id == plan.id }
        if activeIntermittentScheduleID == plan.id {
            activeIntermittentScheduleID = intermittentSchedules.first?.id ?? ""
        }
    }

    func applySchedule(_ plan: IntermittentSchedulePlan) async {
        intermittentTracker.setPresetHours(plan.targetHours)
        activeIntermittentScheduleID = plan.id
        if acceptedLegalNotice {
            notificationStatus = await services.reminders.scheduleIntermittentPlan(plan)
        } else {
            notificationStatus = "Applied \(plan.name). Confirm privacy consent before scheduling reminders."
        }
    }

    func addReflection(title: String, body: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty || !trimmedBody.isEmpty else { return }
        reflectionEntries.insert(
            ReflectionJournalEntry(
                id: UUID().uuidString,
                createdAt: Date(),
                title: trimmedTitle.isEmpty ? "Reflection" : trimmedTitle,
                body: trimmedBody),
            at: 0)
    }

    func toggleChecklistItem(_ item: PremiumChecklistItem) {
        guard let index = premiumChecklist.firstIndex(where: { $0.id == item.id }) else { return }
        premiumChecklist[index].isDone.toggle()
    }

    func toggleJourneyAction(_ actionID: String) {
        let key = GuidedSeasonalJourneyEngine.actionKey(
            program: journeyWeek.program,
            week: journeyWeek.weekNumber,
            actionID: actionID)
        if premiumCompanion.completedProgramActions.contains(key) {
            premiumCompanion.completedProgramActions.removeAll { $0 == key }
        } else {
            premiumCompanion.completedProgramActions.append(key)
        }
    }

    func isJourneyActionCompleted(_ actionID: String) -> Bool {
        let key = GuidedSeasonalJourneyEngine.actionKey(
            program: journeyWeek.program,
            week: journeyWeek.weekNumber,
            actionID: actionID)
        return premiumCompanion.completedProgramActions.contains(key)
    }

    func startFast() {
        intermittentTracker.startFast()
        persistWidgetSnapshot()
        objectWillChange.send()
    }

    func endFast() {
        intermittentTracker.endFast()
        persistWidgetSnapshot()
        objectWillChange.send()
    }

    func cancelFast() {
        intermittentTracker.cancelActiveFast()
        persistWidgetSnapshot()
        objectWillChange.send()
    }
}
