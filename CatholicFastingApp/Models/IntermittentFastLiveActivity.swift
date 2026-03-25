@preconcurrency import Foundation
import os

#if canImport(ActivityKit) && os(iOS)
import ActivityKit

struct IntermittentFastActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let start: Date
        let targetDate: Date
        let targetHours: Int
    }

    let title: String
}

enum IntermittentFastLiveActivityManager {
    private static let logger = Logger(
        subsystem: "com.kevpierce.CatholicFastingApp",
        category: "IntermittentFast")

    static func start(start: Date, targetHours: Int) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        await endAll()
        let attributes = IntermittentFastActivityAttributes(title: "Intermittent Fast")
        let state = IntermittentFastActivityAttributes.ContentState(
            start: start,
            targetDate: start.addingTimeInterval(TimeInterval(targetHours * 3600)),
            targetHours: targetHours)
        do {
            let content = ActivityContent(state: state, staleDate: nil)
            _ = try Activity<IntermittentFastActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil)
        } catch {
            logger.error("Live Activity start failed: \(error.localizedDescription)")
        }
    }

    static func update(start: Date, targetHours: Int) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let updated = IntermittentFastActivityAttributes.ContentState(
            start: start,
            targetDate: start.addingTimeInterval(TimeInterval(targetHours * 3600)),
            targetHours: targetHours)
        for activity in Activity<IntermittentFastActivityAttributes>.activities {
            await activity.update(ActivityContent(state: updated, staleDate: nil))
        }
    }

    static func endAll() async {
        for activity in Activity<IntermittentFastActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
#endif
