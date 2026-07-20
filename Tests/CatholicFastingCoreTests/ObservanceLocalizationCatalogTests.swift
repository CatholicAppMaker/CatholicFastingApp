import Foundation
import XCTest
@testable import CatholicFastingCore

final class ObservanceLocalizationCatalogTests: XCTestCase {
    func testGeneratedCalendarsHaveCompleteLocalizationMappings() throws {
        var generated: [Observance] = []
        for year in [2026, 2027] {
            for region in RuleSettings.RegionProfile.allCases {
                for calendarMode in RuleSettings.CalendarMode.allCases {
                    for ascension in RuleSettings.AscensionObservance.allCases {
                        for fridayMode in RuleSettings.FridayOutsideLentMode.allCases {
                            generated += ObservanceCalculator.makeCalendar(
                                for: year,
                                settings: settings(
                                    region: region,
                                    calendarMode: calendarMode,
                                    ascension: ascension,
                                    fridayMode: fridayMode))
                        }
                    }
                }
            }
        }

        let missingTitles: [String] = Set(generated.compactMap { observance -> String? in
            ObservanceLocalizationCatalog.titleIdentifier(for: observance.title) == nil
                ? observance.title
                : nil
        }).sorted()
        let missingDetails: [String] = Set(generated.compactMap { observance -> String? in
            guard let detail = observance.detail else { return nil }
            return ObservanceLocalizationCatalog.detailIdentifier(for: detail) == nil ? detail : nil
        }).sorted()
        let missingRationales: [String] = Set(generated.compactMap { observance -> String? in
            ObservanceLocalizationCatalog.rationaleIdentifier(for: observance.rationale) == nil
                ? observance.rationale
                : nil
        }).sorted()

        XCTAssertEqual(missingTitles, [], "Generated titles without stable localization IDs: \(missingTitles)")
        XCTAssertEqual(missingDetails, [], "Generated details without stable localization IDs: \(missingDetails)")
        XCTAssertEqual(missingRationales, [], "Generated rationales without stable localization IDs: \(missingRationales)")
    }

    func testEveryCatalogEntryExistsInEverySupportedStringsTable() throws {
        for locale in ["en", "es", "fr-CA"] {
            let table = try localizableTable(locale: locale)
            for identifier in ObservanceLocalizationCatalog.titleDefaultsByIdentifier.keys {
                XCTAssertNotNil(table["observance.title.\(identifier)"], "Missing \(locale) title: \(identifier)")
            }
            for identifier in ObservanceLocalizationCatalog.detailDefaultsByIdentifier.keys {
                XCTAssertNotNil(table["observance.detail.\(identifier)"], "Missing \(locale) detail: \(identifier)")
            }
            for identifier in ObservanceLocalizationCatalog.rationaleDefaultsByIdentifier.keys {
                XCTAssertNotNil(table["observance.rationale.\(identifier)"], "Missing \(locale) rationale: \(identifier)")
            }
        }
    }

    func testRepresentativeFixedMovableAndUSProperTitlesAreLocalized() throws {
        let spanish = try localizableTable(locale: "es")
        let french = try localizableTable(locale: "fr-CA")

        XCTAssertEqual(spanish["observance.title.christmas"], "Navidad")
        XCTAssertEqual(french["observance.title.christmas"], "Noël")
        XCTAssertEqual(spanish["observance.title.easter_sunday"], "Domingo de Pascua")
        XCTAssertEqual(french["observance.title.easter_sunday"], "Dimanche de Pâques")
        XCTAssertEqual(spanish["observance.title.saint_camillus_de_lellis"], "San Camilo de Lelis, presbítero")
        XCTAssertEqual(french["observance.title.saint_camillus_de_lellis"], "Saint Camille de Lellis, prêtre")

        let usCalendar = ObservanceCalculator.makeCalendar(
            for: 2026,
            settings: settings(region: .us))
        XCTAssertTrue(usCalendar.contains { $0.title == "Saint Camillus de Lellis, Priest" })
        XCTAssertTrue(usCalendar.contains { $0.title == "Easter Sunday" })
        XCTAssertTrue(usCalendar.contains { $0.title == "Christmas" })
    }

    private func settings(
        region: RuleSettings.RegionProfile,
        calendarMode: RuleSettings.CalendarMode = .usccb,
        ascension: RuleSettings.AscensionObservance = .sunday,
        fridayMode: RuleSettings.FridayOutsideLentMode = .abstainFromMeat) -> RuleSettings
    {
        RuleSettings(
            birthYear: 1990,
            birthMonth: 1,
            birthDay: 1,
            hasMedicalDispensation: false,
            ascensionObservance: ascension,
            fridayOutsideLentMode: fridayMode,
            calendarMode: calendarMode,
            regionProfile: region)
    }

    private func localizableTable(locale: String) throws -> [String: String] {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let projectDirectory = testsDirectory
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = projectDirectory
            .appendingPathComponent("CatholicFastingApp")
            .appendingPathComponent("\(locale).lproj")
            .appendingPathComponent("Localizable.strings")
        let data = try Data(contentsOf: url)
        let propertyList = try PropertyListSerialization.propertyList(from: data, format: nil)
        return try XCTUnwrap(propertyList as? [String: String])
    }
}
