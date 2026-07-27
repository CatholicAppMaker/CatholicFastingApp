import Foundation
import XCTest

final class StaticLinkContractTests: XCTestCase {
    func testStaticExternalLinkDestinationsStayExact() throws {
        let source = try appThemeAndLinksSource()
        let expectedURLs = [
            "https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar",
            "https://www.usccb.org/prayer-and-worship/liturgical-year-and-calendar/lent/catholic-information-on-lenten-fast-and-abstinence",
            "https://www.cccb.ca/document/keeping-friday/",
            "mailto:support@catholicfasting.app?subject=Catholic%20Fasting%20App%20Feedback",
            "https://x.com/CatholicFasting/status/2026354531273945191",
            "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
            "https://x.com/CatholicFasting",
            "https://apps.apple.com/account/subscriptions",
        ]

        for expectedURL in expectedURLs {
            XCTAssertTrue(
                source.contains(#""\#(expectedURL)""#),
                "Static destination changed or disappeared: \(expectedURL)")
        }
    }

    func testStaticDeepLinkDestinationsStayBackwardCompatible() throws {
        let source = try appThemeAndLinksSource()
        let expectedURLs = [
            "catholicfasting://today",
            "catholicfasting://fasting-days",
            "catholicfasting://intermittent",
            "catholicfasting://more",
            "catholicfasting://settings",
            "catholicfasting://premium",
        ]

        for expectedURL in expectedURLs {
            XCTAssertTrue(
                source.contains(#""\#(expectedURL)""#),
                "Stable deep-link destination changed or disappeared: \(expectedURL)")
        }
    }

    private func appThemeAndLinksSource() throws -> String {
        let repositoryRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: repositoryRoot
                .appendingPathComponent("CatholicFastingApp")
                .appendingPathComponent("AppThemeAndLinks.swift"),
            encoding: .utf8)
    }
}
