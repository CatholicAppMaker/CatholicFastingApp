import Foundation
import XCTest

final class WidgetSourceContractTests: XCTestCase {
    func testWidgetSnapshotUsesLocalizedDispositionAndRefreshesForLanguageChanges() throws {
        let stateSource = try appSource("ContentView+StateHelpers.swift")
        let rootSource = try appSource("ContentView+RootShell.swift")

        XCTAssertTrue(
            stateSource.contains("todayObservance.map(localizedObservanceDispositionLabel)"),
            "The widget snapshot must persist the localized observance disposition.")
        XCTAssertTrue(
            rootSource.range(
                of: #"\.onChange\(of:\s*languageModeRaw\)\s*\{[^{}]*persistWidgetSnapshot\(\)"#,
                options: .regularExpression) != nil,
            "Changing the in-app language must refresh the persisted widget snapshot.")
    }

    func testWidgetAppliesResolvedSnapshotLocaleToSystemFormattedContent() throws {
        let source = try String(
            contentsOf: repositoryRoot()
                .appendingPathComponent("CatholicFastingWidget")
                .appendingPathComponent("CatholicFastingWidget.swift"),
            encoding: .utf8)

        XCTAssertTrue(
            source.contains(#".environment(\.locale, widgetLocale)"#),
            "Widget dates and other system-formatted content must use the snapshot language.")
        XCTAssertTrue(
            source.contains("WidgetLocalizationCode.resolvedSupportedCode(for: entry.localizationCode)"),
            "The widget locale must resolve through the supported localization bundle contract.")
    }

    func testSmallWidgetAccessibilityIncludesActiveFastTarget() throws {
        let source = try String(
            contentsOf: repositoryRoot()
                .appendingPathComponent("CatholicFastingWidget")
                .appendingPathComponent("CatholicFastingWidget.swift"),
            encoding: .utf8)

        XCTAssertTrue(source.contains("parts.append(activeFastAccessibilityStatus)"))
        XCTAssertTrue(source.contains("entry.activeIntermittentTargetDate"))
        XCTAssertTrue(source.contains(#""widget.fast.active_target""#))
        XCTAssertTrue(source.contains(".locale(widgetLocale)"))
    }

    private func appSource(_ filename: String) throws -> String {
        try String(
            contentsOf: repositoryRoot()
                .appendingPathComponent("CatholicFastingApp")
                .appendingPathComponent(filename),
            encoding: .utf8)
    }

    private func repositoryRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
