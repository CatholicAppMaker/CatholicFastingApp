@testable import CatholicFastingCore
import XCTest

final class RequiredDayReminderPlannerTests: XCTestCase {
  func testMaximumRequiredRemindersRespectsQueueCapacityAndHeadroom() {
    XCTAssertEqual(
      RequiredDayReminderPlanner.maximumRequiredReminders(existingNonRequiredPendingCount: 0),
      50
    )
    XCTAssertEqual(
      RequiredDayReminderPlanner.maximumRequiredReminders(existingNonRequiredPendingCount: 10),
      50
    )
    XCTAssertEqual(
      RequiredDayReminderPlanner.maximumRequiredReminders(existingNonRequiredPendingCount: 20),
      44
    )
    XCTAssertEqual(
      RequiredDayReminderPlanner.maximumRequiredReminders(existingNonRequiredPendingCount: 80),
      0
    )
    XCTAssertEqual(
      RequiredDayReminderPlanner.maximumRequiredReminders(existingNonRequiredPendingCount: -5),
      50
    )
  }

  func testUpcomingMandatoryObservancesSortsFiltersAndLimits() {
    let now = makeDate(year: 2026, month: 2, day: 18, hour: 9)
    let observances = [
      makeObservance(
        id: "future-b",
        title: "Future B",
        date: makeDate(year: 2026, month: 2, day: 20),
        obligation: .mandatory
      ),
      makeObservance(
        id: "past",
        title: "Past",
        date: makeDate(year: 2026, month: 2, day: 17),
        obligation: .mandatory
      ),
      makeObservance(
        id: "today",
        title: "Today",
        date: makeDate(year: 2026, month: 2, day: 18),
        obligation: .mandatory
      ),
      makeObservance(
        id: "optional",
        title: "Optional",
        date: makeDate(year: 2026, month: 2, day: 19),
        obligation: .optional
      ),
      makeObservance(
        id: "future-a",
        title: "Future A",
        date: makeDate(year: 2026, month: 2, day: 19),
        obligation: .mandatory
      ),
    ]

    let planned = RequiredDayReminderPlanner.upcomingMandatoryObservances(
      from: observances,
      now: now,
      calendar: .gregorian,
      limit: 2
    )

    XCTAssertEqual(planned.map(\.id), ["today", "future-a"])
  }

  func testUpcomingMandatoryObservancesDeduplicatesByIDAndUsesStableTieBreak() {
    let now = makeDate(year: 2026, month: 2, day: 28, hour: 8)
    let observances = [
      makeObservance(
        id: "dup",
        title: "Duplicate Earlier",
        date: makeDate(year: 2026, month: 3, day: 1),
        obligation: .mandatory
      ),
      makeObservance(
        id: "dup",
        title: "Duplicate Later",
        date: makeDate(year: 2026, month: 3, day: 2),
        obligation: .mandatory
      ),
      makeObservance(
        id: "b",
        title: "Same Day B",
        date: makeDate(year: 2026, month: 3, day: 3),
        obligation: .mandatory
      ),
      makeObservance(
        id: "a",
        title: "Same Day A",
        date: makeDate(year: 2026, month: 3, day: 3),
        obligation: .mandatory
      ),
    ]

    let planned = RequiredDayReminderPlanner.upcomingMandatoryObservances(
      from: observances,
      now: now,
      calendar: .gregorian,
      limit: 10
    )

    XCTAssertEqual(planned.map(\.id), ["dup", "a", "b"])
  }

  func testAdditionalRequiredReminderSlotsClampsAtZeroAndAvailableCapacity() {
    XCTAssertEqual(
      RequiredDayReminderPlanner.additionalRequiredReminderSlots(
        existingRequiredPendingCount: 10,
        existingNonRequiredPendingCount: 10
      ),
      40
    )

    XCTAssertEqual(
      RequiredDayReminderPlanner.additionalRequiredReminderSlots(
        existingRequiredPendingCount: 50,
        existingNonRequiredPendingCount: 10
      ),
      0
    )

    XCTAssertEqual(
      RequiredDayReminderPlanner.additionalRequiredReminderSlots(
        existingRequiredPendingCount: 0,
        existingNonRequiredPendingCount: 80
      ),
      0
    )

    XCTAssertEqual(
      RequiredDayReminderPlanner.additionalRequiredReminderSlots(
        existingRequiredPendingCount: -5,
        existingNonRequiredPendingCount: -2
      ),
      50
    )
  }

  private func makeDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
    Calendar.gregorian.date(from: DateComponents(year: year, month: month, day: day, hour: hour))
      ?? Date.distantFuture
  }

  private func makeObservance(
    id: String,
    title: String,
    date: Date,
    obligation: Observance.Obligation
  ) -> Observance {
    Observance(
      id: id,
      title: title,
      date: date,
      kind: .holyDay,
      obligation: obligation,
      detail: nil,
      rationale: "test",
      citations: [],
      ruleVersion: "test"
    )
  }
}
