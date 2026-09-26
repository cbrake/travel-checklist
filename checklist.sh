#!/bin/sh
# Print a two-column packing checklist PDF for one trip type from
# packing-list.ods. The trip matches a column header by case-insensitive
# prefix (weekend, car, overlanding, backpacking). Writes
# checklist-<trip>.pdf next to this script, or to the path given.
#   ./checklist.sh backpacking
#   ./checklist.sh car ~/car.pdf
#   ./checklist.sh all
#
# Requires LibreOffice (for the CSV export) and Typst.

set -e

if [ $# -lt 1 ]; then
	echo "usage: $0 <trip|all> [output.pdf]" >&2
	exit 1
fi

dir=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# 44,34,76: comma separator, double-quote text, UTF-8
libreoffice --headless --convert-to 'csv:Text - txt - csv (StarCalc):44,34,76' \
	--outdir "$tmp" "$dir/packing-list.ods" >/dev/null
csv="$tmp/packing-list.csv"
trips=$(head -1 "$csv" | tr ',' '\n' | tail -n +4)

build() {
	trip=$(printf '%s\n' "$trips" | awk -v t="$1" 'index(tolower($0), tolower(t)) == 1 { print; exit }')
	if [ -z "$trip" ]; then
		echo "no trip column matches '$1'" >&2
		return 1
	fi
	slug=$(printf %s "$trip" | tr '[:upper:] ' '[:lower:]-')
	out=${2:-"$dir/checklist-$slug.pdf"}
	typst compile --input trip="$trip" --input csv="$(cat "$csv")" \
		"$dir/checklist.typ" "$out"
	echo "$out"
}

if [ "$1" = all ]; then
	printf '%s\n' "$trips" | while IFS= read -r t; do build "$t"; done
else
	build "$1" "$2"
fi
