import SwiftUI

struct FastingIntentionOption: Identifiable {
    let id: String
    let label: String
    let detail: String
}

struct IntermittentFastTargetOption: Identifiable {
    let hours: Int
    let title: String
    let detail: String

    var id: Int {
        hours
    }
}

enum IntermittentFastControlPresentation: Equatable {
    case phone
    case pad

    var columns: [GridItem] {
        switch self {
        case .phone:
            [GridItem(.adaptive(minimum: 92), spacing: 8)]
        case .pad:
            Array(repeating: GridItem(.flexible()), count: 3)
        }
    }

    var gridSpacing: CGFloat {
        self == .phone ? 8 : 10
    }

    var minimumTileHeight: CGFloat {
        self == .phone ? 58 : 72
    }

    var tileCornerRadius: CGFloat {
        self == .phone ? 14 : 16
    }
}

struct IntermittentFastQuickTargetGrid: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let options: [IntermittentFastTargetOption]
    @Binding var selectedHours: Int
    let presentation: IntermittentFastControlPresentation
    let pickerIdentifier: String
    let optionIdentifierPrefix: String

    var body: some View {
        LazyVGrid(
            columns: resolvedColumns,
            spacing: presentation.gridSpacing)
        {
            ForEach(options) { option in
                Button {
                    selectedHours = option.hours
                } label: {
                    VStack(alignment: .leading, spacing: presentation == .phone ? 3 : 4) {
                        Text(option.title)
                            .font(
                                presentation == .phone
                                    ? .system(.headline, design: .rounded).weight(.semibold)
                                    : .title3.weight(.semibold))
                        targetDetail(option.detail)
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: dynamicTypeSize.isAccessibilitySize ? nil : presentation.minimumTileHeight,
                        alignment: .leading)
                    .appInteractiveTileStyle(
                        isSelected: selectedHours == option.hours,
                        cornerRadius: presentation.tileCornerRadius)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("\(optionIdentifierPrefix).\(option.hours)")
                .appSelectedAccessibility(selectedHours == option.hours)
            }
        }
        .accessibilityIdentifier(pickerIdentifier)
    }

    private var resolvedColumns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [GridItem(.flexible())]
        }
        return presentation.columns
    }

    @ViewBuilder
    private func targetDetail(_ detail: String) -> some View {
        switch presentation {
        case .phone:
            Text(detail)
                .font(.caption2)
                .foregroundStyle(CatholicTheme.secondaryInk)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)
        case .pad:
            Text(detail)
                .appSupportingTextStyle()
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct IntermittentFastCustomTargetStepper: View {
    @Binding var targetHours: Int
    let title: String
    let detail: String
    let presentation: IntermittentFastControlPresentation
    let accessibilityIdentifier: String

    var body: some View {
        Stepper(value: $targetHours, in: 12 ... 336, step: 1) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                customTargetDetail
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder
    private var customTargetDetail: some View {
        switch presentation {
        case .phone:
            Text(detail)
                .appEyebrowStyle()
        case .pad:
            Text(detail)
                .appSupportingTextStyle()
        }
    }
}

struct IntermittentFastStartTimeControl: View {
    let label: String
    let hint: String
    @Binding var selection: Date
    let allowedRange: ClosedRange<Date>
    let locale: Locale
    let accessibilityIdentifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            DatePicker(
                label,
                selection: $selection,
                in: allowedRange,
                displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.compact)
                .environment(\.locale, locale)
                .accessibilityIdentifier(accessibilityIdentifier)

            Text(hint)
                .appSupportingTextStyle()
        }
    }
}

struct IntermittentFastIntentionControl: View {
    let label: String
    let options: [FastingIntentionOption]
    @Binding var selection: String
    let detail: String
    let pickerIdentifier: String
    let detailIdentifier: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Picker(label, selection: $selection) {
                ForEach(options) { option in
                    Text(option.label).tag(option.id)
                }
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier(pickerIdentifier)

            detailText
        }
    }

    @ViewBuilder
    private var detailText: some View {
        if let detailIdentifier {
            Text(detail)
                .appSupportingTextStyle()
                .accessibilityIdentifier(detailIdentifier)
        } else {
            Text(detail)
                .appSupportingTextStyle()
        }
    }
}

struct IntermittentFastReminderControl: View {
    @Binding var isOn: Bool
    let label: String
    let hint: String?
    let accessibilityIdentifier: String
    let onChange: () -> Void

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                if let hint {
                    Text(hint)
                        .appEyebrowStyle()
                }
            }
        }
        .onChange(of: isOn) { _, _ in
            onChange()
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct IntermittentFastActionDescriptor {
    let title: String
    let systemImage: String?
    let accessibilityIdentifier: String
}

struct IntermittentFastPrimaryActions: View {
    let isActive: Bool
    let start: IntermittentFastActionDescriptor
    let end: IntermittentFastActionDescriptor
    let cancel: IntermittentFastActionDescriptor
    let minimumHeight: CGFloat
    let onStart: () -> Void
    let onEnd: () -> Void
    let onCancel: () -> Void

    var body: some View {
        if isActive {
            HStack(spacing: 10) {
                primaryButton(end, action: onEnd)
                secondaryButton(cancel, action: onCancel)
            }
        } else {
            primaryButton(start, action: onStart)
        }
    }

    private func primaryButton(
        _ descriptor: IntermittentFastActionDescriptor,
        action: @escaping () -> Void) -> some View
    {
        Button(action: action) {
            if isActive {
                actionLabel(descriptor)
            } else {
                actionLabel(descriptor)
                    .foregroundStyle(.white)
            }
        }
        .appPrimaryButtonStyle(legacyTint: isActive ? .green : CatholicTheme.action)
        .font(.headline.weight(.semibold))
        .frame(maxWidth: .infinity, minHeight: minimumHeight)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(descriptor.accessibilityIdentifier)
    }

    private func secondaryButton(
        _ descriptor: IntermittentFastActionDescriptor,
        action: @escaping () -> Void) -> some View
    {
        Button(action: action) {
            actionLabel(descriptor)
        }
        .appSecondaryButtonStyle()
        .font(.headline.weight(.semibold))
        .frame(maxWidth: .infinity, minHeight: minimumHeight)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(descriptor.accessibilityIdentifier)
    }

    @ViewBuilder
    private func actionLabel(_ descriptor: IntermittentFastActionDescriptor) -> some View {
        if let systemImage = descriptor.systemImage {
            Label(descriptor.title, systemImage: systemImage)
        } else {
            Text(descriptor.title)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
    }
}

struct IntermittentFastFirstViewportContext: View {
    let optionalPracticeLabel: String
    let intentionText: String
    let prudenceText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(optionalPracticeLabel, systemImage: "person.crop.circle.badge.checkmark")
                .font(.caption.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
            Text(intentionText)
                .font(.subheadline.weight(.medium))
            Text(prudenceText)
                .appSupportingTextStyle()
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("intermittent.first_viewport_context")
    }
}

struct IntermittentFastMetricValue: Identifiable {
    let id: String
    let title: String
    let value: String
    var accessibilityIdentifier: String?
}

struct IntermittentFastMetricGrid: View {
    let metrics: [IntermittentFastMetricValue]
    let stacked: Bool

    var body: some View {
        if stacked {
            VStack(spacing: 8) {
                metricViews
            }
        } else {
            HStack(spacing: 8) {
                metricViews
            }
        }
    }

    private var metricViews: some View {
        ForEach(metrics) { metric in
            if let accessibilityIdentifier = metric.accessibilityIdentifier {
                IntermittentFastMetricChip(title: metric.title, value: metric.value)
                    .accessibilityIdentifier(accessibilityIdentifier)
            } else {
                IntermittentFastMetricChip(title: metric.title, value: metric.value)
            }
        }
    }
}

private struct IntermittentFastMetricChip: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.primary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .appSurfaceCard(.utility, cornerRadius: 14)
    }
}

struct IntermittentFastSessionRecapView: View {
    let recap: IntermittentFastSessionRecap
    let session: IntermittentFastSession
    let elapsedTitle: String
    let elapsedValue: String
    let targetTitle: String
    let targetValue: String
    let intentionTitle: String
    let intentionValue: String
    let savedNoteText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: recap.completedTarget ? "checkmark.seal.fill" : "arrow.clockwise.circle.fill")
                    .imageScale(.large)
                    .foregroundStyle(recap.completedTarget ? CatholicTheme.successForeground : CatholicTheme.warningForeground)
                VStack(alignment: .leading, spacing: 4) {
                    Text(recap.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(CatholicTheme.primary)
                    Text(recap.encouragement)
                        .appSupportingTextStyle()
                        .fixedSize(horizontal: false, vertical: true)
                }
                .layoutPriority(1)
                Spacer(minLength: 0)
            }

            HStack(spacing: 8) {
                recapMetric(title: elapsedTitle, value: elapsedValue)
                recapMetric(title: targetTitle, value: targetValue)
                recapMetric(title: intentionTitle, value: intentionValue)
            }

            if let savedNoteText {
                Text(savedNoteText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("intermittent.recap_note.saved")
            }

            Text(recap.suggestedNextAction)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .appSurfaceCard(.primary, cornerRadius: 16)
        .accessibilityValue(Text(session.note ?? ""))
        .accessibilityIdentifier("intermittent.recap_card")
    }

    private func recapMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .appEyebrowStyle()
                .textCase(.uppercase)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
