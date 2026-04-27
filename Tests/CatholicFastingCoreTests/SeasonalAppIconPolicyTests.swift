@testable import CatholicFastingCore
import XCTest

final class SeasonalAppIconPolicyTests: XCTestCase {
    private var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return value
    }

    func testAutomaticSeasonalIconUpdatesDefaultOff() {
        let defaults = makeDefaults()
        XCTAssertFalse(SeasonalAppIconPolicy.automaticUpdatesEnabled(userDefaults: defaults))
        XCTAssertNil(
            SeasonalAppIconPolicy.targetIconName(
                now: makeDate(2026, 4, 12),
                userDefaults: defaults,
                calendar: calendar))
    }

    func testAutomaticSeasonalIconUpdatesReturnSeasonalIconWhenEnabled() {
        let defaults = makeDefaults()
        defaults.set(true, forKey: SeasonalAppIconPolicy.automaticUpdatesStorageKey)

        XCTAssertEqual(
            SeasonalAppIconPolicy.targetIconName(
                now: makeDate(2026, 4, 12),
                userDefaults: defaults,
                calendar: calendar),
            "AppIconEaster")
    }

    func testSeasonalIconUpdatesRespectLiturgicalThemeToggle() {
        let defaults = makeDefaults()
        defaults.set(true, forKey: SeasonalAppIconPolicy.automaticUpdatesStorageKey)
        defaults.set(false, forKey: SeasonalAppIconPolicy.liturgicalSeasonColorsStorageKey)

        XCTAssertNil(
            SeasonalAppIconPolicy.targetIconName(
                now: makeDate(2026, 12, 10),
                userDefaults: defaults,
                calendar: calendar))
    }

    private func makeDefaults() -> UserDefaults {
        let name = "SeasonalAppIconPolicyTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name) ?? .standard
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }
}
