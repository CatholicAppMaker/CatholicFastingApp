#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_ROOT="$ROOT_DIR/release/app-store-screenshots"
OUTPUT_ROOT_OVERRIDDEN=0
RESULTS_DIR="$ROOT_DIR/build/app-store-screenshots"
SCREENSHOT_CONFIG_PATH="/tmp/catholic-fasting-app-store-screenshot-config.json"
IPHONE_DEVICE="${IPHONE_DEVICE:-}"
IPAD_DEVICE="${IPAD_DEVICE:-}"
IOS_VERSION="${SCREENSHOT_IOS_VERSION:-26.5}"
LOCALE_ID="en-US"
LANGUAGE_MODE=""
REGION_PROFILE=""
SKIP_CAPTURE=0
CAPTURE_ONLY=0
CAPTURE_IPHONE=1
CAPTURE_IPAD=1

usage() {
	cat <<'USAGE'
Generate Catholic Fasting App Store screenshots.

Usage:
  scripts/generate_app_store_screenshots.sh [options]

Options:
  --skip-capture          Render final PNGs from existing raw screenshots only.
  --capture-only          Capture raw simulator screenshots without rendering finals.
  --iphone-only           Capture/render only the iPhone screenshot set.
  --ipad-only             Capture/render only the iPad screenshot set.
  --locale LOCALE         Locale set to generate. Supported: en-US, fr-CA, es-MX.
                          Non-English default output goes in a locale subfolder.
  --ios-version VERSION   Simulator iOS runtime to use for capture. Defaults to 26.5.
  --output DIR            Screenshot output root. Defaults to release/app-store-screenshots.
  --iphone-device NAME    Override the iPhone simulator name.
  --ipad-device NAME      Override the iPad simulator name.
  -h, --help              Show this help.

Environment overrides:
  IPHONE_DEVICE, IPAD_DEVICE
  SCREENSHOT_IOS_VERSION=26.5   Override the simulator iOS runtime.
  SCREENSHOT_RESET_SIMULATOR=0   Reuse simulator state instead of erasing before capture.
  DEVELOPER_DIR                  Optional Xcode developer dir. If unset, the script
                                 auto-detects /Applications/Xcode*.app for capture.
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
	--iphone-only)
		CAPTURE_IPHONE=1
		CAPTURE_IPAD=0
		shift
		;;
	--ipad-only)
		CAPTURE_IPHONE=0
		CAPTURE_IPAD=1
		shift
		;;
	--output)
		OUTPUT_ROOT="$2"
		OUTPUT_ROOT_OVERRIDDEN=1
		shift 2
		;;
	--locale)
		LOCALE_ID="$2"
		shift 2
		;;
	--ios-version)
		IOS_VERSION="$2"
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
	-h | --help)
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

configure_locale() {
	case "$LOCALE_ID" in
	en | en-US)
		LOCALE_ID="en-US"
		LANGUAGE_MODE=""
		REGION_PROFILE=""
		;;
	fr | fr-CA | fr_CA | frenchCanadian)
		LOCALE_ID="fr-CA"
		LANGUAGE_MODE="frenchCanadian"
		REGION_PROFILE="canada"
		if [[ "$OUTPUT_ROOT_OVERRIDDEN" -eq 0 ]]; then
			OUTPUT_ROOT="$OUTPUT_ROOT/fr-CA"
		fi
		;;
	es | es-MX | es_MX | spanish)
		LOCALE_ID="es-MX"
		LANGUAGE_MODE="spanish"
		REGION_PROFILE=""
		if [[ "$OUTPUT_ROOT_OVERRIDDEN" -eq 0 ]]; then
			OUTPUT_ROOT="$OUTPUT_ROOT/es-MX"
		fi
		;;
	*)
		echo "Unsupported locale: $LOCALE_ID" >&2
		echo "Supported locales: en-US, fr-CA, es-MX" >&2
		exit 2
		;;
	esac
}

configure_developer_dir_for_capture() {
	if xcrun --find simctl >/dev/null 2>&1 && xcodebuild -version >/dev/null 2>&1; then
		return
	fi

	if [[ -n "${DEVELOPER_DIR:-}" ]]; then
		return
	fi

	local candidate
	for candidate in /Applications/Xcode.app /Applications/Xcode-beta.app /Applications/Xcode*.app; do
		if [[ -d "$candidate/Contents/Developer" ]] &&
			DEVELOPER_DIR="$candidate/Contents/Developer" xcrun --find simctl >/dev/null 2>&1 &&
			DEVELOPER_DIR="$candidate/Contents/Developer" xcodebuild -version >/dev/null 2>&1; then
			export DEVELOPER_DIR="$candidate/Contents/Developer"
			echo "Using DEVELOPER_DIR=$DEVELOPER_DIR"
			return
		fi
	done
}

run_with_timeout() {
	local timeout_seconds="$1"
	shift
	python3 - "$timeout_seconds" "$@" <<'PY'
import subprocess
import sys

timeout_seconds = int(sys.argv[1])
command = sys.argv[2:]
process = subprocess.Popen(command)
try:
    process.wait(timeout=timeout_seconds)
except subprocess.TimeoutExpired:
    process.terminate()
    try:
        process.wait(timeout=20)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=20)
    sys.exit(124)
sys.exit(process.returncode)
PY
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

choose_simulator() {
	local explicit="$1"
	shift

	python3 - "$IOS_VERSION" "$explicit" "$@" <<'PY'
import json
import subprocess
import sys

ios_version = sys.argv[1]
explicit = sys.argv[2]
candidates = sys.argv[3:]

payload = subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "-j"],
    text=True,
)
devices_by_runtime = json.loads(payload).get("devices", {})

def runtime_version(runtime_id):
    marker = "iOS-"
    if marker not in runtime_id:
        return None
    return runtime_id.split(marker, 1)[1].replace("-", ".")

matches = []
for runtime_id, devices in devices_by_runtime.items():
    version = runtime_version(runtime_id)
    if version != ios_version:
        continue
    for device in devices:
        if not device.get("isAvailable", True):
            continue
        matches.append((device.get("name", ""), device.get("udid", ""), version))

if explicit:
    for name, udid, version in matches:
        if explicit in (name, udid):
            print(f"{name}|{udid}|iOS {version}")
            sys.exit(0)
    print(f"Simulator '{explicit}' is not available for iOS {ios_version}.", file=sys.stderr)
    sys.exit(1)

for candidate in candidates:
    for name, udid, version in matches:
        if name == candidate:
            print(f"{name}|{udid}|iOS {version}")
            sys.exit(0)

print(
    f"None of the requested simulators are available for iOS {ios_version}: "
    + " ".join(candidates),
    file=sys.stderr,
)
sys.exit(1)
PY
}

run_capture() {
	local device_spec="$1"
	local device_dir="$2"
	local test_name="$3"
	local device_name="${device_spec%%|*}"
	local remainder="${device_spec#*|}"
	local device_udid="${remainder%%|*}"
	local device_runtime="${device_spec##*|}"
	local result_bundle="$RESULTS_DIR/$device_dir.xcresult"
	local raw_final="$OUTPUT_ROOT/$device_dir/raw"
	local raw_tmp

	rm -rf "$result_bundle"
	mkdir -p "$raw_final" "$RESULTS_DIR"
	raw_tmp="$(mktemp -d "$RESULTS_DIR/$device_dir-raw.XXXXXX")"

	echo "Capturing $device_dir on $device_name ($device_runtime, $device_udid)"
	python3 - "$SCREENSHOT_CONFIG_PATH" "$OUTPUT_ROOT" "$device_dir" "$raw_tmp" "$LANGUAGE_MODE" "$REGION_PROFILE" <<'PY'
import json
import sys

config_path, output_root, device_directory, raw_directory, language_mode, region_profile = sys.argv[1:]
with open(config_path, "w", encoding="utf-8") as handle:
    json.dump({
        "outputRoot": output_root,
        "deviceDirectory": device_directory,
        "rawDirectory": raw_directory,
        "languageMode": language_mode or None,
        "regionProfile": region_profile or None,
    }, handle)
    handle.write("\n")
PY

	if [[ "${SCREENSHOT_RESET_SIMULATOR:-1}" == "1" ]]; then
		xcrun simctl shutdown "$device_udid" >/dev/null 2>&1 || true
		xcrun simctl erase "$device_udid" >/dev/null 2>&1 || true
	fi

	local capture_status=0
	OS_ACTIVITY_MODE=disable \
		run_with_timeout "${SCREENSHOT_CAPTURE_TIMEOUT_SECONDS:-900}" xcodebuild test \
		-project "$ROOT_DIR/CatholicFastingApp.xcodeproj" \
		-scheme CatholicFastingApp \
		-destination "platform=iOS Simulator,id=$device_udid" \
		-destination-timeout 120 \
		-only-testing:"CatholicFastingAppUITests/CatholicFastingAppUITests/$test_name" \
		-parallel-testing-enabled NO \
		-test-timeouts-enabled YES \
		-default-test-execution-time-allowance "${SCREENSHOT_TEST_EXECUTION_TIME_ALLOWANCE:-180}" \
		-resultBundlePath "$result_bundle" || capture_status=$?
	rm -f "$SCREENSHOT_CONFIG_PATH"
	if [[ "$capture_status" -ne 0 ]]; then
		rm -rf "$raw_tmp"
		echo "Capture failed for $device_dir; existing raw screenshots were preserved in $raw_final" >&2
		return "$capture_status"
	fi

	local shot
	for shot in 01-today 02-track-fast 03-privacy 04-fasting-days 05-premium; do
		if [[ ! -f "$raw_tmp/$shot.png" ]]; then
			rm -rf "$raw_tmp"
			echo "Capture did not produce expected raw screenshot: $shot.png" >&2
			echo "Existing raw screenshots were preserved in $raw_final" >&2
			return 1
		fi
	done

	rm -f "$raw_final"/[0-9][0-9]-*.png
	mv "$raw_tmp"/*.png "$raw_final/"
	rmdir "$raw_tmp"
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
		-alpha remove -alpha off -depth 8 "PNG24:$output"
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
		-alpha remove -alpha off -depth 8 "PNG24:$output"
}

shot_title() {
	if [[ "$LOCALE_ID" == "fr-CA" ]]; then
		case "$1" in
		01-today) printf "%s" "Connaître les règles du jour" ;;
		02-track-fast) printf "%s" "Suivre un jeûne avec intention" ;;
		03-fasting-days) printf "%s" "Planifier les jours requis" ;;
		04-premium) printf "%s" "Bâtir un rythme plus stable" ;;
		05-privacy) printf "%s" "Confidentialité intégrée" ;;
		*)
			echo "Unknown shot id: $1" >&2
			exit 1
			;;
		esac
	elif [[ "$LOCALE_ID" == "es-MX" ]]; then
		case "$1" in
		01-today) printf "%s" "Conoce las reglas de hoy" ;;
		02-track-fast) printf "%s" "Sigue un ayuno con intención" ;;
		03-fasting-days) printf "%s" "Planifica los días obligatorios" ;;
		04-premium) printf "%s" "Construye un ritmo constante" ;;
		05-privacy) printf "%s" "Privacidad integrada" ;;
		*)
			echo "Unknown shot id: $1" >&2
			exit 1
			;;
		esac
	else
		case "$1" in
		01-today) printf "%s" "Know today's fasting rules" ;;
		02-track-fast) printf "%s" "Track a fast with intention" ;;
		03-fasting-days) printf "%s" "Plan required days ahead" ;;
		04-premium) printf "%s" "Build a steadier rhythm" ;;
		05-privacy) printf "%s" "Private by design" ;;
		*)
			echo "Unknown shot id: $1" >&2
			exit 1
			;;
		esac
	fi
}

shot_subtitle() {
	if [[ "$LOCALE_ID" == "fr-CA" ]]; then
		case "$1" in
		01-today) printf "%s" "Consultez la guidance, les sources et la prochaine action fidèle." ;;
		02-track-fast) printf "%s" "Gardez la minuterie, la cible et l'intention au même endroit." ;;
		03-fasting-days) printf "%s" "Voyez jeûnes, abstinence, fêtes et guidance régionale." ;;
		04-premium) printf "%s" "Premium soutient revue, récupération, rappels et formation saisonnière." ;;
		05-privacy) printf "%s" "Aucun compte. Aucune publicité. Historique local seulement." ;;
		*)
			echo "Unknown shot id: $1" >&2
			exit 1
			;;
		esac
	elif [[ "$LOCALE_ID" == "es-MX" ]]; then
		case "$1" in
		01-today) printf "%s" "Consulta la guía, las fuentes y la próxima acción fiel." ;;
		02-track-fast) printf "%s" "Mantén el temporizador, la meta y la intención en un solo lugar." ;;
		03-fasting-days) printf "%s" "Ve ayunos, abstinencia, fiestas y orientación regional." ;;
		04-premium) printf "%s" "Premium apoya revisión, recordatorios y formación estacional." ;;
		05-privacy) printf "%s" "Sin cuenta. Sin anuncios. Historial local solamente." ;;
		*)
			echo "Unknown shot id: $1" >&2
			exit 1
			;;
		esac
	else
		case "$1" in
		01-today) printf "%s" "See today's guidance, source context, and next faithful action." ;;
		02-track-fast) printf "%s" "Keep the live timer, target, and intention in one calm place." ;;
		03-fasting-days) printf "%s" "See upcoming fasts, abstinence days, feasts, and regional guidance." ;;
		04-premium) printf "%s" "Premium supports review, recovery, reminders, and seasonal formation." ;;
		05-privacy) printf "%s" "No account. No ads. Local-only fasting history." ;;
		*)
			echo "Unknown shot id: $1" >&2
			exit 1
			;;
		esac
	fi
}

shot_output_name() {
	case "$1" in
	01-today) printf "%s" "01-know-todays-fasting-rules.png" ;;
	02-track-fast) printf "%s" "02-track-fast-with-intention.png" ;;
	03-fasting-days) printf "%s" "03-plan-required-days-ahead.png" ;;
	04-premium) printf "%s" "04-build-a-steadier-rhythm.png" ;;
	05-privacy) printf "%s" "05-private-by-design.png" ;;
	*)
		echo "Unknown shot id: $1" >&2
		exit 1
		;;
	esac
}

shot_raw_name() {
	case "$1" in
	01-today) printf "%s" "01-today.png" ;;
	02-track-fast) printf "%s" "02-track-fast.png" ;;
	03-fasting-days) printf "%s" "04-fasting-days.png" ;;
	04-premium) printf "%s" "05-premium.png" ;;
	05-privacy) printf "%s" "03-privacy.png" ;;
	*)
		echo "Unknown shot id: $1" >&2
		exit 1
		;;
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
	for shot in 01-today 02-track-fast 03-fasting-days 04-premium 05-privacy; do
		raw="$OUTPUT_ROOT/$device_dir/raw/$(shot_raw_name "$shot")"
		output="$OUTPUT_ROOT/$device_dir/$(shot_output_name "$shot")"
		if [[ ! -f "$raw" ]]; then
			echo "Missing raw screenshot: $raw" >&2
			exit 1
		fi
		"$composer" "$raw" "$output" "$(shot_title "$shot")" "$(shot_subtitle "$shot")" "$temp_dir"
		echo "Rendered $output"
	done
}

configure_locale

require_tool magick

FONT_BOLD="${APP_STORE_SCREENSHOT_FONT_BOLD:-$(choose_file "/Library/Fonts/SF-Pro-Display-Bold.otf" "/System/Library/Fonts/Supplemental/Arial Bold.ttf")}"
FONT_SEMIBOLD="${APP_STORE_SCREENSHOT_FONT_SEMIBOLD:-$(choose_file "/Library/Fonts/SF-Pro-Display-Semibold.otf" "/System/Library/Fonts/Supplemental/Arial Bold.ttf")}"

if [[ "$SKIP_CAPTURE" -eq 0 ]]; then
	require_tool xcrun
	require_tool xcodebuild
	configure_developer_dir_for_capture

	IPHONE_DEVICE="$(choose_simulator "$IPHONE_DEVICE" "iPhone 17 Pro Max" "iPhone 16 Pro Max" "iPhone 15 Pro Max")"
	IPAD_DEVICE="$(choose_simulator "$IPAD_DEVICE" "iPad Pro 13-inch (M5)" "iPad Pro 13-inch (M4)" "iPad Air 13-inch (M4)")"

	if [[ "$CAPTURE_IPHONE" -eq 1 ]]; then
		run_capture "$IPHONE_DEVICE" "iphone-17-pro-max" "testIPhoneAppStoreScreenshots"
	fi
	if [[ "$CAPTURE_IPAD" -eq 1 ]]; then
		run_capture "$IPAD_DEVICE" "ipad-pro-13" "testIPadAppStoreScreenshots"
	fi
fi

if [[ "$CAPTURE_ONLY" -eq 0 ]]; then
	if [[ "$CAPTURE_IPHONE" -eq 1 ]]; then
		render_device_set "iphone-17-pro-max" compose_phone
	fi
	if [[ "$CAPTURE_IPAD" -eq 1 ]]; then
		render_device_set "ipad-pro-13" compose_ipad
	fi
fi

echo "App Store screenshots are ready in $OUTPUT_ROOT"
