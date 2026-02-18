import SwiftUI

struct SacredImageryItem: Identifiable {
  let id: String
  let assetName: String
  let title: String
  let subtitle: String
}

enum SacredImageryCatalog {
  static let fastingGallery: [SacredImageryItem] = [
    SacredImageryItem(
      id: "chi-rho",
      assetName: "SacredChiRho",
      title: "Chi-Rho",
      subtitle: "Offer each fast in Christ."
    ),
    SacredImageryItem(
      id: "monstrance",
      assetName: "SacredMonstrance",
      title: "Monstrance",
      subtitle: "Let prayer anchor discipline."
    ),
    SacredImageryItem(
      id: "sacred-heart",
      assetName: "SacredSacredHeart",
      title: "Sacred Heart",
      subtitle: "Unite fasting to charity."
    ),
    SacredImageryItem(
      id: "rosary-cross",
      assetName: "SacredRosaryCross",
      title: "Rosary Cross",
      subtitle: "Pray while you abstain."
    ),
  ]
}

struct SacredImageryCard: View {
  let item: SacredImageryItem
  var width: CGFloat = 168
  var height: CGFloat = 176

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ZStack {
        RoundedRectangle(cornerRadius: 14)
          .fill(.thinMaterial)
          .overlay(
            RoundedRectangle(cornerRadius: 14)
              .fill(CatholicTheme.parchment.opacity(0.16))
          )
          .overlay(
            RoundedRectangle(cornerRadius: 14)
              .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1)
          )

        Image(item.assetName)
          .resizable()
          .scaledToFit()
          .padding(14)
      }
      .frame(height: height - 58)
      .appRoundedGlass(cornerRadius: 14)

      Text(item.title)
        .font(.system(.subheadline, design: .serif).weight(.semibold))
        .foregroundStyle(CatholicTheme.primary)
        .lineLimit(1)

      Text(item.subtitle)
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(2)
    }
    .frame(width: width, alignment: .leading)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(item.title). \(item.subtitle)")
  }
}

extension ContentView {
  var unofficialAppNoticeSection: some View {
    Section("Important Notice") {
      Text(
        "This is an independent devotional app. It is not an official app of the Catholic Church, USCCB, the Vatican, or any diocese/parish."
      )
      .font(.subheadline)
      .foregroundStyle(CatholicTheme.primary)

      Text(
        "Always follow your pastor, local bishop, and legitimate Church authority when guidance differs."
      )
      .font(.caption)
      .foregroundStyle(.secondary)
      .accessibilityIdentifier("notice.unofficial")
    }
  }

  var setupProgressSection: some View {
    guard !isQuickSetupComplete else {
      return AnyView(EmptyView())
    }

    return AnyView(
      Section("Finish Setup") {
        Text("Complete these once for clearer, safer guidance.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Text("Setup progress: \(setupChecklistCompleted)/\(setupChecklistTotal)")
          .font(.caption.weight(.semibold))
          .foregroundStyle(CatholicTheme.primary)
          .accessibilityIdentifier("today.setup.progress")

        setupChecklistRow(
          title: "Birth year set",
          isComplete: hasConfiguredBirthYear
        )
        setupChecklistRow(
          title: "Pastoral consent acknowledged",
          isComplete: hasConfiguredConsent
        )
        setupChecklistRow(
          title: "Reminder plan selected",
          isComplete: hasConfiguredReminderPlan
        )

        Button("Open Quick Setup") {
          homeSurface = .more
        }
        .appPrimaryButtonStyle()
        .accessibilityIdentifier("today.setup.open_quick_setup")
      }
    )
  }

  var dashboardSacredImageSection: some View {
    Section {
      ZStack(alignment: .bottomLeading) {
        Image("HeroSacred")
          .resizable()
          .scaledToFill()
          .frame(height: 210)
          .clipped()
        LinearGradient(
          colors: [.clear, Color.black.opacity(0.6)],
          startPoint: .center,
          endPoint: .bottom
        )
        VStack(alignment: .leading, spacing: 4) {
          Text("Christ Pantocrator")
            .font(.system(.headline, design: .serif))
            .foregroundStyle(.white)
          Text("Let your fasting be prayerful, intentional, and rooted in the Church.")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.92))
        }
        .padding(12)
      }
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .overlay(
        RoundedRectangle(cornerRadius: 14)
          .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1)
      )
      .appRoundedGlass(cornerRadius: 14)
      .accessibilityIdentifier("dashboard.sacred_image")
    }
  }

  var dashboardDevotionalGallerySection: some View {
    Section("Sacred Fasting Imagery") {
      Text("Keep these Catholic symbols in view as you pray, abstain, and fast.")
        .font(.caption)
        .foregroundStyle(.secondary)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(SacredImageryCatalog.fastingGallery) { item in
            SacredImageryCard(item: item)
          }
        }
        .padding(.vertical, 2)
      }
      .accessibilityIdentifier("dashboard.sacred_gallery")
    }
  }

  var readinessMarkers: some View {
    VStack(alignment: .leading, spacing: 0) {
      Color.clear
        .frame(width: 1, height: 1)
        .accessibilityIdentifier("home.ready")
      Color.clear
        .frame(width: 1, height: 1)
        .accessibilityIdentifier(surfaceReadyIdentifier)
    }
  }

  var surfaceReadyIdentifier: String {
    switch homeSurface {
    case .today:
      return "surface.today.ready"
    case .calendar:
      return "surface.calendar.ready"
    case .intermittent:
      return "surface.intermittent.ready"
    case .more:
      return "surface.more.ready"
    }
  }

  var dashboardHeroSection: some View {
    Section {
      VStack(alignment: .leading, spacing: 12) {
        Label("Daily Catholic Fasting Plan", systemImage: "cross.fill")
          .font(.system(.headline, design: .serif))
          .foregroundStyle(CatholicTheme.primary)
        Text(heroSummaryText)
          .font(.subheadline)
          .foregroundStyle(.secondary)
        Text("Offer each observance with prayer, fasting, and charity.")
          .font(.caption)
          .foregroundStyle(CatholicTheme.primary.opacity(0.85))
        ProgressView(value: completionRateValue)
          .tint(CatholicTheme.accent)
        ViewThatFits(in: .horizontal) {
          HStack(spacing: 8) {
            MetricTile(title: "Required", value: "\(mandatoryObservanceCount)")
            MetricTile(title: "Done", value: "\(completedCount)")
            MetricTile(title: "Streak", value: "\(currentStreak)d")
          }
          VStack(spacing: 8) {
            HStack(spacing: 8) {
              MetricTile(title: "Required", value: "\(mandatoryObservanceCount)")
              MetricTile(title: "Done", value: "\(completedCount)")
            }
            MetricTile(title: "Streak", value: "\(currentStreak)d")
          }
        }
      }
      .accessibilityIdentifier("dashboard.hero")
      .padding(.vertical, 4)
      .padding(.horizontal, 6)
      .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(CatholicTheme.accent.opacity(0.10))
      )
      .appRoundedGlass(cornerRadius: 12)
    }
  }

  var dashboardQuickActionsSection: some View {
    Section("Primary Actions") {
      Text("Choose what you want to do right now.")
        .font(.caption)
        .foregroundStyle(.secondary)

      Button {
        homeSurface = .calendar
      } label: {
        Label("Open Calendar", systemImage: "calendar")
      }
      .accessibilityIdentifier("today.quick.calendar")
      .appPrimaryButtonStyle()

      Button {
        homeSurface = .intermittent
      } label: {
        Label("Track Fast Now", systemImage: "timer")
      }
      .accessibilityIdentifier("today.quick.intermittent")
      .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)

      Button {
        homeSurface = .more
      } label: {
        Label("Open More Tools", systemImage: "ellipsis.circle")
      }
      .accessibilityIdentifier("today.quick.more")
      .appSecondaryButtonStyle()
    }
  }

  var todayDecisionCardSection: some View {
    let decision = todayFoodDecision
    return Section("What Can I Eat Today?") {
      Text(decision.obligationLine)
        .font(.headline)
        .foregroundStyle(CatholicTheme.primary)
        .accessibilityIdentifier("today.decision.obligation")

      if !decision.allowed.isEmpty {
        Text("Generally okay:")
          .font(.subheadline.weight(.semibold))
        ForEach(decision.allowed, id: \.self) { item in
          Label(item, systemImage: "checkmark.circle")
        }
      }

      if !decision.avoid.isEmpty {
        Text("Generally avoid:")
          .font(.subheadline.weight(.semibold))
        ForEach(decision.avoid, id: \.self) { item in
          Label(item, systemImage: "xmark.circle")
        }
      }

      Text("Why: \(decision.rationale)")
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(decision.sourceLine)
        .font(.caption)
        .foregroundStyle(.secondary)
      Link("Read official USCCB fast/abstinence guidance", destination: UIConstants.usccbFastAbstinenceURL)
    }
  }

  var todayRecoverySection: some View {
    guard let plan = missedDayRecoveryPlan else {
      return AnyView(EmptyView())
    }

    return AnyView(
      Section("Recovery Plan") {
        Text(plan.titleLine)
          .font(.headline)
          .foregroundStyle(CatholicTheme.primary)
          .accessibilityIdentifier("today.recovery.title")
        Text(plan.summaryLine)
          .font(.subheadline)
          .foregroundStyle(.secondary)
        ForEach(plan.steps, id: \.self) { step in
          Label(step, systemImage: "arrow.forward.circle")
        }
        Text(plan.nextRequiredLine)
          .font(.caption)
          .foregroundStyle(.secondary)

        Button("Mark Today as Recovery Substitute") {
          logRecoverySubstituteForToday()
        }
        .accessibilityIdentifier("today.recovery.mark_substitute")
        .appPrimaryButtonStyle(legacyTint: CatholicTheme.accent)
        .disabled(!canLogRecoverySubstituteToday)

        Button("Open Required Calendar Focus") {
          focusCalendarOnUpcomingRequired()
        }
        .accessibilityIdentifier("today.recovery.open_calendar")
        .appSecondaryButtonStyle()
      }
    )
  }

  var dashboardSeasonSection: some View {
    Section("Liturgical Season") {
      HStack(alignment: .top, spacing: 10) {
        Image(systemName: "sparkles")
          .font(.headline.weight(.semibold))
          .foregroundStyle(CatholicTheme.accent)
          .padding(.top, 2)

        VStack(alignment: .leading, spacing: 4) {
          Text(CatholicTheme.seasonLabel)
            .font(.system(.headline, design: .serif))
            .foregroundStyle(CatholicTheme.primary)
          Text("Offer your fasting with the spirit of this season through prayer, sacrifice, and charity.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }
      .padding(.vertical, 6)
      .padding(.horizontal, 8)
      .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(CatholicTheme.accent.opacity(0.10))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1)
      )
      .appRoundedGlass(cornerRadius: 12)
    }
  }

  var dashboardHighlightsSection: some View {
    Section("Overview") {
      Text("Completion rate: \(completionRateText)")
        .foregroundStyle(CatholicTheme.primary)
      Text("Current streak: \(currentStreak) day(s)")
        .foregroundStyle(CatholicTheme.primary.opacity(0.9))
      if let next = upcomingMandatoryObservance {
        Text("Next required: \(next.title) • \(next.date.formatted(date: .abbreviated, time: .omitted))")
          .foregroundStyle(.red.opacity(0.85))
      } else {
        Text("No upcoming required observances this year.")
          .foregroundStyle(.secondary)
      }
      Button("Open Calendar View") {
        homeSurface = .calendar
      }
      .accessibilityIdentifier("dashboard.open_calendar")
      .appPrimaryButtonStyle()
      Button("Focus Required (Next 30 Days)") {
        focusCalendarOnUpcomingRequired()
      }
      .accessibilityIdentifier("dashboard.focus_required")
      .appSecondaryButtonStyle(legacyTint: CatholicTheme.accent)
    }
  }

  @ViewBuilder
  private func setupChecklistRow(title: String, isComplete: Bool) -> some View {
    Label {
      Text(title)
    } icon: {
      Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
        .foregroundStyle(isComplete ? Color.green : Color.secondary)
    }
  }
}
