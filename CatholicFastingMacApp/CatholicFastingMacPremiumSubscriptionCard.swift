import SwiftUI

struct CatholicFastingMacPremiumSubscriptionCard: View {
    @ObservedObject var model: CatholicFastingMacModel

    var body: some View {
        MacCard(
            title: model.monetizationStore.premiumUnlocked ? "Premium active" : "Subscription",
            subtitle: model.monetizationStore.subscriptionHealthMessage.isEmpty
                ? "Store status"
                : model.monetizationStore.subscriptionHealthMessage)
        {
            if model.monetizationStore.premiumUnlocked {
                Text("Premium tools are unlocked on this Mac. Planner, analytics, recovery coaching, and support reminders are available below.")
                    .foregroundStyle(.secondary)
            } else if model.monetizationStore.premiumProducts.isEmpty {
                Text(model.monetizationStore.statusMessage.isEmpty ? "Loading premium products…" : model.monetizationStore.statusMessage)
                    .foregroundStyle(.secondary)
            }

            ForEach(model.monetizationStore.premiumProducts, id: \.id) { product in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(product.displayName)
                        Text(product.displayPrice)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Unlock") {
                        Task { await model.monetizationStore.purchase(product) }
                    }
                    .accessibilityIdentifier("mac.premium.unlock.\(product.id)")
                    .disabled(model.monetizationStore.isPurchasing)
                }
            }

            HStack {
                Button("Restore Purchases") {
                    Task { await model.monetizationStore.restorePurchases() }
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("mac.premium.restore")

                Button("Manage Subscription") {
                    Task { await model.monetizationStore.openManageSubscriptions() }
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("mac.premium.manage")
            }

            if !model.monetizationStore.statusMessage.isEmpty {
                Text(model.monetizationStore.statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
