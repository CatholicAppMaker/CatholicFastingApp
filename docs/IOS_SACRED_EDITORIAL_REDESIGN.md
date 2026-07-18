# iOS Sacred Editorial Redesign

## Direction decision

The June 2026 clean iPhone and iPad captures are the implementation baseline. The redesign uses the
Quiet Liturgical Edition lane: native navigation, editorial hierarchy, restrained seasonal color,
fewer containers, and direct source-backed actions.

| Direction | Task clarity 30 | Accessibility 20 | Native fit 20 | Density 15 | Brand 10 | Risk 5 | Weighted |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Current UI | 8.2 | 7.6 | 8.0 | 7.1 | 9.1 | 8.2 | 7.98 |
| Quiet Liturgical Edition | 9.4 | 9.2 | 9.4 | 9.1 | 9.2 | 8.4 | 9.23 |
| Parish Almanac | 9.1 | 8.9 | 9.3 | 9.5 | 8.3 | 8.0 | 9.02 |
| Seasonal Companion | 8.5 | 8.4 | 8.5 | 7.7 | 9.5 | 7.4 | 8.40 |

Quiet Liturgical Edition improves the weighted baseline by 15.7 percent. It wins because it keeps
the app's strongest Catholic trust signals while fixing nested cards, repeated metadata, first-fold
action visibility, and stretched phone layouts on iPad.

## Final implementation audit

The implementation retained the Quiet Liturgical Edition direction after clean, matched screenshot
review. The iPad pass was rescored only after the calendar year stopped rendering with a thousands
separator, the Premium plan state could no longer be blank, and More used a selector/detail workspace
at regular portrait width.

| Surface | Task clarity 30 | Accessibility 20 | Native fit 20 | Density 15 | Brand 10 | Risk 5 | Weighted |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Current UI baseline | 8.2 | 7.6 | 8.0 | 7.1 | 9.1 | 8.2 | 7.98 |
| Final iPhone | 9.4 | 9.1 | 9.3 | 9.1 | 9.2 | 9.2 | 9.25 |
| Final iPad | 9.3 | 9.0 | 9.4 | 9.1 | 9.2 | 9.2 | 9.22 |
| Final iOS family average | — | — | — | — | — | — | 9.24 |

The final iOS-family score is 15.8 percent above the baseline, so the adoption gate remains met.
Automated accessibility semantics, localization contracts, first-viewport action contracts, and clean
screenshot checks passed. VoiceOver reading order, increased-contrast appearance, and every widget
rendering mode remain release-checklist items that require manual device review rather than inference
from screenshots.

## Non-negotiables

- Today answers the obligation and next action before formation or decorative imagery.
- Calendar means Church observances; Fast means optional personal practice.
- Sources, regional context, medical prudence, and local-only privacy remain visible.
- Liquid Glass belongs to navigation and controls, not decorative content containers.
- English, Spanish, and French Canadian strings and stable automation identifiers remain contracts.
