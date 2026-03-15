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
        Section("Support & Premium") {
            Picker(
                "View",
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
                    ? "Choose a plan, send a tip, or manage billing."
                    : "Open premium planning, journaling, and exports."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    var premiumToolsLockedSection: some View {
        Section("Premium Tools") {
            Text("Unlock premium to open planning, reminders, analytics, journaling, and exports.")
                .foregroundStyle(.secondary)
            Button("Go to Upgrade") {
                openPremiumUpgrade(focusingOn: .planning)
            }
            .appPrimaryButtonStyle()
            .accessibilityIdentifier("premium.tools.go_to_upgrade")
        }
    }

    var premiumToolsHubSection: some View {
        Section("Formation Toolkit") {
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
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                .disabled(!hasPremiumEntitlement(surface))
                .accessibilityIdentifier("premium.tool.\(surface.rawValue)")
            }
        }
    }

    var premiumAndSupportSection: some View {
        Section("Premium Upgrade") {
            if monetizationStore.premiumUnlocked {
                premiumActiveStateCard
            } else {
                Text("Choose monthly or yearly below.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("premium.upgrade_summary")
                if monetizationStore.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Loading purchases…")
                    }
                    .font(.caption)
                }

                if !monetizationStore.premiumProducts.isEmpty {
                    ForEach(monetizationStore.premiumProducts, id: \.id) { product in
                        let offer = premiumOfferCatalog.offer(for: product.id)
                        premiumOfferCard(product: product, offer: offer)
                    }
                } else {
                    Text("Premium plans are temporarily unavailable. Try again in a moment, then use Restore Purchases if needed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !monetizationStore.tipProducts.isEmpty {
                    Text("Optional support tips")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    ForEach(monetizationStore.tipProducts, id: \.id) { product in
                        Button("Send Tip • \(product.displayPrice)") {
                            Task {
                                await monetizationStore.purchase(product)
                            }
                        }
                        .appSecondaryButtonStyle()
                        .disabled(monetizationStore.isPurchasing)
                    }
                }

                let loadedTipIDs = Set(monetizationStore.tipProducts.map(\.id))
                let missingTipIDs = MonetizationStore.tipProductIDs.subtracting(loadedTipIDs)
                if !missingTipIDs.isEmpty {
                    Text("Optional support tips may take a moment to appear after the App Store finishes loading.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
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
            Text("Premium is active.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("premium.active_summary")

            Button("Open Premium Tools") {
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
                title: monetizationStore.premiumUnlocked ? "Formation Toolkit Active" : "Formation Toolkit",
                subtitle: monetizationStore.premiumUnlocked
                    ? "Keep planning, recovery, reflection, and review in one focused Catholic workflow."
                    : "Build steadier fasting habits with planning, accountability, and reflection rooted in the Church year.",
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
                    .font(.title3)
                    .foregroundStyle(monetizationStore.premiumUnlocked ? .green : CatholicTheme.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(monetizationStore.premiumUnlocked ? "Premium active" : premiumOfferCatalog.title)
                        .font(.headline)
                    Text(
                        monetizationStore.premiumUnlocked
                            ? "Your planning, accountability, reflection, and export tools are unlocked."
                            : "Stay steady through the Church year with one clear premium path for planning, reminders, and review."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }

            if monetizationStore.premiumUnlocked {
                Button("Open Premium Tools") {
                    supportPremiumSurfaceRaw = SupportPremiumSurface.tools.rawValue
                }
                .appPrimaryButtonStyle()
                .accessibilityIdentifier("premium.open_tools")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Premium adds:")
                        .font(.caption.weight(.semibold))
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
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Why users upgrade")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    premiumTrustPill(text: "Local-only data", systemImage: "lock.shield")
                    premiumTrustPill(text: "No ads", systemImage: "nosign")
                    premiumTrustPill(text: "Cancel anytime", systemImage: "creditcard")
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

    var premiumSamplePreviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("See a sample premium plan")
                .font(.headline)
                .foregroundStyle(CatholicTheme.primary)

            Text("This sample shows the kind of planning and review support premium adds.")
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Sample season plan: Lenten Discipline Path")
                    .font(.subheadline.weight(.semibold))
                Text("Example weekly rhythm")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("• Keep the next required observance visible and scheduled ahead of time.")
                    .font(.caption)
                Text("• Add one personal discipline without overriding feast or memorial days.")
                    .font(.caption)
                Text("• Review the week with one reflection prompt and one accountability checkpoint.")
                    .font(.caption)
            }

            Text("Sample only. Unlock premium below.")
                .font(.caption)
                .foregroundStyle(.secondary)
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
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(pillar.outcomes, id: \.self) { outcome in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(CatholicTheme.accent)
                        .padding(.top, 5)
                    Text(outcome)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                            .font(.headline)
                            .foregroundStyle(CatholicTheme.primary)
                        Text(product.displayPrice)
                            .font(.title3.weight(.bold))
                        Text(offer?.billingCadenceLabel ?? "Auto-renewing subscription")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if offer?.isPrimaryAnchor == true {
                        Text("Best value")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(CatholicTheme.accent.opacity(0.18)))
                            .foregroundStyle(CatholicTheme.primary)
                    }
                }

                if offer?.isPrimaryAnchor == true {
                    Text("Best for one steady rhythm through the Church year.")
                        .font(.caption)
                        .foregroundStyle(CatholicTheme.primary.opacity(0.9))
                } else if let summary = offer?.outcomeSummary {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Button("Unlock \(offer?.displayTitle ?? product.displayName) • \(product.displayPrice)") {
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

    var premiumLegalSupportCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Restore / Manage / Legal")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Button("Restore Purchases") {
                Task {
                    await monetizationStore.restorePurchases()
                }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
            .accessibilityIdentifier("premium.restore")

            Button("Manage Subscription") {
                Task {
                    await monetizationStore.openManageSubscriptions()
                }
            }
            .appSecondaryButtonStyle()
            .disabled(monetizationStore.isPurchasing)
            .accessibilityIdentifier("premium.manage")

            Link("Terms of Use (EULA)", destination: UIConstants.termsOfUseURL)
                .font(.caption)
                .accessibilityIdentifier("premium.legal.terms")
            Link("Privacy Policy", destination: UIConstants.privacyPolicyURL)
                .font(.caption)
                .accessibilityIdentifier("premium.legal.privacy")
            Link("Support", destination: UIConstants.supportSiteURL)
                .font(.caption)
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
        let key = "\(selectedPremiumSeasonProgram.rawValue)-w\(premiumProgramWeek)-\(action)"
        if premiumCompanion.completedProgramActions.contains(key) {
            premiumCompanion.completedProgramActions.removeAll { $0 == key }
        } else {
            premiumCompanion.completedProgramActions.append(key)
        }
    }

    func isPremiumSeasonProgramActionCompleted(_ action: String) -> Bool {
        let key = "\(selectedPremiumSeasonProgram.rawValue)-w\(premiumProgramWeek)-\(action)"
        return premiumCompanion.completedProgramActions.contains(key)
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
