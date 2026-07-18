import Foundation
import XCTest

final class LocalizationContractTests: XCTestCase {
    private let supportedLocales = ["en", "es", "fr-CA"]

    func testTranslatedLocalizationsContainEveryExplicitEnglishKey() throws {
        let localizations = try loadSupportedLocalizations()
        let englishKeys = Set(try XCTUnwrap(localizations["en"]).keys)

        for locale in supportedLocales where locale != "en" {
            let localizedKeys = Set(try XCTUnwrap(localizations[locale]).keys)
            let missingKeys = englishKeys.subtracting(localizedKeys).sorted()
            XCTAssertTrue(
                missingKeys.isEmpty,
                "\(locale) is missing explicit English localization keys: \(summarize(missingKeys)).")
        }
    }

    func testSupportedLocalizationValuesAreNonempty() throws {
        for (locale, localization) in try loadSupportedLocalizations() {
            let emptyKeys = localization
                .filter { $0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .map(\.key)
                .sorted()

            XCTAssertTrue(
                emptyKeys.isEmpty,
                "\(locale) has empty localized values for: \(emptyKeys.joined(separator: ", "))")
        }
    }

    func testSupportedLocalizationFormatPlaceholdersStayCompatible() throws {
        let localizations = try loadSupportedLocalizations()
        let english = try XCTUnwrap(localizations["en"])

        for locale in supportedLocales where locale != "en" {
            let localized = try XCTUnwrap(localizations[locale])
            for key in english.keys.sorted() {
                let localizedValue = try XCTUnwrap(
                    localized[key],
                    "\(locale) is missing \(key), so its format placeholders cannot be verified.")
                XCTAssertEqual(
                    formatPlaceholders(in: localizedValue),
                    formatPlaceholders(in: try XCTUnwrap(english[key])),
                    "\(locale) has incompatible format placeholders for \(key).")
            }
        }
    }

    func testRedesignLocalizationKeysExistInEverySupportedLocale() throws {
        let requiredKeys: Set<String> = [
            "common.done",
            "fasting_days.detail.title",
            "fasting_days.detail.why",
            "fasting_days.detail.region",
            "fasting_days.detail.profile",
            "fasting_days.detail.authority",
            "fasting_days.detail.support",
            "fasting_days.detail.sources",
            "fasting_days.detail.open_source",
            "fasting_days.detail.actions",
            "fasting_days.detail.status",
            "fasting_days.detail.schedule",
            "fasting_days.detail.reminder_settings",
            "intermittent.live.optional_practice",
            "intermittent.live.intention_format",
            "intermittent.live.prudence",
            "premium.plan_choice.title",
        ]

        for (locale, localization) in try loadSupportedLocalizations() {
            let missingKeys = requiredKeys.subtracting(localization.keys).sorted()
            XCTAssertTrue(
                missingKeys.isEmpty,
                "\(locale) is missing redesign localization keys: \(missingKeys.joined(separator: ", "))")
        }
    }

    private func loadSupportedLocalizations() throws -> [String: [String: String]] {
        try Dictionary(uniqueKeysWithValues: supportedLocales.map { locale in
            let url = repoRoot()
                .appendingPathComponent("CatholicFastingApp")
                .appendingPathComponent("\(locale).lproj")
                .appendingPathComponent("Localizable.strings")
            let data = try Data(contentsOf: url)
            var format = PropertyListSerialization.PropertyListFormat.openStep
            let propertyList = try PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: &format)
            let localization = try XCTUnwrap(
                propertyList as? [String: String],
                "Unable to decode \(url.path) as a string dictionary.")
            return (locale, localization)
        })
    }

    private func formatPlaceholders(in value: String) -> [String] {
        let pattern = #"%(?:\d+\$)?[-+#0 ']*\d*(?:\.\d+)?(?:hh|h|ll|l|q|z|t|j)?[@diuoxXfFeEgGaAcCsSp]"#
        guard let expression = try? NSRegularExpression(pattern: pattern) else {
            return []
        }

        let range = NSRange(value.startIndex..., in: value)
        return expression.matches(in: value, range: range).compactMap { match in
            guard let matchRange = Range(match.range, in: value) else { return nil }
            let placeholder = String(value[matchRange])
            return placeholder.replacingOccurrences(
                of: #"^%\d+\$"#,
                with: "%",
                options: .regularExpression)
        }.sorted()
    }

    private func summarize(_ keys: [String]) -> String {
        let previewLimit = 20
        let preview = keys.prefix(previewLimit).joined(separator: ", ")
        let remaining = keys.count - min(keys.count, previewLimit)
        return remaining == 0
            ? "\(keys.count) [\(preview)]"
            : "\(keys.count) [\(preview), … +\(remaining) more]"
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
