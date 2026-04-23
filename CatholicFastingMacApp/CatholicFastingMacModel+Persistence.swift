import Foundation

@MainActor
extension CatholicFastingMacModel {
    func wireObservedState() {
        tracker.objectWillChange
            .sink { [weak self] _ in
                self?.persistWidgetSnapshot()
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        penanceNotes.objectWillChange
            .sink { [weak self] _ in
                self?.persistWidgetSnapshot()
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        intermittentTracker.objectWillChange
            .sink { [weak self] _ in
                self?.persistWidgetSnapshot()
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        monetizationStore.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func ensureSelections() {
        if activeHouseholdProfileID.isEmpty {
            activeHouseholdProfileID = householdProfiles.first?.id ?? ""
        }
        if activeIntermittentScheduleID.isEmpty {
            activeIntermittentScheduleID = intermittentSchedules.first?.id ?? ""
        }
        if selectedObservanceID.isEmpty {
            selectedObservanceID = visibleCalendarObservances.first?.id ?? ""
        }
    }

    func persistWidgetSnapshot() {
        WidgetSnapshotStore.persist(widgetSnapshot)
    }

    func persistDefault(_ value: Any, key: String) {
        guard !isBootstrapping else { return }
        defaults.set(value, forKey: key)
        persistWidgetSnapshot()
    }

    func persistAcceptedLegalNotice() {
        guard !isBootstrapping else { return }
        defaults.set(acceptedLegalNotice, forKey: StorageKeys.acceptedLegalNotice)
        acceptedLegalNoticeAt = acceptedLegalNotice ? UIConstants.exportISO8601.string(from: Date()) : ""
        persistWidgetSnapshot()
    }

    func persistPlanningData() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.savePlanningData(planningData)
        persistWidgetSnapshot()
    }

    func persistSchedules() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.saveSchedules(intermittentSchedules)
        persistWidgetSnapshot()
    }

    func persistActiveSchedule() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.saveActiveScheduleID(activeIntermittentScheduleID.isEmpty ? nil : activeIntermittentScheduleID)
    }

    func persistProfiles() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.saveProfiles(householdProfiles)
    }

    func persistActiveProfile() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.saveActiveProfileID(activeHouseholdProfileID.isEmpty ? nil : activeHouseholdProfileID)
    }

    func persistDevotionalFavorites() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.saveDevotionalFavorites(devotionalFavorites)
    }

    func persistReflections() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.saveReflections(reflectionEntries)
    }

    func persistChecklist() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.saveChecklist(premiumChecklist)
    }

    func persistPremiumCompanion() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.savePremiumCompanionState(premiumCompanion)
        persistWidgetSnapshot()
    }

    func persistLaunchFunnelSnapshot() {
        guard !isBootstrapping else { return }
        LocalFeatureStore.saveLaunchFunnelSnapshot(launchFunnelSnapshot)
    }

    func dailyQuoteReminderStateSignature(
        isEnabled: Bool,
        hour: Int,
        minute: Int,
        locale: ContentLocale,
        consentAccepted: Bool,
        notificationsAuthorized: Bool,
        pendingReminderCount: Int) -> String
    {
        let localeLabel = switch locale {
        case .english:
            "en"
        case .spanish:
            "es"
        case .frenchCanadian:
            "fr-CA"
        }
        return [
            isEnabled ? "enabled" : "disabled",
            "\(hour)",
            "\(minute)",
            localeLabel,
            consentAccepted ? "consented" : "not-consented",
            notificationsAuthorized ? "authorized" : "not-authorized",
            "\(pendingReminderCount)",
        ].joined(separator: "|")
    }

    func jsonString(from payload: [String: Any], fallback: String) -> String {
        guard
            JSONSerialization.isValidJSONObject(payload),
            let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys]),
            let string = String(data: data, encoding: .utf8)
        else {
            return fallback
        }
        return string
    }
}
