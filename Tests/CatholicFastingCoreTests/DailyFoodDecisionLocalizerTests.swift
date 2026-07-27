@testable import CatholicFastingCore
import XCTest

final class DailyFoodDecisionLocalizerTests: XCTestCase {
    func testExplicitSelectedLanguageLocalizesEveryDecisionField() throws {
        let decision = DailyFoodDecision(
            obligationLine: "Today requires fasting and abstinence.",
            allowed: [
                "One full meal with up to two smaller meals.",
                "Fish, eggs, dairy, grains, fruits, and vegetables are generally permitted.",
            ],
            avoid: [
                "Meat from land animals (beef, pork, poultry).",
                "Eating patterns that effectively become a second full meal.",
            ],
            rationale: "This is based on Ash Wednesday.",
            sourceLine: "Source: USCCB Fast & Abstinence norms.")

        let localized = try DailyFoodDecisionLocalizer.localized(
            decision,
            languageMode: "spanish",
            bundle: appResourceBundle())

        XCTAssertEqual(localized.obligationLine, "Hoy requiere ayuno y abstinencia.")
        XCTAssertEqual(
            localized.allowed,
            [
                "Una comida completa y hasta dos comidas más pequeñas.",
                "Pescado, huevos, lácteos, granos, frutas y verduras normalmente se permiten.",
            ])
        XCTAssertEqual(
            localized.avoid,
            [
                "Carne de animales terrestres (res, cerdo, aves).",
                "Patrones de comida que en la práctica se convierten en una segunda comida completa.",
            ])
        XCTAssertEqual(localized.rationale, "Esto se basa en Miércoles de Ceniza.")
        XCTAssertEqual(localized.sourceLine, "Fuente: normas de ayuno y abstinencia de la USCCB.")
    }

    func testCurrentLanguagePathMatchesExplicitSelectedLanguagePath() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: #function))
        defer { defaults.removePersistentDomain(forName: #function) }
        defaults.set("frenchCanadian", forKey: "language_mode")

        let decision = DailyFoodDecision(
            obligationLine: "Today may include fasting/abstinence obligations (profile incomplete).",
            allowed: ["Follow age/health and pastoral guidance for your situation."],
            avoid: ["Do not assume no obligation without confirming your profile."],
            rationale:
            "Review the age eligibility toggles in Settings so the app can determine whether "
                + "Ash Wednesday, Good Friday binds you.",
            sourceLine: "Source: CCCB Friday guidance and universal law.")
        let bundle = try appResourceBundle()

        let explicit = DailyFoodDecisionLocalizer.localized(
            decision,
            languageMode: "frenchCanadian",
            bundle: bundle)
        let current = DailyFoodDecisionLocalizer.localizedCurrent(
            decision,
            bundle: bundle,
            userDefaults: defaults)

        assertEqual(current, explicit)
        XCTAssertTrue(current.rationale.contains("Mercredi des Cendres"))
        XCTAssertTrue(current.rationale.contains("Vendredi saint"))
    }

    func testKnownOptionalAndMultipleObservanceRationalesRemainLocalized() throws {
        let bundle = try appResourceBundle()
        let known = DailyFoodDecision(
            obligationLine: "",
            allowed: [],
            avoid: [],
            rationale: "Based on your current profile, Good Friday does not strictly bind today.",
            sourceLine: "")
        let multiple = DailyFoodDecision(
            obligationLine: "",
            allowed: [],
            avoid: [],
            rationale: "This is based on Ash Wednesday, Good Friday.",
            sourceLine: "")

        XCTAssertEqual(
            DailyFoodDecisionLocalizer.localized(
                known,
                languageMode: "spanish",
                bundle: bundle).rationale,
            "Según su perfil actual, Viernes Santo no le obliga estrictamente hoy.")
        XCTAssertEqual(
            DailyFoodDecisionLocalizer.localized(
                multiple,
                languageMode: "spanish",
                bundle: bundle).rationale,
            "Esto se basa en Miércoles de Ceniza, Viernes Santo.")
    }

    func testUnknownEngineOutputPassesThroughUnchanged() throws {
        let decision = DailyFoodDecision(
            obligationLine: "Future obligation",
            allowed: ["Future allowance"],
            avoid: ["Future avoidance"],
            rationale: "Future rationale",
            sourceLine: "Future source")

        let localized = try DailyFoodDecisionLocalizer.localized(
            decision,
            languageMode: "spanish",
            bundle: appResourceBundle())

        assertEqual(localized, decision)
    }

    func testStableTextAndSourceKeyContracts() {
        XCTAssertEqual(DailyFoodDecisionLocalizer.textLocalizationKeys.count, 28)
        XCTAssertEqual(DailyFoodDecisionLocalizer.sourceLocalizationKeys.count, 12)
        XCTAssertEqual(
            DailyFoodDecisionLocalizer.textLocalizationKeys[
                "Today requires Friday penance, but not mandatory fasting."
            ],
            "decision.friday_penance.required_obligation")
        XCTAssertEqual(
            DailyFoodDecisionLocalizer.sourceLocalizationKeys[
                "Source: universal law and the Canada national baseline."
            ],
            "decision.sources.ca.holyday")
    }

    private func assertEqual(
        _ lhs: DailyFoodDecision,
        _ rhs: DailyFoodDecision,
        file: StaticString = #filePath,
        line: UInt = #line)
    {
        XCTAssertEqual(lhs.obligationLine, rhs.obligationLine, file: file, line: line)
        XCTAssertEqual(lhs.allowed, rhs.allowed, file: file, line: line)
        XCTAssertEqual(lhs.avoid, rhs.avoid, file: file, line: line)
        XCTAssertEqual(lhs.rationale, rhs.rationale, file: file, line: line)
        XCTAssertEqual(lhs.sourceLine, rhs.sourceLine, file: file, line: line)
    }

    private func appResourceBundle() throws -> Bundle {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try XCTUnwrap(Bundle(url: root.appendingPathComponent("CatholicFastingApp")))
    }
}
