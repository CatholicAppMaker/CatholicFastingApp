---
name: Catholic Fasting
description: Native Apple fasting guidance with seasonal sacred color, parchment surfaces, and calm devotional clarity.
colors:
  ordinary-primary: "#1A612B"
  ordinary-accent: "#B88F26"
  ordinary-parchment: "#F7F5DB"
  ordinary-parchment-shade: "#DBE6C2"
  ordinary-card-border: "#619657"
  advent-primary: "#1C337D"
  advent-accent: "#B85494"
  advent-parchment: "#F2F2FC"
  advent-parchment-shade: "#D6DBF5"
  advent-card-border: "#6670BA"
  christmas-primary: "#804A12"
  christmas-accent: "#D9A62E"
  christmas-parchment: "#FFFAEB"
  christmas-parchment-shade: "#F2E8C7"
  christmas-card-border: "#C79E3D"
  lent-primary: "#4D2173"
  lent-accent: "#9C75B8"
  lent-parchment: "#F2E8F2"
  lent-parchment-shade: "#D6CAE6"
  lent-card-border: "#8C6BA8"
  easter-primary: "#245E2E"
  easter-accent: "#D1A82E"
  easter-parchment: "#FCFAEB"
  easter-parchment-shade: "#E3EDCC"
  easter-card-border: "#75A866"
typography:
  display:
    fontFamily: "Apple system serif"
    fontSize: "title2-title3"
    fontWeight: 700
    lineHeight: 1.2
  title:
    fontFamily: "Apple system rounded"
    fontSize: "title3"
    fontWeight: 700
    lineHeight: 1.25
  body:
    fontFamily: "Apple system"
    fontSize: "subheadline-body"
    fontWeight: 400
    lineHeight: 1.35
  supporting:
    fontFamily: "Apple system"
    fontSize: "footnote"
    fontWeight: 400
    lineHeight: 1.3
  label:
    fontFamily: "Apple system"
    fontSize: "caption2"
    fontWeight: 600
    lineHeight: 1.2
rounded:
  sm: "12px"
  md: "14px"
  lg: "16px"
  xl: "18px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.ordinary-primary}"
    textColor: "{colors.ordinary-parchment}"
    typography: "{typography.body}"
    rounded: "{rounded.md}"
    height: "44px"
  surface-card-standard:
    backgroundColor: "{colors.ordinary-parchment}"
    textColor: "{colors.ordinary-primary}"
    rounded: "{rounded.lg}"
    padding: "16px"
  surface-card-primary:
    backgroundColor: "{colors.ordinary-parchment}"
    textColor: "{colors.ordinary-primary}"
    rounded: "{rounded.xl}"
    padding: "16px"
  status-tag:
    backgroundColor: "{colors.ordinary-parchment}"
    textColor: "{colors.ordinary-primary}"
    typography: "{typography.label}"
    rounded: "{rounded.md}"
    padding: "3px 8px"
---

# Design System: Catholic Fasting

## 1. Overview

**Creative North Star: "The Quiet Liturgical Companion"**

Catholic Fasting is a product interface, not a marketing surface. Design serves a repeated devotional workflow: checking today's guidance, planning upcoming observances, tracking a fast, understanding a rule, and returning to a steady rhythm after a missed day. The app should feel native, calm, and readable before it feels expressive.

The visual system combines Apple platform controls with a seasonal sacred palette. Parchment backgrounds, muted ecclesial color, modest glass effects, and occasional serif titles create a devotional atmosphere without turning the app into a decorative artifact. Sacred imagery anchors major surfaces when it clarifies mood or context.

The system rejects generic fasting apps, productivity dashboards, aggressive streak mechanics, and wellness-brand polish. It also rejects sacred ornament detached from action. The user should always know what to do next, why it matters, and where to find the underlying rule context.

**Key Characteristics:**

- Parchment-toned root backgrounds with seasonal liturgical color.
- Native SwiftUI controls, glass buttons, platform navigation, and system type.
- Serif titles reserved for devotional or reflective emphasis.
- Rounded, lightly bordered surfaces with low shadow and tonal depth.
- Sacred imagery used as a surface anchor, not as filler.
- Clear citations, rationale, localization, and accessibility identifiers treated as product features.

### Design QA Handoff

Audit and polish loops may use temporary progress notes, checklists, or score tracking while work is in flight. Before final handoff or commit, that progress state must be resolved: clear active/in-progress markers, remove stale temporary status, and leave the app/repo in a stable final state with only the verified outcome reported. A finished polish pass should read as complete, not as an abandoned checklist.

## 2. Colors

The palette changes by liturgical season. Each season provides a primary color, an accent, a parchment base, a parchment shade, and a card border. Ordinary Time is the neutral default, Advent shifts toward blue and rose, Christmas warms toward gold, Lent quiets into violet, and Easter returns with green and gold.

### Primary

- **Ordinary Green** (#1A612B): Default primary for navigation tint, section titles, selected states, and steady daily guidance.
- **Advent Blue** (#1C337D): Seasonal primary for Advent, used with restraint so the app feels watchful and preparatory.
- **Christmas Umber** (#804A12): Seasonal primary for Christmas, warmer and more celebratory while staying grounded.
- **Lenten Violet** (#4D2173): Seasonal primary for Lent, penitential without becoming theatrical.
- **Easter Green** (#245E2E): Seasonal primary for Easter, renewed and vivid enough for celebration without overpowering text.

### Secondary

- **Ordinary Gold** (#B88F26): Accent for highlights, soft gradients, and surface tinting.
- **Advent Rose** (#B85494): Accent for Advent emphasis and Gaudete-adjacent warmth.
- **Christmas Gold** (#D9A62E): Accent for celebratory highlights.
- **Lenten Lavender** (#9C75B8): Accent for Lent, used softly in backgrounds and borders.
- **Easter Gold** (#D1A82E): Accent for Easter highlights and celebratory premium surfaces.

### Neutral

- **Seasonal Parchment**: The root surface family. Each season uses a light parchment base and a slightly deeper shade for gradients and list backgrounds.
- **Seasonal Border**: Muted border color tied to the active season. Use it for 1px strokes and gentle card definition.
- **System Secondary**: Use SwiftUI `.secondary` for subordinate text, metadata, and icon labels where platform contrast remains appropriate.

### Named Rules

**The Seasonal Context Rule.** Seasonal color should orient the user in liturgical time. It should not make each season feel like a different app.

**The Parchment First Rule.** Most surfaces sit on parchment or a tonal shade. White and black are avoided unless required by platform controls, sacred imagery overlays, or accessibility.

**The Obligation Color Rule.** Red, blue, gray, green, indigo, and other status colors may appear for obligation and completion semantics. They should stay functional and not become a competing theme.

## 3. Typography

**Display Font:** Apple system serif for reflective titles and sacred imagery captions.
**Body Font:** Apple system font for readable native UI.
**Label Font:** Apple system caption styles for status tags, metadata, and compact control labels.

**Character:** Typography should feel like a native Apple app with a small devotional inflection. Serif moments are special and local. Rounded title styles give product surfaces warmth without making controls playful.

### Hierarchy

- **Display** (system serif, bold, title2-title3): Used for sacred hero cards, premium reflective moments, and key devotional anchors.
- **Headline** (system rounded or serif, bold, title3): Used for section titles and workspace anchors.
- **Title** (system rounded, bold, title3): Used for card titles, dashboard section titles, and practical product headings.
- **Body** (system, regular, body-subheadline): Used for primary explanations, setup content, guidance, and localized paragraphs.
- **Supporting** (system, regular, footnote): Used for details, citations, captions, and secondary explanatory text.
- **Label** (system, semibold, caption-caption2): Used for status tags, compact metrics, tabs, toolbar badges, and short metadata.

### Named Rules

**The Serif Reserve Rule.** Serif type signals reflection, sacred imagery, or devotional emphasis. Do not use it for every heading.

**The Native Readability Rule.** Dynamic Type, multiline wrapping, and platform text styles matter more than fixed visual precision.

**The No Shame Copy Rule.** Completion and missed-day language should remain truthful, gentle, and recoverable.

## 4. Elevation

Depth is conveyed through tonal layering, 1px seasonal borders, subtle opacity changes, and SwiftUI glass effects. Shadows exist, but they are quiet: most cards use a small shadow at very low primary-color opacity, while hero imagery may use a slightly larger shadow to separate it from the parchment background.

### Shadow Vocabulary

- **Utility Surface Shadow**: Primary color at roughly 0.018 opacity, radius 4, y 2. Used for low-weight utility cards.
- **Primary Surface Shadow**: Primary color at roughly 0.055 opacity, radius 10, y 5. Used for higher-emphasis surfaces and premium anchors.
- **Sacred Image Shadow**: Primary color at roughly 0.08 opacity, radius 12, y 6. Used for image cards that need separation from parchment.

### Named Rules

**The Low Shadow Rule.** Shadows should be felt more than seen. If a card looks like it floats above the app, reduce it.

**The Glass With Purpose Rule.** Use `.glass`, `.glassProminent`, and `glassEffect` where the app already does: controls, rounded surfaces, and compact tags. Do not turn every container into glass.

## 5. Components

### Buttons

- **Primary:** SwiftUI `.glassProminent`, large control size, minimum height 44, tinted with the active seasonal primary.
- **Secondary:** SwiftUI `.glass`, large control size, minimum height 44, tinted with the active seasonal primary.
- **Menus:** Use native `Menu` for status selection and compact option sets.
- **Shape:** System glass controls provide platform shape. Custom rounded glass is capped around 15px.

### Surface Cards

- **Standard:** Parchment fill at about 0.88 opacity, low accent tint, 1px seasonal border, radius capped around 15px.
- **Primary:** Parchment fill at about 0.94 opacity, stronger accent tint, 1px seasonal border at higher opacity, radius capped around 18px.
- **Utility:** Parchment fill at about 0.80 opacity, faint accent tint, low border opacity, radius typically 14-16px.
- **Rule:** Cards should group real decisions, guidance, or repeated items. Avoid nesting cards inside cards.

### Sacred Image Cards

- Use actual app assets such as `HeroSacred`, `SacredCrucifixAltar`, `SacredPlanningJournal`, `SacredMonstrance`, and seasonal imagery when a surface needs devotional context.
- Overlay gradients may protect white text on imagery.
- Fallbacks use a seasonal gradient plus a relevant SF Symbol, usually `cross.case.fill`.
- Titles can use serif bold text, but supporting copy should remain concise.

### Status Tags And Metrics

- Status tags use compact capsule styling, parchment fill, semantic tint overlays, and 1px semantic strokes.
- Metrics use rounded title values and supporting footnote text.
- Obligation and completion colors must remain semantic and accessible.

### Navigation

- iPhone uses tabbed `NavigationStack` surfaces for Today, Fasting Days, Intermittent, and More.
- iPad uses split-view style workspaces.
- Mac uses native `NavigationSplitView`, sidebar rows, toolbars, Settings, commands, and menu bar surfaces.
- Do not copy the iOS More hub into the Mac main window. Settings and desktop surfaces have separate ownership.

## 6. Do's and Don'ts

Do:

- Preserve the seasonal palette API in `CatholicTheme`.
- Use app style helpers such as `appSurfaceCard`, `appRoundedGlass`, `appSectionTitleStyle`, `appSupportingTextStyle`, and `appPrimaryButtonStyle`.
- Keep rule rationale, citations, and regional profile context close to the user's decision.
- Respect localization and test identifiers as stable contracts.
- Use sacred imagery when it helps the user enter the right mode of attention.
- Keep Mac UI native to macOS and iOS UI native to iPhone and iPad.

Don't:

- Do not introduce a generic wellness tracker aesthetic.
- Do not add purple-blue gradients, decorative glassmorphism, identical feature-card grids, or marketing-style hero metrics.
- Do not use streak pressure, shame language, or gamified spiritual performance cues.
- Do not remove local-only privacy assumptions or add networked analytics without an explicit product decision.
- Do not broaden visual rewrites during release prep unless a concrete component-level issue requires it.
- Do not rely on color alone for obligation, completion, or warning states.
