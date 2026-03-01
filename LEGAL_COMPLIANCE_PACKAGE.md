# Legal and Compliance Package

## Scope
- Product: Catholic Fasting App (iOS)
- Data classes: profile settings, observance status, Friday notes, consent timestamps
- Jurisdiction target: U.S. end users

## User-Facing Disclosures
- App guidance is pastoral support information, not medical advice.
- Users must confirm consent before reminders and data export are enabled.
- Sources link to USCCB liturgical calendar guidance.

## Data Handling Summary
- Local storage:
  - profile/rule settings
  - observance completion/status history
  - Friday penance notes
  - consent flags and timestamps
- No cloud sync.
- No analytics or diagnostics collection.
- Export options:
  - plain personal backup
  - premium summary export (if feature is available)

## Retention and Deletion
- Data persists until user deletes it.
- "Delete All App Data" clears local tracker/notes/settings state.
- No sync/diagnostics toggle required because those paths are removed.

## App Store Privacy Label Inputs (Working Draft)
- Data linked to user:
  - none
- Data not linked to user:
  - none
- Data used for tracking: none
- Contact info collection in app: none (feedback uses mail client)

## Release Gate Checklist
- [ ] Legal copy reviewed by publisher
- [ ] Privacy policy URL finalized and available publicly
- [ ] App Store privacy nutrition labels completed
- [ ] Consent gating verified in UI tests
- [ ] Export payload review completed (no unexpected sensitive fields)

## Owner
- Self-publisher (developer account holder) publishes final legal text and signs off before App Store submission.
