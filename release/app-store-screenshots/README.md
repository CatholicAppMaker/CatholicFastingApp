# App Store Screenshot Pipeline

The checked-in screenshots are generated from deterministic UI-test captures.

Run the full pipeline:

```sh
scripts/generate_app_store_screenshots.sh
```

Generate French Canadian screenshots in a clean subfolder:

```sh
scripts/generate_app_store_screenshots.sh --locale fr-CA
```

Generate Spanish (Mexico) screenshots in a clean subfolder:

```sh
scripts/generate_app_store_screenshots.sh --locale es-MX
```

Useful iteration modes:

```sh
scripts/generate_app_store_screenshots.sh --capture-only
scripts/generate_app_store_screenshots.sh --skip-capture
scripts/generate_app_store_screenshots.sh --locale fr-CA --skip-capture
scripts/generate_app_store_screenshots.sh --locale fr-CA --ios-version 26.5
scripts/generate_app_store_screenshots.sh --locale es-MX --skip-capture
scripts/generate_app_store_screenshots.sh --locale es-MX --ios-version 26.5
```

Outputs:

- English:
  - `iphone-17-pro-max/raw/*.png` and `ipad-pro-13/raw/*.png`: direct simulator captures.
  - `iphone-17-pro-max/[0-9][0-9]-*.png` and `ipad-pro-13/[0-9][0-9]-*.png`: framed App Store
    screenshots.
- French Canadian:
  - `fr-CA/iphone-17-pro-max/raw/*.png` and `fr-CA/ipad-pro-13/raw/*.png`: direct simulator
    captures.
  - `fr-CA/iphone-17-pro-max/[0-9][0-9]-*.png` and `fr-CA/ipad-pro-13/[0-9][0-9]-*.png`: framed App
    Store screenshots.
- Spanish (Mexico):
  - `es-MX/iphone-17-pro-max/raw/*.png` and `es-MX/ipad-pro-13/raw/*.png`: direct simulator
    captures.
  - `es-MX/iphone-17-pro-max/[0-9][0-9]-*.png` and `es-MX/ipad-pro-13/[0-9][0-9]-*.png`: framed App
    Store screenshots.

The script captures:

1. Today daily Catholic rule and next faithful action
2. Track Fast live timer
3. Fasting Days planning
4. Guided Seasonal Formation / Premium
5. Privacy and local-only data

Requirements:

- Xcode command line tools
- ImageMagick `magick`
- Available iPhone Pro Max and 13-inch iPad simulators
- The capture script defaults to the iOS 26.5 simulator runtime and pins destinations by UDID. Use
  `--ios-version` or `SCREENSHOT_IOS_VERSION` when you intentionally need a different runtime.
