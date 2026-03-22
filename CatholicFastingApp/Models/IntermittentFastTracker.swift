@preconcurrency import Foundation
import os
import SwiftUI
#if canImport(ActivityKit) && os(iOS)
import ActivityKit
#endif

struct IntermittentFastSession: Identifiable, Hashable {
    let id: String
    let start: Date
    let end: Date
    let targetHours: Int

    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    var completedTarget: Bool {
        duration >= TimeInterval(targetHours * 3600)
    }
}

final class IntermittentFastTracker: ObservableObject {
    @Published private(set) var sessions: [IntermittentFastSession] = []
    @Published private(set) var activeStart: Date?
    @Published private(set) var presetHours: Int = 16

    private let sessionsKey = SyncStoreKeys.intermittentFastSessions
    private let metaKey = SyncStoreKeys.intermittentFastMeta
    private static let activeStartMetaField = "active_start"
    private static let presetHoursMetaField = "preset_hours"
    private static let defaultPresetHours = 16
    private static let minPresetHours = 12
    private static let maxPresetHours = 336
    private static let maxStoredSessions = 500

    init() {
        StorageSchema.migrateIfNeeded()
        loadFromStore()
    }

    func startFast(now: Date = Date()) {
        guard activeStart == nil else { return }
        activeStart = now
        persistMeta()
        #if canImport(ActivityKit) && os(iOS)
        let targetHours = presetHours
        Task {
            await IntermittentFastLiveActivityManager.start(start: now, targetHours: targetHours)
        }
        #endif
    }

    func endFast(now: Date = Date()) {
        guard let start = activeStart, now > start else { return }
        let session = IntermittentFastSession(
            id: UUID().uuidString,
            start: start,
            end: now,
            targetHours: presetHours)
        sessions.insert(session, at: 0)
        if sessions.count > Self.maxStoredSessions {
            sessions = Array(sessions.prefix(Self.maxStoredSessions))
        }
        activeStart = nil
        persistSessions()
        persistMeta()
        #if canImport(ActivityKit) && os(iOS)
        Task {
            await IntermittentFastLiveActivityManager.endAll()
        }
        #endif
    }

    func cancelActiveFast() {
        activeStart = nil
        persistMeta()
        #if canImport(ActivityKit) && os(iOS)
        Task {
            await IntermittentFastLiveActivityManager.endAll()
        }
        #endif
    }

    func setPresetHours(_ hours: Int) {
        presetHours = Self.boundedPresetHours(hours)
        persistMeta()
        #if canImport(ActivityKit) && os(iOS)
        if let activeStart {
            let targetHours = presetHours
            Task {
                await IntermittentFastLiveActivityManager.update(start: activeStart, targetHours: targetHours)
            }
        }
        #endif
    }

    func clearAll() {
        sessions.removeAll()
        activeStart = nil
        presetHours = Self.defaultPresetHours
        SyncedStore.persist([String: String](), for: sessionsKey)
        SyncedStore.persist([String: String](), for: metaKey)
    }

    func exportPayload() -> [String: Any] {
        let formatter = Self.makeISO8601Formatter()
        return [
            "preset_hours": presetHours,
            "active_start": activeStart.map { formatter.string(from: $0) } ?? "",
            "session_count": sessions.count,
            "sessions": sessions.prefix(50).map { session in
                [
                    "id": session.id,
                    "start": formatter.string(from: session.start),
                    "end": formatter.string(from: session.end),
                    "target_hours": session.targetHours,
                    "duration_hours": round((session.duration / 3600) * 100) / 100,
                ]
            },
        ]
    }

    private func loadFromStore() {
        let rawSessions = SyncedStore.mergedStringDictionary(for: sessionsKey)
        sessions = rawSessions.compactMap { decodeSession(id: $0.key, raw: $0.value) }
            .sorted { $0.start > $1.start }
        if sessions.count > Self.maxStoredSessions {
            sessions = Array(sessions.prefix(Self.maxStoredSessions))
        }

        let meta = SyncedStore.mergedStringDictionary(for: metaKey)
        if let activeRaw = meta[Self.activeStartMetaField], let parsed = Self.decodeDate(activeRaw) {
            activeStart = parsed
        } else {
            activeStart = nil
        }
        if let presetRaw = meta[Self.presetHoursMetaField], let parsedPreset = Int(presetRaw) {
            presetHours = Self.boundedPresetHours(parsedPreset)
        } else {
            presetHours = Self.defaultPresetHours
        }
    }

    private func persistSessions() {
        var raw: [String: String] = [:]
        for session in sessions.prefix(Self.maxStoredSessions) {
            if let encoded = encodeSession(session) {
                raw[session.id] = encoded
            }
        }
        SyncedStore.persist(raw, for: sessionsKey)
    }

    private func persistMeta() {
        var meta: [String: String] = [
            Self.presetHoursMetaField: String(presetHours),
        ]
        if let activeStart {
            meta[Self.activeStartMetaField] = Self.encodeDate(activeStart)
        }
        SyncedStore.persist(meta, for: metaKey)
    }

    private func encodeSession(_ session: IntermittentFastSession) -> String? {
        let payload = SessionPayload(
            start: Self.encodeDate(session.start),
            end: Self.encodeDate(session.end),
            targetHours: session.targetHours)
        guard
            let data = try? JSONEncoder().encode(payload),
            let text = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return text
    }

    private func decodeSession(id: String, raw: String) -> IntermittentFastSession? {
        guard
            let data = raw.data(using: .utf8),
            let payload = try? JSONDecoder().decode(SessionPayload.self, from: data),
            let start = Self.decodeDate(payload.start),
            let end = Self.decodeDate(payload.end)
        else {
            return nil
        }
        return IntermittentFastSession(id: id, start: start, end: end, targetHours: payload.targetHours)
    }

    private struct SessionPayload: Codable {
        let start: String
        let end: String
        let targetHours: Int
    }

    private static func makeISO8601Formatter() -> ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }

    private static func encodeDate(_ date: Date) -> String {
        makeISO8601Formatter().string(from: date)
    }

    private static func decodeDate(_ raw: String) -> Date? {
        makeISO8601Formatter().date(from: raw)
    }

    private static func boundedPresetHours(_ hours: Int) -> Int {
        min(maxPresetHours, max(minPresetHours, hours))
    }
}

extension IntermittentFastTracker: @unchecked Sendable {}

#if canImport(ActivityKit) && os(iOS)
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
