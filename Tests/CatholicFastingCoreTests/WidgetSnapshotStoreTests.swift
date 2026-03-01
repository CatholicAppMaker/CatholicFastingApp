@testable import CatholicFastingCore
import Foundation
import XCTest

final class WidgetSnapshotStoreTests: XCTestCase {
  override func setUp() {
    super.setUp()
    beginStoreIsolation()
    resetStores()
    UserDefaults(suiteName: "group.com.kevpierce.CatholicFastingApp")?.removeObject(forKey: "widget_snapshot")
  }

  override func tearDown() {
    UserDefaults(suiteName: "group.com.kevpierce.CatholicFastingApp")?.removeObject(forKey: "widget_snapshot")
    resetStores()
    endStoreIsolation()
    super.tearDown()
  }

  func testWidgetSnapshotRoundTrip() {
    let generatedAt = Date(timeIntervalSince1970: 1_726_500_000)
    let nextRequiredDate = Date(timeIntervalSince1970: 1_726_600_000)
    let snapshot = WidgetSnapshot(
      generatedAt: generatedAt,
      todayTitle: "Ash Wednesday",
      todayObligation: "Required",
      nextRequiredTitle: "Good Friday",
      nextRequiredDate: nextRequiredDate,
      completionRate: 0.72,
      hasActiveIntermittentFast: true,
      activeIntermittentFastStart: generatedAt,
      activeIntermittentTargetHours: 16
    )

    WidgetSnapshotStore.persist(snapshot)
    let loaded = WidgetSnapshotStore.load()

    XCTAssertEqual(loaded, snapshot)
  }

  func testWidgetSnapshotOverwritePersistsLatestValue() {
    let initial = WidgetSnapshot(
      generatedAt: Date(timeIntervalSince1970: 1_726_500_000),
      todayTitle: "No observance today",
      todayObligation: "No obligation",
      nextRequiredTitle: "No upcoming required observance",
      nextRequiredDate: nil,
      completionRate: 0,
      hasActiveIntermittentFast: false,
      activeIntermittentFastStart: nil,
      activeIntermittentTargetHours: 16
    )
    let updated = WidgetSnapshot(
      generatedAt: Date(timeIntervalSince1970: 1_726_700_000),
      todayTitle: "Good Friday",
      todayObligation: "Required",
      nextRequiredTitle: "Holy Saturday",
      nextRequiredDate: Date(timeIntervalSince1970: 1_726_786_400),
      completionRate: 0.95,
      hasActiveIntermittentFast: false,
      activeIntermittentFastStart: nil,
      activeIntermittentTargetHours: 20
    )

    WidgetSnapshotStore.persist(initial)
    WidgetSnapshotStore.persist(updated)

    XCTAssertEqual(WidgetSnapshotStore.load(), updated)
  }
}
