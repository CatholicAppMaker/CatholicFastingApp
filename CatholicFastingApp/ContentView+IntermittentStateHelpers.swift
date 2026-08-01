import SwiftUI

extension ContentView {
    func addOrUpdateIntermittentSchedulePlan() {
        let count = planningSession.schedules.count + 1
        let trimmedName = fastPresentation.scheduleName.trimmingCharacters(in: .whitespacesAndNewlines)
        let weekdays = Array(fastPresentation.scheduleWeekdays).sorted()
        guard !weekdays.isEmpty else { return }
        let normalizedHour = min(max(fastPresentation.scheduleStartHour, 0), 23)

        if let index = planningSession.schedules.firstIndex(where: { $0.id == fastPresentation.editingScheduleID }) {
            planningSession.schedules[index].name = trimmedName.isEmpty ? "Plan \(index + 1)" : trimmedName
            planningSession.schedules[index].targetHours = intermittentTracker.presetHours
            planningSession.schedules[index].startHour = normalizedHour
            planningSession.schedules[index].weekdays = weekdays
            planningSession.activeScheduleID = planningSession.schedules[index].id
            fastPresentation.editingScheduleID = ""
        } else {
            let newPlan = IntermittentSchedulePlan(
                id: UUID().uuidString,
                name: trimmedName.isEmpty ? "Plan \(count)" : trimmedName,
                targetHours: intermittentTracker.presetHours,
                startHour: normalizedHour,
                weekdays: weekdays)
            planningSession.schedules.append(newPlan)
            planningSession.activeScheduleID = newPlan.id
        }

        fastPresentation.scheduleName = ""
        fastPresentation.scheduleStartHour = 20
        fastPresentation.scheduleWeekdays = [2, 4, 6]
    }

    func startEditingIntermittentSchedule(_ plan: IntermittentSchedulePlan) {
        fastPresentation.editingScheduleID = plan.id
        fastPresentation.scheduleName = plan.name
        fastPresentation.scheduleStartHour = plan.startHour
        fastPresentation.scheduleWeekdays = Set(plan.weekdays)
        intermittentTracker.setPresetHours(plan.targetHours)
    }

    func cancelEditingIntermittentSchedule() {
        fastPresentation.editingScheduleID = ""
        fastPresentation.scheduleName = ""
        fastPresentation.scheduleStartHour = 20
        fastPresentation.scheduleWeekdays = [2, 4, 6]
    }

    func deleteIntermittentSchedule(_ plan: IntermittentSchedulePlan) {
        planningSession.schedules.removeAll { $0.id == plan.id }
        if planningSession.activeScheduleID == plan.id {
            planningSession.activeScheduleID = ""
        }
        if fastPresentation.editingScheduleID == plan.id {
            cancelEditingIntermittentSchedule()
        }
    }

    func applyIntermittentSchedule(_ plan: IntermittentSchedulePlan) async {
        intermittentTracker.setPresetHours(plan.targetHours)
        planningSession.activeScheduleID = plan.id
        if acceptedLegalNotice {
            feedback.notificationStatus = await ReminderScheduler.scheduleIntermittentPlan(plan)
        } else {
            feedback.notificationStatus = localizedFormat(
                "reminder.status.plan_applied_consent_required_format",
                default: "Applied %@. Enable consent in Privacy & Data to schedule start reminders.",
                plan.name)
        }
    }

    var intermittentLongestSessionText: String {
        durationText(intermittentHabitSummary.longestDuration)
    }

    var intermittentHabitSummary: IntermittentHabitSummary {
        IntermittentHabitSummaryEngine.summary(
            sessions: intermittentTracker.sessions,
            now: AppClock.now(),
            calendar: liturgicalCalendar)
    }

    var intermittentWindowLabel: String {
        intermittentPlanDescription(intermittentTracker.presetHours)
    }

    var intermittentPresetBinding: Binding<Int> {
        Binding(
            get: { intermittentTracker.presetHours },
            set: { newValue in
                intermittentTracker.setPresetHours(newValue)
                refreshIntermittentTargetReminder()
            })
    }

    var intermittentManualStartRange: ClosedRange<Date> {
        let latest = AppClock.now()
        let earliest = liturgicalCalendar.date(byAdding: .day, value: -14, to: latest) ?? latest
        return earliest ... latest
    }

    var intermittentActiveStartBinding: Binding<Date> {
        Binding(
            get: { intermittentTracker.activeStart ?? fastPresentation.manualStart },
            set: { newValue in
                fastPresentation.manualStart = newValue
                intermittentTracker.updateActiveStart(to: newValue)
                fastPresentation.manualStart = intermittentTracker.activeStart ?? newValue
                refreshIntermittentTargetReminder()
            })
    }

    func startIntermittentFastFromSelectedTime() {
        intermittentTracker.startFast(now: fastPresentation.manualStart)
        fastPresentation.manualStart = intermittentTracker.activeStart ?? AppClock.now()
        fastPresentation.recapNote = ""
        refreshIntermittentTargetReminder()
    }

    func endIntermittentFastWithReview() {
        intermittentRecapNoteFocused = false
        intermittentTracker.endFast(
            now: AppClock.now(),
            intentionID: intermittentIntentionRaw,
            note: fastPresentation.recapNote)
        navigationState.homeSurface = .intermittent
        let didCompleteTarget = intermittentTracker.sessions.first?.completedTarget ?? false
        let completedTargetSessionCount = intermittentTracker.sessions.count(where: \.completedTarget)
        requestAppReviewIfEligible(
            justCompletedTarget: didCompleteTarget,
            completedTargetSessionCount: completedTargetSessionCount)
        fastPresentation.recapNote = ""
        resetIntermittentManualStartToNow()
        Task {
            feedback.notificationStatus = await ReminderScheduler.clearIntermittentTargetReminders()
        }
    }

    func requestAppReviewIfEligible(
        justCompletedTarget: Bool,
        completedTargetSessionCount: Int)
    {
        guard AppReviewPromptPolicy.shouldRequestReview(
            hasRequestedReview: didRequestAppReview,
            justCompletedTarget: justCompletedTarget,
            completedTargetSessionCount: completedTargetSessionCount,
            isUITest: ProcessInfo.processInfo.environment["UITEST_MODE"] == "1")
        else {
            return
        }

        didRequestAppReview = true
        requestReview()
    }

    func cancelIntermittentFast() {
        intermittentRecapNoteFocused = false
        intermittentTracker.cancelActiveFast()
        navigationState.homeSurface = .intermittent
        fastPresentation.recapNote = ""
        resetIntermittentManualStartToNow()
        Task {
            feedback.notificationStatus = await ReminderScheduler.clearIntermittentTargetReminders()
        }
    }

    func resetIntermittentManualStartToNow() {
        fastPresentation.manualStart = AppClock.now()
    }

    func refreshIntermittentTargetReminder() {
        Task {
            feedback.notificationStatus = await ReminderScheduler.scheduleIntermittentTargetReminder(
                enabled: intermittentTargetReminderEnabled,
                start: intermittentTracker.activeStart,
                targetHours: intermittentTracker.presetHours)
        }
    }

    func durationText(_ duration: TimeInterval) -> String {
        let totalMinutes = max(0, Int(duration / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02dh %02dm", hours, minutes)
    }

    func countdownText(_ duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration))
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if days > 0 {
            return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    func intermittentPlanDescription(_ hours: Int) -> String {
        if hours <= 24 {
            return localizedFormat(
                "intermittent.plan.schedule_format",
                default: "%dh fast / %dh eating",
                hours,
                24 - hours)
        }
        return localizedFormat(
            "intermittent.plan.target_only_format",
            default: "%dh fast target",
            hours)
    }

    var canSaveIntermittentSchedule: Bool {
        !fastPresentation.scheduleWeekdays.isEmpty
    }

    var isEditingIntermittentSchedule: Bool {
        !fastPresentation.editingScheduleID.isEmpty
    }

    func weekdayListText(_ weekdays: [Int]) -> String {
        let labels =
            weekdays
                .map { weekdayLabel(for: $0) }
                .filter { !$0.isEmpty }
        return labels.isEmpty
            ? localized("intermittent.schedule.custom_days", default: "Custom days")
            : labels.joined(separator: ", ")
    }

    func weekdayLabel(for value: Int) -> String {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        let index = value - 1
        guard index >= 0, index < symbols.count else { return "" }
        return symbols[index]
    }

    func toggleIntermittentScheduleWeekday(_ weekday: Int) {
        guard (1 ... 7).contains(weekday) else { return }
        if fastPresentation.scheduleWeekdays.contains(weekday) {
            fastPresentation.scheduleWeekdays.remove(weekday)
        } else {
            fastPresentation.scheduleWeekdays.insert(weekday)
        }
    }
}
