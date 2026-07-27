@testable import CatholicFastingCore
import Foundation
import XCTest

final class AppClockTests: XCTestCase {
    func testFixedDateEnvironmentUsesNoonUTCForDateOnlyValue() throws {
        let date = try XCTUnwrap(AppClock.now(environment: ["UITEST_FIXED_DATE": "2026-02-18"], arguments: []))
        let timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let components = Calendar(identifier: .gregorian).dateComponents(in: timeZone, from: date)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 18)
        XCTAssertEqual(components.hour, 12)
    }

    func testFixedDateEnvironmentAcceptsISO8601Value() {
        let date = AppClock.now(
            environment: ["CFA_FIXED_DATE": "2026-04-03T16:30:00Z"],
            arguments: [])
        XCTAssertEqual(date.timeIntervalSince1970, 1_775_233_800, accuracy: 0.5)
    }

    func testFixedDateArgumentIsInjectable() {
        let date = AppClock.now(environment: [:], arguments: ["app", "-fixed-date", "2026-07-17"])
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 7)
        XCTAssertEqual(components.day, 17)
    }

    func testFixedDateEnvironmentPrecedesLaunchArgument() {
        let date = AppClock.now(
            environment: ["UITEST_FIXED_DATE": "2026-02-18"],
            arguments: ["app", "-fixed-date", "2027-03-26"])
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: date)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 2)
        XCTAssertEqual(components.day, 18)
    }
}
