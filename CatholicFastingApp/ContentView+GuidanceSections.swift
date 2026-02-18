import SwiftUI

extension ContentView {
  var guidanceSacredImageSection: some View {
    Section {
      ZStack(alignment: .bottomLeading) {
        Image("GuidanceSacred")
          .resizable()
          .scaledToFill()
          .frame(height: 200)
          .clipped()
        LinearGradient(
          colors: [.clear, Color.black.opacity(0.58)],
          startPoint: .center,
          endPoint: .bottom
        )
        VStack(alignment: .leading, spacing: 4) {
          Text("St. Peter's Basilica")
            .font(.system(.headline, design: .serif))
            .foregroundStyle(.white)
          Text("Guidance should always be interpreted with pastoral direction.")
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
      .accessibilityIdentifier("guidance.sacred_image")
    }
  }

  var guidanceDevotionalGallerySection: some View {
    Section("Catholic Symbol Gallery") {
      Text("A visual prayer companion for fasting, abstinence, and penitential Fridays.")
        .font(.caption)
        .foregroundStyle(.secondary)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(SacredImageryCatalog.fastingGallery) { item in
            SacredImageryCard(item: item, width: 154, height: 166)
          }
        }
        .padding(.vertical, 2)
      }
      .accessibilityIdentifier("guidance.sacred_gallery")
    }
  }

  var foodGuidanceSection: some View {
    let recommendations = FoodGuidanceEngine.recommendations(
      for: guidanceScenario, settings: settings)
    return Section(localized("guidance.food_guidelines", default: "Today’s Guidance")) {
      Picker(localized("guidance.scenario", default: "Scenario"), selection: $guidanceScenario) {
        ForEach(GuidanceScenario.allCases) { scenario in
          Text(scenario.label).tag(scenario)
        }
      }
      .accessibilityIdentifier("guidance.scenario")

      ForEach(recommendations, id: \.self) { line in
        Text(line)
      }
    }
  }

  var guidanceSeasonContextSection: some View {
    Section("Seasonal Intention") {
      HStack(alignment: .top, spacing: 10) {
        Image(systemName: "leaf")
          .font(.headline.weight(.semibold))
          .foregroundStyle(CatholicTheme.accent)
          .padding(.top, 2)
        VStack(alignment: .leading, spacing: 4) {
          Text("Current season: \(CatholicTheme.seasonLabel)")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(CatholicTheme.primary)
          Text("Let your food discipline match the Church’s prayer in this season.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
  }

  var fastDayQuickRulesSection: some View {
    Section("Fast Day Quick Rules") {
      Label(
        "Abstinence means no meat from land animals (beef, pork, chicken, turkey).",
        systemImage: "xmark.circle")
      Label("Fish and shellfish are generally permitted.", systemImage: "checkmark.circle")
      Label(
        "Fasting usually means one full meal plus up to two small meals.", systemImage: "fork.knife"
      )
      Label(
        "If health or duty makes fasting unsafe, speak with your pastor.", systemImage: "cross.case"
      )
    }
  }

  var usccbGuidelinesSection: some View {
    Section(localized("guidance.usccb.title", default: "USCCB Fast & Abstinence (Official)")) {
      Text(
        "This app references USCCB materials but is not affiliated with or published by the USCCB."
      )
      .foregroundStyle(.secondary)
      Text(
        localized(
          "guidance.usccb.summary",
          default:
            "USCCB states that Ash Wednesday and Good Friday are obligatory days of fasting and abstinence for Latin Catholics."
        ))
      Label(
        localized(
          "guidance.usccb.fast_rule",
          default: "Fasting applies from age 18 until age 59."
        ),
        systemImage: "calendar.badge.clock"
      )
      Label(
        localized(
          "guidance.usccb.abstinence_rule",
          default: "Abstinence from meat applies from age 14 onward."
        ),
        systemImage: "fork.knife.circle"
      )
      Label(
        localized(
          "guidance.usccb.friday_rule",
          default: "Fridays in Lent are days of abstinence."
        ),
        systemImage: "calendar"
      )
      Text(
        localized(
          "guidance.usccb.dispensation_note",
          default: "Pastors and local bishops may give legitimate dispensations and local norms."
        )
      )
      .foregroundStyle(.secondary)
      Link(
        localized(
          "guidance.usccb.link_label", default: "Read Full USCCB Fast & Abstinence Guidelines"),
        destination: UIConstants.usccbFastAbstinenceURL
      )
    }
  }

  var practicalFoodExamplesSection: some View {
    Section("Practical Food Examples") {
      Text(
        "Usually okay: fish, eggs, dairy, vegetables, fruit, bread, grains, soups without meat stock."
      )
      Text(
        "Avoid on abstinence days: beef, pork, chicken, turkey, and foods clearly made from those meats."
      )
      Text(
        "When uncertain at restaurants, choose the simpler non-meat option and keep a penitential spirit."
      )
      .foregroundStyle(.secondary)
    }
  }

  var pastoralGuidanceSection: some View {
    Section(localized("guidance.pastoral_guidance", default: "Pastoral Guidance")) {
      Text(
        localized(
          "guidance.pastoral_line_1",
          default:
            "If you are pregnant, nursing, elderly, ill, under intense labor, or managing chronic conditions, seek pastoral and medical guidance before fasting."
        ))
      Text(
        localized(
          "guidance.pastoral_line_2",
          default:
            "Dispensations and substitutions are legitimate in many cases. This app is an aid, not your pastor."
        ))
      Text(
        localized(
          "guidance.pastoral_line_3",
          default: "When in doubt, choose obedience, charity, and prudence over private rigor."))
    }
  }

  var faqSection: some View {
    Section(localized("guidance.faq.title", default: "FAQ (With Sources)")) {
      Text(
        localized(
          "guidance.faq.q1",
          default:
            "Q: What are mandatory fast days in the Latin Church? A: Ash Wednesday and Good Friday."
        ))
      Text(
        localized(
          "guidance.faq.q2",
          default:
            "Q: What does abstinence mean? A: No meat from land animals; fish is generally permitted."
        ))
      Text(
        localized(
          "guidance.faq.q3",
          default:
            "Q: Do local bishops change rules? A: Yes, local norms and dispensations may apply."))
      Text(
        localized(
          "guidance.faq.sources", default: "Sources: USCCB pastoral statements and universal norms."
        )
      )
      .foregroundStyle(.secondary)
    }
  }

  var sourcesSection: some View {
    Section("Sources") {
      Link("USCCB Liturgical Calendar Guidance", destination: UIConstants.legalPolicyURL)
      Link(
        localized(
          "guidance.usccb.link_label", default: "Read Full USCCB Fast & Abstinence Guidelines"),
        destination: UIConstants.usccbFastAbstinenceURL
      )
      Link("Send Feedback", destination: UIConstants.supportEmail)
      Text(
        localized(
          "guidance.sources.local_decrees_note",
          default: "Always confirm local decrees for your location and year.")
      )
      .foregroundStyle(.secondary)
    }
  }
}
