@testable import CatholicFastingCore
import XCTest

final class GrowthContractsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        beginStoreIsolation()
        resetStores()
        LocalFeatureStore.clearAll()
    }

    override func tearDown() {
        LocalFeatureStore.clearAll()
        resetStores()
        endStoreIsolation()
        super.tearDown()
    }

    func testRuleSettingsDefaultsRegionProfileToUS() {
        let settings = RuleSettings(
            birthYear: 1990,
            hasMedicalDispensation: false,
            ascensionObservance: .sunday,
            fridayOutsideLentMode: .substitutePenance,
            calendarMode: .usccb
        )

        XCTAssertEqual(settings.regionProfile, .us)
    }

    func testSubscriptionOfferCatalogHasMonthlyAndYearlyInSingleCatalog() {
        let catalog = SubscriptionOfferCatalog.catholicFasting

        XCTAssertEqual(catalog.pillars.count, 3)
        XCTAssertEqual(catalog.offers.count, 2)
        XCTAssertTrue(catalog.canonicalSubscriptionProductIDs.contains("com.kevpierce.catholicfasting.premium.monthly.v3"))
        XCTAssertTrue(catalog.canonicalSubscriptionProductIDs.contains("com.kevpierce.catholicfasting.premium.yearly.v3"))
    }

    func testReminderTierInferenceMatchesExpectedCadence() {
        XCTAssertEqual(ReminderTier.infer(supportEnabled: false, morningEnabled: false, eveningEnabled: false), .minimal)
        XCTAssertEqual(ReminderTier.infer(supportEnabled: true, morningEnabled: true, eveningEnabled: false), .balanced)
        XCTAssertEqual(ReminderTier.infer(supportEnabled: true, morningEnabled: true, eveningEnabled: true), .guided)
    }

    func testSeasonalContentPackReturnsLocalizedContent() {
        let englishLent = SeasonalContentPackCatalog.pack(for: .lent, locale: .english)
        let spanishLent = SeasonalContentPackCatalog.pack(for: .lent, locale: .spanish)

        XCTAssertEqual(englishLent.season, .lent)
        XCTAssertEqual(spanishLent.season, .lent)
        XCTAssertFalse(englishLent.quotes.isEmpty)
        XCTAssertFalse(spanishLent.quotes.isEmpty)
        XCTAssertNotEqual(englishLent.campaignTitle, spanishLent.campaignTitle)
    }

    func testLaunchFunnelSnapshotPersistsLocally() {
        var snapshot = LaunchFunnelSnapshot.default
        snapshot.selectedRegionRaw = RuleSettings.RegionProfile.canada.rawValue
        snapshot.selectedReminderTierRaw = ReminderTier.guided.rawValue
        snapshot.paywallSeenAt = Date(timeIntervalSince1970: 1_700_000_000)
        snapshot.paywallViewCount = 3
        snapshot.lockedUpgradeTapCount = 2
        snapshot.premiumPreviewSeenAt = Date(timeIntervalSince1970: 1_700_000_100)

        LocalFeatureStore.saveLaunchFunnelSnapshot(snapshot)
        let loaded = LocalFeatureStore.loadLaunchFunnelSnapshot()

        XCTAssertEqual(loaded.selectedRegionRaw, RuleSettings.RegionProfile.canada.rawValue)
        XCTAssertEqual(loaded.selectedReminderTierRaw, ReminderTier.guided.rawValue)
        XCTAssertEqual(loaded.paywallSeenAt, snapshot.paywallSeenAt)
        XCTAssertEqual(loaded.paywallViewCount, 3)
        XCTAssertEqual(loaded.lockedUpgradeTapCount, 2)
        XCTAssertEqual(loaded.premiumPreviewSeenAt, snapshot.premiumPreviewSeenAt)
    }
}
