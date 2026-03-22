# Apple Design Reference Bundle

This folder is a practical local reference bundle for `Catholic Fasting App` UI/UX work, especially the planned `4.0` design pass.

## What is here

### PDFs
- `apple-design-get-started.pdf`
  - Good high-level Apple design principles and design workflow context.
- `apple-design-resources.pdf`
  - Good overview of Apple downloadable design resources.
- `apple-localization-resources.pdf`
  - Useful for multilingual UX and localization quality work.
- `apple-sf-symbols.pdf`
  - Good local reference for SF Symbols overview and download context.
- `apple-hig.pdf`
- `apple-hig-designing-for-ios.pdf`
- `apple-hig-accessibility.pdf`
  - These are lightweight PDF snapshots of Apple's documentation pages. They are useful as quick local pointers, but the live web docs remain more complete.

### HTML snapshots
Stored in `html/`:
- `apple-design-get-started.html`
- `apple-design-resources.html`
- `apple-hig.html`
- `apple-hig-designing-for-ios.html`
- `apple-hig-accessibility.html`
- `apple-localization-resources.html`
- `apple-sf-symbols.html`

These are saved local snapshots of the official Apple pages. For the HIG pages, Apple serves most content through a JS-heavy shell, so the snapshots are mainly useful as stable local references to the page structure and source URL.

### Downloads
Stored in `downloads/`:
- `SF-Symbols-7.dmg`
  - Official Apple SF Symbols app download.
  - Use this for icon exploration, symbol naming, weights/scales, rendering modes, and better symbol selection for iPhone/iPad layouts.

### Fonts
Stored in `fonts/`:
- `SFNS.ttf` and related variants
- `NewYork.ttf` and `NewYorkItalic.ttf`

These are practical local copies of the Apple system fonts installed on this Mac, included so the project has immediate local references for SF-style UI typography and New York serif typography.

## Recommended use for this app

For `Catholic Fasting App`, use this bundle in roughly this order:
1. `apple-design-get-started.pdf`
2. `apple-design-resources.pdf`
3. `apple-sf-symbols.pdf` and `downloads/SF-Symbols-7.dmg`
4. `apple-localization-resources.pdf`
5. Live Apple HIG pages when deeper detail is needed

## Best references for 4.0
- Better hierarchy and spacing: `apple-design-get-started.pdf`
- Native-feeling iPhone/iPad component direction: Apple Design Resources + live HIG
- Icon cleanup and symbol selection: `downloads/SF-Symbols-7.dmg`
- Spanish / French Canadian UX quality: `apple-localization-resources.pdf`

## Official source URLs
- https://developer.apple.com/design/get-started/
- https://developer.apple.com/design/resources/
- https://developer.apple.com/design/human-interface-guidelines/
- https://developer.apple.com/design/human-interface-guidelines/designing-for-ios
- https://developer.apple.com/design/human-interface-guidelines/accessibility
- https://developer.apple.com/localization/resources/
- https://developer.apple.com/sf-symbols/

## Notes
- The SF Symbols DMG is the most practically useful downloadable asset in this bundle.
- Apple font downloads such as SF Pro / New York are available through Apple Developer resources, but some download paths are sign-in gated; this bundle includes practical local copies from macOS in `fonts/` instead.
- If we want, we can add a second pass later with Apple bezel assets for App Store screenshot/mockup work.
