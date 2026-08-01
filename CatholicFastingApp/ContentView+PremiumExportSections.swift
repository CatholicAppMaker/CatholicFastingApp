import SwiftUI

extension ContentView {
    var premiumExportSummarySection: some View {
        Section(localized("premium.export.section", default: "Export Summary")) {
            ShareLink(
                item: premiumDirectionSummaryText,
                subject: Text(localized("premium.export.subject", default: "Catholic Fasting Summary")),
                message: Text(localized("premium.export.message", default: "Structured fasting summary for personal review.")))
            {
                Label(localized("premium.export.button", default: "Export Fasting Summary"), systemImage: "square.and.arrow.up")
            }
            .appSecondaryButtonStyle()
            .disabled(!acceptedLegalNotice)
            .accessibilityIdentifier("premium.export_summary")

            Text(localized("premium.export.summary_note", default: "Use this when you want one concise snapshot for personal review or spiritual conversation."))
                .font(.caption)
                .foregroundStyle(.secondary)

            if !acceptedLegalNotice {
                Text(localized("premium.export.consent_note", default: "Enable consent in Privacy & Data before exporting premium summaries."))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var premiumAdvancedExportSection: some View {
        Section(localized("premium.export.advanced.section", default: "Advanced Exports")) {
            DisclosureGroup(localized("premium.export.advanced.group", default: "Weekly and monthly reports")) {
                ShareLink(
                    item: premiumWeeklySummaryText,
                    subject: Text(localized("premium.export.weekly.subject", default: "Catholic Fasting Weekly Report")),
                    message: Text(localized("premium.export.weekly.message", default: "Weekly fasting summary from Premium.")))
                {
                    Label(localized("premium.export.weekly.button", default: "Export Weekly Report"), systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)

                ShareLink(
                    item: premiumMonthlySummaryText,
                    subject: Text(localized("premium.export.monthly.subject", default: "Catholic Fasting Monthly Report")),
                    message: Text(localized("premium.export.monthly.message", default: "Monthly fasting summary from Premium.")))
                {
                    Label(localized("premium.export.monthly.button", default: "Export Monthly Report"), systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)
            }
        }
    }
}
