import SwiftUI

extension ContentView {
    func fastingObservanceDetail(_ observance: Observance) -> some View {
        let context = RegionalGuidanceContextFactory.presentationContext(for: observance, settings: settings)

        return List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Text(localizedCompleteDate(observance.date))
                        .appEyebrowStyle()
                    Text(localizedObservanceTitle(observance.title))
                        .appSectionTitleStyle(serif: true)
                    HStack(spacing: 8) {
                        StatusTag(text: localizedObservanceKindLabel(observance.kind), color: observance.kind.color)
                        StatusTag(
                            text: localizedObservanceDispositionLabel(observance),
                            color: observance.obligation == .mandatory ? .red : .blue)
                    }
                    Text(context.nextActionText)
                        .appLeadTextStyle()
                        .foregroundStyle(CatholicTheme.primary)
                }
                .padding(.vertical, 4)
            }

            Section(localized("fasting_days.detail.why", default: "Why this day matters")) {
                if let detail = localizedObservanceDetail(observance), !detail.isEmpty {
                    Text(detail)
                }
                Text(localizedObservanceRationale(observance))
                    .appSupportingTextStyle()
            }

            Section(localized("fasting_days.detail.region", default: "Regional applicability")) {
                LabeledContent(localized("fasting_days.detail.profile", default: "Profile"), value: context.regionalContext.classificationLabel)
                LabeledContent(localized("fasting_days.detail.authority", default: "Authority"), value: context.regionalContext.authorityLabel)
                LabeledContent(localized("fasting_days.detail.support", default: "Rule support"), value: context.regionalContext.supportLevel.label)
                Text(context.regionalContext.disclosureText)
                    .appSupportingTextStyle()
            }

            Section(localized("fasting_days.detail.sources", default: "Sources and transparency")) {
                Text(context.sourceSummary)
                    .appSupportingTextStyle()
                ForEach(context.regionalContext.citations, id: \.self) { citation in
                    LabeledContent(citation.shortReference, value: citation.title)
                }
                if let sourceURL = context.regionalContext.sourceURL {
                    Link(localized("fasting_days.detail.open_source", default: "Open source guidance"), destination: sourceURL)
                }
            }

            Section(localized("fasting_days.detail.actions", default: "Actions")) {
                if observance.obligation != .notApplicable {
                    Picker(
                        localized("fasting_days.detail.status", default: "Observance status"),
                        selection: Binding(
                            get: { tracker.status(for: observance.id) },
                            set: { tracker.setStatus($0, for: observance.id) }))
                    {
                        ForEach(CompletionStatus.allCases) { status in
                            Text(localizedCompletionStatusLabel(status)).tag(status)
                        }
                    }
                    .accessibilityIdentifier("fasting_days.detail.status_picker")
                }

                if observance.obligation == .mandatory {
                    Button(localized("fasting_days.detail.schedule", default: "Schedule required-day reminder")) {
                        Task {
                            feedback.notificationStatus = await ReminderScheduler.schedule(observances: [observance])
                        }
                    }
                    .accessibilityIdentifier("fasting_days.detail.schedule_reminder")
                }

                Button(localized("fasting_days.detail.reminder_settings", default: "Open reminder settings")) {
                    navigateToMoreDestination(.setupAndReminders)
                }
                .accessibilityIdentifier("fasting_days.detail.reminder_settings")

                if !feedback.notificationStatus.isEmpty {
                    Text(feedback.notificationStatus)
                        .appSupportingTextStyle()
                }
            }
        }
        .listStyle(.insetGrouped)
        .appListBackground()
        .navigationTitle(localized("fasting_days.detail.title", default: "Observance"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("fasting_days.observance_detail")
    }
}
