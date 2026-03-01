@testable import CatholicFastingCore
import XCTest

final class ObservanceCalculatorTests: XCTestCase {
  func testAshWednesdayAndGoodFridayArePresent() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)

    XCTAssertNotNil(observances.first(where: { $0.title == "Ash Wednesday" }))
    XCTAssertNotNil(observances.first(where: { $0.title == "Good Friday" }))
  }

  func testFastObligationRespectsAgeRange() {
    let young = RuleSettings(
      birthYear: 2012,
      isAge18OrOlderForFasting: false,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let adult = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

    let youngAsh = ObservanceCalculator.makeCalendar(for: 2026, settings: young).first(where: { $0.title == "Ash Wednesday" })
    let adultAsh = ObservanceCalculator.makeCalendar(for: 2026, settings: adult).first(where: { $0.title == "Ash Wednesday" })

    XCTAssertEqual(youngAsh?.obligation, .mandatory)
    XCTAssertEqual(youngAsh?.kind, .abstinence)
    XCTAssertEqual(adultAsh?.obligation, .mandatory)
    XCTAssertEqual(adultAsh?.kind, .fastAndAbstinence)
  }

  func testAshWednesdayIsMandatoryAbstinenceForTeenProfiles() {
    let teen = RuleSettings(
      birthYear: 2010,
      birthMonth: 1,
      birthDay: 1,
      isAge18OrOlderForFasting: false,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

    let ashWednesday = ObservanceCalculator.makeCalendar(for: 2026, settings: teen)
      .first(where: { $0.title == "Ash Wednesday" })

    XCTAssertEqual(ashWednesday?.obligation, .mandatory)
    XCTAssertEqual(ashWednesday?.kind, .abstinence)
    XCTAssertTrue((ashWednesday?.detail ?? "").localizedCaseInsensitiveContains("abstinence from meat"))
  }

  func testFastObligationTurnsMandatoryOnEighteenthBirthday() {
    let turningEighteen = RuleSettings(
      birthYear: 2008,
      birthMonth: 2,
      birthDay: 18,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let stillSeventeen = RuleSettings(
      birthYear: 2008,
      birthMonth: 2,
      birthDay: 19,
      isAge18OrOlderForFasting: false,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

    let ashTurningEighteen = ObservanceCalculator.makeCalendar(for: 2026, settings: turningEighteen)
      .first(where: { $0.title == "Ash Wednesday" })
    let ashStillSeventeen = ObservanceCalculator.makeCalendar(for: 2026, settings: stillSeventeen)
      .first(where: { $0.title == "Ash Wednesday" })

    XCTAssertEqual(ashTurningEighteen?.obligation, .mandatory)
    XCTAssertEqual(ashStillSeventeen?.obligation, .mandatory)
    XCTAssertEqual(ashStillSeventeen?.kind, .abstinence)
  }

  func testFastObligationStopsWhenTurningSixty() {
    let stillFiftyNine = RuleSettings(
      birthYear: 1966,
      birthMonth: 2,
      birthDay: 19,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let turningSixty = RuleSettings(
      birthYear: 1966,
      birthMonth: 2,
      birthDay: 18,
      isAge18OrOlderForFasting: false,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

    let ashStillFiftyNine = ObservanceCalculator.makeCalendar(for: 2026, settings: stillFiftyNine)
      .first(where: { $0.title == "Ash Wednesday" })
    let ashTurningSixty = ObservanceCalculator.makeCalendar(for: 2026, settings: turningSixty)
      .first(where: { $0.title == "Ash Wednesday" })

    XCTAssertEqual(ashStillFiftyNine?.obligation, .mandatory)
    XCTAssertEqual(ashTurningSixty?.obligation, .mandatory)
    XCTAssertEqual(ashTurningSixty?.kind, .abstinence)
  }

  func testAbstinenceObligationTurnsMandatoryOnFourteenthBirthday() {
    let turningFourteen = RuleSettings(
      birthYear: 2012,
      birthMonth: 2,
      birthDay: 20,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let stillThirteen = RuleSettings(
      birthYear: 2012,
      birthMonth: 2,
      birthDay: 21,
      isAge14OrOlderForAbstinence: false,
      isAge18OrOlderForFasting: false,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

    let targetDate = Calendar.gregorian.date(from: DateComponents(year: 2026, month: 2, day: 20, hour: 12))
    let mandatoryFriday = ObservanceCalculator.makeCalendar(for: 2026, settings: turningFourteen).first {
      $0.title == "Friday of Lent"
        && Calendar.gregorian.isDate($0.date, inSameDayAs: targetDate ?? .distantPast)
    }
    let nonMandatoryFriday = ObservanceCalculator.makeCalendar(for: 2026, settings: stillThirteen).first {
      $0.title == "Friday of Lent"
        && Calendar.gregorian.isDate($0.date, inSameDayAs: targetDate ?? .distantPast)
    }

    XCTAssertEqual(mandatoryFriday?.obligation, .mandatory)
    XCTAssertEqual(nonMandatoryFriday?.obligation, .notApplicable)
  }

  func testAscensionPlacementFollowsSetting() {
    let sunday = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let thursday = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .thursday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

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
      calendarMode: .usccb
    )

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
      calendarMode: .usccb
    )

    let observances = ObservanceCalculator.makeCalendar(for: 2025, settings: settings)
    let allSaints = observances.first(where: { $0.title == "All Saints" })

    XCTAssertEqual(allSaints?.obligation, .optional)  // 2025-11-01 is Saturday
  }

  func testTransferredImmaculateConceptionIsNotMandatoryInUS() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

    let observances = ObservanceCalculator.makeCalendar(for: 2024, settings: settings)
    let transferredImmaculate = observances.first(where: { $0.title == "Immaculate Conception (Transferred)" })

    XCTAssertEqual(transferredImmaculate?.obligation, .optional)
    XCTAssertTrue((transferredImmaculate?.detail ?? "").localizedCaseInsensitiveContains("does not transfer"))
  }

  func testImmaculateConceptionIsMandatoryWhenNotTransferred() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let immaculate = observances.first(where: { $0.title == "Immaculate Conception" })

    XCTAssertEqual(immaculate?.obligation, .mandatory)
  }

  func testFridayOutsideLentDetailReflectsSelectedMode() throws {
    let abstainSettings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .abstainFromMeat,
      calendarMode: .usccb
    )
    let substituteSettings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

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
      isAge14OrOlderForAbstinence: false,
      isAge18OrOlderForFasting: false,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let ashWednesday = observances.first(where: { $0.title == "Ash Wednesday" })
    let christmas = observances.first(where: { $0.title == "Christmas" })

    XCTAssertEqual(ashWednesday?.obligation, .optional)
    XCTAssertEqual(christmas?.obligation, .optional)
    XCTAssertTrue((ashWednesday?.detail ?? "").localizedCaseInsensitiveContains("age eligibility"))
  }

  func testAshWednesdayDateMatchesLocalLiturgicalDay() throws {
    let originalTimeZone = NSTimeZone.default
    let testTimeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
    NSTimeZone.default = testTimeZone
    defer {
      NSTimeZone.default = originalTimeZone
    }

    ObservanceCalculator.resetCacheForTesting()
    let settings = RuleSettings(
      birthYear: 1988,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .abstainFromMeat,
      calendarMode: .usccb
    )

    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)
    let ashWednesday = try XCTUnwrap(observances.first(where: { $0.title == "Ash Wednesday" }))

    var localCalendar = Calendar(identifier: .gregorian)
    localCalendar.timeZone = testTimeZone
    let components = localCalendar.dateComponents([.year, .month, .day], from: ashWednesday.date)
    XCTAssertEqual(components.year, 2026)
    XCTAssertEqual(components.month, 2)
    XCTAssertEqual(components.day, 18)
  }

  func testUSCCBFeastAndSolemnityDatesAreIncludedFor2026() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)

    func dateParts(for title: String) -> DateComponents? {
      guard let date = observances.first(where: { $0.title == title && $0.kind == .feastDay })?.date else {
        return nil
      }
      return Calendar.gregorian.dateComponents([.year, .month, .day], from: date)
    }

    XCTAssertEqual(dateParts(for: "Epiphany of the Lord")?.month, 1)
    XCTAssertEqual(dateParts(for: "Epiphany of the Lord")?.day, 4)

    XCTAssertEqual(dateParts(for: "The Most Holy Trinity")?.month, 5)
    XCTAssertEqual(dateParts(for: "The Most Holy Trinity")?.day, 31)

    XCTAssertEqual(dateParts(for: "The Most Holy Body and Blood of Christ")?.month, 6)
    XCTAssertEqual(dateParts(for: "The Most Holy Body and Blood of Christ")?.day, 7)

    XCTAssertEqual(dateParts(for: "The Most Sacred Heart of Jesus")?.month, 6)
    XCTAssertEqual(dateParts(for: "The Most Sacred Heart of Jesus")?.day, 12)

    XCTAssertEqual(dateParts(for: "Our Lord Jesus Christ, King of the Universe")?.month, 11)
    XCTAssertEqual(dateParts(for: "Our Lord Jesus Christ, King of the Universe")?.day, 22)

    XCTAssertEqual(dateParts(for: "The Holy Family of Jesus, Mary, and Joseph")?.month, 12)
    XCTAssertEqual(dateParts(for: "The Holy Family of Jesus, Mary, and Joseph")?.day, 27)
  }

  func testMemorialDatesAreIncludedFor2026() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)

    func dateParts(for title: String) -> DateComponents? {
      guard let date = observances.first(where: { $0.title == title && $0.kind == .memorialDay })?.date else {
        return nil
      }
      return Calendar.gregorian.dateComponents([.year, .month, .day], from: date)
    }

    XCTAssertEqual(dateParts(for: "Saint Kateri Tekakwitha, Virgin")?.month, 7)
    XCTAssertEqual(dateParts(for: "Saint Kateri Tekakwitha, Virgin")?.day, 14)

    XCTAssertEqual(dateParts(for: "Blessed Virgin Mary, Mother of the Church")?.month, 5)
    XCTAssertEqual(dateParts(for: "Blessed Virgin Mary, Mother of the Church")?.day, 25)

    XCTAssertEqual(dateParts(for: "The Immaculate Heart of the Blessed Virgin Mary")?.month, 6)
    XCTAssertEqual(dateParts(for: "The Immaculate Heart of the Blessed Virgin Mary")?.day, 13)

    XCTAssertEqual(dateParts(for: "Saint Frances Xavier Cabrini, Virgin")?.month, 11)
    XCTAssertEqual(dateParts(for: "Saint Frances Xavier Cabrini, Virgin")?.day, 13)

    XCTAssertEqual(dateParts(for: "Saint John Neumann, Bishop")?.month, 1)
    XCTAssertEqual(dateParts(for: "Saint John Neumann, Bishop")?.day, 5)

    XCTAssertEqual(dateParts(for: "Saint John Henry Newman, Priest")?.month, 10)
    XCTAssertEqual(dateParts(for: "Saint John Henry Newman, Priest")?.day, 9)
  }

  func testFeastAndMemorialAreCelebrateNotFastFor2026() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let observances = ObservanceCalculator.makeCalendar(for: 2026, settings: settings)

    let epiphany = observances.first { $0.title == "Epiphany of the Lord" && $0.kind == .feastDay }
    let kateri = observances.first { $0.title == "Saint Kateri Tekakwitha, Virgin" && $0.kind == .memorialDay }

    XCTAssertEqual(epiphany?.obligation, .notApplicable)
    XCTAssertEqual(kateri?.obligation, .notApplicable)
  }

  func testUSCCBProperMemorialsInclude2027SpecificEntries() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let observances = ObservanceCalculator.makeCalendar(for: 2027, settings: settings)

    let rose = observances.first {
      $0.title == "Saint Rose Philippine Duchesne, Virgin" && $0.kind == .memorialDay
    }
    let miguel = observances.first {
      $0.title == "Saint Miguel Agustín Pro, Priest and Martyr" && $0.kind == .memorialDay
    }
    let newman = observances.first {
      $0.title == "Saint John Henry Newman, Priest" && $0.kind == .memorialDay
    }

    XCTAssertEqual(Calendar.gregorian.component(.month, from: rose?.date ?? .distantPast), 11)
    XCTAssertEqual(Calendar.gregorian.component(.day, from: rose?.date ?? .distantPast), 18)
    XCTAssertEqual(Calendar.gregorian.component(.month, from: miguel?.date ?? .distantPast), 11)
    XCTAssertEqual(Calendar.gregorian.component(.day, from: miguel?.date ?? .distantPast), 23)
    XCTAssertEqual(Calendar.gregorian.component(.month, from: newman?.date ?? .distantPast), 10)
    XCTAssertEqual(Calendar.gregorian.component(.day, from: newman?.date ?? .distantPast), 9)
    XCTAssertEqual(rose?.obligation, .notApplicable)
    XCTAssertEqual(miguel?.obligation, .notApplicable)
  }

  func testUSCCBProperMemorialsFallbackForYearsAfter2027() {
    let settings = RuleSettings(
      birthYear: 1990,
      hasMedicalDispensation: false,
      ascensionObservance: .sunday,
      fridayOutsideLentMode: .substitutePenance,
      calendarMode: .usccb
    )
    let observances = ObservanceCalculator.makeCalendar(for: 2028, settings: settings)

    XCTAssertNotNil(
      observances.first {
        $0.title == "Saint Rose Philippine Duchesne, Virgin" && $0.kind == .memorialDay
      })
    XCTAssertNotNil(
      observances.first {
        $0.title == "Saint Miguel Agustín Pro, Priest and Martyr" && $0.kind == .memorialDay
      })
  }
}
