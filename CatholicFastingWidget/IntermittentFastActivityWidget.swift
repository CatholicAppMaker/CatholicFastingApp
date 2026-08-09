import ActivityKit
import SwiftUI
import WidgetKit

struct IntermittentFastActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let start: Date
        let targetDate: Date
        let targetHours: Int
    }

    let title: String
    let localizationCode: String?
}

struct IntermittentFastActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IntermittentFastActivityAttributes.self) { context in
            IntermittentFastActivityLockScreen(context: context)
                .activityBackgroundTint(Color(red: 0.97, green: 0.95, blue: 0.89))
                .activitySystemActionForegroundColor(Color(red: 0.42, green: 0.08, blue: 0.12))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(
                        IntermittentFastActivityLocalization.text(
                            "fast.live_activity.elapsed",
                            default: "Elapsed",
                            code: context.attributes.localizationCode),
                        systemImage: "timer")
                        .font(.caption.weight(.semibold))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    IntermittentFastActivityTimer(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.title)
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    IntermittentFastActivityStatus(context: context)
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .accessibilityLabel(
                        IntermittentFastActivityLocalization.text(
                            "fast.live_activity.title",
                            default: "Personal Fast",
                            code: context.attributes.localizationCode))
            } compactTrailing: {
                IntermittentFastActivityTimer(context: context)
                    .font(.caption2.monospacedDigit())
            } minimal: {
                Image(systemName: "timer")
                    .accessibilityLabel(
                        IntermittentFastActivityLocalization.text(
                            "fast.live_activity.title",
                            default: "Personal Fast",
                            code: context.attributes.localizationCode))
            }
            .widgetURL(URL(string: "catholicfasting://intermittent"))
            .keylineTint(Color(red: 0.42, green: 0.08, blue: 0.12))
        }
    }
}

private struct IntermittentFastActivityLockScreen: View {
    let context: ActivityViewContext<IntermittentFastActivityAttributes>

    private var targetReached: Bool {
        context.state.targetDate <= Date.now
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: targetReached ? "checkmark.circle.fill" : "timer")
                    .foregroundStyle(Color(red: 0.42, green: 0.08, blue: 0.12))
                Text(context.attributes.title)
                    .font(.headline.weight(.semibold))
                Spacer(minLength: 8)
                Text("\(context.state.targetHours)h")
                    .font(.subheadline.weight(.semibold).monospacedDigit())
            }

            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(
                        IntermittentFastActivityLocalization.text(
                            targetReached
                                ? "fast.live_activity.target_reached"
                                : "fast.live_activity.fasting",
                            default: targetReached ? "Target reached" : "Fasting in progress",
                            code: context.attributes.localizationCode))
                        .font(.subheadline.weight(.semibold))
                    Text(
                        IntermittentFastActivityLocalization.text(
                            targetReached
                                ? "fast.live_activity.end_anytime"
                                : "fast.live_activity.keep_going",
                            default: targetReached
                                ? "You can end the fast when ready."
                                : "Keep going to complete this plan.",
                            code: context.attributes.localizationCode))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 12)
                IntermittentFastActivityTimer(context: context)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }

            HStack {
                Text(
                    IntermittentFastActivityLocalization.text(
                        "fast.live_activity.started",
                        default: "Started",
                        code: context.attributes.localizationCode))
                Text(context.state.start, style: .time)
                Spacer(minLength: 8)
                Text(
                    IntermittentFastActivityLocalization.text(
                        "fast.live_activity.target",
                        default: "Target",
                        code: context.attributes.localizationCode))
                Text(context.state.targetDate, style: .time)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .environment(
            \.locale,
            IntermittentFastActivityLocalization.locale(for: context.attributes.localizationCode))
    }
}

private struct IntermittentFastActivityStatus: View {
    let context: ActivityViewContext<IntermittentFastActivityAttributes>

    private var targetReached: Bool {
        context.state.targetDate <= Date.now
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: targetReached ? "checkmark.circle.fill" : "hourglass")
            Text(
                IntermittentFastActivityLocalization.text(
                    targetReached
                        ? "fast.live_activity.target_reached"
                        : "fast.live_activity.keep_going",
                    default: targetReached ? "Target reached" : "Keep going",
                    code: context.attributes.localizationCode))
                .font(.subheadline.weight(.semibold))
            Spacer(minLength: 8)
            IntermittentFastActivityTimer(context: context)
                .font(.subheadline.monospacedDigit())
        }
        .accessibilityElement(children: .combine)
        .environment(
            \.locale,
            IntermittentFastActivityLocalization.locale(for: context.attributes.localizationCode))
    }
}

private struct IntermittentFastActivityTimer: View {
    let context: ActivityViewContext<IntermittentFastActivityAttributes>

    private var targetReached: Bool {
        context.state.targetDate <= Date.now
    }

    var body: some View {
        Text(targetReached ? context.state.start : context.state.targetDate, style: .timer)
            .monospacedDigit()
            .accessibilityLabel(
                IntermittentFastActivityLocalization.text(
                    targetReached ? "fast.live_activity.elapsed" : "fast.live_activity.remaining",
                    default: targetReached ? "Elapsed" : "Remaining",
                    code: context.attributes.localizationCode))
            .environment(
                \.locale,
                IntermittentFastActivityLocalization.locale(for: context.attributes.localizationCode))
    }
}

private enum IntermittentFastActivityLocalization {
    static func text(_ key: String, default defaultValue: String, code: String?) -> String {
        WidgetLocalization.text(key, default: defaultValue, code: code)
    }

    static func locale(for code: String?) -> Locale {
        Locale(identifier: WidgetLocalizationCode.resolvedSupportedCode(for: code ?? "en"))
    }
}
