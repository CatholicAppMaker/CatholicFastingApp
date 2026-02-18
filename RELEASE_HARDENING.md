# Release Hardening

## 1) Deterministic iOS Test Execution
- Use `scripts/run_ios_tests.sh` for simulator UI test execution.
- The script:
  - performs `build-for-testing`
  - resets simulator state per attempt
  - runs `test-without-building` with an explicit `.xcresult` bundle
  - enforces a hard timeout per attempt (`TEST_TIMEOUT_SECONDS`)
  - retries failed UI runs (default: 2 attempts)

Run:
```bash
chmod +x scripts/run_ios_tests.sh
./scripts/run_ios_tests.sh
```

## 2) Signed Rule Bundle Workflow
- Rule bundle verification now uses Ed25519 signatures with trusted key IDs.
- Signing metadata is embedded in the rule bundle JSON under `signing`.
- To sign a bundle:
```bash
export RULE_BUNDLE_PRIVATE_KEY_B64="<ed25519-private-key-base64>"
export RULE_BUNDLE_KEY_ID="release-2026-q1"
xcrun swift scripts/sign_rule_bundle.swift unsigned-rule-bundle.json signed-rule-bundle.json
```
- The app verifies:
  - algorithm is `ed25519`
  - key ID exists in trusted key map
  - signature over canonical payload (`metadata` + `changes`, sorted keys)

## 3) Productization Controls
- Legal acknowledgment is required before scheduling reminders and exports.
- Export/support bundles now include legal acceptance timestamps and consent flags.
- Critical user controls include accessibility hints and identifiers for UI testing.

## 4) Accessibility and Localization Production Pass
- Completed bilingual (English/Spanish) Settings copy for profile, regional norms, privacy, export, and data management actions.
- Added accessibility hints on consent/export controls to improve VoiceOver clarity.
- Added readiness checklist in `ACCESSIBILITY_LOCALIZATION_READINESS.md`.

## 5) Launch Operations Workflows
- Added legal/compliance package in `LEGAL_COMPLIANCE_PACKAGE.md`.
- Added launch runbook, incident tiers, and support SLA in `LAUNCH_OPERATIONS_RUNBOOK.md`.
- Defined pre-launch and launch-day validation sequence for engineering + QA.

## 6) App Store Submission Assets
- Added submission drafts under `release/`:
  - `APP_STORE_METADATA_DRAFT.md`
  - `APP_STORE_PRIVACY_QUESTIONNAIRE_DRAFT.md`
  - `APP_REVIEW_PRECHECK.md`
  - `APP_STORE_SUBMISSION_PLAYBOOK.md`
  - `SDK_COMPLIANCE_CHECK.md`
  - `PRIVACY_POLICY_TEMPLATE.md`
  - `APP_STORE_READY_CHECKLIST.md`
