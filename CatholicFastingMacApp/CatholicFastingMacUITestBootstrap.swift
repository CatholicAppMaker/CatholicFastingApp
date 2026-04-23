import Foundation

enum CatholicFastingMacUITestBootstrap {
    static func applyLaunchOverridesIfNeeded() {
        let arguments = ProcessInfo.processInfo.arguments
        let environment = ProcessInfo.processInfo.environment
        let isUITestMode =
            arguments.contains("-uitest-reset")
                || arguments.contains("-uitest-skip-onboarding")
                || arguments.contains("-uitest-seed-deterministic")
                || arguments.contains("-uitest-seed-missed")
                || environment["UITEST_MODE"] == "1"

        guard isUITestMode else {
            return
        }

        let defaults = UserDefaults.standard
        if arguments.contains("-uitest-reset"), let bundleIdentifier = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleIdentifier)
            LocalFeatureStore.clearAll()
            WidgetSnapshotStore.clear()
            defaults.removeObject(forKey: "debug_simulator_premium_unlocked")
            clearSavedApplicationState(bundleIdentifier: bundleIdentifier)
        }

        if arguments.contains("-uitest-seed-deterministic") {
            defaults.set(true, forKey: StorageKeys.age14OrOlderForAbstinence)
            defaults.set(true, forKey: StorageKeys.age18OrOlderForFasting)
            defaults.set(false, forKey: StorageKeys.medicalDispensation)
            defaults.set(RuleSettings.AscensionObservance.sunday.rawValue, forKey: StorageKeys.ascensionObservance)
            defaults.set(RuleSettings.FridayOutsideLentMode.substitutePenance.rawValue, forKey: StorageKeys.fridayOutsideLentMode)
            defaults.set(RuleSettings.USProvincePreset.otherUSProvince.rawValue, forKey: StorageKeys.usProvincePreset)
            defaults.set(RuleSettings.CalendarMode.usccb.rawValue, forKey: StorageKeys.calendarMode)
            defaults.set(LanguageMode.english.rawValue, forKey: StorageKeys.languageMode)
            defaults.set(RuleSettings.RegionProfile.us.rawValue, forKey: StorageKeys.regionProfile)
            defaults.set(false, forKey: StorageKeys.acceptedLegalNotice)
            defaults.set("", forKey: StorageKeys.acceptedLegalNoticeAt)
            defaults.set(true, forKey: StorageKeys.liturgicalSeasonColorsEnabled)
            defaults.set(true, forKey: StorageKeys.dailyReminderSupportEnabled)
            defaults.set(true, forKey: StorageKeys.morningReminderEnabled)
            defaults.set(false, forKey: StorageKeys.eveningReminderEnabled)
            defaults.set(ReminderTier.balanced.rawValue, forKey: StorageKeys.reminderTier)
            defaults.set(3, forKey: SyncStoreKeys.storageSchemaVersion)
        }

        if let regionOverride = environment["UITEST_REGION_PROFILE"], !regionOverride.isEmpty {
            defaults.set(regionOverride, forKey: StorageKeys.regionProfile)
        }

        if let languageOverride = environment["UITEST_LANGUAGE_MODE"], !languageOverride.isEmpty {
            defaults.set(languageOverride, forKey: StorageKeys.languageMode)
        }

        if let premiumUnlockedOverride = environment["UITEST_PREMIUM_UNLOCKED"], !premiumUnlockedOverride.isEmpty {
            defaults.set(premiumUnlockedOverride == "1", forKey: "debug_simulator_premium_unlocked")
        }

        if arguments.contains("-uitest-seed-missed") {
            let settings = RuleSettings(
                birthYear: 0,
                birthMonth: 0,
                birthDay: 0,
                isAge14OrOlderForAbstinence: true,
                isAge18OrOlderForFasting: true,
                hasMedicalDispensation: false,
                ascensionObservance: .sunday,
                fridayOutsideLentMode: .substitutePenance,
                calendarMode: .usccb)
            let year = Calendar.current.component(.year, from: Date())
            let observances = ObservanceCalculator.makeCalendar(for: year, settings: settings)
            let today = Calendar.current.startOfDay(for: Date())
            let missedTarget =
                observances.last(where: {
                    $0.obligation == .mandatory
                        && Calendar.current.startOfDay(for: $0.date) <= today
                })
                ?? observances.first(where: { $0.obligation == .mandatory })

            if let missedTarget {
                defaults.set([missedTarget.id: CompletionStatus.missed.rawValue], forKey: SyncStoreKeys.observanceStatuses)
            }
        }

        if arguments.contains("-uitest-skip-onboarding") {
            defaults.set(true, forKey: StorageKeys.didCompleteOnboarding)
        } else if arguments.contains("-uitest-seed-deterministic") {
            defaults.set(false, forKey: StorageKeys.didCompleteOnboarding)
        }
    }

    private static func clearSavedApplicationState(bundleIdentifier: String) {
        guard let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        let savedStateURL = libraryURL
            .appendingPathComponent("Saved Application State", isDirectory: true)
            .appendingPathComponent("\(bundleIdentifier).savedState", isDirectory: true)
        try? FileManager.default.removeItem(at: savedStateURL)
    }
}
