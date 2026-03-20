import SwiftUI
#if canImport(StoreKit)
    import StoreKit
#endif
#if canImport(AppIntents)
    import AppIntents
#endif
#if canImport(TipKit)
    import TipKit
#endif
#if canImport(UIKit)
    import UIKit
#endif
#if canImport(UserNotifications)
    import UserNotifications
#endif

#if canImport(TipKit)
    @available(iOS 18.0, *)
    struct FastingDaysFocusTip: Tip {
        var title: Text {
            Text("Focus Required Days")
        }

        var message: Text? {
            Text("Open Fasting Days to filter required observances and plan ahead.")
        }

        var image: Image? {
            Image(systemName: "calendar.badge.clock")
        }
    }

    @available(iOS 18.0, *)
    struct IntermittentTrackerTip: Tip {
        var title: Text {
            Text("Track Personal Fasts")
        }

        var message: Text? {
            Text("Use Track Fast for optional intermittent disciplines.")
        }

        var image: Image? {
            Image(systemName: "timer")
        }
    }

    @available(iOS 18.0, *)
    struct MoreToolsTip: Tip {
        var title: Text {
            Text("Everything Else Is in More")
        }

        var message: Text? {
            Text("Use More for setup, reminders, premium, and privacy controls.")
        }

        var image: Image? {
            Image(systemName: "ellipsis.circle")
        }
    }
#endif

#if canImport(StoreKit)
    @MainActor
    final class MonetizationStore: ObservableObject {
        static let premiumCatalog = SubscriptionOfferCatalog.catholicFasting
        static let premiumMonthlyID = "com.kevpierce.catholicfasting.premium.monthly.v3"
        static let premiumYearlyID = "com.kevpierce.catholicfasting.premium.yearly.v3"
        static let tipSmallID = "com.kevpierce.catholicfasting.tip.small"
        static let tipMediumID = "com.kevpierce.catholicfasting.tip.medium"
        static let tipLargeID = "com.kevpierce.catholicfasting.tip.large"

        static let premiumProductIDs: Set<String> = premiumCatalog.canonicalSubscriptionProductIDs
        static let tipProductIDs: Set<String> = [tipSmallID, tipMediumID, tipLargeID]
        static let allProductIDs: Set<String> = premiumProductIDs.union(tipProductIDs)

        @Published var premiumUnlocked = false
        @Published var isLoading = false
        @Published var isPurchasing = false
        @Published var statusMessage = ""
        @Published var subscriptionHealthMessage = ""
        @Published var premiumProducts: [Product] = []
        @Published var tipProducts: [Product] = []

        private static let debugPremiumUnlockedKey = "debug_simulator_premium_unlocked"
        private var updatesTask: Task<Void, Never>?

        init() {
            updatesTask = Task {
                await monitorTransactionUpdates()
            }
        }

        deinit {
            updatesTask?.cancel()
        }

        func refreshCatalogAndEntitlements() async {
            isLoading = true
            defer { isLoading = false }

            do {
                let products = try await Product.products(for: Array(Self.allProductIDs))
                premiumProducts =
                    products
                        .filter { Self.premiumProductIDs.contains($0.id) }
                        .sorted { premiumSortIndex(for: $0.id) < premiumSortIndex(for: $1.id) }
                tipProducts =
                    products
                        .filter { Self.tipProductIDs.contains($0.id) }
                        .sorted { tipSortIndex(for: $0.id) < tipSortIndex(for: $1.id) }
                await refreshEntitlements()
                await refreshSubscriptionHealth()
            } catch {
                statusMessage = "Unable to load purchases right now."
            }
        }

        func purchase(_ product: Product) async {
            if Self.usesSimulatorDebugPurchases {
                if Self.premiumProductIDs.contains(product.id) {
                    premiumUnlocked = true
                    UserDefaults.standard.set(true, forKey: Self.debugPremiumUnlockedKey)
                    statusMessage = "Premium unlocked (simulator debug purchase)."
                } else {
                    statusMessage = "Thank you for supporting this app (simulator debug tip)."
                }
                await refreshSubscriptionHealth()
                return
            }

            isPurchasing = true
            defer { isPurchasing = false }

            do {
                let result = try await product.purchase()
                switch result {
                case let .success(verification):
                    guard case let .verified(transaction) = verification else {
                        statusMessage = "Purchase could not be verified."
                        return
                    }
                    await transaction.finish()
                    await refreshEntitlements()
                    await refreshSubscriptionHealth()
                    if Self.premiumProductIDs.contains(product.id) {
                        statusMessage = "Premium unlocked."
                    } else {
                        statusMessage = "Thank you for supporting this app."
                    }
                case .pending:
                    statusMessage = "Purchase pending approval."
                case .userCancelled:
                    statusMessage = "Purchase cancelled."
                @unknown default:
                    statusMessage = "Purchase did not complete."
                }
            } catch {
                statusMessage = "Purchase failed: \(error.localizedDescription)"
            }
        }

        func restorePurchases() async {
            if Self.usesSimulatorDebugPurchases {
                premiumUnlocked = UserDefaults.standard.bool(forKey: Self.debugPremiumUnlockedKey)
                await refreshSubscriptionHealth()
                statusMessage =
                    premiumUnlocked
                        ? "Simulator debug purchase restored."
                        : "No simulator debug premium purchase found."
                return
            }

            isPurchasing = true
            defer { isPurchasing = false }

            do {
                try await AppStore.sync()
                await refreshEntitlements()
                await refreshSubscriptionHealth()
                statusMessage = premiumUnlocked ? "Purchases restored." : "No active premium purchase found."
            } catch {
                statusMessage = "Could not restore purchases."
            }
        }

        func openManageSubscriptions() async {
            #if canImport(UIKit)
                guard let scene = Self.activeWindowScene() else {
                    if !openManageSubscriptionsFallback() {
                        statusMessage = "Unable to open subscription management right now."
                    }
                    return
                }
                do {
                    try await AppStore.showManageSubscriptions(in: scene)
                } catch {
                    if !openManageSubscriptionsFallback() {
                        statusMessage = "Unable to open subscription settings."
                    }
                }
            #else
                statusMessage = "Subscription management is unavailable on this platform."
            #endif
        }

        func resetSimulatorDebugPurchase() async {
            guard Self.usesSimulatorDebugPurchases else { return }
            UserDefaults.standard.removeObject(forKey: Self.debugPremiumUnlockedKey)
            premiumUnlocked = false
            statusMessage = "Simulator debug premium reset."
            await refreshSubscriptionHealth()
        }

        private func refreshEntitlements() async {
            if Self.usesSimulatorDebugPurchases {
                premiumUnlocked = UserDefaults.standard.bool(forKey: Self.debugPremiumUnlockedKey)
                return
            }

            premiumUnlocked = false
            for await verification in Transaction.currentEntitlements {
                guard case let .verified(transaction) = verification else { continue }
                guard Self.premiumProductIDs.contains(transaction.productID) else { continue }
                if transaction.revocationDate != nil { continue }
                if let expiration = transaction.expirationDate, expiration <= Date() { continue }
                premiumUnlocked = true
            }
        }

        private func monitorTransactionUpdates() async {
            if Self.usesSimulatorDebugPurchases {
                return
            }

            for await verification in Transaction.updates {
                guard case let .verified(transaction) = verification else { continue }
                await transaction.finish()
                await refreshEntitlements()
                await refreshSubscriptionHealth()
            }
        }

        private func refreshSubscriptionHealth() async {
            var states: [PremiumSubscriptionState] = []
            for product in premiumProducts {
                guard let subscription = product.subscription else { continue }
                guard let statuses = try? await subscription.status else { continue }
                for status in statuses {
                    switch status.state {
                    case .subscribed:
                        states.append(.subscribed)
                    case .expired:
                        states.append(.expired)
                    case .inGracePeriod:
                        states.append(.inGracePeriod)
                    case .inBillingRetryPeriod:
                        states.append(.inBillingRetry)
                    case .revoked:
                        states.append(.revoked)
                    default:
                        continue
                    }
                }
            }
            subscriptionHealthMessage = PremiumSubscriptionHealthEvaluator.message(
                states: states,
                premiumUnlocked: premiumUnlocked
            )
        }

        #if canImport(UIKit)
            private static func activeWindowScene() -> UIWindowScene? {
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first(where: { $0.activationState == .foregroundActive })
                    ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
            }

            private func openManageSubscriptionsFallback() -> Bool {
                UIApplication.shared.open(UIConstants.manageSubscriptionsURL)
                statusMessage = "Opened account subscriptions in App Store."
                return true
            }
        #endif

        private func premiumSortIndex(for productID: String) -> Int {
            Self.premiumCatalog.offers.firstIndex(where: { $0.id == productID }) ?? 99
        }

        private func tipSortIndex(for productID: String) -> Int {
            switch productID {
            case Self.tipSmallID:
                0
            case Self.tipMediumID:
                1
            case Self.tipLargeID:
                2
            default:
                99
            }
        }

        private static var usesSimulatorDebugPurchases: Bool {
            #if DEBUG && targetEnvironment(simulator)
                true
            #else
                false
            #endif
        }
    }
#else
    @MainActor
    final class MonetizationStore: ObservableObject {
        @Published var premiumUnlocked = false
        @Published var isLoading = false
        @Published var isPurchasing = false
        @Published var statusMessage = "Purchases unavailable on this platform."
        @Published var subscriptionHealthMessage = ""
        @Published var premiumProducts: [String] = []
        @Published var tipProducts: [String] = []

        func refreshCatalogAndEntitlements() async {}
        func restorePurchases() async {}
        func purchase(_: String) async {}
        func openManageSubscriptions() async {}
        func resetSimulatorDebugPurchase() async {}
    }
#endif

#if canImport(AppIntents)
    @available(iOS 18.0, *)
    struct OpenTodayIntent: AppIntent {
        static let title: LocalizedStringResource = "Open Today Plan"
        static let description = IntentDescription("Open the Today tab in Catholic Fasting.")
        static var openAppWhenRun: Bool = true

        func perform() async throws -> some IntentResult & OpensIntent {
            .result(opensIntent: OpenURLIntent(UIConstants.deepLinkTodayURL))
        }
    }

    @available(iOS 18.0, *)
    struct OpenFastingDaysIntent: AppIntent {
        static let title: LocalizedStringResource = "Open Fasting Days"
        static let description = IntentDescription("Open the fasting days list.")
        static var openAppWhenRun: Bool = true

        func perform() async throws -> some IntentResult & OpensIntent {
            .result(opensIntent: OpenURLIntent(UIConstants.deepLinkFastingDaysURL))
        }
    }

    @available(iOS 18.0, *)
    struct OpenIntermittentTrackerIntent: AppIntent {
        static let title: LocalizedStringResource = "Open Fast Tracker"
        static let description = IntentDescription("Open the intermittent fasting tracker.")
        static var openAppWhenRun: Bool = true

        func perform() async throws -> some IntentResult & OpensIntent {
            .result(opensIntent: OpenURLIntent(UIConstants.deepLinkIntermittentURL))
        }
    }

    @available(iOS 18.0, *)
    struct CatholicFastingAppShortcuts: AppShortcutsProvider {
        static var appShortcuts: [AppShortcut] {
            AppShortcut(
                intent: OpenTodayIntent(),
                phrases: ["Open \(.applicationName) today"],
                shortTitle: "Today Plan",
                systemImageName: "sun.max"
            )
            AppShortcut(
                intent: OpenFastingDaysIntent(),
                phrases: ["Open \(.applicationName) fasting days"],
                shortTitle: "Fasting Days",
                systemImageName: "calendar"
            )
            AppShortcut(
                intent: OpenIntermittentTrackerIntent(),
                phrases: ["Open \(.applicationName) fast tracker"],
                shortTitle: "Track Fast",
                systemImageName: "timer"
            )
        }
    }
#endif

struct ObservanceRowView: View {
    let observance: Observance
    let status: CompletionStatus
    let noteBinding: Binding<String>
    let onToggleCompletion: () -> Void
    let onSetStatus: (CompletionStatus) -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(observance.title)
                    .font(.headline)

                Text(observance.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    StatusTag(text: observance.kind.label, color: observance.kind.color)
                    StatusTag(text: observance.dispositionLabel, color: obligationColor)
                }

                if let detail = observance.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("Why: \(observance.rationale)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !observance.citations.isEmpty {
                    Text(citationSummary)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if observance.kind == .fridayPenance, observance.obligation != .notApplicable {
                    TextField("What penance did you do?", text: noteBinding)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
            }

            Spacer()

            if observance.obligation == .notApplicable {
                Image(systemName: "minus.circle")
                    .imageScale(.large)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            } else {
                Menu {
                    ForEach(CompletionStatus.allCases) { statusOption in
                        Button(statusOption.label) {
                            onSetStatus(statusOption)
                        }
                    }
                } label: {
                    Image(systemName: statusIcon)
                        .imageScale(.large)
                        .foregroundStyle(statusColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Set status \(status.label)")
                .contextMenu {
                    Button("Toggle Complete", action: onToggleCompletion)
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(rowTint.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rowBorderColor, lineWidth: 1)
        )
        .appRoundedGlass(cornerRadius: 12)
    }

    private var statusIcon: String {
        switch status {
        case .notStarted:
            "circle"
        case .completed:
            "checkmark.circle.fill"
        case .substituted:
            "arrow.triangle.2.circlepath.circle.fill"
        case .dispensed:
            "cross.case.circle.fill"
        case .missed:
            "xmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch status {
        case .notStarted:
            .secondary
        case .completed:
            .green
        case .substituted:
            .blue
        case .dispensed:
            .indigo
        case .missed:
            .red
        }
    }

    private var citationSummary: String {
        observance.citations
            .map { "\($0.authority.rawValue): \($0.shortReference)" }
            .joined(separator: " • ")
    }

    private var obligationColor: Color {
        switch observance.obligation {
        case .mandatory:
            .red
        case .optional:
            .blue
        case .notApplicable:
            .gray
        }
    }

    private var rowTint: Color {
        switch observance.obligation {
        case .mandatory:
            .red
        case .optional:
            .blue
        case .notApplicable:
            .gray
        }
    }

    private var rowBorderColor: Color {
        switch observance.obligation {
        case .mandatory:
            Color.red.opacity(0.35)
        case .optional:
            Color.blue.opacity(0.35)
        case .notApplicable:
            CatholicTheme.cardBorder.opacity(0.4)
        }
    }
}

struct StatusTag: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.thinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .fill(color.opacity(0.16))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.55), lineWidth: 0.8)
            )
            .appCapsuleGlass()
    }
}

struct MetricTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .foregroundStyle(CatholicTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(CatholicTheme.parchment.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(tileTint.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CatholicTheme.cardBorder.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: tileTint.opacity(0.08), radius: 10, y: 4)
        .appRoundedGlass(cornerRadius: 14)
    }

    private var tileTint: Color {
        switch title {
        case "Required":
            .red
        case "Done":
            .green
        case "Streak":
            CatholicTheme.accent
        default:
            CatholicTheme.primary
        }
    }
}

struct FridayNotesHistoryView: View {
    @ObservedObject var notesStore: FridayPenanceNotes
    @State private var searchText = ""

    private var allRecords: [FridayPenanceRecord] {
        notesStore.records()
    }

    private var filteredRecords: [FridayPenanceRecord] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return allRecords
        }

        let query = searchText.lowercased()
        return allRecords.filter { record in
            let dateString = record.date.formatted(date: .abbreviated, time: .omitted).lowercased()
            return record.title.lowercased().contains(query)
                || record.note.lowercased().contains(query)
                || dateString.contains(query)
        }
    }

    private var exportText: String {
        var lines = ["Date,Observance,Note"]
        for record in filteredRecords {
            let date = DateFormatter.localizedString(from: record.date, dateStyle: .medium, timeStyle: .none)
            lines.append("\(csvEscape(date)),\(csvEscape(record.title)),\(csvEscape(record.note))")
        }
        return lines.joined(separator: "\n")
    }

    var body: some View {
        List {
            if filteredRecords.isEmpty {
                ContentUnavailableView("No notes found", systemImage: "magnifyingglass")
            } else {
                ForEach(filteredRecords) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(record.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(record.title)
                            .font(.headline)
                        Text(record.note)
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Friday Notes")
        .searchable(text: $searchText, prompt: "Search notes")
        .toolbar {
            ShareLink(
                item: exportText,
                subject: Text("Friday Penance Notes Export"),
                message: Text("Exported from Catholic Fasting")
            ) {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .disabled(filteredRecords.isEmpty)
        }
    }

    private func csvEscape(_ raw: String) -> String {
        "\"\(raw.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}

#Preview {
    ContentView()
}

struct OnboardingView: View {
    @Binding var age14OrOlderForAbstinence: Bool
    @Binding var age18OrOlderForFasting: Bool
    @Binding var medicalDispensation: Bool
    @Binding var languageModeRaw: String
    @Binding var regionProfileRaw: String
    @Binding var fridayModeRaw: String
    @Binding var reminderTierRaw: String
    @Binding var dailyReminderSupportEnabled: Bool
    @Binding var morningReminderEnabled: Bool
    @Binding var eveningReminderEnabled: Bool
    let onComplete: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section(localized("onboarding.step1.title", default: "Step 1 of 4: Eligibility Profile")) {
                    Text(
                        localized(
                            "onboarding.step1.intro",
                            default: "Use simple eligibility toggles to keep guidance accurate without sharing your birthday."
                        )
                    )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Toggle(
                        localized(
                            "onboarding.step1.age14",
                            default: "I am 14 or older (abstinence age)"
                        ),
                        isOn: $age14OrOlderForAbstinence
                    )
                        .accessibilityIdentifier("onboarding.age14_toggle")
                    Toggle(
                        localized(
                            "onboarding.step1.age18",
                            default: "I am 18 or older (fasting age)"
                        ),
                        isOn: $age18OrOlderForFasting
                    )
                        .accessibilityIdentifier("onboarding.age18_toggle")
                    Toggle(
                        localized(
                            "onboarding.step1.dispensation",
                            default: "Health/pastoral dispensation (if needed)"
                        ),
                        isOn: $medicalDispensation
                    )
                        .accessibilityIdentifier("onboarding.dispensation")
                }

                Section(localized("onboarding.step2.title", default: "Step 2 of 4: Language and Region")) {
                    Picker(localized("onboarding.step2.language", default: "Language"), selection: $languageModeRaw) {
                        ForEach(LanguageMode.allCases) { option in
                            Text(option.label).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("onboarding.language")

                    Picker(
                        localized("onboarding.step2.region", default: "Region"),
                        selection: $regionProfileRaw
                    ) {
                        ForEach(RuleSettings.RegionProfile.allCases) { option in
                            Text(localizedRegionLabel(option)).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("onboarding.region")

                    Picker(
                        localized(
                            "onboarding.step2.friday_mode",
                            default: "Friday practice outside Lent"
                        ),
                        selection: $fridayModeRaw
                    ) {
                        ForEach(RuleSettings.FridayOutsideLentMode.allCases) { option in
                            Text(localizedFridayModeLabel(option)).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("onboarding.friday_mode")
                    Text(
                        localized(
                            "onboarding.step2.helper",
                            default: "You can change all of this later in Profile & Norms."
                        )
                    )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section(localized("onboarding.step3.title", default: "Step 3 of 4: Reminder Strategy")) {
                    Picker(localized("onboarding.step3.reminder_style", default: "Reminder style"), selection: $reminderTierRaw) {
                        ForEach(ReminderTier.allCases) { tier in
                            Text("\(localizedReminderTierLabel(tier)) - \(localizedReminderTierSummary(tier))").tag(tier.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("onboarding.reminder_tier")
                    .onChange(of: reminderTierRaw) { _, newValue in
                        let tier = ReminderTier(rawValue: newValue) ?? .balanced
                        dailyReminderSupportEnabled = tier.supportEnabled
                        morningReminderEnabled = tier.morningEnabled
                        eveningReminderEnabled = tier.eveningEnabled
                    }

                    Text(
                        localized(
                            "onboarding.step3.helper",
                            default: "Reminders can be changed any time in Setup & Reminders."
                        )
                    )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section(localized("onboarding.step4.title", default: "Step 4 of 4: Premium Preview")) {
                    Text(
                        localized(
                            "onboarding.step4.intro",
                            default: "Free core gives required fasting guidance. Premium adds a focused Formation Toolkit."
                        )
                    )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ForEach(SubscriptionOfferCatalog.catholicFasting.pillars) { pillar in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(pillar.title)
                                .font(.headline)
                            Text(pillar.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ForEach(pillar.outcomes, id: \.self) { outcome in
                                Text("• \(outcome)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section(localized("onboarding.trust.title", default: "Why This Is Trustworthy")) {
                    Text(
                        localized(
                            "onboarding.trust.independent",
                            default: "This is an independent Catholic devotional app with cited guidance references."
                        )
                    )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(
                        localized(
                            "onboarding.trust.sources",
                            default: "Sources: USCCB liturgical calendar and fast/abstinence guidance, with in-app citation links."
                        )
                    )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(
                        localized(
                            "onboarding.trust.unofficial",
                            default: "This is an independent devotional app and not an official app of the Catholic Church, USCCB, Vatican, or any diocese/parish."
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    Text(
                        localized(
                            "onboarding.trust.follow_guidance",
                            default: "Always follow your pastor, local Church norms, and medical guidance."
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(localized("onboarding.title", default: "Welcome"))
            .onAppear {
                let tier = ReminderTier(rawValue: reminderTierRaw) ?? .balanced
                dailyReminderSupportEnabled = tier.supportEnabled
                morningReminderEnabled = tier.morningEnabled
                eveningReminderEnabled = tier.eveningEnabled
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localized("onboarding.finish", default: "Finish Setup")) {
                        onComplete()
                    }
                    .appPrimaryButtonStyle()
                    .accessibilityIdentifier("onboarding.continue")
                }
            }
        }
    }

    private func localized(_ key: String, default defaultValue: String) -> String {
        AppLocalizer.localized(key, default: defaultValue, languageCode: languageModeRaw)
    }

    private func localizedRegionLabel(_ option: RuleSettings.RegionProfile) -> String {
        switch option {
        case .us:
            localized("onboarding.region.us", default: option.label)
        case .canada:
            localized("onboarding.region.canada", default: option.label)
        case .other:
            localized("onboarding.region.other", default: option.label)
        }
    }

    private func localizedFridayModeLabel(_ option: RuleSettings.FridayOutsideLentMode) -> String {
        switch option {
        case .abstainFromMeat:
            localized("onboarding.friday.abstain", default: option.label)
        case .substitutePenance:
            localized("onboarding.friday.substitute", default: option.label)
        }
    }

    private func localizedReminderTierLabel(_ tier: ReminderTier) -> String {
        switch tier {
        case .minimal:
            localized("onboarding.reminder.minimal.label", default: tier.label)
        case .balanced:
            localized("onboarding.reminder.balanced.label", default: tier.label)
        case .guided:
            localized("onboarding.reminder.guided.label", default: tier.label)
        }
    }

    private func localizedReminderTierSummary(_ tier: ReminderTier) -> String {
        switch tier {
        case .minimal:
            localized("onboarding.reminder.minimal.summary", default: tier.summary)
        case .balanced:
            localized("onboarding.reminder.balanced.summary", default: tier.summary)
        case .guided:
            localized("onboarding.reminder.guided.summary", default: tier.summary)
        }
    }
}
