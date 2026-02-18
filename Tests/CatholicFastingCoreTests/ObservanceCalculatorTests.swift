import XCTest
@testable import CatholicFastingCore

final class ObservanceCalculatorTests: XCTestCase {
  func testAshWednesdayAndGoodFridayArePresent() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)

    XCTAssertNotNil(observances.first(where: { $0.title == "Ash Wednesday" }))
    XCTAssertNotNil(observances.first(where: { $0.title == "Good Friday" }))
  }

  func testFastObligationRespectsAgeRange() {
    let young = RuleSettings(
      birthYear: 2012,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)
    let adult = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let youngAsh = ObservanceCalculator.makeCalendar(for: 2026, settings: young).first(where: { $0.title == "Ash Wednesday" })
    let adultAsh = ObservanceCalculator.makeCalendar(for: 2026, settings: adult).first(where: { $0.title == "Ash Wednesday" })

    XCTAssertEqual(youngAsh?.obligation, .notApplicable)
    XCTAssertEqual(adultAsh?.obligation, .mandatory)
  }

  func testAscensionPlacementFollowsSetting() {
    let sunday = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)
    let thursday = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .thursday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let sundayAscension = ObservanceCalculator.makeCalendar(for: 2026, settings: sunday).first(where: { $0.title == "Ascension" })
    let thursdayAscension = ObservanceCalculator.makeCalendar(for: 2026, settings: thursday).first(where: { $0.title == "Ascension" })

    XCTAssertNotNil(sundayAscension)
    XCTAssertNotNil(thursdayAscension)
    XCTAssertNotEqual(sundayAscension?.date, thursdayAscension?.date)
  }

  func testOutsideLentFridaysAreGenerated() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let outsideLentFridays = observances.filter { $0.kind == .fridayPenance }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    XCTAssertGreaterThan(outsideLentFridays.count, 40)
    XCTAssertTrue(outsideLentFridays.allSatisfy { calendar.component(.weekday, from: $0.date) == 6 })
  }

  func testHolyDayWeekdayAbrogationRuleForAllSaints() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let observances = ObservanceCalculator.makeCalendar(for: 2025, settings: settings)
    let allSaints = observances.first(where: { $0.title == "All Saints" })

    XCTAssertEqual(allSaints?.obligation, .optional)  // 2025-11-01 is Saturday
  }

  func testFridayOutsideLentDetailReflectsSelectedMode() throws {
    let abstainSettings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .abstainFromMeat,
      calendarMode: .usccb)
    let substituteSettings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let abstainFriday = try XCTUnwrap(
      ObservanceCalculator.makeCalendar(for: 2026, settings: abstainSettings).first(where: { $0.kind == .fridayPenance })
    )
    let substituteFriday = try XCTUnwrap(
      ObservanceCalculator.makeCalendar(for: 2026, settings: substituteSettings).first(where: { $0.kind == .fridayPenance })
    )

    XCTAssertTrue((abstainFriday.detail ?? "").localizedCaseInsensitiveContains("abstain from meat"))
    XCTAssertTrue((substituteFriday.detail ?? "").localizedCaseInsensitiveContains("penitential act"))
  }

  func testUnknownBirthYearDefaultsToOptionalForAgeBasedRules() {
    let settings = RuleSettings(
      birthYear: 0,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let ashWednesday = observances.first(where: { $0.title == "Ash Wednesday" })
    let christmas = observances.first(where: { $0.title == "Christmas" })

    XCTAssertEqual(ashWednesday?.obligation, .optional)
    XCTAssertEqual(christmas?.obligation, .optional)
    XCTAssertTrue((ashWednesday?.detail ?? "").localizedCaseInsensitiveContains("Set birth year"))
  }
}
