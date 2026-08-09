@preconcurrency import Foundation

enum CompanionActionDestination: Hashable {
    case today
    case fastingDays
    case trackFast
    case guidance
    case setup
    case premium
    case journal
}

enum CompanionActionPriority: Int, Comparable, Hashable {
    case low = 0
    case normal = 1
    case high = 2

    static func < (lhs: CompanionActionPriority, rhs: CompanionActionPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct CompanionNextAction: Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let destination: CompanionActionDestination
    let priority: CompanionActionPriority
    let requiresPremium: Bool
}

struct CompanionRuleDecision: Hashable {
    let category: DailyFoodDecision.Category
    let obligationLine: String
    let rationale: String
    let sourceLine: String
    let todayTitles: [String]
    let hasMandatoryObservance: Bool
}

struct CompanionLiveFastState: Hashable {
    let activeStart: Date?
    let targetHours: Int
    let latestSession: IntermittentFastSession?
    let progress: FastProgressState
}

struct CompanionFormationState: Hashable {
    let season: LiturgicalSeason
    let seasonLabel: String
    let journeyTitle: String
    let nextJourneyActionTitle: String
    let nextJourneyActionDetail: String
    let completionSummary: String
    let recoverySummary: String?
    let currentStreak: Int
    let premiumUnlocked: Bool
}

struct CompanionSnapshot: Hashable {
    let date: Date
    let ruleDecision: CompanionRuleDecision
    let liveFast: CompanionLiveFastState
    let nextRequiredObservance: Observance?
    let formation: CompanionFormationState
    let primaryAction: CompanionNextAction
    let secondaryActions: [CompanionNextAction]
}

struct CompanionSnapshotRequest {
    let date: Date
    let observances: [Observance]
    let settings: RuleSettings
    let statusesByID: [String: CompletionStatus]
    let activeFastStart: Date?
    let activeFastTargetHours: Int
    let intermittentSessions: [IntermittentFastSession]
    let journeyWeek: GuidedSeasonalJourneyWeek
    let journeyProgress: GuidedSeasonalJourneyProgress
    let currentStreak: Int
    let premiumUnlocked: Bool
    let calendar: Calendar
}

enum CompanionSnapshotEngine {
    static func snapshot(_ request: CompanionSnapshotRequest) -> CompanionSnapshot {
        let date = request.date
        let observances = request.observances
        let settings = request.settings
        let statusesByID = request.statusesByID
        let activeFastStart = request.activeFastStart
        let activeFastTargetHours = request.activeFastTargetHours
        let intermittentSessions = request.intermittentSessions
        let journeyWeek = request.journeyWeek
        let journeyProgress = request.journeyProgress
        let currentStreak = request.currentStreak
        let premiumUnlocked = request.premiumUnlocked
        let calendar = request.calendar

        let startOfToday = calendar.startOfDay(for: date)
        let sortedObservances = observances.sorted { $0.date < $1.date }
        let todayObservances = sortedObservances.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
        let todayActionable = todayObservances.filter { $0.obligation != .notApplicable }
        let decision = DailyFoodDecisionEngine.decision(
            for: sortedObservances,
            settings: settings,
            date: date,
            calendar: calendar)
        let nextRequired = sortedObservances.first {
            $0.obligation == .mandatory && calendar.startOfDay(for: $0.date) > startOfToday
        }
        let recovery = MissedDayRecoveryEngine.plan(
            observances: sortedObservances,
            statusesByID: statusesByID,
            today: date,
            calendar: calendar)
        let liveProgress = FastProgressState.current(
            activeStart: activeFastStart,
            targetHours: activeFastTargetHours,
            sessions: intermittentSessions,
            now: date,
            calendar: calendar)
        let localizedDecision = DailyFoodDecisionLocalizer.localizedCurrent(decision)
        let ruleDecision = CompanionRuleDecision(
            category: localizedDecision.category,
            obligationLine: localizedDecision.obligationLine,
            rationale: localizedDecision.rationale,
            sourceLine: localizedDecision.sourceLine,
            todayTitles: todayObservances.map { ObservanceLocalizationCatalog.localizedCurrentTitle($0.title) },
            hasMandatoryObservance: todayActionable.contains { $0.obligation == .mandatory })
        let nextJourneyAction = journeyProgress.nextAction
        let formation = CompanionFormationState(
            season: journeyWeek.season,
            seasonLabel: journeyWeek.season.label,
            journeyTitle: journeyWeek.title,
            nextJourneyActionTitle: nextJourneyAction?.title
                ?? CoreLocalizer.localizedCurrent(
                    "companion.formation.review_ready",
                    default: "Review this week's rhythm"),
            nextJourneyActionDetail: nextJourneyAction?.detail
                ?? journeyProgress.completionSummary,
            completionSummary: journeyProgress.completionSummary,
            recoverySummary: recovery?.summaryLine,
            currentStreak: currentStreak,
            premiumUnlocked: premiumUnlocked)
        let primaryAction = primaryAction(
            decision: localizedDecision,
            hasMedicalDispensation: settings.hasMedicalDispensation,
            todayActionable: todayActionable,
            nextRequired: nextRequired,
            recovery: recovery,
            liveProgress: liveProgress,
            premiumUnlocked: premiumUnlocked)
        let secondaryActions = secondaryActions(
            nextRequired: nextRequired,
            liveProgress: liveProgress,
            journeyAction: nextJourneyAction,
            premiumUnlocked: premiumUnlocked)

        return CompanionSnapshot(
            date: date,
            ruleDecision: ruleDecision,
            liveFast: CompanionLiveFastState(
                activeStart: activeFastStart,
                targetHours: activeFastTargetHours,
                latestSession: intermittentSessions.first,
                progress: liveProgress),
            nextRequiredObservance: nextRequired,
            formation: formation,
            primaryAction: primaryAction,
            secondaryActions: secondaryActions)
    }

    private static func primaryAction(
        decision: DailyFoodDecision,
        hasMedicalDispensation: Bool,
        todayActionable: [Observance],
        nextRequired: Observance?,
        recovery: MissedDayRecoveryPlan?,
        liveProgress: FastProgressState,
        premiumUnlocked: Bool) -> CompanionNextAction
    {
        if recovery != nil {
            return CompanionNextAction(
                id: "recovery",
                title: CoreLocalizer.localizedCurrent(
                    "companion.action.recovery.title",
                    default: "Start a gentle recovery"),
                detail: CoreLocalizer.localizedCurrent(
                    "companion.action.recovery.detail",
                    default: "A missed day can become today's concrete act of renewal."),
                destination: premiumUnlocked ? .premium : .fastingDays,
                priority: .high,
                requiresPremium: false)
        }

        if hasMedicalDispensation {
            return CompanionNextAction(
                id: "dispensation-guidance",
                title: CoreLocalizer.localizedCurrent(
                    "companion.action.dispensation.title",
                    default: "Review prudent guidance"),
                detail: decision.rationale,
                destination: .guidance,
                priority: .high,
                requiresPremium: false)
        }

        if todayActionable.contains(where: { $0.obligation == .mandatory }) {
            return CompanionNextAction(
                id: "today-rule",
                title: CoreLocalizer.localizedCurrent(
                    "companion.action.today_rule.title",
                    default: "Review today's rule"),
                detail: decision.rationale,
                destination: .guidance,
                priority: .high,
                requiresPremium: false)
        }

        switch liveProgress {
        case .active, .targetReached:
            return CompanionNextAction(
                id: "active-fast",
                title: CoreLocalizer.localizedCurrent(
                    "companion.action.active_fast.title",
                    default: "Check the live fast"),
                detail: CoreLocalizer.localizedCurrent(
                    "companion.action.active_fast.detail",
                    default: "Elapsed, remaining, target, and intention are ready in Fast."),
                destination: .trackFast,
                priority: .high,
                requiresPremium: false)
        case .completedRecap:
            return CompanionNextAction(
                id: "fast-recap",
                title: CoreLocalizer.localizedCurrent(
                    "companion.action.fast_recap.title",
                    default: "Review the fast recap"),
                detail: CoreLocalizer.localizedCurrent(
                    "companion.action.fast_recap.detail",
                    default: "Mark the good fruit and choose a prudent next rhythm."),
                destination: .trackFast,
                priority: .normal,
                requiresPremium: false)
        case .inactive where nextRequired != nil,
             .eatingWindow where nextRequired != nil:
            return CompanionNextAction(
                id: "next-required",
                title: CoreLocalizer.localizedCurrent(
                    "companion.action.next_required.title",
                    default: "Plan the next required day"),
                detail: CoreLocalizer.localizedCurrent(
                    "companion.action.next_required.detail",
                    default: "Keep the next obligation visible before the day gets crowded."),
                destination: .fastingDays,
                priority: .normal,
                requiresPremium: false)
        case .inactive, .eatingWindow:
            return CompanionNextAction(
                id: "start-fast",
                title: CoreLocalizer.localizedCurrent(
                    "companion.action.start_fast.title",
                    default: "Start a faithful fast"),
                detail: CoreLocalizer.localizedCurrent(
                    "companion.action.start_fast.detail",
                    default: "Choose an intention and keep the next rhythm prudent."),
                destination: .trackFast,
                priority: .normal,
                requiresPremium: false)
        }
    }

    private static func secondaryActions(
        nextRequired: Observance?,
        liveProgress: FastProgressState,
        journeyAction: GuidedSeasonalJourneyAction?,
        premiumUnlocked: Bool) -> [CompanionNextAction]
    {
        var actions: [CompanionNextAction] = [
            CompanionNextAction(
                id: "track-fast",
                title: CoreLocalizer.localizedCurrent(
                    "companion.action.track_fast.title",
                    default: "Fast"),
                detail: CoreLocalizer.localizedCurrent(
                    "companion.action.track_fast.detail",
                    default: "Start, edit, or review your fasting window."),
                destination: .trackFast,
                priority: liveProgress.isActive ? .high : .normal,
                requiresPremium: false),
        ]

        if nextRequired != nil {
            actions.append(
                CompanionNextAction(
                    id: "fasting-days",
                    title: CoreLocalizer.localizedCurrent(
                        "companion.action.fasting_days.title",
                        default: "Open Calendar"),
                    detail: CoreLocalizer.localizedCurrent(
                        "companion.action.fasting_days.detail",
                        default: "Review required and optional observances."),
                    destination: .fastingDays,
                    priority: .normal,
                    requiresPremium: false))
        }

        actions.append(
            CompanionNextAction(
                id: "formation",
                title: journeyAction?.title
                    ?? CoreLocalizer.localizedCurrent(
                        "companion.action.formation.title",
                        default: "Open formation"),
                detail: journeyAction?.detail
                    ?? CoreLocalizer.localizedCurrent(
                        "companion.action.formation.detail",
                        default: "Keep fasting tied to prayer, charity, and review."),
                destination: premiumUnlocked ? .premium : .setup,
                priority: premiumUnlocked ? .normal : .low,
                requiresPremium: true))

        return actions.sorted { $0.priority > $1.priority }
    }
}

enum FastStage: Hashable {
    case ready
    case early
    case steady
    case targetReached
    case eatingWindow
    case completed

    var label: String {
        switch self {
        case .ready:
            CoreLocalizer.localizedCurrent("fast.stage.ready", default: "Ready")
        case .early:
            CoreLocalizer.localizedCurrent("fast.stage.early", default: "Early fast")
        case .steady:
            CoreLocalizer.localizedCurrent("fast.stage.steady", default: "Steady fast")
        case .targetReached:
            CoreLocalizer.localizedCurrent("fast.stage.target_reached", default: "Target reached")
        case .eatingWindow:
            CoreLocalizer.localizedCurrent("fast.stage.eating_window", default: "Eating window")
        case .completed:
            CoreLocalizer.localizedCurrent("fast.stage.completed", default: "Completed")
        }
    }
}

enum FastProgressState: Hashable {
    case inactive(targetHours: Int, latestSession: IntermittentFastSession?)
    case active(start: Date, targetHours: Int, elapsed: TimeInterval, remaining: TimeInterval, progress: Double, stage: FastStage)
    case targetReached(start: Date, targetHours: Int, elapsed: TimeInterval, progress: Double, stage: FastStage)
    case eatingWindow(latestSession: IntermittentFastSession, elapsedSinceEnd: TimeInterval, suggestedNextStart: Date?)
    case completedRecap(IntermittentFastSessionRecap)

    static func current(
        activeStart: Date?,
        targetHours: Int,
        sessions: [IntermittentFastSession],
        now: Date = AppClock.now(),
        calendar: Calendar = .current) -> FastProgressState
    {
        if let activeStart {
            let elapsed = max(0, now.timeIntervalSince(activeStart))
            let target = TimeInterval(max(1, targetHours) * 3600)
            let remaining = max(0, target - elapsed)
            let progress = min(1, elapsed / target)
            if remaining == 0 {
                return .targetReached(
                    start: activeStart,
                    targetHours: targetHours,
                    elapsed: elapsed,
                    progress: 1,
                    stage: .targetReached)
            }
            return .active(
                start: activeStart,
                targetHours: targetHours,
                elapsed: elapsed,
                remaining: remaining,
                progress: progress,
                stage: elapsed < 4 * 3600 ? .early : .steady)
        }

        guard let latest = sessions.first else {
            return .inactive(targetHours: targetHours, latestSession: nil)
        }

        let recap = IntermittentFastSessionRecap.make(session: latest)
        let endedRecently = now.timeIntervalSince(latest.end) <= 2 * 3600
        if endedRecently {
            return .completedRecap(recap)
        }

        let eatingHours = max(0, 24 - min(latest.targetHours, 24))
        guard eatingHours > 0 else {
            return .inactive(targetHours: targetHours, latestSession: latest)
        }

        let suggestedNextStart = calendar.date(byAdding: .hour, value: eatingHours, to: latest.end)
        if let suggestedNextStart, now < suggestedNextStart {
            return .eatingWindow(
                latestSession: latest,
                elapsedSinceEnd: now.timeIntervalSince(latest.end),
                suggestedNextStart: suggestedNextStart)
        }

        return .inactive(targetHours: targetHours, latestSession: latest)
    }

    var isActive: Bool {
        switch self {
        case .active, .targetReached:
            true
        case .inactive, .eatingWindow, .completedRecap:
            false
        }
    }

    var stage: FastStage {
        switch self {
        case .inactive:
            .ready
        case .active(_, _, _, _, _, let stage):
            stage
        case .targetReached:
            .targetReached
        case .eatingWindow:
            .eatingWindow
        case .completedRecap:
            .completed
        }
    }
}

struct IntermittentFastSessionRecap: Hashable {
    let sessionID: String
    let duration: TimeInterval
    let targetHours: Int
    let completedTarget: Bool
    let title: String
    let encouragement: String
    let suggestedNextAction: String

    static func make(
        session: IntermittentFastSession,
        hasMedicalDispensation: Bool = false) -> IntermittentFastSessionRecap
    {
        if hasMedicalDispensation {
            return IntermittentFastSessionRecap(
                sessionID: session.id,
                duration: session.duration,
                targetHours: session.targetHours,
                completedTarget: session.completedTarget,
                title: CoreLocalizer.localizedCurrent(
                    "fast.recap.dispensation.title",
                    default: "Prudent discipline logged"),
                encouragement: CoreLocalizer.localizedCurrent(
                    "fast.recap.dispensation.encouragement",
                    default: "Health and pastoral obedience remain part of faithful discipline."),
                suggestedNextAction: CoreLocalizer.localizedCurrent(
                    "fast.recap.dispensation.next",
                    default: "Choose prayer, charity, or a lighter rhythm before adding intensity."))
        }

        if session.completedTarget {
            return IntermittentFastSessionRecap(
                sessionID: session.id,
                duration: session.duration,
                targetHours: session.targetHours,
                completedTarget: true,
                title: CoreLocalizer.localizedCurrent(
                    "fast.recap.completed.title",
                    default: "Fast completed"),
                encouragement: CoreLocalizer.localizedCurrent(
                    "fast.recap.completed.encouragement",
                    default: "Good rhythm. Receive the fruit with gratitude, not pressure."),
                suggestedNextAction: CoreLocalizer.localizedCurrent(
                    "fast.recap.completed.next",
                    default: "Break the fast gently and keep the next required day visible."))
        }

        return IntermittentFastSessionRecap(
            sessionID: session.id,
            duration: session.duration,
            targetHours: session.targetHours,
            completedTarget: false,
            title: CoreLocalizer.localizedCurrent(
                "fast.recap.short.title",
                default: "Fast ended early"),
            encouragement: CoreLocalizer.localizedCurrent(
                "fast.recap.short.encouragement",
                default: "Ending early can still be honest discipline when you re-enter calmly."),
            suggestedNextAction: CoreLocalizer.localizedCurrent(
                "fast.recap.short.next",
                default: "Choose a lighter target or pair the next fast with a concrete prayer intention."))
    }
}
