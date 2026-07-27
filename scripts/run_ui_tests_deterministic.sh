#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SUITE="${SUITE:-${1:-iphone}}"

case "${SUITE}" in
iphone)
	export TEST_SUITE="release-phone"
	if [[ -n "${SIMULATOR_ID:-}" ]]; then
		export PHONE_SIMULATOR_ID="${SIMULATOR_ID}"
	fi
	if [[ -n "${SIMULATOR_NAME:-}" ]]; then
		export PHONE_SIMULATOR_NAME="${SIMULATOR_NAME}"
	fi
	;;
ipad)
	export TEST_SUITE="release-ipad"
	if [[ -n "${SIMULATOR_ID:-}" ]]; then
		export IPAD_SIMULATOR_ID="${SIMULATOR_ID}"
	fi
	if [[ -n "${SIMULATOR_NAME:-}" ]]; then
		export IPAD_SIMULATOR_NAME="${SIMULATOR_NAME}"
	fi
	;;
*)
	printf '%s\n' "Unknown SUITE=${SUITE}. Use iphone or ipad." >&2
	exit 2
	;;
esac

exec "${ROOT_DIR}/scripts/run_ios_tests.sh"
