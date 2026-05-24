#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_ROOT="$ROOT_DIR/release/app-store-screenshots"
RESULTS_DIR="$ROOT_DIR/build/app-store-screenshots"
SCREENSHOT_CONFIG_PATH="/tmp/catholic-fasting-app-store-screenshot-config.json"
IPHONE_DEVICE="${IPHONE_DEVICE:-}"
IPAD_DEVICE="${IPAD_DEVICE:-}"
SKIP_CAPTURE=0
CAPTURE_ONLY=0

usage() {
  cat <<'USAGE'
Generate Catholic Fasting App Store screenshots.

Usage:
  scripts/generate_app_store_screenshots.sh [options]

Options:
  --skip-capture          Render final PNGs from existing raw screenshots only.
  --capture-only          Capture raw simulator screenshots without rendering finals.
  --output DIR            Screenshot output root. Defaults to release/app-store-screenshots.
  --iphone-device NAME    Override the iPhone simulator name.
  --ipad-device NAME      Override the iPad simulator name.
  -h, --help              Show this help.

Environment overrides:
  IPHONE_DEVICE, IPAD_DEVICE
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-capture)
      SKIP_CAPTURE=1
      shift
      ;;
    --capture-only)
      CAPTURE_ONLY=1
      shift
      ;;
    --output)
      OUTPUT_ROOT="$2"
      shift 2
      ;;
    --iphone-device)
      IPHONE_DEVICE="$2"
      shift 2
      ;;
    --ipad-device)
      IPAD_DEVICE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required tool: $1" >&2
    exit 1
  fi
}

choose_file() {
  local candidate
  for candidate in "$@"; do
    if [[ -f "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done

  echo "None of the requested files exist: $*" >&2
  exit 1
}

simulator_exists() {
  xcrun simctl list devices available | grep -F "$1 (" >/dev/null
}

choose_simulator() {
  local explicit="$1"
  shift
  if [[ -n "$explicit" ]]; then
    if ! simulator_exists "$explicit"; then
      echo "Simulator '$explicit' is not available." >&2
      exit 1
    fi
    printf '%s\n' "$explicit"
    return
  fi

  local candidate
  for candidate in "$@"; do
    if simulator_exists "$candidate"; then
      printf '%s\n' "$candidate"
      return
    fi
  done

  echo "None of the requested simulators are available: $*" >&2
  exit 1
}

run_capture() {
  local device="$1"
  local device_dir="$2"
  local test_name="$3"
  local result_bundle="$RESULTS_DIR/$device_dir.xcresult"

  rm -rf "$result_bundle"
  mkdir -p "$OUTPUT_ROOT/$device_dir/raw" "$RESULTS_DIR"
  rm -f "$OUTPUT_ROOT/$device_dir/raw"/[0-9][0-9]-*.png

  echo "Capturing $device_dir on $device"
  local escaped_output="${OUTPUT_ROOT//\\/\\\\}"
  escaped_output="${escaped_output//\"/\\\"}"
  local escaped_device="${device_dir//\\/\\\\}"
  escaped_device="${escaped_device//\"/\\\"}"
  printf '{"outputRoot":"%s","deviceDirectory":"%s"}\n' \
    "$escaped_output" "$escaped_device" > "$SCREENSHOT_CONFIG_PATH"

  local capture_status=0
  OS_ACTIVITY_MODE=disable \
    xcodebuild test \
      -project "$ROOT_DIR/CatholicFastingApp.xcodeproj" \
      -scheme CatholicFastingApp \
      -destination "platform=iOS Simulator,name=$device" \
      -only-testing:"CatholicFastingAppUITests/CatholicFastingAppUITests/$test_name" \
      -resultBundlePath "$result_bundle" || capture_status=$?
  rm -f "$SCREENSHOT_CONFIG_PATH"
  return "$capture_status"
}

make_rounded_crop() {
  local raw="$1"
  local width="$2"
  local height="$3"
  local radius="$4"
  local output="$5"

  magick "$raw" \
    -resize "${width}x${height}^" \
    -gravity north \
    -extent "${width}x${height}" \
    \( -size "${width}x${height}" xc:none -fill white \
      -draw "roundrectangle 0,0 $((width - 1)),$((height - 1)) $radius,$radius" \) \
    -alpha set -compose DstIn -composite "$output"
}

make_caption() {
  local width="$1"
  local height="$2"
  local point_size="$3"
  local font="$4"
  local color="$5"
  local text="$6"
  local output="$7"

  magick -background none -fill "$color" -font "$font" \
    -gravity center -size "${width}x${height}" -pointsize "$point_size" \
    "caption:$text" "$output"
}

compose_phone() {
  local raw="$1"
  local output="$2"
  local title="$3"
  local subtitle="$4"
  local temp_dir="$5"

  local screen="$temp_dir/phone-screen.png"
  local brand="$temp_dir/phone-brand.png"
  local title_image="$temp_dir/phone-title.png"
  local subtitle_image="$temp_dir/phone-subtitle.png"
  make_rounded_crop "$raw" 970 1950 78 "$screen"
  make_caption 1100 70 38 "$FONT_BOLD" "#217747" "CATHOLIC FASTING" "$brand"
  make_caption 1120 180 76 "$FONT_BOLD" "#10200f" "$title" "$title_image"
  make_caption 1080 130 40 "$FONT_SEMIBOLD" "#737a6d" "$subtitle" "$subtitle_image"

  magick -size 1320x2868 xc:"#fbf8ea" \
    -fill "#dfe9d5" -draw "circle 82,610 398,610" \
    -fill "#dfe9d5" -draw "circle 1218,540 952,540" \
    "$brand" -geometry +110+334 -composite \
    "$title_image" -geometry +100+430 -composite \
    "$subtitle_image" -geometry +120+628 -composite \
    \( -size 1034x2014 xc:none -fill black \
      -draw "roundrectangle 0,0 1033,2013 92,92" \) \
      -geometry +143+790 -composite \
    "$screen" -geometry +175+822 -composite \
    -fill black -draw "roundrectangle 505,852 815,906 28,28" \
    "$output"
}

compose_ipad() {
  local raw="$1"
  local output="$2"
  local title="$3"
  local subtitle="$4"
  local temp_dir="$5"

  local screen="$temp_dir/ipad-screen.png"
  local brand="$temp_dir/ipad-brand.png"
  local title_image="$temp_dir/ipad-title.png"
  local subtitle_image="$temp_dir/ipad-subtitle.png"
  make_rounded_crop "$raw" 1500 2020 52 "$screen"
  make_caption 1200 70 36 "$FONT_BOLD" "#c64650" "CATHOLIC FASTING" "$brand"
  make_caption 1420 160 76 "$FONT_BOLD" "#301d17" "$title" "$title_image"
  make_caption 1480 120 40 "$FONT_SEMIBOLD" "#745f51" "$subtitle" "$subtitle_image"

  magick -size 2064x2752 xc:"#f8f2e6" \
    -fill "#fbf8ea" -draw "rectangle 0,0 2064,118" \
    -fill "#f0e4d1" -draw "rectangle 0,2120 2064,2752" \
    \( -size 1556x2076 xc:none -fill "#242424" \
      -draw "roundrectangle 0,0 1555,2075 86,86" \) \
      -geometry +254+120 -composite \
    "$screen" -geometry +282+148 -composite \
    -fill "#c64650" -draw "roundrectangle 350,2246 1714,2254 4,4" \
    "$brand" -geometry +432+2284 -composite \
    "$title_image" -geometry +322+2362 -composite \
    "$subtitle_image" -geometry +292+2518 -composite \
    "$output"
}

shot_title() {
  case "$1" in
    01-today) printf "%s" "Know today's fasting rule" ;;
    02-track-fast) printf "%s" "Track a fast with intention" ;;
    03-privacy) printf "%s" "Private by design" ;;
    04-fasting-days) printf "%s" "Plan Lent and required days" ;;
    05-premium) printf "%s" "Guided Seasonal Formation" ;;
    *) echo "Unknown shot id: $1" >&2; exit 1 ;;
  esac
}

shot_subtitle() {
  case "$1" in
    01-today) printf "%s" "Catholic fast days, abstinence, feasts, and Friday penance." ;;
    02-track-fast) printf "%s" "A clear timer for prayer, mercy, penance, or discipline." ;;
    03-privacy) printf "%s" "No account. No ads. Local-only fasting history." ;;
    04-fasting-days) printf "%s" "See fasts, abstinence days, solemnities, and regional guidance." ;;
    05-premium) printf "%s" "A weekly Catholic rhythm for review, recovery, and the next faithful action." ;;
    *) echo "Unknown shot id: $1" >&2; exit 1 ;;
  esac
}

shot_output_name() {
  case "$1" in
    01-today) printf "%s" "01-know-todays-rule.png" ;;
    02-track-fast) printf "%s" "02-track-fast-with-intention.png" ;;
    03-privacy) printf "%s" "03-private-by-design.png" ;;
    04-fasting-days) printf "%s" "04-plan-lent-and-required-days.png" ;;
    05-premium) printf "%s" "05-guided-seasonal-formation.png" ;;
    *) echo "Unknown shot id: $1" >&2; exit 1 ;;
  esac
}

render_device_set() {
  local device_dir="$1"
  local composer="$2"
  local temp_dir
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "$temp_dir"' RETURN

  mkdir -p "$OUTPUT_ROOT/$device_dir/raw"
  rm -f "$OUTPUT_ROOT/$device_dir"/[0-9][0-9]-*.png

  local shot raw output
  for shot in 01-today 02-track-fast 03-privacy 04-fasting-days 05-premium; do
    raw="$OUTPUT_ROOT/$device_dir/raw/$shot.png"
    output="$OUTPUT_ROOT/$device_dir/$(shot_output_name "$shot")"
    if [[ ! -f "$raw" ]]; then
      echo "Missing raw screenshot: $raw" >&2
      exit 1
    fi
    "$composer" "$raw" "$output" "$(shot_title "$shot")" "$(shot_subtitle "$shot")" "$temp_dir"
    echo "Rendered $output"
  done
}

require_tool xcrun
require_tool xcodebuild
require_tool magick

FONT_BOLD="${APP_STORE_SCREENSHOT_FONT_BOLD:-$(choose_file "/Library/Fonts/SF-Pro-Display-Bold.otf" "/System/Library/Fonts/Supplemental/Arial Bold.ttf")}"
FONT_SEMIBOLD="${APP_STORE_SCREENSHOT_FONT_SEMIBOLD:-$(choose_file "/Library/Fonts/SF-Pro-Display-Semibold.otf" "/System/Library/Fonts/Supplemental/Arial Bold.ttf")}"

IPHONE_DEVICE="$(choose_simulator "$IPHONE_DEVICE" "iPhone 17 Pro Max" "iPhone 16 Pro Max" "iPhone 15 Pro Max")"
IPAD_DEVICE="$(choose_simulator "$IPAD_DEVICE" "iPad Pro 13-inch (M5)" "iPad Pro 13-inch (M4)" "iPad Air 13-inch (M4)")"

if [[ "$SKIP_CAPTURE" -eq 0 ]]; then
  run_capture "$IPHONE_DEVICE" "iphone-17-pro-max" "testIPhoneAppStoreScreenshots"
  run_capture "$IPAD_DEVICE" "ipad-pro-13" "testIPadAppStoreScreenshots"
fi

if [[ "$CAPTURE_ONLY" -eq 0 ]]; then
  render_device_set "iphone-17-pro-max" compose_phone
  render_device_set "ipad-pro-13" compose_ipad
fi

echo "App Store screenshots are ready in $OUTPUT_ROOT"
