import XCTest
@testable import CatholicFastingCore

final class RuleEngineExtendedTests: XCTestCase {
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

  func testMedicalDispensationRemovesMandatoryFasting() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: true,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let ash = observances.first { $0.title == "Ash Wednesday" }
    let goodFriday = observances.first { $0.title == "Good Friday" }

    XCTAssertEqual(ash?.obligation, .notApplicable)
    XCTAssertEqual(goodFriday?.obligation, .notApplicable)
  }

  func testFridayModeAbstainFromMeatChangesDetail() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .abstainFromMeat,
      calendarMode: .usccb)

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let friday = observances.first { $0.kind == .fridayPenance }

    XCTAssertNotNil(friday)
    XCTAssertTrue(friday?.detail?.contains("abstain from meat") == true)
  }

  func testTraditionalModeMarksEmberDetailDifferently() {
    let usccb = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)
    let traditional = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .traditional1962)

    let usccbEmber = ObservanceCalculator.makeCalendar(for: 2026, settings: usccb).first { $0.kind == .optionalEmber }
    let tradEmber = ObservanceCalculator.makeCalendar(for: 2026, settings: traditional).first { $0.kind == .optionalEmber }

    XCTAssertNotNil(usccbEmber)
    XCTAssertNotNil(tradEmber)
    XCTAssertNotEqual(usccbEmber?.detail, tradEmber?.detail)
  }

  func testAscensionDifferenceIsThreeDays() {
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

    let sundayDate = ObservanceCalculator.makeCalendar(for: 2026, settings: sunday).first { $0.title == "Ascension" }?.date
    let thursdayDate = ObservanceCalculator.makeCalendar(for: 2026, settings: thursday).first { $0.title == "Ascension" }?.date

    XCTAssertNotNil(sundayDate)
    XCTAssertNotNil(thursdayDate)

    if let sundayDate, let thursdayDate {
      let days = Calendar(identifier: .gregorian).dateComponents([.day], from: thursdayDate, to: sundayDate).day
      XCTAssertEqual(days, 3)
    }
  }

  func testHolyDayUnderAgeSevenIsNotRequired() {
    let settings = RuleSettings(
      birthYear: 2022,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let christmas = ObservanceCalculator.makeCalendar(for: 2026, settings: settings).first { $0.title == "Christmas" }
    XCTAssertEqual(christmas?.obligation, .notApplicable)
  }

  func testChristmasIsMandatoryForAdultProfile() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let christmas = ObservanceCalculator.makeCalendar(for: 2026, settings: settings).first { $0.title == "Christmas" }
    XCTAssertEqual(christmas?.obligation, .mandatory)
  }

  func testFridayPenanceOutsideLentNeverIncludesGoodFriday() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let outsideLent = observances.filter { $0.kind == .fridayPenance }
    let goodFriday = observances.first { $0.title == "Good Friday" }

    XCTAssertNotNil(goodFriday)
    XCTAssertFalse(outsideLent.contains { $0.date == goodFriday?.date })
  }

  func testObservancesAreSortedByDateAscending() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb)

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    XCTAssertEqual(observances, observances.sorted { $0.date < $1.date })
  }

}
