import Foundation
import XCTest

final class LocalizationContractTests: XCTestCase {
    private let supportedLocales = ["en", "es", "fr-CA"]

    func testEverySourceExtractedKeyExistsInEverySupportedLocale() throws {
        let sourceContract = try extractSourceLocalizationContract()
        let localizations = try loadSupportedLocalizations()

        XCTAssertFalse(sourceContract.keys.isEmpty, "No explicit localization keys were extracted from app sources.")

        for locale in supportedLocales {
            let localizedKeys = try Set(XCTUnwrap(localizations[locale]).keys)
            let missingKeys = sourceContract.keys.subtracting(localizedKeys).sorted()
            XCTAssertTrue(
                missingKeys.isEmpty,
                "\(locale) is missing source-extracted localization keys: \(summarize(missingKeys)).")
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

    func testSupportedAppLocalizationTablesShareTheSameKeys() throws {
        let localizations = try loadSupportedLocalizations()
        let englishKeys = try Set(XCTUnwrap(localizations["en"]).keys)

        for locale in supportedLocales {
            let localizedKeys = try Set(XCTUnwrap(localizations[locale]).keys)
            let missing = englishKeys.subtracting(localizedKeys).sorted()
            let unexpected = localizedKeys.subtracting(englishKeys).sorted()
            XCTAssertTrue(
                missing.isEmpty && unexpected.isEmpty,
                "\(locale) app localization keys differ from English. "
                    + "Missing: \(summarize(missing)); unexpected: \(summarize(unexpected)).")
        }
    }

    func testLocalizationTablesDoNotContainDuplicateKeys() throws {
        let tables = [
            (target: "CatholicFastingApp", table: "Localizable.strings"),
            (target: "CatholicFastingApp", table: "AppShortcuts.strings"),
            (target: "CatholicFastingWidget", table: "Localizable.strings"),
        ]

        for locale in supportedLocales {
            for table in tables {
                let url = repoRoot()
                    .appendingPathComponent(table.target)
                    .appendingPathComponent("\(locale).lproj")
                    .appendingPathComponent(table.table)
                let source = try String(contentsOf: url, encoding: .utf8)
                let keys = try stringTableKeys(in: source)
                var seen = Set<String>()
                let duplicates = Set(keys.filter { !seen.insert($0).inserted }).sorted()
                XCTAssertTrue(
                    duplicates.isEmpty,
                    "\(locale) \(table.table) contains duplicate keys: \(duplicates.joined(separator: ", "))")
            }
        }
    }

    func testSupportedLocalizationFormatPlaceholdersStayCompatible() throws {
        let sourceContract = try extractSourceLocalizationContract()
        let localizations = try loadSupportedLocalizations()
        let english = try XCTUnwrap(localizations["en"])

        for locale in supportedLocales {
            let localized = try XCTUnwrap(localizations[locale])
            for key in sourceContract.keys.sorted() {
                let localizedValue = try XCTUnwrap(
                    localized[key],
                    "\(locale) is missing \(key), so its format placeholders cannot be verified.")
                let canonicalValue: String = if let sourceDefault = sourceContract.literalDefaults[key] {
                    sourceDefault
                } else {
                    try XCTUnwrap(
                        english[key],
                        "English is missing \(key), so its format placeholders cannot be used as the fallback contract.")
                }
                XCTAssertEqual(
                    formatPlaceholders(in: localizedValue),
                    formatPlaceholders(in: canonicalValue),
                    "\(locale) has placeholders incompatible with the source contract for \(key).")
            }
        }
    }

    func testVisibleRootLabelsKeepProductTerminology() throws {
        let expectedValues: [String: [String: String]] = [
            "en": ["home.surface.today": "Today", "home.surface.fasting_days": "Calendar", "home.surface.intermittent": "Fast", "home.surface.more": "More"],
            "es": ["home.surface.today": "Hoy", "home.surface.fasting_days": "Calendario", "home.surface.intermittent": "Ayuno", "home.surface.more": "Más"],
            "fr-CA": ["home.surface.today": "Aujourd’hui", "home.surface.fasting_days": "Calendrier", "home.surface.intermittent": "Jeûne", "home.surface.more": "Plus"],
        ]
        let localizations = try loadSupportedLocalizations()

        for locale in supportedLocales {
            let localization = try XCTUnwrap(localizations[locale])
            for (key, expectedValue) in try XCTUnwrap(expectedValues[locale]) {
                XCTAssertEqual(localization[key], expectedValue, "\(locale) changed the visible root label for \(key).")
            }
        }
    }

    func testWidgetLocalizationTablesShareKeysAndCompatiblePlaceholders() throws {
        let localizations = try loadLocalizations(in: "CatholicFastingWidget")
        let english = try XCTUnwrap(localizations["en"])
        let englishKeys = Set(english.keys)

        for locale in supportedLocales {
            let localization = try XCTUnwrap(localizations[locale])
            let localizedKeys = Set(localization.keys)
            XCTAssertEqual(localizedKeys, englishKeys, "\(locale) widget localization keys differ from English.")

            let emptyKeys = localization
                .filter { $0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .map(\.key)
                .sorted()
            XCTAssertTrue(emptyKeys.isEmpty, "\(locale) has empty widget values for: \(emptyKeys.joined(separator: ", "))")

            for key in englishKeys.sorted() {
                XCTAssertEqual(
                    try formatPlaceholders(in: XCTUnwrap(localization[key])),
                    try formatPlaceholders(in: XCTUnwrap(english[key])),
                    "\(locale) widget placeholders are incompatible for \(key).")
            }
        }
    }

    func testEveryWidgetSourceLocalizationKeyExistsInEverySupportedLocale() throws {
        let widgetDirectory = repoRoot().appendingPathComponent("CatholicFastingWidget")
        let widgetSource = try FileManager.default
            .contentsOfDirectory(at: widgetDirectory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map { try String(contentsOf: $0, encoding: .utf8) }
            .joined(separator: "\n")
        let keyExpression = try NSRegularExpression(
            pattern: #"\"((?:widget|fast\.live_activity)\.[^\"]+)\""#)
        let sourceKeys = Set(matches(of: keyExpression, in: widgetSource).compactMap(\.first))
        let localizations = try loadLocalizations(in: "CatholicFastingWidget")

        XCTAssertFalse(sourceKeys.isEmpty, "No widget localization keys were extracted from source.")
        for locale in supportedLocales {
            let localizedKeys = try Set(XCTUnwrap(localizations[locale]).keys)
            let missingKeys = sourceKeys.subtracting(localizedKeys).sorted()
            let staleKeys = localizedKeys.subtracting(sourceKeys).sorted()
            XCTAssertTrue(
                missingKeys.isEmpty && staleKeys.isEmpty,
                "\(locale) widget keys differ from source. "
                    + "Missing: \(missingKeys.joined(separator: ", ")); "
                    + "stale: \(staleKeys.joined(separator: ", "))")
        }
    }

    func testSharedWidgetFallbackValuesMatchAppTables() throws {
        let appLocalizations = try loadSupportedLocalizations()
        let widgetLocalizations = try loadLocalizations(in: "CatholicFastingWidget")
        let sharedFallbackKeys = [
            "widget.fallback.today.title",
            "widget.fallback.today.obligation",
            "widget.fallback.next_required",
        ]

        for locale in supportedLocales {
            let app = try XCTUnwrap(appLocalizations[locale])
            let widget = try XCTUnwrap(widgetLocalizations[locale])
            for key in sharedFallbackKeys {
                XCTAssertEqual(
                    app[key],
                    widget[key],
                    "\(locale) uses different app and widget fallback text for \(key).")
            }
        }
    }

    func testWidgetConfigurationNameKeepsStableProductName() throws {
        let localizations = try loadLocalizations(in: "CatholicFastingWidget")

        for locale in supportedLocales {
            XCTAssertEqual(
                try XCTUnwrap(localizations[locale])["widget.configuration.name"],
                "Catholic Fasting",
                "\(locale) translated the fixed Catholic Fasting product name.")
        }
    }

    func testAppIntentAndShortcutLocalizationsStayComplete() throws {
        let intentMetadataKeys: Set = [
            "Open Today Plan",
            "Open the Today tab in Catholic Fasting.",
            "Open Calendar",
            "Open the Church observance calendar.",
            "Open Fast",
            "Open the optional personal fast tracker.",
            "Today Plan",
            "Calendar",
            "Fast",
        ]
        let shortcutPhraseKeys: Set = [
            "Open ${applicationName} today",
            "Open ${applicationName} Calendar",
            "Open ${applicationName} fasting days",
            "Open ${applicationName} Fast",
            "Open ${applicationName} fast tracker",
        ]
        let shortcutSource = try String(
            contentsOf: repoRoot()
                .appendingPathComponent("CatholicFastingApp")
                .appendingPathComponent("AppTipsAndShortcuts.swift"),
            encoding: .utf8)

        for key in intentMetadataKeys {
            XCTAssertTrue(
                shortcutSource.contains("\"\(key)\""),
                "AppTipsAndShortcuts.swift no longer declares the localized metadata key \(key).")
        }
        for key in shortcutPhraseKeys {
            let sourcePhrase = key.replacingOccurrences(
                of: "${applicationName}",
                with: #"\(.applicationName)"#)
            XCTAssertTrue(
                shortcutSource.contains("\"\(sourcePhrase)\""),
                "AppTipsAndShortcuts.swift no longer declares the localized phrase \(key).")
        }

        let appLocalizations = try loadSupportedLocalizations()
        let shortcutLocalizations = try loadLocalizations(
            in: "CatholicFastingApp",
            table: "AppShortcuts.strings")

        for locale in supportedLocales {
            let appLocalization = try XCTUnwrap(appLocalizations[locale])
            let missingIntentKeys = intentMetadataKeys.subtracting(appLocalization.keys).sorted()
            XCTAssertTrue(
                missingIntentKeys.isEmpty,
                "\(locale) is missing App Intent metadata: \(missingIntentKeys.joined(separator: ", "))")
            for key in intentMetadataKeys {
                XCTAssertFalse(
                    try XCTUnwrap(appLocalization[key])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty,
                    "\(locale) has empty App Intent metadata for \(key).")
            }

            let shortcuts = try XCTUnwrap(shortcutLocalizations[locale])
            XCTAssertEqual(
                Set(shortcuts.keys),
                shortcutPhraseKeys,
                "\(locale) App Shortcut phrase keys differ from the source phrases.")
            for (key, value) in shortcuts {
                XCTAssertFalse(
                    value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    "\(locale) has an empty App Shortcut phrase for \(key).")
                XCTAssertEqual(
                    shortcutTokens(in: value),
                    ["${applicationName}"],
                    "\(locale) App Shortcut phrase \(key) must preserve the application-name token exactly once.")
            }
        }
    }

    private func loadSupportedLocalizations() throws -> [String: [String: String]] {
        try loadLocalizations(in: "CatholicFastingApp")
    }

    private func loadLocalizations(
        in targetDirectory: String,
        table: String = "Localizable.strings") throws -> [String: [String: String]]
    {
        try Dictionary(uniqueKeysWithValues: supportedLocales.map { locale in
            let url = repoRoot()
                .appendingPathComponent(targetDirectory)
                .appendingPathComponent("\(locale).lproj")
                .appendingPathComponent(table)
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

    private func extractSourceLocalizationContract() throws -> (keys: Set<String>, literalDefaults: [String: String]) {
        let sourceDirectory = repoRoot().appendingPathComponent("CatholicFastingApp")
        let enumerator = try XCTUnwrap(
            FileManager.default.enumerator(
                at: sourceDirectory,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]))
        let sourceURLs = enumerator.compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }

        let callPrefix = #"(?:\b(?:localized|localizedFormat)\s*\(|\b(?:AppLocalizer|CoreLocalizer)\.[A-Za-z_]\w*\s*\()"#
        let literal = #"\"((?:\\.|[^\"\\])*)\""#
        let keyExpression = try NSRegularExpression(pattern: callPrefix + #"\s*"# + literal)
        let defaultExpression = try NSRegularExpression(
            pattern: callPrefix + #"\s*"# + literal + #"\s*,\s*default\s*:\s*"# + literal)

        var keys = Set<String>()
        var literalDefaults: [String: String] = [:]
        for url in sourceURLs {
            let source = try String(contentsOf: url, encoding: .utf8)
            for captures in matches(of: keyExpression, in: source) {
                guard !captures[0].contains(#"\("#) else { continue }
                keys.insert(captures[0])
            }
            for captures in matches(of: defaultExpression, in: source) {
                guard !captures[0].contains(#"\("#) else { continue }
                literalDefaults[captures[0], default: captures[1]] = captures[1]
            }
        }
        return (keys, literalDefaults)
    }

    private func matches(of expression: NSRegularExpression, in source: String) -> [[String]] {
        let sourceRange = NSRange(source.startIndex..., in: source)
        return expression.matches(in: source, range: sourceRange).compactMap { match in
            guard match.numberOfRanges > 1 else { return nil }
            return (1 ..< match.numberOfRanges).compactMap { captureIndex in
                guard let range = Range(match.range(at: captureIndex), in: source) else { return nil }
                return String(source[range])
            }
        }
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

    private func shortcutTokens(in value: String) -> [String] {
        let pattern = #"\$\{[^}]+\}"#
        guard let expression = try? NSRegularExpression(pattern: pattern) else {
            return []
        }

        let range = NSRange(value.startIndex..., in: value)
        return expression.matches(in: value, range: range).compactMap { match in
            guard let matchRange = Range(match.range, in: value) else { return nil }
            return String(value[matchRange])
        }.sorted()
    }

    private func stringTableKeys(in source: String) throws -> [String] {
        let expression = try NSRegularExpression(
            pattern: #"(?m)^\s*\"((?:\\.|[^\"\\])*)\"\s*="#)
        return matches(of: expression, in: source).compactMap(\.first)
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
