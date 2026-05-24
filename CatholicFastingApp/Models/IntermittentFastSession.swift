@preconcurrency import Foundation

struct IntermittentFastSession: Identifiable, Hashable {
    let id: String
    let start: Date
    let end: Date
    let targetHours: Int
    let intentionID: String?
    let note: String?

    init(
        id: String,
        start: Date,
        end: Date,
        targetHours: Int,
        intentionID: String? = nil,
        note: String? = nil)
    {
        self.id = id
        self.start = start
        self.end = end
        self.targetHours = targetHours
        self.intentionID = intentionID
        self.note = note
    }

    var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    var completedTarget: Bool {
        duration >= TimeInterval(targetHours * 3600)
    }
}
