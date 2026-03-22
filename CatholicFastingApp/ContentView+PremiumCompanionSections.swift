import SwiftUI
#if canImport(StoreKit)
    import StoreKit
#endif

extension ContentView {
    var premiumOfferCatalog: SubscriptionOfferCatalog {
        .catholicFasting
    }

    func hasPremiumEntitlement(_: PremiumEntitlementSurface) -> Bool {
        // Current SKU grants all premium surfaces; keep explicit surface gate for future splits.
        monetizationStore.premiumUnlocked
    }

    func premiumToolDestination(for surface: PremiumEntitlementSurface) -> PremiumToolDestination {
        switch surface {
        case .planning:
            .planner
        case .accountability:
            .analytics
        case .reflection:
            .journal
        case .export:
            .export
        }
    }

    var selectedSupportPremiumSurface: SupportPremiumSurface {
        SupportPremiumSurface(rawValue: supportPremiumSurfaceRaw) ?? .upgrade
    }

    func openPremiumUpgrade(focusingOn surface: PremiumEntitlementSurface? = nil) {
        if let surface {
            selectedPremiumToolDestination = premiumToolDestination(for: surface)
        }
        launchFunnelSnapshot.lockedUpgradeTapCount += 1
        selectedMoreDestination = .supportAndPremium
        supportPremiumSurfaceRaw = SupportPremiumSurface.upgrade.rawValue
        homeSurface = .more
    }

    var premiumSurfacePickerSection: some View {
        Section(localized("premium.section.support", default: "Support & Premium")) {
            Picker(
                localized("premium.section.view", default: "View"),
                selection: Binding(
                    get: { selectedSupportPremiumSurface },
                    set: { supportPremiumSurfaceRaw = $0.rawValue }
                )
            ) {
                ForEach(SupportPremiumSurface.allCases) { item in
                    Text(item.label).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("premium.surface_picker")

            Text(
                selectedSupportPremiumSurface == .upgrade
                    ? localized("premium.section.upgrade_hint", default: "Choose a plan first, then use tips or billing tools if needed.")
                    : localized("premium.section.tools_hint", default: "Open premium planning, journaling, and exports.")
            )
            .appSupportingTextStyle()
        }
    }

    var premiumToolsLockedSection: some View {
        Section(localized("premium.tools.section", default: "Premium Tools")) {
            Text(localized("premium.tools.locked_hint", default: "Unlock premium to open planning, reminders, analytics, journaling, and exports."))
                .foregroundStyle(.secondary)
            Button(localized("premium.tools.go_to_upgrade", default: "Go to Upgrade")) {
                openPremiumUpgrade(focusingOn: .planning)
            }
            .appPrimaryButtonStyle()
            .accessibilityIdentifier("premium.tools.go_to_upgrade")
        }
    }

    var premiumToolsHubSection: some View {
        Section(localized("premium.tools.formation", default: "Formation Toolkit")) {
            ForEach(PremiumEntitlementSurface.allCases) { surface in
                let destination = premiumToolDestination(for: surface)
                NavigationLink {
                    premiumToolList(for: destination)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(surface.title, systemImage: destination.iconName)
                            .font(.headline)
                            .foregroundStyle(CatholicTheme.primary)
                        Text(surface.guidance)
                            .appSupportingTextStyle()
                    }
                    .padding(.vertical, 2)
                }
                .disabled(!hasPremiumEntitlement(surface))
                .accessibilityIdentifier("premium.tool.\(surface.rawValue)")
            }
        }
    }

    var premiumAndSupportSection: some View {
        Section(localized("premium.upgrade.section", default: "Premium Upgrade")) {
            premiumStatusSummaryCard

            if monetizationStore.premiumUnlocked {
                premiumJourneyCard(sample: false)
            } else {
                premiumJourneyCard(sample: true)
            }

            if monetizationStore.premiumUnlocked {
                premiumActiveStateCard
            } else {
                Text(localized("premium.upgrade.choose_plan", default: "Choose the yearly or monthly plan below."))
                    .appSupportingTextStyle()
                    .accessibilityIdentifier("premium.upgrade_summary")
                if monetizationStore.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text(localized("premium.upgrade.loading", default: "Loading purchases…"))
                    }
                    .font(.caption)
                }

                if !monetizationStore.premiumProducts.isEmpty {
                    ForEach(monetizationStore.premiumProducts, id: \.id) { product in
                        let offer = premiumOfferCatalog.offer(for: product.id)
                        premiumOfferCard(product: product, offer: offer)
                    }
                } else {
                    Text(localized("premium.upgrade.unavailable", default: "Premium plans are temporarily unavailable. Try again in a moment, then use Restore Purchases if needed."))
                        .appSupportingTextStyle()
                }

                if !monetizationStore.tipProducts.isEmpty {
                    premiumTipsSupportCard
                }

                let loadedTipIDs = Set(monetizationStore.tipProducts.map(\.id))
                let missingTipIDs = MonetizationStore.tipProductIDs.subtracting(loadedTipIDs)
                if !missingTipIDs.isEmpty {
                    Text(localized("premium.tips.loading_hint", default: "Optional support tips may take a moment to appear after the App Store finishes loading."))
                        .appEyebrowStyle()
                }
            }

            premiumLegalSupportCard
            premiumStoreFeedbackSection
        }
        .animation(.none, value: monetizationStore.premiumProducts.map(\.id))
        .animation(.none, value: monetizationStore.tipProducts.map(\.id))
        .animation(.none, value: monetizationStore.isLoading)
        .animation(.none, value: monetizationStore.statusMessage)
    }

    @ViewBuilder
    var premiumStoreFeedbackSection: some View {
        if !monetizationStore.subscriptionHealthMessage.isEmpty {
            Text(monetizationStore.subscriptionHealthMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("premium.subscription_health")
        }

        if !monetizationStore.statusMessage.isEmpty {
            Text(monetizationStore.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("premium.status")
        }
    }

    var premiumActiveStateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localized("premium.active.label", default: "Premium is active."))
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.active_summary")

            Button(localized("premium.active.open_tools", default: "Open Premium Tools")) {
                supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue
            }
            .appPrimaryButtonStyle()
            .accessibilityIdentifier("premium.open_tools")

            #if DEBUG && targetEnvironment(simulator)
                Button("Reset Simulator Premium") {
                    Task {
                        await monetizationStore.resetSimulatorDebugPurchase()
                    }
                }
                .appSecondaryButtonStyle()
                .disabled(monetizationStore.isPurchasing)
                .accessibilityIdentifier("premium.reset_simulator")
            #endif
        }
        .padding(14)
        .appSurfaceCard(.primary, cornerRadius: 18)
    }

    var premiumUpgradeHeroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SacredHeroCard(
                assetName: guidanceHeroArtwork.assetName,
                title: monetizationStore.premiumUnlocked
                    ? localized("premium.hero.active_title", default: "Formation Toolkit Active")
                    : localized("premium.hero.title", default: "Formation Toolkit"),
                subtitle: monetizationStore.premiumUnlocked
                    ? localized("premium.hero.active_subtitle", default: "Keep planning, recovery, reflection, and review in one focused Catholic workflow.")
                    : localized("premium.hero.subtitle", default: "Choose one clear premium path for planning, reminders, reflection, and review through the Church year."),
                height: 156,
                accessibilityIdentifier: "premium.hero"
            )

            CatholicFastingQuoteCard(
                quote: guidanceFastingQuote,
                compact: true
            )
            .accessibilityIdentifier("premium.quote")
        }
    }

    var premiumStatusSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: monetizationStore.premiumUnlocked ? "checkmark.seal.fill" : "star.circle.fill")
                    .appSymbolStyle(.prominent)
                    .foregroundStyle(monetizationStore.premiumUnlocked ? .green : CatholicTheme.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(monetizationStore.premiumUnlocked ? localized("premium.active.title", default: "Premium active") : premiumOfferCatalog.title)
                        .appSectionTitleStyle(serif: true)
                    Text(
                        monetizationStore.premiumUnlocked
                            ? localized("premium.active.summary", default: "Your planning, accountability, reflection, and export tools are unlocked.")
                            : localized("premium.locked.summary", default: "Stay steady through the Church year with one clear premium path for planning, reminders, and review.")
                    )
                    .appLeadTextStyle()
                }
            }

            if monetizationStore.premiumUnlocked {
                Button(localized("premium.active.open_tools", default: "Open Premium Tools")) {
                    supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue
                }
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("premium.open_tools")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(localized("premium.locked.adds", default: "Premium adds:"))
                        .appEyebrowStyle()
                        .foregroundStyle(CatholicTheme.primary)

                    ForEach(premiumOfferCatalog.pillars) { pillar in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: premiumIconName(for: pillar.requiredSurface))
                                .foregroundStyle(CatholicTheme.primary)
                                .frame(width: 18)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pillar.title)
                                    .font(.subheadline.weight(.semibold))
                                Text(pillar.subtitle)
                                    .appSupportingTextStyle()
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(localized("premium.trust.title", default: "Why users upgrade"))
                    .appEyebrowStyle()

                HStack(spacing: 8) {
                    premiumTrustPill(text: localized("premium.trust.local_only", default: "Local-only data"), systemImage: "lock.shield")
                    premiumTrustPill(text: localized("premium.trust.no_ads", default: "No ads"), systemImage: "nosign")
                    premiumTrustPill(text: localized("premium.trust.cancel_anytime", default: "Cancel anytime"), systemImage: "creditcard")
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(CatholicTheme.parchment.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CatholicTheme.cardBorder.opacity(0.5), lineWidth: 1)
        )
        .appRoundedGlass(cornerRadius: 16)
    }

    func premiumJourneyCard(sample: Bool) -> some View {
        let journey = premiumGuidedJourneyWeek
        let previewActions = sample ? Array(journey.actions.prefix(3)) : journey.actions

        return VStack(alignment: .leading, spacing: 10) {
            Text(sample ? localized("premium.journey.preview_title", default: "See the Guided Seasonal Journey") : localized("premium.journey.current_title", default: "Your Guided Seasonal Journey"))
                .appSectionTitleStyle(serif: true)

            Text(
                sample
                    ? localized("premium.journey.preview_intro", default: "This preview shows how premium turns the current season into one steady weekly rhythm.")
                    : localized("premium.journey.current_intro", default: "Premium keeps the current week visible so you know what to do next without rebuilding the whole plan.")
            )
                .appSupportingTextStyle()

            VStack(alignment: .leading, spacing: 6) {
                Text(sample
                    ? localizedFormat("premium.journey.preview_week_format", default: "Preview journey week: %@", journey.title)
                    : localizedFormat("premium.journey.current_week_format", default: "Current journey week: %@", journey.title))
                    .font(.subheadline.weight(.semibold))
                Text(sample ? localized("premium.journey.preview_eyebrow", default: "Seasonal rhythm") : localized("premium.journey.current_eyebrow", default: "Current weekly rhythm"))
                    .appEyebrowStyle()
                Text(journey.summary)
                    .appSupportingTextStyle()

                ForEach(previewActions, id: \.id) { action in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: sample ? "circle" : (isPremiumJourneyActionCompleted(action) ? "checkmark.circle.fill" : "circle"))
                            .foregroundStyle(sample ? CatholicTheme.primary : (isPremiumJourneyActionCompleted(action) ? .green : CatholicTheme.primary))
                            .padding(.top, 2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(action.category.label)
                                .appEyebrowStyle()
                            Text(action.title)
                                .font(.subheadline.weight(.semibold))
                            Text(action.detail)
                                .appSupportingTextStyle()
                        }
                    }
                }
            }

            if sample {
                Text(localized("premium.journey.preview_hint", default: "Preview only. Unlock premium below to track progress, keep the current week, and carry the journey through the season."))
                    .appSupportingTextStyle()
            } else {
                Text(premiumJourneyCompletionSummary)
                    .appSupportingTextStyle()
                if let nextAction = premiumGuidedJourneyNextAction {
                    Text(localizedFormat("premium.journey.next_step_format", default: "Next step: %@", nextAction.title))
                        .appEyebrowStyle()
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(CatholicTheme.parchment.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(CatholicTheme.cardBorder.opacity(0.4), lineWidth: 1)
        )
        .appRoundedGlass(cornerRadius: 16)
        .accessibilityIdentifier("premium.sample_preview")
        .onAppear {
            if launchFunnelSnapshot.premiumPreviewSeenAt == nil {
                launchFunnelSnapshot.premiumPreviewSeenAt = Date()
            }
        }
    }

    func premiumPillarCard(for pillar: SubscriptionOfferCatalog.Pillar) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(pillar.title, systemImage: premiumIconName(for: pillar.requiredSurface))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CatholicTheme.primary)

            Text(pillar.subtitle)
                .appSupportingTextStyle()

            ForEach(pillar.outcomes, id: \.self) { outcome in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .appSymbolStyle(.subtle)
                        .foregroundStyle(CatholicTheme.accent)
                        .padding(.top, 5)
                    Text(outcome)
                        .appSupportingTextStyle()
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(CatholicTheme.parchment.opacity(0.86))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(CatholicTheme.cardBorder.opacity(0.4), lineWidth: 1)
        )
    }

    #if canImport(StoreKit)
        func premiumOfferCard(product: Product, offer: SubscriptionOfferCatalog.Offer?) -> some View {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(offer?.displayTitle ?? product.displayName)
                            .appSectionTitleStyle(serif: offer?.isPrimaryAnchor == true)
                        Text(product.displayPrice)
                            .appMetricValueStyle()
                        Text(offer?.billingCadenceLabel ?? localized("premium.offer.auto_renew", default: "Auto-renewing subscription"))
                            .appSupportingTextStyle()
                    }

                    Spacer()

                    if offer?.isPrimaryAnchor == true {
                        Text(localized("premium.offer.best_value", default: "Best value"))
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(CatholicTheme.accent.opacity(0.18)))
                            .foregroundStyle(CatholicTheme.primary)
                    }
                }

                if offer?.isPrimaryAnchor == true {
                    Text(offer?.outcomeSummary ?? localized("premium.offer.best_value_summary", default: "Best value for one steady rhythm through the Church year."))
                        .appSupportingTextStyle()
                        .foregroundStyle(CatholicTheme.primary.opacity(0.9))
                } else if let summary = offer?.outcomeSummary {
                    Text(summary)
                        .appSupportingTextStyle()
                        .lineLimit(2)
                }

                Button(localizedFormat("premium.offer.unlock_format", default: "Unlock %@ • %@", offer?.displayTitle ?? product.displayName, product.displayPrice)) {
                    Task {
                        await monetizationStore.purchase(product)
                    }
                }
                .appPrimaryButtonStyle(legacyTint: offer?.isPrimaryAnchor == true ? CatholicTheme.primary : CatholicTheme.accent)
                .disabled(monetizationStore.isPurchasing)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appSurfaceCard(offer?.isPrimaryAnchor == true ? .primary : .standard, cornerRadius: 16)
        }
    #endif

    var premiumTipsSupportCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localized("premium.tips.title", default: "Optional support tips"))
                .appEyebrowStyle()

            Text(localized("premium.tips.summary", default: "Tips support ongoing development and do not unlock features."))
                .appSupportingTextStyle()

            ForEach(monetizationStore.tipProducts, id: \.id) { product in
                Button(localizedFormat("premium.tips.send_tip_format", default: "Send Tip • %@", product.displayPrice)) {
                    Task {
                        await monetizationStore.purchase(product)
                    }
                }
                .appSecondaryButtonStyle()
                .disabled(monetizationStore.isPurchasing)
                .accessibilityIdentifier("premium.tip.\(product.id)")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(.utility, cornerRadius: 16)
        .accessibilityIdentifier("premium.tips_card")
    }

    var premiumLegalSupportCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(localized("premium.legal.title", default: "Restore / Manage / Legal"))
                .appEyebrowStyle()

            Text(localized("premium.legal.summary", default: "Use these after choosing a plan if you need to restore billing or open legal links."))
                .appSupportingTextStyle()

            Button(localized("premium.legal.restore", default: "Restore Purchases")) {
                Task {
                    await monetizationStore.restorePurchases()
                }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
            .accessibilityIdentifier("premium.restore")

            Button(localized("premium.legal.manage", default: "Manage Subscription")) {
                Task {
                    await monetizationStore.openManageSubscriptions()
                }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
            .accessibilityIdentifier("premium.manage")

            Link(localized("premium.legal.terms", default: "Terms of Use (EULA)"), destination: UIConstants.termsOfUseURL)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.legal.terms")
            Link(localized("premium.legal.privacy", default: "Privacy Policy"), destination: UIConstants.privacyPolicyURL)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.legal.privacy")
            Link(localized("premium.legal.support", default: "Support"), destination: UIConstants.supportSiteURL)
                .appSupportingTextStyle()
                .accessibilityIdentifier("premium.legal.support")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appSurfaceCard(.utility, cornerRadius: 16)
    }

    func premiumIconName(for surface: PremiumEntitlementSurface) -> String {
        switch surface {
        case .planning:
            "calendar.badge.clock"
        case .accountability:
            "chart.bar.xaxis"
        case .reflection:
            "book.closed"
        case .export:
            "square.and.arrow.up"
        }
    }

    func premiumTrustPill(text: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(CatholicTheme.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(CatholicTheme.accent.opacity(0.12))
        )
    }

    #if canImport(StoreKit)
        private func subscriptionPeriodSuffix(for product: Product) -> String {
            guard let period = product.subscription?.subscriptionPeriod else { return "" }
            let unitText =
                switch period.unit {
                case .day: "day"
                case .week: "week"
                case .month: "month"
                case .year: "year"
                @unknown default: "period"
                }
            let count = period.value
            if count == 1 {
                return " per \(unitText)"
            }
            return " per \(count) \(unitText)s"
        }
    #endif

    var premiumChecklistSection: some View {
        Section("Consistency Checklist") {
            Text("Keep one clear next step visible instead of carrying the whole season in your head.")
                .font(.caption)
                .foregroundStyle(.secondary)
            if !monetizationStore.premiumUnlocked {
                Text("Unlock Premium to keep a focused consistency checklist.")
                    .foregroundStyle(.secondary)
            } else {
                if premiumChecklist.isEmpty {
                    Text("No checklist items yet. Add one to keep your next Catholic fasting step visible.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(premiumChecklist) { item in
                        Button {
                            toggleChecklistItem(item.id)
                        } label: {
                            HStack {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isDone ? .green : .secondary)
                                Text(item.title)
                                    .strikethrough(item.isDone, color: .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("premium.checklist.\(item.id)")
                    }
                }
                Button("Add Suggested Checklist Item") {
                    premiumChecklist.append(
                        PremiumChecklistItem(
                            id: UUID().uuidString,
                            title: "Review upcoming required observances for next 30 days",
                            isDone: false
                        )
                    )
                }
                .appSecondaryButtonStyle()
            }
        }
    }

    var reflectionJournalSection: some View {
        Section("Reflection & Review (Local)") {
            if !monetizationStore.premiumUnlocked {
                Text("Premium unlocks local reflection and review tools.")
                    .foregroundStyle(.secondary)
            } else {
                Text("Keep reflections short. The goal is consistency, not long journaling.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("Reflection title", text: $newReflectionTitle)
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("premium.journal.title")
                TextField("Write a short reflection", text: $newReflectionBody, axis: .vertical)
                    .lineLimit(2 ... 5)
                    .accessibilityIdentifier("premium.journal.body")
                Button("Save Reflection") {
                    addReflectionEntry()
                }
                .appPrimaryButtonStyle()
                .disabled(!canSaveReflection)
                .accessibilityIdentifier("premium.journal.save")

                if reflectionEntries.isEmpty {
                    Text("No reflections yet. Capture one short line after your fast to build a faithful habit.")
                        .foregroundStyle(.secondary)
                } else {
                    DisclosureGroup("Recent reflections") {
                        ForEach(reflectionEntries.prefix(5)) { entry in
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
                    Label("Export Season Plan (Text)", systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)
            }
        }
    }

    var premiumPlannerSection: some View {
        Section("Discipline Planner") {
            Text("Set a realistic season path, cadence, and guardrails.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            DisclosureGroup("Planner controls") {
                Picker(
                    "Rule Template",
                    selection: Binding(
                        get: { selectedPremiumTemplate },
                        set: { applyPremiumRuleTemplate($0) }
                    )
                ) {
                    ForEach(PremiumRuleTemplate.allCases) { template in
                        Text(template.label).tag(template)
                    }
                }
                .pickerStyle(.menu)

                Stepper("Optional disciplines/week: \(premiumCompanion.optionalDisciplinesPerWeek)", value: $premiumCompanion.optionalDisciplinesPerWeek, in: 0 ... 7)
                Stepper("Fixed personal fast day: \(weekdayLabel(for: premiumCompanion.fixedFastWeekday))", value: $premiumCompanion.fixedFastWeekday, in: 1 ... 7)
                Toggle("Protect feast/holy days from personal fasts", isOn: $premiumCompanion.protectFeastDays)
            }

            Text(premiumAdaptivePlan.title)
                .font(.subheadline.weight(.semibold))
            Text(premiumAdaptivePlan.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(premiumAdaptivePlan.weeklyActions, id: \.self) { action in
                Text("• \(action)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(premiumAdaptivePlan.caution)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Divider()

            Text("Season Plan: \(premiumSeasonPlan.titleLine)")
                .font(.subheadline.weight(.semibold))
            Text(premiumSeasonPlan.focusLine)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Intensity: \(premiumSeasonPlan.fastingIntensity)")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(premiumSeasonPlan.practices, id: \.self) { practice in
                Text("• \(practice)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("premium.planner")
    }

    var premiumRemindersSection: some View {
        Section("Reminders") {
            Text("Start with the recommendation first. Use advanced rules only if you need more pressure or structure.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Smart Recommendation")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(premiumReminderRecommendation.summaryLine)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(
                "Daily support: \(premiumReminderRecommendation.shouldEnableDailySupport ? "On" : "Off") • Morning: \(premiumReminderRecommendation.shouldEnableMorning ? "On" : "Off") • Evening: \(premiumReminderRecommendation.shouldEnableEvening ? "On" : "Off")"
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            Button("Apply Smart Reminder Plan") {
                applyPremiumReminderRecommendation()
            }
            .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
            .accessibilityIdentifier("premium.apply_reminder_plan")

            DisclosureGroup("Advanced reminder rules") {
                Toggle("Remind if no fasting log by noon", isOn: $premiumCompanion.conditionRules.remindIfUnloggedByNoon)
                Toggle("Double reminders on required days", isOn: $premiumCompanion.conditionRules.requiredDaysDoubleReminder)
                Toggle("Milestone nudges during active fast", isOn: $premiumCompanion.conditionRules.milestoneNudgesForActiveFast)

                Button("Apply Condition Rules") {
                    applyPremiumConditionRules()
                }
                .appSecondaryButtonStyle()
            }

            if !premiumCoachStatus.isEmpty {
                Text(premiumCoachStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("premium.coach_status")
            }
            if !premiumCompanionStatus.isEmpty {
                Text(premiumCompanionStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("premium.reminders")
    }

    var premiumAnalyticsSection: some View {
        Section("Analytics") {
            Text("Review completion, consistency, and seasonal trend lines.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Required completion: \(premiumAnalyticsSummary.requiredCompletionPercent)%")
                .font(.caption)
            Text("Overall completion: \(premiumAnalyticsSummary.overallCompletionPercent)%")
                .font(.caption)
            Text("Missed: \(premiumAnalyticsSummary.missedCount) • Substituted: \(premiumAnalyticsSummary.substitutedCount)")
                .font(.caption)
            Text("Intermittent target hits: \(premiumAnalyticsSummary.intermittentTargetHitPercent)%")
                .font(.caption)

            if !premiumAnalyticsSummary.seasonRows.isEmpty {
                DisclosureGroup("Season-by-season breakdown") {
                    ForEach(premiumAnalyticsSummary.seasonRows) { row in
                        Text("\(row.season.label): \(row.completionPercent)% (\(row.completedCount)/\(row.totalCount))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .accessibilityIdentifier("premium.analytics")
    }

    var premiumRecoveryCoachSection: some View {
        Section("Recovery Coaching") {
            Text(premiumRecoveryCoachPlan.title)
                .font(.subheadline.weight(.semibold))
            Text(premiumRecoveryCoachPlan.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(premiumRecoveryCoachPlan.steps, id: \.self) { step in
                Text("• \(step)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("premium.recovery")
    }

    var premiumReflectionPromptSection: some View {
        Section("Daily Premium Reflection") {
            Text(premiumReflection.title)
                .font(.subheadline.weight(.semibold))
            Text(premiumReflection.body)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Action: \(premiumReflection.action)")
                .font(.caption)
                .foregroundStyle(CatholicTheme.primary)
        }
        .accessibilityIdentifier("premium.reflection")
    }

    var premiumVirtueTrackingSection: some View {
        Section("Virtue Check-ins") {
            Text("Use one short note to connect fasting effort with a concrete virtue.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Virtue", selection: $selectedVirtue) {
                ForEach(["Temperance", "Patience", "Charity", "Humility", "Obedience"], id: \.self) { virtue in
                    Text(virtue).tag(virtue)
                }
            }
            .pickerStyle(.menu)

            TextField("Virtue note", text: $newVirtueNote, axis: .vertical)
                .lineLimit(2 ... 4)
            Button("Log Virtue Check-in") {
                addPremiumVirtueLog()
            }
            .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
            .disabled(newVirtueNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if premiumCompanion.virtueLogs.isEmpty {
                Text("No virtue check-ins yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(premiumCompanion.virtueLogs.prefix(5)) { log in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(log.virtue) • \(log.createdAt.formatted(date: .abbreviated, time: .shortened))")
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

    var premiumExportSummarySection: some View {
        Section("Export Summary") {
            ShareLink(
                item: premiumDirectionSummaryText,
                subject: Text("Catholic Fasting Summary"),
                message: Text("Structured fasting summary for personal review.")
            ) {
                Label("Export Fasting Summary", systemImage: "square.and.arrow.up")
            }
            .appSecondaryButtonStyle()
            .disabled(!acceptedLegalNotice)
            .accessibilityIdentifier("premium.export_summary")

            Text("Use this when you want one concise snapshot for personal review or spiritual conversation.")
                .font(.caption)
                .foregroundStyle(.secondary)

            if !acceptedLegalNotice {
                Text("Enable consent in Privacy & Data before exporting premium summaries.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var premiumAdvancedExportSection: some View {
        Section("Advanced Exports") {
            DisclosureGroup("Weekly and monthly reports") {
                ShareLink(
                    item: premiumWeeklySummaryText,
                    subject: Text("Catholic Fasting Weekly Report"),
                    message: Text("Weekly fasting summary from Premium.")
                ) {
                    Label("Export Weekly Report", systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)

                ShareLink(
                    item: premiumMonthlySummaryText,
                    subject: Text("Catholic Fasting Monthly Report"),
                    message: Text("Monthly fasting summary from Premium.")
                ) {
                    Label("Export Monthly Report", systemImage: "square.and.arrow.up")
                }
                .appSecondaryButtonStyle()
                .disabled(!acceptedLegalNotice)
            }
        }
    }

    var premiumHouseholdShareSection: some View {
        Section("Household Share (Local)") {
            Text("This is a local transfer tool for households sharing one device workflow. It is not cloud sync.")
                .font(.caption)
                .foregroundStyle(.secondary)
            DisclosureGroup("Share code tools") {
                Button("Generate Local Share Code") {
                    generatePremiumHouseholdShareCode()
                }
                .appSecondaryButtonStyle()
                if !premiumHouseholdExportCode.isEmpty {
                    Text(premiumHouseholdExportCode)
                        .font(.caption2.monospaced())
                        .textSelection(.enabled)
                }
                TextField("Paste household share code", text: $premiumHouseholdImportCode, axis: .vertical)
                    .lineLimit(2 ... 6)
                Button("Import Household Code (Local)") {
                    importPremiumHouseholdShareCode()
                }
                .appSecondaryButtonStyle()
                .disabled(premiumHouseholdImportCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if !premiumCompanionStatus.isEmpty {
                Text(premiumCompanionStatus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var premiumSeasonPlan: PremiumSeasonPlan {
        PremiumSeasonPlanEngine.plan(for: currentLiturgicalSeason, settings: settings)
    }

    var selectedPremiumTemplate: PremiumRuleTemplate {
        PremiumRuleTemplate(rawValue: premiumCompanion.templateRawValue) ?? .steady
    }

    var selectedPremiumSeasonProgram: PremiumSeasonProgram {
        PremiumSeasonProgram(rawValue: premiumCompanion.seasonProgramRawValue) ?? .liturgicalRhythm
    }

    var premiumProgramWeek: Int {
        let days =
            liturgicalCalendar.dateComponents(
                [.day],
                from: liturgicalCalendar.startOfDay(for: premiumCompanion.seasonProgramStartDate),
                to: liturgicalCalendar.startOfDay(for: Date())
            ).day ?? 0
        return max(1, (days / 7) + 1)
    }

    var premiumAdaptivePlan: PremiumAdaptiveRulePlan {
        PremiumAdaptiveRulePlanner.plan(
            season: currentLiturgicalSeason,
            settings: settings,
            template: selectedPremiumTemplate,
            optionalDisciplinesPerWeek: premiumCompanion.optionalDisciplinesPerWeek,
            fixedFastWeekday: premiumCompanion.fixedFastWeekday,
            protectFeastDays: premiumCompanion.protectFeastDays
        )
    }

    var premiumReminderRecommendation: PremiumReminderRecommendation {
        PremiumReminderPlanner.recommendation(
            observances: currentYearObservances,
            statusesByID: tracker.statusesByID
        )
    }

    var premiumConditionRuleRecommendation: PremiumReminderRecommendation {
        PremiumConditionReminderAdvisor.applyRules(
            premiumCompanion.conditionRules,
            hasUpcomingRequiredDays: upcomingMandatoryObservance != nil
        )
    }

    var premiumAnalyticsSummary: PremiumAnalyticsSummary {
        PremiumAnalyticsEngine.summary(
            observances: currentYearObservances,
            statusesByID: tracker.statusesByID,
            sessions: intermittentTracker.sessions
        )
    }

    var premiumReflection: PremiumReflection {
        PremiumReflectionEngine.reflection(
            season: currentLiturgicalSeason
        )
    }

    var premiumRecoveryCoachPlan: PremiumRecoveryCoachPlan {
        PremiumRecoveryCoachEngine.plan(
            missedPlan: missedDayRecoveryPlan,
            season: currentLiturgicalSeason
        )
    }

    var premiumSeasonProgramActions: [String] {
        PremiumSeasonProgramEngine.actions(
            for: selectedPremiumSeasonProgram,
            week: premiumProgramWeek
        )
    }

    var premiumGuidedJourneyWeek: GuidedSeasonalJourneyWeek {
        GuidedSeasonalJourneyEngine.week(
            for: currentLiturgicalSeason,
            program: selectedPremiumSeasonProgram,
            week: premiumProgramWeek
        )
    }

    var premiumJourneyCompletedCount: Int {
        premiumGuidedJourneyWeek.actions.filter(isPremiumJourneyActionCompleted).count
    }

    var premiumGuidedJourneyNextAction: GuidedSeasonalJourneyAction? {
        premiumGuidedJourneyWeek.actions.first(where: { !isPremiumJourneyActionCompleted($0) })
    }

    var premiumJourneyCompletionSummary: String {
        let total = premiumGuidedJourneyWeek.actions.count
        let done = premiumJourneyCompletedCount
        if done == total {
            return "This week is complete. Reuse the review prompt and carry the rhythm into the next week."
        }
        return "\(done) of \(total) journey actions completed this week."
    }

    var premiumPrepAndRefeedGuidance: [String] {
        PremiumFastPrepGuidanceEngine.prepAndRefeed(
            targetHours: intermittentTracker.presetHours,
            hasMedicalDispensation: settings.hasMedicalDispensation
        )
    }

    var premiumMotivationLine: String {
        PremiumMotivationEngine.line(
            season: currentLiturgicalSeason,
            streak: currentStreak,
            template: selectedPremiumTemplate
        )
    }

    var premiumDirectionSummaryText: String {
        PremiumDirectionSummaryEngine.summaryText(
            season: currentLiturgicalSeason,
            analytics: premiumAnalyticsSummary,
            reminder: premiumReminderRecommendation,
            plan: premiumSeasonPlan,
            latestReflection: premiumReflection
        )
    }

    var premiumWeeklySummaryText: String {
        let start = liturgicalCalendar.date(byAdding: .day, value: -6, to: Date()) ?? Date()
        let weeklyObservances = currentYearObservances.filter { $0.date >= start && $0.date <= Date() }
        let completed = weeklyObservances.filter { tracker.status(for: $0.id).countsTowardProgress }.count
        return [
            "Catholic Fasting Weekly Report",
            "Week ending \(Date().formatted(date: .abbreviated, time: .omitted))",
            "",
            "Completed observances: \(completed)/\(weeklyObservances.count)",
            "Current streak: \(currentStreak) day(s)",
            "Template: \(selectedPremiumTemplate.label)",
            "Program: \(selectedPremiumSeasonProgram.label) (Week \(premiumProgramWeek))",
            "Motivation: \(premiumMotivationLine)",
        ].joined(separator: "\n")
    }

    var premiumMonthlySummaryText: String {
        let month = liturgicalCalendar.component(.month, from: Date())
        let year = liturgicalCalendar.component(.year, from: Date())
        let monthlyObservances = currentYearObservances.filter {
            liturgicalCalendar.component(.month, from: $0.date) == month
                && liturgicalCalendar.component(.year, from: $0.date) == year
        }
        let completed = monthlyObservances.filter { tracker.status(for: $0.id).countsTowardProgress }.count
        return [
            "Catholic Fasting Monthly Report",
            "Month: \(Date().formatted(.dateTime.month(.wide).year()))",
            "",
            "Completed observances: \(completed)/\(monthlyObservances.count)",
            "Required completion: \(premiumAnalyticsSummary.requiredCompletionPercent)%",
            "Overall completion: \(premiumAnalyticsSummary.overallCompletionPercent)%",
            "Intermittent target hit rate: \(premiumAnalyticsSummary.intermittentTargetHitPercent)%",
            "Motivation: \(premiumMotivationLine)",
        ].joined(separator: "\n")
    }

    func applyPremiumReminderRecommendation() {
        let recommendation = premiumReminderRecommendation
        dailyReminderSupportEnabled = recommendation.shouldEnableDailySupport
        morningReminderEnabled = recommendation.shouldEnableMorning
        eveningReminderEnabled = recommendation.shouldEnableEvening
        syncReminderTierFromCurrentToggleState()
        premiumCoachStatus = recommendation.summaryLine
    }

    func applyPremiumConditionRules() {
        let recommendation = premiumConditionRuleRecommendation
        dailyReminderSupportEnabled = recommendation.shouldEnableDailySupport
        morningReminderEnabled = recommendation.shouldEnableMorning
        eveningReminderEnabled = recommendation.shouldEnableEvening
        syncReminderTierFromCurrentToggleState()
        premiumCompanionStatus = recommendation.summaryLine
    }

    func applyPremiumRuleTemplate(_ template: PremiumRuleTemplate) {
        premiumCompanion.templateRawValue = template.rawValue
        switch template {
        case .beginner:
            premiumCompanion.optionalDisciplinesPerWeek = 1
        case .steady:
            premiumCompanion.optionalDisciplinesPerWeek = 2
        case .disciplined:
            premiumCompanion.optionalDisciplinesPerWeek = 3
        case .traditional:
            premiumCompanion.optionalDisciplinesPerWeek = 4
        case .custom:
            break
        }
        premiumCompanionStatus = "\(template.label) template applied."
    }

    func togglePremiumSeasonProgramAction(_ action: String) {
        let key = GuidedSeasonalJourneyEngine.actionKey(
            program: selectedPremiumSeasonProgram,
            week: premiumProgramWeek,
            actionID: action
        )
        if premiumCompanion.completedProgramActions.contains(key) {
            premiumCompanion.completedProgramActions.removeAll { $0 == key }
        } else {
            premiumCompanion.completedProgramActions.append(key)
        }
    }

    func isPremiumSeasonProgramActionCompleted(_ action: String) -> Bool {
        let key = GuidedSeasonalJourneyEngine.actionKey(
            program: selectedPremiumSeasonProgram,
            week: premiumProgramWeek,
            actionID: action
        )
        return premiumCompanion.completedProgramActions.contains(key)
    }

    func togglePremiumJourneyAction(_ action: GuidedSeasonalJourneyAction) {
        togglePremiumSeasonProgramAction(action.id)
    }

    func isPremiumJourneyActionCompleted(_ action: GuidedSeasonalJourneyAction) -> Bool {
        isPremiumSeasonProgramActionCompleted(action.id)
    }

    func restartPremiumSeasonProgram() {
        premiumCompanion.seasonProgramStartDate = Date()
        premiumCompanion.completedProgramActions = []
        premiumCompanionStatus = "\(selectedPremiumSeasonProgram.label) restarted."
    }

    func addPremiumVirtueLog() {
        let trimmed = newVirtueNote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        premiumCompanion.virtueLogs.insert(
            PremiumVirtueLog(
                id: UUID().uuidString,
                createdAt: Date(),
                virtue: selectedVirtue,
                note: trimmed
            ),
            at: 0
        )
        newVirtueNote = ""
    }

    func deletePremiumVirtueLog(_ log: PremiumVirtueLog) {
        premiumCompanion.virtueLogs.removeAll { $0.id == log.id }
    }

    func generatePremiumHouseholdShareCode() {
        let packet = PremiumHouseholdSharePacket(
            generatedAt: Date(),
            planningData: planningData,
            schedules: intermittentSchedules,
            checklist: premiumChecklist
        )
        guard let data = try? JSONEncoder().encode(packet) else {
            premiumCompanionStatus = "Could not generate household share code."
            return
        }
        premiumHouseholdExportCode = data.base64EncodedString()
        premiumCompanionStatus = "Household share code generated."
    }

    func importPremiumHouseholdShareCode() {
        let code = premiumHouseholdImportCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty, let data = Data(base64Encoded: code) else {
            premiumCompanionStatus = "Invalid share code."
            return
        }
        guard let packet = try? JSONDecoder().decode(PremiumHouseholdSharePacket.self, from: data) else {
            premiumCompanionStatus = "Could not decode household packet."
            return
        }
        planningData = packet.planningData
        intermittentSchedules = packet.schedules
        premiumChecklist = packet.checklist
        premiumCompanionStatus = "Household packet imported locally."
    }

    var premiumCompanionLabSection: some View {
        Section("Premium Companion Lab") {
            if !monetizationStore.premiumUnlocked {
                Text("Unlock Premium to access adaptive planning, advanced exports, season programs, virtue tracking, and private household sharing.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. Adaptive Rule-of-Life Planner")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Picker(
                        "Rule Template",
                        selection: Binding(
                            get: { selectedPremiumTemplate },
                            set: { applyPremiumRuleTemplate($0) }
                        )
                    ) {
                        ForEach(PremiumRuleTemplate.allCases) { template in
                            Text(template.label).tag(template)
                        }
                    }
                    .pickerStyle(.menu)

                    Stepper("Optional disciplines/week: \(premiumCompanion.optionalDisciplinesPerWeek)", value: $premiumCompanion.optionalDisciplinesPerWeek, in: 0 ... 7)
                    Stepper("Fixed personal fast day: \(weekdayLabel(for: premiumCompanion.fixedFastWeekday))", value: $premiumCompanion.fixedFastWeekday, in: 1 ... 7)
                    Toggle("Protect feast/holy days from personal fasts", isOn: $premiumCompanion.protectFeastDays)

                    Text(premiumAdaptivePlan.title)
                        .font(.subheadline.weight(.semibold))
                    Text(premiumAdaptivePlan.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(premiumAdaptivePlan.weeklyActions, id: \.self) { action in
                        Text("• \(action)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(premiumAdaptivePlan.caution)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("2. Condition-based Reminder Engine")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Toggle("Remind if no fasting log by noon", isOn: $premiumCompanion.conditionRules.remindIfUnloggedByNoon)
                    Toggle("Double reminders on required days", isOn: $premiumCompanion.conditionRules.requiredDaysDoubleReminder)
                    Toggle("Milestone nudges during active fast", isOn: $premiumCompanion.conditionRules.milestoneNudgesForActiveFast)

                    Button("Apply Condition Rules") {
                        applyPremiumConditionRules()
                    }
                    .appSecondaryButtonStyle()
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("3. Recovery Coaching")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(premiumRecoveryCoachPlan.title)
                        .font(.subheadline.weight(.semibold))
                    Text(premiumRecoveryCoachPlan.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(premiumRecoveryCoachPlan.steps, id: \.self) { step in
                        Text("• \(step)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("4. Advanced Export Pack")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ShareLink(
                        item: premiumWeeklySummaryText,
                        subject: Text("Catholic Fasting Weekly Report"),
                        message: Text("Weekly fasting summary from Premium.")
                    ) {
                        Label("Export Weekly Report", systemImage: "square.and.arrow.up")
                    }
                    .appSecondaryButtonStyle()
                    .disabled(!acceptedLegalNotice)

                    ShareLink(
                        item: premiumMonthlySummaryText,
                        subject: Text("Catholic Fasting Monthly Report"),
                        message: Text("Monthly fasting summary from Premium.")
                    ) {
                        Label("Export Monthly Report", systemImage: "square.and.arrow.up")
                    }
                    .appSecondaryButtonStyle()
                    .disabled(!acceptedLegalNotice)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("5. Premium Season Programs")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Picker("Season Program", selection: $premiumCompanion.seasonProgramRawValue) {
                        ForEach(PremiumSeasonProgram.allCases) { program in
                            Text(program.label).tag(program.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    Text("Current week: \(premiumProgramWeek)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(premiumSeasonProgramActions, id: \.self) { action in
                        Button {
                            togglePremiumSeasonProgramAction(action)
                        } label: {
                            Label(
                                action,
                                systemImage: isPremiumSeasonProgramActionCompleted(action)
                                    ? "checkmark.circle.fill" : "circle"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    Button("Restart Program Week Cycle") {
                        restartPremiumSeasonProgram()
                    }
                    .appSecondaryButtonStyle()
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("6. Personal Rule Templates")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(PremiumRuleTemplate.allCases) { template in
                        Button("Apply \(template.label) Template") {
                            applyPremiumRuleTemplate(template)
                        }
                        .appSecondaryButtonStyle()
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("7. Milestone + Virtue Tracking")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Picker("Virtue", selection: $selectedVirtue) {
                        ForEach(["Temperance", "Patience", "Charity", "Humility", "Obedience"], id: \.self) { virtue in
                            Text(virtue).tag(virtue)
                        }
                    }
                    .pickerStyle(.menu)
                    TextField("Virtue note", text: $newVirtueNote, axis: .vertical)
                        .lineLimit(2 ... 4)
                    Button("Log Virtue Check-in") {
                        addPremiumVirtueLog()
                    }
                    .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
                    .disabled(newVirtueNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    if premiumCompanion.virtueLogs.isEmpty {
                        Text("No virtue check-ins yet.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(premiumCompanion.virtueLogs.prefix(5)) { log in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(log.virtue) • \(log.createdAt.formatted(date: .abbreviated, time: .shortened))")
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

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("8. Home/Lock Motivation")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(premiumMotivationLine)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CatholicTheme.primary)
                    Text("This line is also pushed to the widget snapshot.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Button("Refresh Motivation in Widget") {
                        persistWidgetSnapshot()
                        premiumCompanionStatus = "Widget motivation refreshed."
                    }
                    .appSecondaryButtonStyle()
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("9. Fast Prep + Refeed Guidance")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("Plan target: \(intermittentTracker.presetHours)h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(premiumPrepAndRefeedGuidance, id: \.self) { item in
                        Text("• \(item)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("10. Private Household Mode (Local)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Button("Generate Local Share Code") {
                        generatePremiumHouseholdShareCode()
                    }
                    .appSecondaryButtonStyle()
                    if !premiumHouseholdExportCode.isEmpty {
                        Text(premiumHouseholdExportCode)
                            .font(.caption2.monospaced())
                            .textSelection(.enabled)
                    }
                    TextField("Paste household share code", text: $premiumHouseholdImportCode, axis: .vertical)
                        .lineLimit(2 ... 6)
                    Button("Import Household Code (Local)") {
                        importPremiumHouseholdShareCode()
                    }
                    .appSecondaryButtonStyle()
                    .disabled(premiumHouseholdImportCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if !premiumCompanionStatus.isEmpty {
                    Text(premiumCompanionStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
