import Foundation
import SwiftUI
import WidgetKit

private struct FastingEntry: TimelineEntry {
    let date: Date
    let todayTitle: String
    let todayObligation: String
    let nextRequiredTitle: String
    let nextRequiredDate: Date?
    let hasActiveIntermittentFast: Bool
    let activeIntermittentFastStart: Date?
    let activeIntermittentTargetHours: Int
    let localizationCode: String

    var activeIntermittentTargetDate: Date? {
        WidgetActiveFastTiming.targetDate(
            isActive: hasActiveIntermittentFast,
            start: activeIntermittentFastStart,
            targetHours: activeIntermittentTargetHours)
    }

    func hasReachedActiveIntermittentTarget(at date: Date) -> Bool {
        guard let activeIntermittentTargetDate else { return false }
        return date >= activeIntermittentTargetDate
    }
}

private struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> FastingEntry {
        fallbackEntry(at: .now)
    }

    func getSnapshot(in _: Context, completion: @escaping (FastingEntry) -> Void) {
        let now = Date.now
        completion(loadEntry(at: now))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<FastingEntry>) -> Void) {
        let now = Date.now
        let entry = loadEntry(at: now)
        let refresh = WidgetTimelineSchedule.nextRefreshDate(
            after: now,
            activeFastTargetDate: entry.activeIntermittentTargetDate)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func loadEntry(at date: Date) -> FastingEntry {
        guard let snapshot = WidgetSnapshotStore.load() else {
            return fallbackEntry(at: date)
        }
        guard snapshot.isCurrent(at: date) else {
            return fallbackEntry(
                at: date,
                localizationCode: snapshot.localizationCode,
                activeFastStart: snapshot.hasActiveIntermittentFast ? snapshot.activeIntermittentFastStart : nil,
                activeFastTargetHours: snapshot.activeIntermittentTargetHours)
        }

        return FastingEntry(
            date: date,
            todayTitle: snapshot.todayTitle,
            todayObligation: snapshot.todayObligation,
            nextRequiredTitle: snapshot.nextRequiredTitle,
            nextRequiredDate: snapshot.nextRequiredDate,
            hasActiveIntermittentFast: snapshot.hasActiveIntermittentFast,
            activeIntermittentFastStart: snapshot.activeIntermittentFastStart,
            activeIntermittentTargetHours: snapshot.activeIntermittentTargetHours,
            localizationCode: snapshot.localizationCode)
    }

    private func fallbackEntry(
        at date: Date,
        localizationCode: String? = WidgetSnapshotStore.fallbackLocalizationCode(),
        activeFastStart: Date? = nil,
        activeFastTargetHours: Int = 16) -> FastingEntry
    {
        let resolvedLocalizationCode = localizationCode ?? Locale.current.identifier
        return FastingEntry(
            date: date,
            todayTitle: WidgetLocalization.text(
                "widget.fallback.today.title",
                default: "No observance today",
                code: resolvedLocalizationCode),
            todayObligation: WidgetLocalization.text(
                "widget.fallback.today.obligation",
                default: "No obligation",
                code: resolvedLocalizationCode),
            nextRequiredTitle: WidgetLocalization.text(
                "widget.fallback.next_required",
                default: "No upcoming required observance",
                code: resolvedLocalizationCode),
            nextRequiredDate: nil,
            hasActiveIntermittentFast: activeFastStart != nil,
            activeIntermittentFastStart: activeFastStart,
            activeIntermittentTargetHours: activeFastTargetHours,
            localizationCode: resolvedLocalizationCode)
    }
}

enum WidgetLocalization {
    static func text(_ key: String, default defaultValue: String, code: String? = nil) -> String {
        let requestedCode = code ?? Locale.current.identifier
        for candidate in WidgetLocalizationCode.candidates(for: requestedCode) {
            if let path = Bundle.main.path(forResource: candidate, ofType: "lproj"),
               let bundle = Bundle(path: path)
            {
                return NSLocalizedString(
                    key, tableName: "Localizable", bundle: bundle, value: defaultValue, comment: "")
            }
        }
        return NSLocalizedString(key, tableName: "Localizable", bundle: .main, value: defaultValue, comment: "")
    }
}

private struct CatholicFastingWidgetView: View {
    let entry: FastingEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                mediumContent
            default:
                smallContent
            }
        }
        .widgetURL(URL(string: entry.hasActiveIntermittentFast ? "catholicfasting://intermittent" : "catholicfasting://today"))
        .containerBackground(.fill.tertiary, for: .widget)
        .environment(\.locale, widgetLocale)
        .accessibilityElement(children: .contain)
    }

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            Label(
                WidgetLocalization.text("widget.section.today", default: "Today", code: entry.localizationCode),
                systemImage: entry.hasActiveIntermittentFast ? "timer" : "cross.case.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(secondaryStyle)
                .widgetAccentable()
            Text(entry.todayObligation)
                .font(.system(.headline, design: .serif).weight(.bold))
                .lineLimit(3)
            Spacer(minLength: 0)
            if entry.hasActiveIntermittentFast {
                activeFastStatus
            } else {
                Text(entry.todayTitle)
                    .font(.caption)
                    .foregroundStyle(secondaryStyle)
                    .lineLimit(2)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(smallAccessibilityLabel)
    }

    private var mediumContent: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(WidgetLocalization.text("widget.section.today.upper", default: "TODAY", code: entry.localizationCode))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(secondaryStyle)
                Text(entry.todayObligation)
                    .font(.system(.headline, design: .serif).weight(.bold))
                    .lineLimit(3)
                    .layoutPriority(2)
                Text(entry.todayTitle)
                    .font(.caption)
                    .foregroundStyle(secondaryStyle)
                    .lineLimit(2)
                if entry.hasActiveIntermittentFast {
                    activeFastStatus
                        .layoutPriority(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            VStack(alignment: .leading, spacing: 7) {
                Text(WidgetLocalization.text(
                    "widget.section.next_required.upper", default: "NEXT REQUIRED", code: entry.localizationCode))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(secondaryStyle)
                Text(entry.nextRequiredTitle)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(3)
                if let nextRequiredDate = entry.nextRequiredDate {
                    Text(nextRequiredDate, format: .dateTime.month(.abbreviated).day())
                        .font(.caption)
                        .foregroundStyle(secondaryStyle)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
    }

    private var secondaryStyle: AnyShapeStyle {
        if renderingMode == .fullColor, !isLuminanceReduced {
            AnyShapeStyle(.secondary)
        } else {
            AnyShapeStyle(.primary.opacity(0.82))
        }
    }

    private var widgetLocale: Locale {
        Locale(identifier: WidgetLocalizationCode.resolvedSupportedCode(for: entry.localizationCode))
    }

    private var smallAccessibilityLabel: String {
        var parts = [
            "\(WidgetLocalization.text("widget.section.today", default: "Today", code: entry.localizationCode)): \(entry.todayObligation)",
            entry.todayTitle,
        ]
        if entry.hasActiveIntermittentFast {
            parts.append(activeFastAccessibilityStatus)
        }
        return parts.joined(separator: ". ")
    }

    private var activeFastAccessibilityStatus: String {
        guard let target = entry.activeIntermittentTargetDate else {
            return WidgetLocalization.text(
                "widget.fast.active",
                default: "Fast active",
                code: entry.localizationCode)
        }
        if entry.hasReachedActiveIntermittentTarget(at: entry.date) {
            return WidgetLocalization.text(
                "widget.fast.target_reached",
                default: "Fast target reached",
                code: entry.localizationCode)
        }

        let targetTime = target.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened)
                .locale(widgetLocale))
        let format = WidgetLocalization.text(
            "widget.fast.active_target",
            default: "Fast active. Target %@",
            code: entry.localizationCode)
        return String(format: format, locale: widgetLocale, targetTime)
    }

    @ViewBuilder
    private var activeFastStatus: some View {
        if let target = entry.activeIntermittentTargetDate {
            if !entry.hasReachedActiveIntermittentTarget(at: entry.date) {
                HStack(spacing: 4) {
                    Text(WidgetLocalization.text(
                        "widget.fast.active", default: "Fast active", code: entry.localizationCode))
                    Text(target, style: .timer)
                        .monospacedDigit()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(secondaryStyle)
                .lineLimit(2)
            } else {
                Text(WidgetLocalization.text(
                    "widget.fast.target_reached", default: "Fast target reached", code: entry.localizationCode))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(secondaryStyle)
                    .lineLimit(2)
            }
        } else {
            Text(WidgetLocalization.text(
                "widget.fast.active", default: "Fast active", code: entry.localizationCode))
                .font(.caption.weight(.semibold))
                .foregroundStyle(secondaryStyle)
                .lineLimit(2)
        }
    }
}

struct CatholicFastingWidget: Widget {
    let kind: String = WidgetSnapshotContract.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CatholicFastingWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.configuration.name")
        .description("widget.configuration.description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
