# App Store Screenshot Pipeline

The checked-in screenshots are generated from deterministic UI-test captures.

Run the full pipeline:

```sh
scripts/generate_app_store_screenshots.sh
```

Useful iteration modes:

```sh
scripts/generate_app_store_screenshots.sh --capture-only
scripts/generate_app_store_screenshots.sh --skip-capture
```

Outputs:

- `iphone-17-pro-max/raw/*.png` and `ipad-pro-13/raw/*.png`: direct simulator captures.
- `iphone-17-pro-max/[0-9][0-9]-*.png` and `ipad-pro-13/[0-9][0-9]-*.png`: framed App Store screenshots.

The script captures:

1. Today daily fasting rule
2. Track Fast live timer
3. Privacy and local-only data
4. Fasting Days planning
5. Guided Seasonal Formation / Premium

Requirements:

- Xcode command line tools
- ImageMagick `magick`
- Available iPhone Pro Max and 13-inch iPad simulators
