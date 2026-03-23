# Catholic Fasting App 4.0 Visual Checklist

Use this checklist during the final 4.0 visual pass and again before release-candidate screenshots.

Primary local references:
- `/Users/kevpierce/Desktop/CatholicFastingApp/design/apple/notes/APPLE_STAGE2_NOTES.md`
- `/Users/kevpierce/Desktop/CatholicFastingApp/design/apple/apple-hig.pdf`
- `/Users/kevpierce/Desktop/CatholicFastingApp/design/apple/apple-hig-accessibility.pdf`
- `/Users/kevpierce/Desktop/CatholicFastingApp/design/apple/videos/wwdc25-elevate-ipad-design.pdf`
- `/Users/kevpierce/Desktop/CatholicFastingApp/design/apple/videos/wwdc25-build-swiftui-new-design.pdf`
- `/Users/kevpierce/Desktop/CatholicFastingApp/design/apple/videos/wwdc20-make-your-app-visually-accessible.pdf`

## Design Rules
- SF-style UI text is the default for controls, labels, body, utility text, and metrics.
- `New York` is accent typography only: observance titles, seasonal headings, premium journey emphasis.
- `SF Symbols` are the default icon system.
- Keep the tone `sacred calm`, not dramatic or ornamental.
- Prefer native controls and compact interactions over custom chrome.
- Use elevated surfaces to clarify hierarchy, not to decorate every block equally.

## Cross-App Checklist
- The first screen on every tab answers the main user question without scrolling.
- Supporting copy is readable at a glance and does not collapse into tiny caption text.
- Only the top-priority heading on a screen uses serif emphasis.
- Button hierarchy is clear:
  - one primary action
  - one secondary action if needed
  - destructive or legal actions visually demoted
- Touch targets feel comfortably tappable on both iPhone and iPad.
- Icons use consistent size and weight across related actions.
- Cards are visually tiered:
  - primary
  - standard
  - utility
- Repeated metrics do not compete with the main answer.
- Empty states feel invitational, not like missing data.

## Today
- The daily answer is visually first.
- Observance context appears near the top and reads as part of today’s answer.
- Food guidance and next actions are visible without feeling like separate apps.
- Serif emphasis is reserved for the most important observance or devotional heading.
- Progress, streak, and recovery metrics support the daily answer instead of overpowering it.
- Quick actions feel native and obvious on both iPhone and iPad.

## Fasting Days
- Calendar and planning controls scan quickly.
- Day detail is readable without dense card stacking.
- Obligation vs celebration vs optional context is visually clear.
- Filters and scope controls feel like utility tools, not hero content.
- Feast and memorial emphasis is calm and restrained.

## Track Fast
- The top of the screen clearly answers:
  - am I fasting now?
  - what is my target?
  - what should I do next?
- Start/end/cancel controls are easy to find.
- The manual start-time picker feels supportive, not complicated.
- Advanced tools remain visibly secondary by default.
- History stays accessible without crowding the live tracker.
- On iPad, the left lane is clearly primary and the right lane clearly supporting.

## Support & Premium
- The premium story is obvious within one screen:
  - what premium gives
  - why yearly is the strongest option
  - what the Guided Seasonal Journey means
- Yearly is visually primary over monthly.
- Tips are clearly separate from subscriptions.
- Restore/manage/legal remain visible but demoted below plan choice.
- Journey preview/current journey feels like a premium product, not extra copy.
- Premium typography and icon treatment stay consistent between iPhone and iPad.

## More
- Workspace choices are easy to scan and clearly grouped.
- The selected workspace is obvious on iPad.
- Utility destinations feel calm and trustworthy, especially setup and privacy.
- No destination feels like it belongs to a different visual system.

## Onboarding and Setup
- Language and region are available early and feel important.
- Changing language updates visible setup copy immediately.
- Reminder and trust copy are readable and reassuring.
- The setup flow feels shorter and calmer than the amount of functionality behind it.

## iPad-Specific Checklist
- Each workspace has one clear primary lane.
- Secondary/support panels never visually compete with the primary lane.
- Sidebar actions remain obvious and stable after repeated switching.
- Detail panes do not feel overloaded above the fold.
- Compact cards and utility chips remain readable at iPad viewing distance.

## Accessibility Checklist
- Key supporting text remains legible at larger Dynamic Type sizes.
- Contrast remains sufficient for secondary and muted text.
- Important controls are not conveyed by color alone.
- Dense screens still have one dominant visual path.
- Accessibility labels and identifiers remain stable on new or edited controls.

## Final Screenshot Pass
- Screenshot candidates show one clean primary message per screen.
- No stale pricing or obsolete copy appears.
- Premium screenshots show the journey, not just purchase controls.
- iPad screenshots demonstrate workspace clarity.
- Localized screenshots, if used, reflect the actual localized UI.

## Release-Candidate Gate
- Review `Today`, `Fasting Days`, `Track Fast`, `Support & Premium`, and `More` side by side.
- Review iPhone and iPad in the same session for hierarchy drift.
- Check English, Spanish, and French Canadian for spacing, truncation, and tone.
- Re-run this checklist after any late feature/UI change before 4.0 submission.
