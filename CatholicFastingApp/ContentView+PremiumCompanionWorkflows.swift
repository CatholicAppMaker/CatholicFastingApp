import SwiftUI

extension ContentView {
    private func localizedVirtueLabel(_ virtue: String) -> String {
        switch virtue {
        case "Temperance":
            localized("premium.virtue.temperance", default: "Temperance")
        case "Patience":
            localized("premium.virtue.patience", default: "Patience")
        case "Charity":
            localized("premium.virtue.charity", default: "Charity")
        case "Humility":
            localized("premium.virtue.humility", default: "Humility")
        case "Obedience":
            localized("premium.virtue.obedience", default: "Obedience")
        default:
            virtue
        }
    }

    var premiumChecklistSection: some View {
        Section(localized("premium.checklist.section", default: "Consistency Checklist")) {
            Text(localized("premium.checklist.intro", default: "Keep one clear next step visible instead of carrying the whole season in your head."))
                .font(.caption)
                .foregroundStyle(.secondary)
            if !monetizationStore.premiumUnlocked {
                Text(localized("premium.checklist.unlock_hint", default: "Unlock Premium to keep a focused consistency checklist."))
                    .foregroundStyle(.secondary)
            } else {
                if premiumSession.checklist.isEmpty {
                    Text(localized("premium.checklist.empty", default: "No checklist items yet. Add one to keep your next Catholic fasting step visible."))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(premiumSession.checklist) { item in
                        Button {
                            toggleChecklistItem(item.id)
                        } label: {
                            HStack {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isDone ? CatholicTheme.successForeground : .secondary)
                                Text(item.title)
                                    .strikethrough(item.isDone, color: .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("premium.checklist.\(item.id)")
                    }
                }
                Button(localized("premium.checklist.add_suggested", default: "Add Suggested Checklist Item")) {
                    premiumSession.checklist.append(
                        PremiumChecklistItem(
                            id: UUID().uuidString,
                            title: localized("premium.checklist.suggested_item", default: "Review upcoming required observances for next 30 days"),
                            isDone: false))
                }
                .appSecondaryButtonStyle()
            }
        }
    }

    var reflectionJournalSection: some View {
        Section(localized("premium.journal.section", default: "Reflection & Review (Local)")) {
            if !monetizationStore.premiumUnlocked {
                Text(localized("premium.journal.unlock_hint", default: "Premium unlocks local reflection and review tools."))
                    .foregroundStyle(.secondary)
            } else {
                Text(localized("premium.journal.intro", default: "Keep reflections short. The goal is consistency, not long journaling."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(localized("premium.journal.title_placeholder", default: "Reflection title"), text: $premiumPresentation.newReflectionTitle)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("premium.journal.title")
                TextField(localized("premium.journal.body_placeholder", default: "Write a short reflection"), text: $premiumPresentation.newReflectionBody, axis: .vertical)
                    .lineLimit(2 ... 5)
                    .accessibilityIdentifier("premium.journal.body")
                Button(localized("premium.journal.save", default: "Save Reflection")) {
                    addReflectionEntry()
                }
                .appPrimaryButtonStyle()
                .disabled(!canSaveReflection)
                .accessibilityIdentifier("premium.journal.save")

                if premiumSession.reflections.isEmpty {
                    Text(localized("premium.journal.empty", default: "No reflections yet. Capture one short line after your fast to build a faithful habit."))
                        .foregroundStyle(.secondary)
                } else {
                    DisclosureGroup(localized("premium.journal.recent", default: "Recent reflections")) {
                        ForEach(premiumSession.reflections.prefix(5)) { entry in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.title)
                                    .font(.subheadline.weight(.semibold))
                                Text(entry.body)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                ShareLink(item: seasonPlanExportText) {
                    Label(localized("premium.journal.export_plan", default: "Export Season Plan (Text)"), systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)
            }
        }
    }

    var premiumReflectionPromptSection: some View {
        Section(localized("premium.reflection.section", default: "Daily Premium Reflection")) {
            Text(premiumReflection.title)
                .font(.subheadline.weight(.semibold))
            Text(premiumReflection.body)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(localizedFormat("premium.reflection.action_format", default: "Action: %@", premiumReflection.action))
                .font(.caption)
                .foregroundStyle(CatholicTheme.primary)
        }
        .accessibilityIdentifier("premium.reflection")
    }

    var premiumVirtueTrackingSection: some View {
        Section(localized("premium.virtue.section", default: "Virtue Check-ins")) {
            Text(localized("premium.virtue.intro", default: "Use one short note to connect fasting effort with a concrete virtue."))
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker(localized("premium.virtue.picker", default: "Virtue"), selection: $premiumPresentation.selectedVirtue) {
                ForEach(["Temperance", "Patience", "Charity", "Humility", "Obedience"], id: \.self) { virtue in
                    Text(localizedVirtueLabel(virtue)).tag(virtue)
                }
            }
            .pickerStyle(.menu)

            TextField(localized("premium.virtue.note_placeholder", default: "Virtue note"), text: $premiumPresentation.newVirtueNote, axis: .vertical)
                .lineLimit(2 ... 4)
            Button(localized("premium.virtue.log", default: "Log Virtue Check-in")) {
                addPremiumVirtueLog()
            }
            .appPrimaryButtonStyle(legacyTint: CatholicTheme.accentForeground)
            .disabled(premiumPresentation.newVirtueNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if premiumSession.companion.virtueLogs.isEmpty {
                Text(localized("premium.virtue.empty", default: "No virtue check-ins yet."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(premiumSession.companion.virtueLogs.prefix(5)) { log in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(localizedVirtueLabel(log.virtue)) • \(log.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption.weight(.semibold))
                            Text(log.note)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(role: .destructive) {
                            deletePremiumVirtueLog(log)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .accessibilityIdentifier("premium.virtue")
    }
}
