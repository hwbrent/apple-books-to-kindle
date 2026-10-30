#!/usr/bin/env bash
# Re-zips unpacked .epub folders (as exported by Apple Books) into proper
# single-file EPUBs. Originals are left untouched.
#
# Usage: ./fix_epubs.sh [source_dir] [output_dir]
# Defaults: source = ~/Downloads, output = <source>/fixed-epubs

set -u

SRC="${1:-$HOME/Downloads}"
OUT="${2:-$SRC/fixed-epubs}"

if [ ! -d "$SRC" ]; then
  echo "Source directory not found: $SRC" >&2
  exit 1
fi

mkdir -p "$OUT"
fixed=0
skipped=0

# Only look at directories whose name ends in .epub (real .epub files are skipped)
while IFS= read -r -d '' dir; do
  name="$(basename "$dir")"
  target="$OUT/$name"

  if [ -e "$target" ]; then
    echo "Skipping (already exists): $name"
    skipped=$((skipped + 1))
    continue
  fi

  # Work on a temp copy so we never touch the original or add files to it
  tmp="$(mktemp -d)"
  cp -R "$dir/." "$tmp/"

  # An EPUB must contain a mimetype file with this exact content
  if [ ! -f "$tmp/mimetype" ]; then
    echo "Note: no mimetype file in $name, creating one"
    printf 'application/epub+zip' > "$tmp/mimetype"
  fi

  # Clean out macOS junk
  find "$tmp" -name '.DS_Store' -delete

  (
    cd "$tmp" || exit 1
    # mimetype first, stored uncompressed, no extra attributes
    zip -X0 -q "$target" mimetype &&
    # then everything else, compressed
    zip -Xr9D -q "$target" . -x mimetype
  )
  status=$?
  rm -rf "$tmp"

  if [ $status -eq 0 ]; then
    echo "Fixed: $name"
    fixed=$((fixed + 1))
  else
    echo "FAILED: $name" >&2
    rm -f "$target"
    skipped=$((skipped + 1))
  fi
done < <(find "$SRC" -maxdepth 1 -type d -name '*.epub' -print0)

echo
echo "Done. Fixed: $fixed, skipped/failed: $skipped"
echo "Output folder: $OUT"
