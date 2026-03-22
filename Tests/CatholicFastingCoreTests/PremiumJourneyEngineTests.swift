@testable import CatholicFastingCore
import XCTest

final class PremiumJourneyEngineTests: XCTestCase {
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

    func testSeasonPlanLentWithoutDispensationIsStrong() {
        let settings = RuleSettings(
            birthYear: 1991,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)

        let plan = PremiumSeasonPlanEngine.plan(for: .lent, settings: settings)
        XCTAssertEqual(plan.fastingIntensity, "Strong")
        XCTAssertTrue(plan.titleLine.localizedCaseInsensitiveContains("lenten"))
    }

    func testSeasonPlanWithMedicalDispensationUsesGentlePlanForAnySeason() {
        let settings = RuleSettings(
            birthYear: 1986,
            hasMedicalDispensation: true,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)

        let adventPlan = PremiumSeasonPlanEngine.plan(for: .advent, settings: settings)
        let lentPlan = PremiumSeasonPlanEngine.plan(for: .lent, settings: settings)

        XCTAssertEqual(adventPlan.fastingIntensity, "Gentle")
        XCTAssertEqual(lentPlan.fastingIntensity, "Gentle")
        XCTAssertEqual(adventPlan.titleLine, "Medical/Pastoral Plan")
        XCTAssertEqual(lentPlan.titleLine, "Medical/Pastoral Plan")
    }

    func testGuidedJourneyUsesSeasonSpecificWeeklyStructure() {
        let lentWeek = GuidedSeasonalJourneyEngine.week(
            for: .lent,
            program: .lentDeepen,
            week: 2)

        XCTAssertEqual(lentWeek.weekNumber, 2)
        XCTAssertEqual(lentWeek.actions.count, 4)
        XCTAssertTrue(lentWeek.title.localizedCaseInsensitiveContains("lenten"))
        XCTAssertEqual(lentWeek.actions.map(\.category), [.fasting, .prayer, .charity, .review])
    }

    func testGuidedJourneyProgressRestoresCompletedActionAndFindsNextStep() {
        let week = GuidedSeasonalJourneyEngine.week(
            for: .advent,
            program: .adventWatch,
            week: 3)
        let completedKey = GuidedSeasonalJourneyEngine.actionKey(
            program: .adventWatch,
            week: week.weekNumber,
            actionID: "fasting")

        var state = PremiumCompanionState.default
        state.seasonProgramRawValue = PremiumSeasonProgram.adventWatch.rawValue
        state.completedProgramActions = [completedKey]
        LocalFeatureStore.savePremiumCompanionState(state)

        let loaded = LocalFeatureStore.loadPremiumCompanionState()
        let progress = GuidedSeasonalJourneyEngine.progress(
            for: week,
            completedActionKeys: loaded.completedProgramActions)

        XCTAssertEqual(loaded.completedProgramActions, [completedKey])
        XCTAssertEqual(progress.completedCount, 1)
        XCTAssertEqual(progress.totalCount, 4)
        XCTAssertEqual(progress.nextAction?.id, "prayer")
        XCTAssertEqual(progress.completionSummary, "1 of 4 journey actions completed this week.")
    }

    func testGuidedJourneyProgressUsesCompletionCopyWhenWeekIsDone() {
        let week = GuidedSeasonalJourneyEngine.week(
            for: .ordinary,
            program: .liturgicalRhythm,
            week: 0)
        let completedKeys = week.actions.map {
            GuidedSeasonalJourneyEngine.actionKey(
                program: week.program,
                week: week.weekNumber,
                actionID: $0.id)
        }

        let progress = GuidedSeasonalJourneyEngine.progress(
            for: week,
            completedActionKeys: completedKeys)

        XCTAssertEqual(week.weekNumber, 1)
        XCTAssertEqual(progress.completedCount, week.actions.count)
        XCTAssertNil(progress.nextAction)
        XCTAssertTrue(progress.completionSummary.localizedCaseInsensitiveContains("week is complete"))
    }

    func testSeasonProgramActionsNormalizeWeekBeforeBuildingCopy() {
        let actions = PremiumSeasonProgramEngine.actions(for: .fridayFidelity, week: 0)
        XCTAssertTrue(actions.contains("End Friday with a gratitude examen checkpoint #1."))
    }
}
