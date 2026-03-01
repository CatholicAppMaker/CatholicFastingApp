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
    static let premiumMonthlyID = "com.kevpierce.catholicfasting.premium.monthly"
    static let premiumYearlyID = "com.kevpierce.catholicfasting.premium.yearly"
    static let tipSmallID = "com.kevpierce.catholicfasting.tip.small"
    static let tipMediumID = "com.kevpierce.catholicfasting.tip.medium"
    static let tipLargeID = "com.kevpierce.catholicfasting.tip.large"

    static let premiumProductIDs: Set<String> = [premiumMonthlyID, premiumYearlyID]
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
      switch productID {
      case Self.premiumYearlyID:
        return 0
      case Self.premiumMonthlyID:
        return 1
      default:
        return 99
      }
    }

    private func tipSortIndex(for productID: String) -> Int {
      switch productID {
      case Self.tipSmallID:
        return 0
      case Self.tipMediumID:
        return 1
      case Self.tipLargeID:
        return 2
      default:
        return 99
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
          StatusTag(text: observance.obligation.label, color: obligationColor)
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

        if observance.kind == .fridayPenance && observance.obligation != .notApplicable {
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
      return "circle"
    case .completed:
      return "checkmark.circle.fill"
    case .substituted:
      return "arrow.triangle.2.circlepath.circle.fill"
    case .dispensed:
      return "cross.case.circle.fill"
    case .missed:
      return "xmark.circle.fill"
    }
  }

  private var statusColor: Color {
    switch status {
    case .notStarted:
      return .secondary
    case .completed:
      return .green
    case .substituted:
      return .blue
    case .dispensed:
      return .indigo
    case .missed:
      return .red
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
      return .red
    case .optional:
      return .blue
    case .notApplicable:
      return .gray
    }
  }

  private var rowTint: Color {
    switch observance.obligation {
    case .mandatory:
      return .red
    case .optional:
      return .blue
    case .notApplicable:
      return .gray
    }
  }

  private var rowBorderColor: Color {
    switch observance.obligation {
    case .mandatory:
      return Color.red.opacity(0.35)
    case .optional:
      return Color.blue.opacity(0.35)
    case .notApplicable:
      return CatholicTheme.cardBorder.opacity(0.4)
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
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.caption2)
        .foregroundStyle(CatholicTheme.primary.opacity(0.85))
      Text(value)
        .font(.headline)
        .fontWeight(.semibold)
        .foregroundStyle(CatholicTheme.primary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 10)
    .padding(.vertical, 8)
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .fill(tileTint.opacity(0.12))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10, style: .continuous)
        .stroke(CatholicTheme.cardBorder.opacity(0.5), lineWidth: 1)
    )
    .appRoundedGlass(cornerRadius: 10)
  }

  private var tileTint: Color {
    switch title {
    case "Required":
      return .red
    case "Done":
      return .green
    case "Streak":
      return CatholicTheme.accent
    default:
      return CatholicTheme.primary
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
  @Binding var fridayModeRaw: String
  @Binding var dailyReminderSupportEnabled: Bool
  let onComplete: () -> Void

  var body: some View {
    NavigationStack {
      List {
        Section("Welcome") {
          Text("Set this up once so your day-to-day guidance is accurate.")
        }

        Section("Profile Setup") {
          Toggle("I am 14 or older (abstinence age)", isOn: $age14OrOlderForAbstinence)
            .accessibilityIdentifier("onboarding.age14_toggle")
          Toggle("I am 18 or older (fasting age)", isOn: $age18OrOlderForFasting)
            .accessibilityIdentifier("onboarding.age18_toggle")
          Text("You can update these anytime in Settings as your age status changes.")
            .font(.caption)
            .foregroundStyle(.secondary)

          Toggle("Health/pastoral dispensation (if needed)", isOn: $medicalDispensation)
            .accessibilityIdentifier("onboarding.dispensation")
          Text("Why this matters: this prevents guidance that may be unsafe or inapplicable.")
            .font(.caption)
            .foregroundStyle(.secondary)

          Picker("Friday practice outside Lent", selection: $fridayModeRaw) {
            ForEach(RuleSettings.FridayOutsideLentMode.allCases) { option in
              Text(option.label).tag(option.rawValue)
            }
          }
          .pickerStyle(.menu)
          .accessibilityIdentifier("onboarding.friday_mode")
          Text("Why this matters: dioceses and personal discipline can differ for Friday penance.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Section("Reminder Preference") {
          Toggle("Enable daily reminder support", isOn: $dailyReminderSupportEnabled)
            .accessibilityIdentifier("onboarding.reminders_toggle")
          Text("Why this matters: reminders help consistency and recovery after missed days.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        Section("Important") {
          Text(
            "This is an independent devotional app and not an official app of the Catholic Church, USCCB, Vatican, or any diocese/parish."
          )
          .foregroundStyle(.secondary)
          Text(
            "Always follow your pastor, local Church norms, and medical guidance when obligations conflict with health or vocation duties."
          )
          .foregroundStyle(.secondary)
        }
      }
      .navigationTitle("Welcome")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Finish Setup") {
            onComplete()
          }
          .appPrimaryButtonStyle()
          .accessibilityIdentifier("onboarding.continue")
        }
      }
    }
  }
}
