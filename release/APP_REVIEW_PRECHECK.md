# App Review Precheck

## Guideline Risk Areas
- 1.4 (Physical harm / medical framing)
  - In-app copy states app is not medical advice.
  - Consent flow requires acknowledgment for reminders/exports.
- 2.1 (App completeness)
  - Verify no dead controls, placeholder text, or unfinished settings.
- 5.1 (Privacy)
  - Privacy policy URL must be live.
  - App Privacy questionnaire must match real behavior.

## Functional Checklist
- [ ] Onboarding completes without blocking bugs
- [ ] Dashboard, Calendar, Guidance, Settings all accessible
- [ ] Consent gating works for reminder/export actions
- [ ] Delete All App Data clears tracker/notes/settings
- [ ] Data & Privacy screen reflects local-only data handling
- [ ] English/Spanish switching is consistent on migrated screens

## Content Checklist
- [ ] App description matches features actually present
- [ ] No claims of official Church authority or legal/medical guarantees
- [ ] Sources and pastoral disclaimers are visible and accurate

## Submission Evidence
- Attach:
  - Latest xcresult for UI tests
  - swift test pass output
  - Build success output
