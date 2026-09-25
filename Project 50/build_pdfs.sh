#!/usr/bin/env bash
# Every Markdown and HTML in the vault gets a sibling PDF. Idempotent: rebuilds only when the source is newer.
# All conversion happens outside the vault and only the finished PDF is copied in (soffice litters tmp files; this sandbox cannot delete). Usage: bash _build/build_pdfs.sh
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CSS="$ROOT/_build/print.css"
TMP="$(mktemp -d)"
find "$ROOT" \( -path "$ROOT/90_Archive" -o -path "$ROOT/_build" -o -path "$ROOT/.obsidian" -o -path "$ROOT/.git" -o -name ".*" \) -prune -o \( -name "*.md" -o -name "*.html" \) -type f -print | while IFS= read -r src; do
  case "$src" in "$ROOT/_build/"*|"$ROOT/90_Archive/"*) continue;; esac
  dir="$(dirname "$src")"; base="$(basename "$src")"; stem="${base%.*}"; pdf="$dir/$stem.pdf"
  if [ -f "$pdf" ] && [ ! "$src" -nt "$pdf" ]; then continue; fi
  case "$base" in
    *.md)  mkdir -p "$TMP/$stem.d"; pandoc "$src" -s --metadata title="$stem" -c "$CSS" -o "$TMP/$stem.d/$stem.html" 2>/dev/null || continue
           soffice --headless --convert-to pdf --outdir "$TMP/$stem.d" "$TMP/$stem.d/$stem.html" >/dev/null 2>&1
           [ -f "$TMP/$stem.d/$stem.pdf" ] && cp "$TMP/$stem.d/$stem.pdf" "$pdf" ;;
    *.html) mkdir -p "$TMP/$stem.h"; soffice --headless --convert-to pdf --outdir "$TMP/$stem.h" "$src" >/dev/null 2>&1
           [ -f "$TMP/$stem.h/$stem.pdf" ] && cp "$TMP/$stem.h/$stem.pdf" "$pdf" ;;
  esac
  [ -f "$pdf" ] && echo "built: ${pdf#$ROOT/}"
done
