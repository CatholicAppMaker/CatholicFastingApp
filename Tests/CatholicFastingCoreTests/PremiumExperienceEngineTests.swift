@testable import CatholicFastingCore
import XCTest

final class PremiumExperienceEngineTests: XCTestCase {
    override func setUp() {
        super.setUp()
        beginStoreIsolation()
        resetStores()
    }

    override func tearDown() {
        resetStores()
        endStoreIsolation()
        super.tearDown()
    }

    func testReminderPlannerUsesRecoveryModeForMultipleMisses() {
        let now = makeDate(year: 2026, month: 3, day: 10)
        let observances = [
            makeObservance(id: "a", title: "A", date: makeDate(year: 2026, month: 3, day: 2), obligation: .mandatory),
            makeObservance(id: "b", title: "B", date: makeDate(year: 2026, month: 3, day: 5), obligation: .mandatory),
            makeObservance(id: "c", title: "C", date: makeDate(year: 2026, month: 3, day: 8), obligation: .mandatory),
        ]
        let statuses: [String: CompletionStatus] = [
            "a": .missed,
            "b": .missed,
            "c": .completed,
        ]

        let recommendation = PremiumReminderPlanner.recommendation(
            observances: observances,
            statusesByID: statuses,
            now: now,
            calendar: fixedCalendar)

        XCTAssertTrue(recommendation.shouldEnableDailySupport)
        XCTAssertTrue(recommendation.shouldEnableMorning)
        XCTAssertTrue(recommendation.shouldEnableEvening)
        XCTAssertTrue(recommendation.summaryLine.localizedCaseInsensitiveContains("recovery"))
    }

    func testReminderPlannerFallsBackToMaintenanceModeWithoutUpcomingRequiredDays() {
        let now = makeDate(year: 2026, month: 7, day: 15)
        let observances = [
            makeObservance(id: "a", title: "A", date: makeDate(year: 2026, month: 6, day: 20), obligation: .optional),
            makeObservance(id: "b", title: "B", date: makeDate(year: 2026, month: 7, day: 10), obligation: .optional),
        ]
        let statuses: [String: CompletionStatus] = [
            "a": .completed,
            "b": .completed,
        ]

        let recommendation = PremiumReminderPlanner.recommendation(
            observances: observances,
            statusesByID: statuses,
            now: now,
            calendar: fixedCalendar)

        XCTAssertTrue(recommendation.shouldEnableDailySupport)
        XCTAssertFalse(recommendation.shouldEnableMorning)
        XCTAssertTrue(recommendation.shouldEnableEvening)
        XCTAssertTrue(recommendation.summaryLine.localizedCaseInsensitiveContains("maintenance"))
    }

    func testAnalyticsSummaryComputesCompletionAndIntermittentRate() {
        let observances = [
            makeObservance(id: "r1", title: "R1", date: makeDate(year: 2026, month: 2, day: 10), obligation: .mandatory),
            makeObservance(id: "r2", title: "R2", date: makeDate(year: 2026, month: 3, day: 10), obligation: .mandatory),
            makeObservance(id: "o1", title: "O1", date: makeDate(year: 2026, month: 7, day: 10), obligation: .optional),
        ]
        let statuses: [String: CompletionStatus] = [
            "r1": .completed,
            "r2": .missed,
            "o1": .substituted,
        ]
        let sessions = [
            IntermittentFastSession(
                id: "s1",
                start: makeDate(year: 2026, month: 1, day: 1),
                end: makeDate(year: 2026, month: 1, day: 2),
                targetHours: 16),
            IntermittentFastSession(
                id: "s2",
                start: makeDate(year: 2026, month: 1, day: 3),
                end: makeDate(year: 2026, month: 1, day: 3, hour: 10),
                targetHours: 16),
        ]

        let summary = PremiumAnalyticsEngine.summary(
            observances: observances,
            statusesByID: statuses,
            sessions: sessions)

        XCTAssertEqual(summary.requiredCompletionPercent, 50)
        XCTAssertEqual(summary.overallCompletionPercent, 67)
        XCTAssertEqual(summary.missedCount, 1)
        XCTAssertEqual(summary.substitutedCount, 1)
        XCTAssertEqual(summary.intermittentTargetHitPercent, 50)
        XCTAssertFalse(summary.seasonRows.isEmpty)
    }

    func testReflectionIsDeterministicForDateAndSeason() {
        let date = makeDate(year: 2026, month: 12, day: 9)
        let first = PremiumReflectionEngine.reflection(for: date, season: .advent)
        let second = PremiumReflectionEngine.reflection(for: date, season: .advent)
        XCTAssertEqual(first, second)
    }

    func testDirectionSummaryContainsCoreSections() {
        let analytics = PremiumAnalyticsSummary(
            requiredCompletionPercent: 80,
            overallCompletionPercent: 77,
            missedCount: 1,
            substitutedCount: 2,
            intermittentTargetHitPercent: 60,
            seasonRows: [])
        let reminder = PremiumReminderRecommendation(
            shouldEnableDailySupport: true,
            shouldEnableMorning: true,
            shouldEnableEvening: false,
            summaryLine: "Preparation mode")
        let plan = PremiumSeasonPlan(
            titleLine: "Lenten Discipline Plan",
            focusLine: "Repentance focus",
            practices: ["Practice 1"],
            fastingIntensity: "Strong")
        let reflection = PremiumReflection(
            title: "Return to the Lord",
            body: "Fasting with prayer.",
            action: "Pray now.")

        let summary = PremiumDirectionSummaryEngine.summaryText(
            date: makeDate(year: 2026, month: 3, day: 1),
            season: .lent,
            analytics: analytics,
            reminder: reminder,
            plan: plan,
            latestReflection: reflection)

        XCTAssertTrue(summary.contains("Catholic Fasting Premium Summary"))
        XCTAssertTrue(summary.contains("Discipline Metrics"))
        XCTAssertTrue(summary.contains("Reminder Strategy"))
        XCTAssertTrue(summary.contains("Reflection"))
    }

    func testSubscriptionHealthMatrixPrioritizesCriticalStates() {
        XCTAssertEqual(
            PremiumSubscriptionHealthEvaluator.message(states: [.revoked], premiumUnlocked: true),
            "Subscription was revoked. Restore or update your account.")
        XCTAssertEqual(
            PremiumSubscriptionHealthEvaluator.message(states: [.inBillingRetry], premiumUnlocked: true),
            "Billing issue detected. Update your payment method to keep Premium.")
        XCTAssertEqual(
            PremiumSubscriptionHealthEvaluator.message(states: [.inGracePeriod], premiumUnlocked: true),
            "You are in billing grace period. Premium remains active for now.")
        XCTAssertEqual(
            PremiumSubscriptionHealthEvaluator.message(states: [.expired], premiumUnlocked: false),
            "Premium subscription expired.")
        XCTAssertEqual(
            PremiumSubscriptionHealthEvaluator.message(states: [.subscribed], premiumUnlocked: false),
            "Premium subscription is active.")
        XCTAssertEqual(
            PremiumSubscriptionHealthEvaluator.message(states: [], premiumUnlocked: true),
            "Premium subscription is active.")
        XCTAssertEqual(
            PremiumSubscriptionHealthEvaluator.message(states: [], premiumUnlocked: false),
            "")
    }

    func testSubscriptionHealthMatrixUsesPriorityOrderWhenMultipleStatesExist() {
        let message = PremiumSubscriptionHealthEvaluator.message(
            states: [.subscribed, .expired, .inBillingRetry, .revoked],
            premiumUnlocked: true)
        XCTAssertEqual(message, "Subscription was revoked. Restore or update your account.")

        let gracePriority = PremiumSubscriptionHealthEvaluator.message(
            states: [.expired, .inGracePeriod, .subscribed],
            premiumUnlocked: true)
        XCTAssertEqual(gracePriority, "You are in billing grace period. Premium remains active for now.")
    }

    private var fixedCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        fixedCalendar.date(
            from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) ?? .distantPast
    }

    private func makeObservance(
        id: String,
        title: String,
        date: Date,
        obligation: Observance.Obligation) -> Observance
    {
        Observance(
            id: id,
            title: title,
            date: date,
            kind: .feastDay,
            obligation: obligation,
            detail: nil,
            rationale: "Test rationale",
            citations: [],
            ruleVersion: "test")
    }
}
