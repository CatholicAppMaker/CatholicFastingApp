@preconcurrency import Foundation

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
