# Launch Operations Runbook

## Roles
- Release owner: approves tag/build and submission
- QA owner: executes smoke and regression checks
- Support owner: monitors inbound support and triages exports

## Pre-Launch (T-7 to T-1)
1. Run validation:
   - `swift test`
   - `xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingApp -destination 'platform=iOS Simulator,name=iPhone 17' build`
   - `xcodebuild -project CatholicFastingApp.xcodeproj -scheme CatholicFastingApp -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:CatholicFastingAppUITests test`
2. Verify legal package checklist completion.
3. Verify support email alias and response template are active.
4. Freeze release branch and generate signed build artifacts.

## Launch Day
1. Submit build and release notes.
2. Perform post-submit smoke test on production build.
3. Monitor first 24h for:
   - crash reports
   - sync warnings trend
   - export/backup issues

## Incident Playbook
- Severity 1 (data loss, crash on launch):
  - Halt rollout if possible
  - Open hotfix branch
  - Publish support banner copy
- Severity 2 (feature degraded):
  - Triage within 4 hours
  - Prepare patch release if reproducible
- Severity 3 (minor UX/docs):
  - Add to backlog for next minor release

## Support SLA (initial)
- P0/P1: initial response within 4 business hours
- P2: initial response within 1 business day
- P3: initial response within 3 business days

## Post-Launch (Week 1)
1. Review top support issues and categorize root causes.
2. Re-score release quality and document backlog priorities.
3. Schedule first maintenance release scope.
