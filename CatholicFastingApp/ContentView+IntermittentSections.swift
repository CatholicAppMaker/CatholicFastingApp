import SwiftUI

extension ContentView {
  var intermittentHeroSection: some View {
    Section {
      ZStack(alignment: .bottomLeading) {
        Image("HeroSacred")
          .resizable()
          .scaledToFill()
          .frame(height: 190)
          .clipped()
        LinearGradient(
          colors: [Color.clear, Color.black.opacity(0.6)],
          startPoint: .center,
          endPoint: .bottom
        )
        VStack(alignment: .leading, spacing: 4) {
          Label("Intermittent Fasting Companion", systemImage: "cross.case.fill")
            .font(.system(.headline, design: .serif))
            .foregroundStyle(.white)
          Text("Offer this fast with intention: prayer, almsgiving, and conversion.")
            .font(.caption)
            .foregroundStyle(.white.opacity(0.94))
        }
        .padding(12)
      }
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .overlay(
        RoundedRectangle(cornerRadius: 14)
          .stroke(CatholicTheme.cardBorder.opacity(0.6), lineWidth: 1)
      )
      .appRoundedGlass(cornerRadius: 14)
      .accessibilityIdentifier("intermittent.hero")
    }
  }

  var intermittentOverviewSection: some View {
    Section("Rule of Life") {
      Text("Use intermittent fasting as a personal discipline. Liturgical obligations remain in Calendar.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      ViewThatFits(in: .horizontal) {
        HStack {
          MetricTile(title: "Sessions", value: "\(intermittentTracker.sessions.count)")
          MetricTile(title: "Plan", value: intermittentWindowLabel)
          MetricTile(title: "Longest", value: intermittentLongestSessionText)
        }
        VStack(spacing: 8) {
          HStack {
            MetricTile(title: "Sessions", value: "\(intermittentTracker.sessions.count)")
            MetricTile(title: "Plan", value: intermittentWindowLabel)
          }
          MetricTile(title: "Longest", value: intermittentLongestSessionText)
        }
      }

      if let activeStart = intermittentTracker.activeStart {
        Text("Current fast began \(activeStart.formatted(date: .abbreviated, time: .shortened)).")
          .font(.caption)
          .foregroundStyle(CatholicTheme.primary.opacity(0.9))
      } else {
        Text("No active fast right now.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }

  var intermittentControlsSection: some View {
    Section("Fasting Plan") {
      Picker("Quick Plan", selection: intermittentPresetBinding) {
        ForEach([12, 14, 16, 18, 20, 24], id: \.self) { hours in
          Text(intermittentPlanDescription(hours)).tag(hours)
        }
      }
      .pickerStyle(.menu)
      .accessibilityIdentifier("intermittent.target_picker")

      if monetizationStore.premiumUnlocked {
        Stepper(value: intermittentPresetBinding, in: 12...336, step: 1) {
          VStack(alignment: .leading, spacing: 2) {
            Text("Custom target: \(intermittentTracker.presetHours)h")
            Text("Use for longer disciplines (up to 14 days / 336h).")
              .font(.caption2)
              .foregroundStyle(.secondary)
          }
        }
        .accessibilityIdentifier("intermittent.custom_target_stepper")
      } else {
        Text("Custom targets beyond preset plans are Premium.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      Text("Selected plan: \(intermittentWindowLabel)")
        .font(.caption)
        .foregroundStyle(.secondary)

      if intermittentTracker.activeStart == nil {
        Button {
          intermittentTracker.startFast()
          LocalAnalyticsStore.track(.intermittentFastStarted)
        } label: {
          Label("Start Fast Now", systemImage: "play.fill")
        }
        .appPrimaryButtonStyle()
        .accessibilityIdentifier("intermittent.start_fast")
      } else {
        HStack {
          Button {
            intermittentTracker.endFast()
          } label: {
            Label("End Fast", systemImage: "stop.fill")
          }
          .appPrimaryButtonStyle(legacyTint: .green)
          .accessibilityIdentifier("intermittent.end_fast")

          Button {
            intermittentTracker.cancelActiveFast()
          } label: {
            Label("Cancel", systemImage: "xmark")
          }
          .appSecondaryButtonStyle()
          .accessibilityIdentifier("intermittent.cancel_fast")
        }
      }
    }
  }

  var intermittentActiveSection: some View {
    Section("Active Fast") {
      if let start = intermittentTracker.activeStart {
        TimelineView(.periodic(from: .now, by: 1)) { context in
          let elapsed = context.date.timeIntervalSince(start)
          let targetSeconds = TimeInterval(intermittentTracker.presetHours * 3600)
          let progress = min(1.0, max(0.0, elapsed / targetSeconds))
          let targetDate = start.addingTimeInterval(targetSeconds)

          VStack(alignment: .leading, spacing: 8) {
            Text("Started: \(start.formatted(date: .abbreviated, time: .shortened))")
              .font(.caption)
              .foregroundStyle(.secondary)

            Text("Elapsed: \(durationText(elapsed))")
              .font(.headline)
              .foregroundStyle(CatholicTheme.primary)
              .accessibilityIdentifier("intermittent.active_elapsed")

            ProgressView(value: progress)
              .tint(progress >= 1 ? .green : CatholicTheme.accent)

            Text("Target time: \(targetDate.formatted(date: .abbreviated, time: .shortened))")
              .font(.caption)
              .foregroundStyle(.secondary)

            if elapsed >= targetSeconds {
              Text("Target reached. You may end your fast when ready.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.green)
                .accessibilityIdentifier("intermittent.target_reached")
            } else {
              Text("Remaining: \(durationText(targetSeconds - elapsed))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
          }
        }
      } else {
        Text("No active intermittent fast.")
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("intermittent.no_active")
      }
    }
  }

  var intermittentSessionHistorySection: some View {
    Section("Recent Sessions") {
      if intermittentTracker.sessions.isEmpty {
        Text("No sessions yet.")
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("intermittent.history_empty")
      } else {
        let sessionLimit = monetizationStore.premiumUnlocked ? 12 : 3
        ForEach(intermittentTracker.sessions.prefix(sessionLimit)) { session in
          HStack(alignment: .top, spacing: 10) {
            Image(systemName: session.completedTarget ? "checkmark.seal.fill" : "clock.badge.xmark.fill")
              .imageScale(.large)
              .foregroundStyle(session.completedTarget ? .green : .orange)
              .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
              Text("\(session.start.formatted(date: .abbreviated, time: .shortened)) → \(session.end.formatted(date: .abbreviated, time: .shortened))")
                .font(.subheadline.weight(.semibold))
              Text("Duration: \(durationText(session.duration)) • Plan: \(session.targetHours)h")
                .font(.caption)
                .foregroundStyle(.secondary)
              Text(session.completedTarget ? "Target met" : "Below target")
                .font(.caption)
                .foregroundStyle(session.completedTarget ? .green : .orange)
            }
            Spacer(minLength: 0)
          }
          .padding(.vertical, 4)
          .accessibilityIdentifier("intermittent.session_row")
        }

        if !monetizationStore.premiumUnlocked && intermittentTracker.sessions.count > 3 {
          Text("Unlock Premium to view full intermittent session history.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
  }
}
