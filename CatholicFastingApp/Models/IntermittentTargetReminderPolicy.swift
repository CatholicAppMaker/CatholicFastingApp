@preconcurrency import Foundation

enum IntermittentTargetReminderPolicy {
    static let identifierPrefix = "intermittent-target-"

    static func identifier(start: Date) -> String {
        "\(identifierPrefix)\(Int(start.timeIntervalSince1970))"
    }
}
