@testable import CatholicFastingCore
import XCTest

final class LiturgicalSeasonThemeEngineTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return value
    }

    func testLentDateIsDetected() {
        let date = makeDate(2026, 3, 10)
        XCTAssertEqual(LiturgicalSeasonThemeEngine.season(for: date, calendar: calendar), .lent)
    }

    func testEasterSeasonDateIsDetected() {
        let date = makeDate(2026, 4, 12)
        XCTAssertEqual(LiturgicalSeasonThemeEngine.season(for: date, calendar: calendar), .easter)
    }

    func testAdventDateIsDetected() {
        let date = makeDate(2026, 12, 10)
        XCTAssertEqual(LiturgicalSeasonThemeEngine.season(for: date, calendar: calendar), .advent)
    }

    func testChristmasDateIsDetected() {
        let date = makeDate(2026, 12, 26)
        XCTAssertEqual(LiturgicalSeasonThemeEngine.season(for: date, calendar: calendar), .christmas)
    }

    func testEarlyJanuaryIsChristmasSeason() {
        let date = makeDate(2027, 1, 8)
        XCTAssertEqual(LiturgicalSeasonThemeEngine.season(for: date, calendar: calendar), .christmas)
    }

    func testOrdinaryTimeDateIsDetected() {
        let date = makeDate(2026, 7, 8)
        XCTAssertEqual(LiturgicalSeasonThemeEngine.season(for: date, calendar: calendar), .ordinary)
    }

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }
}
