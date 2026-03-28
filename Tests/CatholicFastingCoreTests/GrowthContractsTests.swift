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
            calendarMode: .usccb)

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

    func testSeasonalContentPackMaintainsHealthyQuoteDepthAcrossLocales() {
        let seasons: [LiturgicalSeason] = [.lent, .advent, .christmas, .easter, .ordinary]
        let locales: [ContentLocale] = [.english, .spanish, .frenchCanadian]

        for locale in locales {
            for season in seasons {
                let pack = SeasonalContentPackCatalog.pack(for: season, locale: locale)
                XCTAssertGreaterThanOrEqual(
                    pack.quotes.count,
                    7,
                    "Expected at least 7 quotes for \(locale.rawValue) \(season.rawValue)")
            }
        }
    }

    func testDailyQuoteReminderProviderUsesLocalizedSeasonalQuotePool() {
        let date = Date(timeIntervalSince1970: 1_773_100_800) // 2026-03-10 UTC

        let englishQuote = DailyQuoteReminderContentProvider.quote(for: date, locale: .english)
        let spanishQuote = DailyQuoteReminderContentProvider.quote(for: date, locale: .spanish)
        let frenchQuote = DailyQuoteReminderContentProvider.quote(for: date, locale: .frenchCanadian)

        XCTAssertFalse(englishQuote.text.isEmpty)
        XCTAssertFalse(spanishQuote.text.isEmpty)
        XCTAssertFalse(frenchQuote.text.isEmpty)
        XCTAssertNotEqual(englishQuote.text, spanishQuote.text)
    }

    func testDailyQuoteReminderBodyIncludesAttributionAndRespectsLimit() {
        let date = Date(timeIntervalSince1970: 1_773_100_800) // 2026-03-10 UTC
        let body = DailyQuoteReminderContentProvider.reminderBody(
            for: date,
            locale: .english,
            characterLimit: 120)

        XCTAssertLessThanOrEqual(body.count, 120)
        XCTAssertTrue(body.contains("—"))
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

    func testDailyQuoteReminderRefreshStateRequestsRefreshWhenSettingsChange() {
        let baseline = DailyQuoteReminderRefreshState(
            isEnabled: true,
            hour: 12,
            minute: 0,
            locale: .english,
            consentAccepted: true,
            notificationsAuthorized: true,
            pendingReminderCount: 21)

        XCTAssertTrue(baseline.shouldRefresh(storedSignature: "english-7-0"))
    }

    func testDailyQuoteReminderRefreshStateRequestsRefreshWhenPermissionComesOnlineWithoutPendingReminders() {
        let state = DailyQuoteReminderRefreshState(
            isEnabled: true,
            hour: 12,
            minute: 0,
            locale: .english,
            consentAccepted: true,
            notificationsAuthorized: true,
            pendingReminderCount: 0)

        XCTAssertTrue(state.shouldRefresh(storedSignature: state.signature))
    }

    func testDailyQuoteReminderRefreshStateSkipsRefreshOnForegroundWhenScheduleMatches() {
        let state = DailyQuoteReminderRefreshState(
            isEnabled: true,
            hour: 12,
            minute: 0,
            locale: .frenchCanadian,
            consentAccepted: true,
            notificationsAuthorized: true,
            pendingReminderCount: 21)

        XCTAssertFalse(state.shouldRefresh(storedSignature: state.signature))
    }

    func testDashboardMetricsSnapshotMatchesExpectedCounts() {
        let calendar = Calendar.gregorian
        let now = calendar.date(from: DateComponents(year: 2026, month: 3, day: 27, hour: 12)) ?? Date()
        let monthlyRequired = makeObservance(id: "required-1", date: calendar.date(from: DateComponents(year: 2026, month: 3, day: 26)) ?? now, obligation: .mandatory)
        let monthlyOptional = makeObservance(id: "optional-1", date: calendar.date(from: DateComponents(year: 2026, month: 3, day: 24)) ?? now, obligation: .optional)
        let monthlyMissed = makeObservance(id: "missed-1", date: calendar.date(from: DateComponents(year: 2026, month: 3, day: 23)) ?? now, obligation: .mandatory)
        let olderOptional = makeObservance(id: "optional-older", date: calendar.date(from: DateComponents(year: 2026, month: 2, day: 12)) ?? now, obligation: .optional)
        let notApplicable = makeObservance(id: "not-applicable", date: calendar.date(from: DateComponents(year: 2026, month: 3, day: 25)) ?? now, obligation: .notApplicable)
        let twoHours = TimeInterval(2 * 3600)
        let threeHours = TimeInterval(3 * 3600)
        let fourHours = TimeInterval(4 * 3600)
        let fiveHours = TimeInterval(5 * 3600)
        let sixHours = TimeInterval(6 * 3600)
        let statuses: [String: CompletionStatus] = [
            monthlyRequired.id: .completed,
            monthlyOptional.id: .substituted,
            monthlyMissed.id: .missed,
            olderOptional.id: .dispensed,
        ]
        let sessions = [
            IntermittentFastSession(
                id: "session-1",
                start: now.addingTimeInterval(-twoHours),
                end: now.addingTimeInterval(-TimeInterval(3600)),
                targetHours: 1),
            IntermittentFastSession(
                id: "session-2",
                start: now.addingTimeInterval(-fourHours),
                end: now.addingTimeInterval(-threeHours),
                targetHours: 2),
            IntermittentFastSession(
                id: "session-3",
                start: now.addingTimeInterval(-sixHours),
                end: now.addingTimeInterval(-fiveHours),
                targetHours: 1),
        ]

        let snapshot = DashboardMetricsSnapshot.build(
            observances: [monthlyRequired, monthlyOptional, monthlyMissed, olderOptional, notApplicable],
            statusesByID: statuses,
            sessions: sessions,
            now: now,
            calendar: calendar)

        XCTAssertEqual(snapshot.monthlyCompletionCount, 2)
        XCTAssertEqual(snapshot.yearlyRequiredCompletions, 1)
        XCTAssertEqual(snapshot.yearlyOptionalCompletions, 2)
        XCTAssertEqual(snapshot.weeklyActionableCount, 3)
        XCTAssertEqual(snapshot.weeklyCompletedCount, 2)
        XCTAssertEqual(snapshot.intermittentHitRatePercent, 67)
    }

    private func makeObservance(
        id: String,
        date: Date,
        obligation: Observance.Obligation,
        kind: Observance.Kind = .fridayPenance) -> Observance
    {
        Observance(
            id: id,
            title: id,
            date: date,
            kind: kind,
            obligation: obligation,
            detail: nil,
            rationale: "Test rationale",
            citations: [],
            ruleVersion: "test")
    }
}
