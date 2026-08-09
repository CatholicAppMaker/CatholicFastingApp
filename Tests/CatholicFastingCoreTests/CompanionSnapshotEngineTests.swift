@testable import CatholicFastingCore
import XCTest

final class CompanionSnapshotEngineTests: XCTestCase {
    func testSnapshotPrioritizesRequiredDayGuidance() throws {
        let date = try XCTUnwrap(Calendar.gregorian.date(from: DateComponents(year: 2026, month: 2, day: 18, hour: 12)))
        let settings = makeSettings()
        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let journey = GuidedSeasonalJourneyEngine.week(for: .lent, program: .lentDeepen, week: 1)
        let progress = GuidedSeasonalJourneyEngine.progress(for: journey, completedActionKeys: [])

        let snapshot = CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: date,
            observances: observances,
            settings: settings,
            statusesByID: [:],
            activeFastStart: nil,
            activeFastTargetHours: 16,
            intermittentSessions: [],
            journeyWeek: journey,
            journeyProgress: progress,
            currentStreak: 0,
            premiumUnlocked: false,
            calendar: .gregorian))

        XCTAssertTrue(snapshot.ruleDecision.hasMandatoryObservance)
        XCTAssertEqual(snapshot.primaryAction.destination, .guidance)
        XCTAssertEqual(snapshot.primaryAction.priority, .high)
        XCTAssertTrue(snapshot.ruleDecision.obligationLine.localizedCaseInsensitiveContains("fasting"))
    }

    func testSnapshotPrioritizesActiveFastWhenNoRequiredDayIsActive() throws {
        let date = try XCTUnwrap(Calendar.gregorian.date(from: DateComponents(year: 2026, month: 5, day: 24, hour: 12)))
        let start = date.addingTimeInterval(-3 * 3600)
        let settings = makeSettings()
        let journey = GuidedSeasonalJourneyEngine.week(for: .ordinary, program: .liturgicalRhythm, week: 2)
        let progress = GuidedSeasonalJourneyEngine.progress(for: journey, completedActionKeys: [])

        let snapshot = CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: date,
            observances: ObservanceCalculator.makeCalendar(for: 2026, settings: settings),
            settings: settings,
            statusesByID: [:],
            activeFastStart: start,
            activeFastTargetHours: 16,
            intermittentSessions: [],
            journeyWeek: journey,
            journeyProgress: progress,
            currentStreak: 3,
            premiumUnlocked: true,
            calendar: .gregorian))

        XCTAssertEqual(snapshot.primaryAction.destination, .trackFast)
        XCTAssertTrue(snapshot.liveFast.progress.isActive)
        XCTAssertEqual(snapshot.formation.currentStreak, 3)
        XCTAssertTrue(snapshot.formation.premiumUnlocked)
    }

    func testSnapshotTreatsTargetReachedFastAsHighPriorityTrackerAction() throws {
        let date = try XCTUnwrap(Calendar.gregorian.date(from: DateComponents(year: 2026, month: 5, day: 24, hour: 12)))
        let start = date.addingTimeInterval(-18 * 3600)
        let settings = makeSettings()
        let journey = GuidedSeasonalJourneyEngine.week(for: .ordinary, program: .liturgicalRhythm, week: 2)
        let progress = GuidedSeasonalJourneyEngine.progress(for: journey, completedActionKeys: [])

        let snapshot = CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: date,
            observances: ObservanceCalculator.makeCalendar(for: 2026, settings: settings),
            settings: settings,
            statusesByID: [:],
            activeFastStart: start,
            activeFastTargetHours: 16,
            intermittentSessions: [],
            journeyWeek: journey,
            journeyProgress: progress,
            currentStreak: 2,
            premiumUnlocked: false,
            calendar: .gregorian))

        XCTAssertEqual(snapshot.primaryAction.id, "active-fast")
        XCTAssertEqual(snapshot.primaryAction.destination, .trackFast)
        XCTAssertEqual(snapshot.primaryAction.priority, .high)
        guard case .targetReached(_, let targetHours, _, let progressValue, let stage) = snapshot.liveFast.progress else {
            XCTFail("Expected targetReached live fast state, got \(snapshot.liveFast.progress)")
            return
        }
        XCTAssertEqual(targetHours, 16)
        XCTAssertEqual(progressValue, 1)
        XCTAssertEqual(stage, .targetReached)
    }

    func testSnapshotCompletedRecapTakesPrecedenceOverPlanningNextRequiredDay() throws {
        let date = try XCTUnwrap(Calendar.gregorian.date(from: DateComponents(year: 2026, month: 5, day: 24, hour: 12)))
        let start = date.addingTimeInterval(-18 * 3600)
        let session = IntermittentFastSession(
            id: "completed",
            start: start,
            end: date.addingTimeInterval(-20 * 60),
            targetHours: 16)
        let settings = makeSettings()
        let journey = GuidedSeasonalJourneyEngine.week(for: .ordinary, program: .liturgicalRhythm, week: 2)
        let progress = GuidedSeasonalJourneyEngine.progress(for: journey, completedActionKeys: [])

        let snapshot = CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: date,
            observances: ObservanceCalculator.makeCalendar(for: 2026, settings: settings),
            settings: settings,
            statusesByID: [:],
            activeFastStart: nil,
            activeFastTargetHours: 16,
            intermittentSessions: [session],
            journeyWeek: journey,
            journeyProgress: progress,
            currentStreak: 2,
            premiumUnlocked: false,
            calendar: .gregorian))

        XCTAssertNotNil(snapshot.nextRequiredObservance)
        XCTAssertEqual(snapshot.primaryAction.id, "fast-recap")
        XCTAssertEqual(snapshot.primaryAction.destination, .trackFast)
        guard case .completedRecap(let recap) = snapshot.liveFast.progress else {
            XCTFail("Expected completedRecap live fast state, got \(snapshot.liveFast.progress)")
            return
        }
        XCTAssertTrue(recap.completedTarget)
    }

    func testSnapshotPrioritizesGentleRecoveryForMissedDay() throws {
        let date = try XCTUnwrap(Calendar.gregorian.date(from: DateComponents(year: 2026, month: 2, day: 21, hour: 12)))
        let settings = makeSettings()
        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let ashWednesday = try XCTUnwrap(observances.first { $0.title == "Ash Wednesday" })
        let journey = GuidedSeasonalJourneyEngine.week(for: .lent, program: .lentDeepen, week: 1)
        let progress = GuidedSeasonalJourneyEngine.progress(for: journey, completedActionKeys: [])

        let snapshot = CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: date,
            observances: observances,
            settings: settings,
            statusesByID: [ashWednesday.id: .missed],
            activeFastStart: nil,
            activeFastTargetHours: 16,
            intermittentSessions: [],
            journeyWeek: journey,
            journeyProgress: progress,
            currentStreak: 0,
            premiumUnlocked: true,
            calendar: .gregorian))

        XCTAssertEqual(snapshot.primaryAction.destination, .premium)
        XCTAssertEqual(snapshot.primaryAction.priority, .high)
        XCTAssertNotNil(snapshot.formation.recoverySummary)
    }

    func testMedicalDispensationKeepsPastoralDecisionVisible() throws {
        let date = try XCTUnwrap(Calendar.gregorian.date(from: DateComponents(year: 2026, month: 2, day: 18, hour: 12)))
        let settings = makeSettings(hasMedicalDispensation: true)
        let journey = GuidedSeasonalJourneyEngine.week(for: .lent, program: .lentDeepen, week: 1)
        let progress = GuidedSeasonalJourneyEngine.progress(for: journey, completedActionKeys: [])

        let snapshot = CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: date,
            observances: ObservanceCalculator.makeCalendar(for: 2026, settings: settings),
            settings: settings,
            statusesByID: [:],
            activeFastStart: nil,
            activeFastTargetHours: 16,
            intermittentSessions: [],
            journeyWeek: journey,
            journeyProgress: progress,
            currentStreak: 1,
            premiumUnlocked: false,
            calendar: .gregorian))

        XCTAssertTrue(snapshot.ruleDecision.obligationLine.localizedCaseInsensitiveContains("dispensation"))
        XCTAssertEqual(snapshot.ruleDecision.category, .medicalDispensation)
        XCTAssertEqual(snapshot.primaryAction.destination, .guidance)
    }

    func testSnapshotAvoidsPlanningMissingNextRequiredDay() throws {
        let date = try XCTUnwrap(Calendar.gregorian.date(from: DateComponents(year: 2026, month: 12, day: 30, hour: 12)))
        let settings = makeSettings()
        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let journey = GuidedSeasonalJourneyEngine.week(for: .christmas, program: .liturgicalRhythm, week: 1)
        let progress = GuidedSeasonalJourneyEngine.progress(for: journey, completedActionKeys: [])

        let snapshot = CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: date,
            observances: observances,
            settings: settings,
            statusesByID: [:],
            activeFastStart: nil,
            activeFastTargetHours: 16,
            intermittentSessions: [],
            journeyWeek: journey,
            journeyProgress: progress,
            currentStreak: 0,
            premiumUnlocked: false,
            calendar: .gregorian))

        XCTAssertNil(snapshot.nextRequiredObservance)
        XCTAssertEqual(snapshot.primaryAction.destination, .trackFast)
        XCTAssertEqual(snapshot.primaryAction.id, "start-fast")
    }

    func testSnapshotKeepsLockedFormationSecondaryActionInSetup() throws {
        let date = try XCTUnwrap(Calendar.gregorian.date(from: DateComponents(year: 2026, month: 12, day: 30, hour: 12)))
        let settings = makeSettings()
        let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
        let journey = GuidedSeasonalJourneyEngine.week(for: .christmas, program: .liturgicalRhythm, week: 1)
        let progress = GuidedSeasonalJourneyEngine.progress(for: journey, completedActionKeys: [])

        let lockedSnapshot = CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: date,
            observances: observances,
            settings: settings,
            statusesByID: [:],
            activeFastStart: nil,
            activeFastTargetHours: 16,
            intermittentSessions: [],
            journeyWeek: journey,
            journeyProgress: progress,
            currentStreak: 0,
            premiumUnlocked: false,
            calendar: .gregorian))

        let unlockedSnapshot = CompanionSnapshotEngine.snapshot(CompanionSnapshotRequest(
            date: date,
            observances: observances,
            settings: settings,
            statusesByID: [:],
            activeFastStart: nil,
            activeFastTargetHours: 16,
            intermittentSessions: [],
            journeyWeek: journey,
            journeyProgress: progress,
            currentStreak: 0,
            premiumUnlocked: true,
            calendar: .gregorian))

        let lockedFormation = try XCTUnwrap(lockedSnapshot.secondaryActions.first { $0.id == "formation" })
        let unlockedFormation = try XCTUnwrap(unlockedSnapshot.secondaryActions.first { $0.id == "formation" })
        XCTAssertTrue(lockedFormation.requiresPremium)
        XCTAssertEqual(lockedFormation.destination, .setup)
        XCTAssertEqual(unlockedFormation.destination, .premium)
    }

    private func makeSettings(hasMedicalDispensation: Bool = false) -> RuleSettings {
        RuleSettings(
            birthYear: 0,
            isAge14OrOlderForAbstinence: true,
            isAge18OrOlderForFasting: true,
            hasMedicalDispensation: hasMedicalDispensation,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb,
            regionProfile: .us)
    }
}
