@testable import CatholicFastingCore
import XCTest

final class ObservanceQueryEngineTests: XCTestCase {
  private var calendar: Calendar {
    var value = Calendar(identifier: .gregorian)
    value.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
    return value
  }

  func testRequiredOnlyFilterReturnsMandatoryObservances() {
    let now = makeDate(2026, 3, 1)
    let result = ObservanceQueryEngine.filter(
      observances: sampleObservances(),
      query: "",
      filter: .requiredOnly,
      window: .allYear,
      sortOrder: .chronological,
      statusesByID: [:],
      now: now,
      calendar: calendar
    )

    XCTAssertEqual(result.map(\.title), ["Ash Wednesday", "Good Friday"])
  }

  func testTrackedOnlyFilterUsesStatusesDictionary() {
    let items = sampleObservances()
    let statuses: [String: CompletionStatus] = [
      items[1].id: .completed,
      items[2].id: .missed,
    ]
    let result = ObservanceQueryEngine.filter(
      observances: items,
      query: "",
      filter: .trackedOnly,
      window: .allYear,
      sortOrder: .chronological,
      statusesByID: statuses,
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )

    XCTAssertEqual(result.map(\.title), ["Good Friday", "Ember Day"])
  }

  func testQueryMatchesDetailKindAndObligationLabels() {
    let items = sampleObservances()
    let detailMatch = ObservanceQueryEngine.filter(
      observances: items,
      query: "meat",
      filter: .all,
      window: .allYear,
      sortOrder: .chronological,
      statusesByID: [:],
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )
    XCTAssertEqual(detailMatch.map(\.title), ["Friday Penance (Outside Lent)"])

    let kindMatch = ObservanceQueryEngine.filter(
      observances: items,
      query: "holy day",
      filter: .all,
      window: .allYear,
      sortOrder: .chronological,
      statusesByID: [:],
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )
    XCTAssertEqual(kindMatch.map(\.title), ["Ascension"])

    let obligationMatch = ObservanceQueryEngine.filter(
      observances: items,
      query: "required",
      filter: .all,
      window: .allYear,
      sortOrder: .chronological,
      statusesByID: [:],
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )
    XCTAssertTrue(obligationMatch.map(\.title).contains("Ash Wednesday"))
    XCTAssertTrue(obligationMatch.map(\.title).contains("Good Friday"))
  }

  func testThisMonthWindowFiltersToCurrentMonthAndYear() {
    let result = ObservanceQueryEngine.filter(
      observances: sampleObservances(),
      query: "",
      filter: .all,
      window: .thisMonth,
      sortOrder: .chronological,
      statusesByID: [:],
      now: makeDate(2026, 3, 20),
      calendar: calendar
    )

    XCTAssertEqual(result.map(\.title), ["Ash Wednesday", "Good Friday"])
  }

  func testNext30DaysIncludesBoundaryDate() {
    let result = ObservanceQueryEngine.filter(
      observances: sampleObservances(),
      query: "",
      filter: .all,
      window: .next30Days,
      sortOrder: .chronological,
      statusesByID: [:],
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )

    XCTAssertEqual(result.map(\.title), ["Ash Wednesday", "Good Friday"])
  }

  func testRequiredFirstSortPlacesMandatoryThenOptionalThenNotApplicable() {
    let result = ObservanceQueryEngine.filter(
      observances: sampleObservances(),
      query: "",
      filter: .all,
      window: .allYear,
      sortOrder: .requiredFirst,
      statusesByID: [:],
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )

    XCTAssertEqual(result.first?.obligation, .mandatory)
    XCTAssertEqual(result.last?.obligation, .notApplicable)
  }

  func testChronologicalSortUsesTitleTieBreaker() {
    let date = makeDate(2026, 6, 1)
    let a = makeObservance(id: "a", title: "B observance", date: date, obligation: .optional, detail: nil, kind: .feastDay)
    let b = makeObservance(id: "b", title: "A observance", date: date, obligation: .optional, detail: nil, kind: .feastDay)

    let result = ObservanceQueryEngine.filter(
      observances: [a, b],
      query: "",
      filter: .all,
      window: .allYear,
      sortOrder: .chronological,
      statusesByID: [:],
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )

    XCTAssertEqual(result.map(\.title), ["A observance", "B observance"])
  }

  func testCombinedFiltersCanYieldEmptyResult() {
    let result = ObservanceQueryEngine.filter(
      observances: sampleObservances(),
      query: "nonexistent",
      filter: .requiredOnly,
      window: .next30Days,
      sortOrder: .requiredFirst,
      statusesByID: [:],
      now: makeDate(2026, 9, 1),
      calendar: calendar
    )

    XCTAssertTrue(result.isEmpty)
  }

  func testNext30DaysExcludesDay31() {
    let beyondWindow = makeObservance(
      id: "2026-04-01|Beyond Window|optional",
      title: "Beyond Window",
      date: makeDate(2026, 4, 1),
      obligation: .optional,
      detail: nil,
      kind: .feastDay
    )

    let result = ObservanceQueryEngine.filter(
      observances: sampleObservances() + [beyondWindow],
      query: "",
      filter: .all,
      window: .next30Days,
      sortOrder: .chronological,
      statusesByID: [:],
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )

    XCTAssertFalse(result.map(\.title).contains("Beyond Window"))
  }

  func testTrackedOnlyIgnoresExplicitNotStartedStatus() {
    let items = sampleObservances()
    let statuses: [String: CompletionStatus] = [
      items[0].id: .notStarted,
      items[1].id: .completed,
    ]

    let result = ObservanceQueryEngine.filter(
      observances: items,
      query: "",
      filter: .trackedOnly,
      window: .allYear,
      sortOrder: .chronological,
      statusesByID: statuses,
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )

    XCTAssertEqual(result.map(\.title), ["Good Friday"])
  }

  func testRequiredFirstSortUsesDateThenTitleWithinSameObligation() {
    let date = makeDate(2026, 8, 1)
    let b = makeObservance(id: "b", title: "B optional", date: date, obligation: .optional, detail: nil, kind: .feastDay)
    let a = makeObservance(id: "a", title: "A optional", date: date, obligation: .optional, detail: nil, kind: .feastDay)

    let result = ObservanceQueryEngine.filter(
      observances: [b, a],
      query: "",
      filter: .all,
      window: .allYear,
      sortOrder: .requiredFirst,
      statusesByID: [:],
      now: makeDate(2026, 3, 1),
      calendar: calendar
    )

    XCTAssertEqual(result.map(\.title), ["A optional", "B optional"])
  }

  private func sampleObservances() -> [Observance] {
    [
      makeObservance(
        id: "2026-03-04|Ash Wednesday|fastAndAbstinence",
        title: "Ash Wednesday",
        date: makeDate(2026, 3, 4),
        obligation: .mandatory,
        detail: "One full meal and two smaller meals.",
        kind: .fastAndAbstinence
      ),
      makeObservance(
        id: "2026-03-31|Good Friday|fastAndAbstinence",
        title: "Good Friday",
        date: makeDate(2026, 3, 31),
        obligation: .mandatory,
        detail: "Fast and abstinence are required.",
        kind: .fastAndAbstinence
      ),
      makeObservance(
        id: "2026-09-23|Ember Day|optionalEmber",
        title: "Ember Day",
        date: makeDate(2026, 9, 23),
        obligation: .optional,
        detail: "Optional in U.S. profile mode.",
        kind: .optionalEmber
      ),
      makeObservance(
        id: "2026-05-22|Friday Penance (Outside Lent)|fridayPenance",
        title: "Friday Penance (Outside Lent)",
        date: makeDate(2026, 5, 22),
        obligation: .notApplicable,
        detail: "Outside Lent: abstain from meat as your Friday penance.",
        kind: .fridayPenance
      ),
      makeObservance(
        id: "2026-05-17|Ascension|holyDay",
        title: "Ascension",
        date: makeDate(2026, 5, 17),
        obligation: .optional,
        detail: "Holy day obligation depends on local norms.",
        kind: .holyDay
      ),
    ]
  }

  private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
  }

  private func makeObservance(
    id: String,
    title: String,
    date: Date,
    obligation: Observance.Obligation,
    detail: String?,
    kind: Observance.Kind
  ) -> Observance {
    Observance(
      id: id,
      title: title,
      date: date,
      kind: kind,
      obligation: obligation,
      detail: detail,
      rationale: "test rationale",
      citations: [],
      ruleVersion: "test"
    )
  }
}
