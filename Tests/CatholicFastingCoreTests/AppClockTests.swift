@testable import CatholicFastingCore
import Foundation
import XCTest

final class AppClockTests: XCTestCase {
    func testFixedDateEnvironmentUsesNoonUTCForDateOnlyValue() throws {
        let date = try XCTUnwrap(AppClock.now(environment: ["UITEST_FIXED_DATE": "2026-02-18"], arguments: []))
        let components = Calendar(identifier: .gregorian).dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: date)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 18)
        XCTAssertEqual(components.hour, 12)
    }

    func testFixedDateEnvironmentAcceptsISO8601Value() throws {
        let date = AppClock.now(
            environment: ["CFA_FIXED_DATE": "2026-04-03T16:30:00Z"],
            arguments: [])
        XCTAssertEqual(date.timeIntervalSince1970, 1_775_233_800, accuracy: 0.5)
    }

    func testFixedDateArgumentIsInjectable() throws {
        let date = AppClock.now(environment: [:], arguments: ["app", "-fixed-date", "2026-07-17"])
        XCTAssertEqual(
            Calendar(identifier: .gregorian).component(.day, from: date),
            17)
    }
}
