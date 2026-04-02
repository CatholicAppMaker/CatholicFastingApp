import Foundation
import XCTest

final class AppIconConfigurationTests: XCTestCase {
    func testInfoPlistMirrorsAlternateIconsForIPad() throws {
        let plist = try XCTUnwrap(NSDictionary(contentsOf: appInfoPlistURL()) as? [String: Any])

        let iphoneIcons = try iconDictionary(named: "CFBundleIcons", from: plist)
        let ipadIcons = try iconDictionary(named: "CFBundleIcons~ipad", from: plist)

        XCTAssertEqual(
            primaryIconFiles(from: iphoneIcons),
            primaryIconFiles(from: ipadIcons),
            "Primary icon declarations should stay mirrored between iPhone and iPad.")
        XCTAssertEqual(
            alternateIconFiles(from: iphoneIcons),
            alternateIconFiles(from: ipadIcons),
            "Alternate icon declarations should stay mirrored between iPhone and iPad.")
    }

    func testInfoPlistDeclaresAllSeasonalAlternateIcons() throws {
        let plist = try XCTUnwrap(NSDictionary(contentsOf: appInfoPlistURL()) as? [String: Any])
        let icons = try iconDictionary(named: "CFBundleIcons", from: plist)
        let alternateIcons = try alternateIcons(from: icons)

        XCTAssertEqual(
            Set(alternateIcons.keys),
            ["AppIconAdvent", "AppIconChristmas", "AppIconLent", "AppIconEaster"],
            "The shipped seasonal icon catalog should stay complete and explicit.")
    }

    private func appInfoPlistURL(filePath: StaticString = #filePath) -> URL {
        URL(fileURLWithPath: filePath.description)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("CatholicFastingApp")
            .appendingPathComponent("Info.plist")
    }

    private func iconDictionary(named key: String, from plist: [String: Any]) throws -> [String: Any] {
        try XCTUnwrap(plist[key] as? [String: Any], "Missing \(key) in Info.plist.")
    }

    private func primaryIconFiles(from iconDictionary: [String: Any]) -> [String] {
        ((iconDictionary["CFBundlePrimaryIcon"] as? [String: Any])?["CFBundleIconFiles"] as? [String]) ?? []
    }

    private func alternateIcons(from iconDictionary: [String: Any]) throws -> [String: [String]] {
        let rawAlternates = try XCTUnwrap(
            iconDictionary["CFBundleAlternateIcons"] as? [String: [String: Any]],
            "Missing CFBundleAlternateIcons in icon dictionary.")

        return rawAlternates.mapValues { entry in
            (entry["CFBundleIconFiles"] as? [String]) ?? []
        }
    }

    private func alternateIconFiles(from iconDictionary: [String: Any]) -> [String: [String]] {
        (try? alternateIcons(from: iconDictionary)) ?? [:]
    }
}
