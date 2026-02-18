import SwiftUI
#if canImport(StoreKit)
  import StoreKit
#endif
#if canImport(UIKit)
  import UIKit
#endif
#if canImport(UserNotifications)
  import UserNotifications
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
      isPurchasing = true
      defer { isPurchasing = false }

      do {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
          guard case .verified(let transaction) = verification else {
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
      premiumUnlocked = false
      for await verification in Transaction.currentEntitlements {
        guard case .verified(let transaction) = verification else { continue }
        guard Self.premiumProductIDs.contains(transaction.productID) else { continue }
        if transaction.revocationDate != nil { continue }
        if let expiration = transaction.expirationDate, expiration <= Date() { continue }
        premiumUnlocked = true
      }
    }

    private func monitorTransactionUpdates() async {
      for await verification in Transaction.updates {
        guard case .verified(let transaction) = verification else { continue }
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
    func purchase(_ product: String) async {}
    func openManageSubscriptions() async {}
  }
#endif

enum ReminderScheduler {
  private static let reminderPrefix = "required-day-"
  private static let supportReminderPrefix = "habit-support-"
  private static let reminderCategory = "habit-reminder"

  static func requestPermission() async -> String {
    #if canImport(UserNotifications)
      let center = UNUserNotificationCenter.current()
      let existingStatus = await authorizationStatus(center)
      if isAuthorizedStatus(existingStatus) {
        configureReminderActions(center)
        return "Permission already granted"
      }
      if existingStatus == .denied {
        return "Notifications denied. Enable them in iOS Settings."
      }
      do {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        configureReminderActions(center)
        return granted ? "Permission granted" : "Permission denied"
      } catch {
        return "Permission error: \(error.localizedDescription)"
      }
    #else
      return "Notifications unavailable on this platform"
    #endif
  }

  static func schedule(observances: [Observance]) async -> String {
    #if canImport(UserNotifications)
      let center = UNUserNotificationCenter.current()
      let status = await authorizationStatus(center)
      guard isAuthorizedStatus(status) else {
        return "Notifications are not enabled. Request permission first."
      }
      configureReminderActions(center)
      let existing = await pendingRequests(center)
      let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(reminderPrefix) }
      if !toRemove.isEmpty {
        center.removePendingNotificationRequests(withIdentifiers: toRemove)
      }

      let startOfToday = Calendar.current.startOfDay(for: Date())
      let upcomingMandatoryObservances = observances.filter { observance in
        observance.obligation == .mandatory && Calendar.current.startOfDay(for: observance.date) >= startOfToday
      }

      guard !upcomingMandatoryObservances.isEmpty else {
        return "No upcoming required observances to schedule"
      }

      var scheduled = 0
      for observance in upcomingMandatoryObservances {
        let identifier = "required-day-\(observance.id)"
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: observance.date)
        dateComponents.hour = 7
        dateComponents.minute = 0

        let content = UNMutableNotificationContent()
        content.title = observance.title
        content.body = "Required observance today. Open Catholic Fasting to mark completion."
        content.sound = .default
        content.categoryIdentifier = reminderCategory

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        do {
          try await center.add(request)
          scheduled += 1
        } catch {
          return "Scheduling error: \(error.localizedDescription)"
        }
      }

      return "Scheduled \(scheduled) upcoming reminder(s)"
    #else
      return "Notifications unavailable on this platform"
    #endif
  }

  static func scheduleHabitSupport(morning: Bool, evening: Bool) async -> String {
    #if canImport(UserNotifications)
      let center = UNUserNotificationCenter.current()
      let status = await authorizationStatus(center)
      guard isAuthorizedStatus(status) else {
        return "Notifications are not enabled. Request permission first."
      }
      configureReminderActions(center)
      let existing = await pendingRequests(center)
      let toRemove = existing.map(\.identifier).filter { $0.hasPrefix(supportReminderPrefix) }
      if !toRemove.isEmpty {
        center.removePendingNotificationRequests(withIdentifiers: toRemove)
      }

      guard morning || evening else {
        return "Select morning or evening support first"
      }

      var scheduled = 0

      if morning {
        if await addHabitSupportReminder(
          center: center,
          identifier: "\(supportReminderPrefix)morning",
          title: "Morning fasting check",
          body: "Review today’s observance plan before your first meal.",
          hour: 7,
          minute: 0
        ) {
          scheduled += 1
        }
      }

      if evening {
        if await addHabitSupportReminder(
          center: center,
          identifier: "\(supportReminderPrefix)evening",
          title: "Evening examen",
          body: "Mark progress and prepare for tomorrow’s observance.",
          hour: 20,
          minute: 0
        ) {
          scheduled += 1
        }
      }

      return scheduled > 0 ? "Scheduled \(scheduled) daily support reminder(s)" : "No support reminders selected"
    #else
      return "Notifications unavailable on this platform"
    #endif
  }

  static func notificationSummary() async -> String {
    #if canImport(UserNotifications)
      let center = UNUserNotificationCenter.current()
      let status = await authorizationStatus(center)
      if status == .notDetermined {
        return "Permission not requested"
      }
      if status == .denied {
        return "Notifications denied in iOS Settings"
      }

      let requests = await pendingRequests(center)
      let requiredCount = requests.map(\.identifier).filter { $0.hasPrefix(reminderPrefix) }.count
      let supportCount = requests.map(\.identifier).filter { $0.hasPrefix(supportReminderPrefix) }.count
      if requiredCount == 0 && supportCount == 0 {
        return "No reminders queued"
      }
      if requiredCount > 0 && supportCount > 0 {
        return "\(requiredCount) required-day and \(supportCount) support reminder(s) queued"
      }
      if requiredCount > 0 {
        return "\(requiredCount) required-day reminder(s) queued"
      }
      return "\(supportCount) support reminder(s) queued"
    #else
      return "Notifications unavailable on this platform"
    #endif
  }

  #if canImport(UserNotifications)
    private static func configureReminderActions(_ center: UNUserNotificationCenter) {
      let reviewAction = UNNotificationAction(
        identifier: "review_today",
        title: "Review Today",
        options: [.foreground]
      )
      let recoveryAction = UNNotificationAction(
        identifier: "open_recovery",
        title: "Recovery Plan",
        options: [.foreground]
      )
      let category = UNNotificationCategory(
        identifier: reminderCategory,
        actions: [reviewAction, recoveryAction],
        intentIdentifiers: [],
        options: []
      )
      center.setNotificationCategories([category])
    }

    private static func addHabitSupportReminder(
      center: UNUserNotificationCenter,
      identifier: String,
      title: String,
      body: String,
      hour: Int,
      minute: Int
    ) async -> Bool {
      var dateComponents = DateComponents()
      dateComponents.hour = hour
      dateComponents.minute = minute

      let content = UNMutableNotificationContent()
      content.title = title
      content.body = body
      content.sound = .default
      content.categoryIdentifier = reminderCategory

      let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
      let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
      do {
        try await center.add(request)
        return true
      } catch {
        return false
      }
    }

    private static func pendingRequests(_ center: UNUserNotificationCenter) async -> [UNNotificationRequest] {
      await withCheckedContinuation { continuation in
        center.getPendingNotificationRequests { requests in
          continuation.resume(returning: requests)
        }
      }
    }

    private static func authorizationStatus(_ center: UNUserNotificationCenter) async
      -> UNAuthorizationStatus
    {
      await withCheckedContinuation { continuation in
        center.getNotificationSettings { settings in
          continuation.resume(returning: settings.authorizationStatus)
        }
      }
    }

    private static func isAuthorizedStatus(_ status: UNAuthorizationStatus) -> Bool {
      switch status {
      case .authorized, .provisional, .ephemeral:
        return true
      default:
        return false
      }
    }
  #endif
}

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
  @Binding var birthYear: Int
  @Binding var medicalDispensation: Bool
  @Binding var fridayModeRaw: String
  @Binding var dailyReminderSupportEnabled: Bool
  let onComplete: () -> Void

  private var birthYearRange: [Int] {
    Array((UIConstants.minBirthYear...Calendar.current.component(.year, from: Date())).reversed())
  }

  var body: some View {
    NavigationStack {
      List {
        Section("Welcome") {
          Text("Set this up once so your day-to-day guidance is accurate.")
        }

        Section("Profile Setup") {
          Picker("Birth Year", selection: $birthYear) {
            Text("Not set").tag(0)
            ForEach(birthYearRange, id: \.self) { year in
              Text(String(year)).tag(year)
            }
          }
          .pickerStyle(.menu)
          .accessibilityIdentifier("onboarding.birth_year")
          Text("Why this matters: age determines whether fasting or abstinence binds.")
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
