import SwiftUI

extension ContentView {
    var dailyQuoteReminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                liturgicalCalendar.date(
                    from: DateComponents(
                        hour: dailyQuoteReminderHour,
                        minute: dailyQuoteReminderMinute))
                    ?? liturgicalCalendar.date(from: DateComponents(hour: 12, minute: 0))
                    ?? AppClock.now()
            },
            set: { newValue in
                let components = liturgicalCalendar.dateComponents([.hour, .minute], from: newValue)
                dailyQuoteReminderHour = components.hour ?? DefaultValues.dailyQuoteReminderHour
                dailyQuoteReminderMinute = components.minute ?? DefaultValues.dailyQuoteReminderMinute
            })
    }

    var dailyQuoteReminderRefreshState: DailyQuoteReminderRefreshState {
        DailyQuoteReminderRefreshState(
            isEnabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            locale: languageMode.contentLocale,
            consentAccepted: acceptedLegalNotice,
            notificationsAuthorized: true,
            pendingReminderCount: 0)
    }

    var activeHouseholdProfile: HouseholdProfile? {
        profileSession.householdProfiles.first(where: { $0.id == profileSession.activeHouseholdProfileID })
    }

    var currentSeasonCommitments: [SeasonCommitment] {
        planningSession.data.seasonCommitments.filter { $0.season == currentLiturgicalSeason && $0.isEnabled }
    }

    var canAddHouseholdProfile: Bool {
        !premiumPresentation.newHouseholdProfileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canAddSeasonCommitment: Bool {
        !premiumPresentation.newSeasonCommitmentTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canSaveReflection: Bool {
        !premiumPresentation.newReflectionTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !premiumPresentation.newReflectionBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addSeasonCommitment() {
        let title = premiumPresentation.newSeasonCommitmentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        planningSession.data.seasonCommitments.append(
            SeasonCommitment(
                id: UUID().uuidString,
                season: currentLiturgicalSeason,
                title: title,
                isEnabled: true))
        premiumPresentation.newSeasonCommitmentTitle = ""
    }

    func addHouseholdProfile() {
        let name = premiumPresentation.newHouseholdProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let profile = HouseholdProfile(
            id: UUID().uuidString,
            name: name,
            isAge14OrOlderForAbstinence: age14OrOlderForAbstinence,
            isAge18OrOlderForFasting: age18OrOlderForFasting,
            medicalDispensation: medicalDispensation)
        profileSession.householdProfiles.append(profile)
        profileSession.activeHouseholdProfileID = profile.id
        premiumPresentation.newHouseholdProfileName = ""
    }

    func applyActiveHouseholdProfile() {
        guard let profile = activeHouseholdProfile else { return }
        age14OrOlderForAbstinence = profile.isAge14OrOlderForAbstinence
        age18OrOlderForFasting = profile.isAge18OrOlderForFasting
        medicalDispensation = profile.medicalDispensation
    }

    func ensureActiveHouseholdProfileSelection() {
        guard profileSession.activeHouseholdProfileID.isEmpty else { return }
        if let firstProfile = profileSession.householdProfiles.first {
            profileSession.activeHouseholdProfileID = firstProfile.id
        } else {
            profileSession.activeHouseholdProfileID = ""
        }
    }

    func applyReminderTier(_ tier: ReminderTier) {
        reminderTierRaw = tier.rawValue
        dailyReminderSupportEnabled = tier.supportEnabled
        morningReminderEnabled = tier.morningEnabled
        eveningReminderEnabled = tier.eveningEnabled
        launchFunnelSnapshot.selectedReminderTierRaw = tier.rawValue
    }

    func scheduleDailyQuoteReminderFromCurrentSettings() async {
        let refreshState = dailyQuoteReminderRefreshState
        feedback.notificationStatus = await ReminderScheduler.scheduleDailyQuoteReminder(
            enabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            languageMode: languageMode)
        dailyQuoteReminderSignature = refreshState.signature
    }

    func refreshDailyQuoteReminderIfNeeded() async {
        let pendingReminderCount = await ReminderScheduler.pendingDailyQuoteReminderCount()
        let notificationsAuthorized = await ReminderScheduler.notificationsAuthorizedForScheduling()
        let refreshState = DailyQuoteReminderRefreshState(
            isEnabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            locale: languageMode.contentLocale,
            consentAccepted: acceptedLegalNotice,
            notificationsAuthorized: notificationsAuthorized,
            pendingReminderCount: pendingReminderCount)

        guard refreshState.shouldRefresh(storedSignature: dailyQuoteReminderSignature) else {
            return
        }

        feedback.notificationStatus = await ReminderScheduler.scheduleDailyQuoteReminder(
            enabled: dailyQuoteReminderEnabled,
            hour: dailyQuoteReminderHour,
            minute: dailyQuoteReminderMinute,
            languageMode: languageMode)
        dailyQuoteReminderSignature = refreshState.signature
    }

    func syncReminderTierFromCurrentToggleState() {
        let inferred = ReminderTier.infer(
            supportEnabled: dailyReminderSupportEnabled,
            morningEnabled: morningReminderEnabled,
            eveningEnabled: eveningReminderEnabled)
        if reminderTierRaw != inferred.rawValue {
            reminderTierRaw = inferred.rawValue
        }
        launchFunnelSnapshot.selectedReminderTierRaw = reminderTierRaw
    }

    func addReflectionEntry() {
        let title = premiumPresentation.newReflectionTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = premiumPresentation.newReflectionBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty || !body.isEmpty else { return }
        premiumSession.reflections.insert(
            ReflectionJournalEntry(
                id: UUID().uuidString,
                createdAt: Date(),
                title: title.isEmpty
                    ? localized("premium.journal.default_title", default: "Reflection")
                    : title,
                body: body),
            at: 0)
        premiumPresentation.newReflectionTitle = ""
        premiumPresentation.newReflectionBody = ""
    }

    func toggleChecklistItem(_ itemID: String) {
        guard let index = premiumSession.checklist.firstIndex(where: { $0.id == itemID }) else { return }
        premiumSession.checklist[index].isDone.toggle()
    }
}
