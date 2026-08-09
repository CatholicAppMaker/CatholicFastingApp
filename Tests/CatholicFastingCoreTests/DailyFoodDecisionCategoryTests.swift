@testable import CatholicFastingCore
import XCTest

final class DailyFoodDecisionCategoryTests: XCTestCase {
    private struct ExpectedPresentation {
        let symbolName: String
        let tone: AppSemanticTone
        let localizationKey: String
    }

    func testEngineReturnsEverySemanticCategory() {
        let requiredFast = decision(kind: .fastAndAbstinence, obligation: .mandatory)
        let requiredAbstinence = decision(kind: .abstinence, obligation: .mandatory)
        let fridayPenance = decision(kind: .fridayPenance, obligation: .mandatory)
        let requiredNonFood = decision(kind: .holyDay, obligation: .mandatory)
        let optionalFast = decision(kind: .fastAndAbstinence, obligation: .optional)
        let unrestricted = decision(observances: [])
        let dispensation = decision(
            observances: [],
            settings: makeSettings(hasMedicalDispensation: true))

        XCTAssertEqual(requiredFast.category, .fastAndAbstinence)
        XCTAssertEqual(requiredAbstinence.category, .abstinence)
        XCTAssertEqual(fridayPenance.category, .fridayPenance)
        XCTAssertEqual(requiredNonFood.category, .requiredNoFoodRestriction)
        XCTAssertEqual(optionalFast.category, .optionalFastOrAbstinence)
        XCTAssertEqual(unrestricted.category, .unrestricted)
        XCTAssertEqual(dispensation.category, .medicalDispensation)
    }

    func testPresentationMappingIsCompleteAndSemantic() {
        let expected: [DailyFoodDecision.Category: ExpectedPresentation] = [
            .medicalDispensation: ExpectedPresentation(
                symbolName: "cross.case.fill",
                tone: .information,
                localizationKey: "today.decision.next_action.dispensation"),
            .fastAndAbstinence: ExpectedPresentation(
                symbolName: "exclamationmark.circle.fill",
                tone: .danger,
                localizationKey: "today.decision.next_action.required"),
            .abstinence: ExpectedPresentation(
                symbolName: "exclamationmark.circle.fill",
                tone: .danger,
                localizationKey: "today.decision.next_action.required"),
            .fridayPenance: ExpectedPresentation(
                symbolName: "hand.raised.fill",
                tone: .warning,
                localizationKey: "today.decision.next_action.friday"),
            .requiredNoFoodRestriction: ExpectedPresentation(
                symbolName: "calendar.badge.exclamationmark",
                tone: .information,
                localizationKey: "today.decision.next_action.required_no_food_restriction"),
            .optionalFastOrAbstinence: ExpectedPresentation(
                symbolName: "info.circle.fill",
                tone: .information,
                localizationKey: "today.decision.next_action.optional"),
            .unrestricted: ExpectedPresentation(
                symbolName: "checkmark.circle.fill",
                tone: .success,
                localizationKey: "today.decision.next_action.clear"),
        ]

        XCTAssertEqual(expected.count, DailyFoodDecision.Category.allCases.count)

        for category in DailyFoodDecision.Category.allCases {
            let presentation = DailyFoodDecisionPresentation.presentation(for: category)
            let expectation = expected[category]
            XCTAssertEqual(presentation.symbolName, expectation?.symbolName)
            XCTAssertEqual(presentation.tone, expectation?.tone)
            XCTAssertEqual(presentation.nextActionLocalizationKey, expectation?.localizationKey)
            XCTAssertFalse(presentation.nextActionDefaultValue.isEmpty)
        }
    }

    private func decision(
        kind: Observance.Kind,
        obligation: Observance.Obligation) -> DailyFoodDecision
    {
        decision(observances: [makeObservance(kind: kind, obligation: obligation)])
    }

    private func decision(
        observances: [Observance],
        settings: RuleSettings? = nil) -> DailyFoodDecision
    {
        DailyFoodDecisionEngine.decision(
            for: observances,
            settings: settings ?? makeSettings(),
            date: testDate,
            calendar: testCalendar)
    }

    private func makeObservance(
        kind: Observance.Kind,
        obligation: Observance.Obligation) -> Observance
    {
        Observance(
            id: "test-\(kind.rawValue)-\(obligation.rawValue)",
            title: "Test Observance",
            date: testDate,
            kind: kind,
            obligation: obligation,
            detail: nil,
            rationale: "Test rationale",
            citations: [],
            ruleVersion: "test")
    }

    private func makeSettings(hasMedicalDispensation: Bool = false) -> RuleSettings {
        RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: hasMedicalDispensation,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb)
    }

    private var testCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }

    private var testDate: Date {
        testCalendar.date(from: DateComponents(year: 2026, month: 5, day: 4, hour: 12)) ?? .distantPast
    }
}
