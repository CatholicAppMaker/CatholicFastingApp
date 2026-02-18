# Accessibility and Localization Readiness

## Accessibility Pass (Implemented)
- Stable accessibility identifiers on critical controls:
  - consent toggle
  - export actions
  - diagnostics warnings
  - navigation/surface controls
- Added accessibility hints for export behavior and consent prerequisites.
- Dynamic type compatible list-based layouts retained.

## Localization Pass (Implemented)
- Added bilingual (English/Spanish) labels and messaging in Settings:
  - profile
  - regional norms
  - privacy and consent
  - backups and exports
  - destructive data management dialogs
- Added localized status strings for sync timestamps and consent copy.

## Remaining Production Tasks
- [ ] Externalize strings to `Localizable.strings` for full i18n workflow.
- [ ] Native-speaker review for Spanish phrasing.
- [ ] VoiceOver manual QA sweep on physical device.
- [ ] Accessibility contrast audit across all liturgical season palettes.

## QA Matrix
- Devices: iPhone SE/standard/max sizes
- Content size categories: default + accessibility large
- Languages: English, Spanish
- Modes: season theme on/off
