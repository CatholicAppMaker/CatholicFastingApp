import SwiftUI

extension ContentView {
    var premiumHouseholdShareSection: some View {
        Section(localized("premium.household.section", default: "Household Share (Local)")) {
            Text(localized("premium.household.intro", default: "This is a local transfer tool for households sharing one device workflow. It is not cloud sync."))
                .font(.caption)
                .foregroundStyle(.secondary)
            DisclosureGroup(localized("premium.household.group", default: "Share code tools")) {
                Button(localized("premium.household.generate", default: "Generate Local Share Code")) {
                    generatePremiumHouseholdShareCode()
                }
                .appSecondaryButtonStyle()
                if !premiumPresentation.householdExportCode.isEmpty {
                    Text(premiumPresentation.householdExportCode)
                        .font(.caption2.monospaced())
                        .textSelection(.enabled)
                }
                TextField(localized("premium.household.import.placeholder", default: "Paste household share code"), text: $premiumPresentation.householdImportCode, axis: .vertical)
                    .lineLimit(2 ... 6)
                Button(localized("premium.household.import.button", default: "Import Household Code (Local)")) {
                    importPremiumHouseholdShareCode()
                }
                .appSecondaryButtonStyle()
                .disabled(premiumPresentation.householdImportCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if !premiumPresentation.companionStatus.isEmpty {
                Text(premiumPresentation.companionStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
