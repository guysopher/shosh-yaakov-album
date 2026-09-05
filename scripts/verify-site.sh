#!/usr/bin/env bash
set -euo pipefail

site_dir="$(cd "$(dirname "$0")/.." && pwd)"

required_files=(
  "$site_dir/index.html"
  "$site_dir/styles.css"
  "$site_dir/app.js"
  "$site_dir/.nojekyll"
  "$site_dir/.github/workflows/pages.yml"
  "$site_dir/assets/covers/front-cover.jpg"
  "$site_dir/assets/covers/back-cover.jpg"
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "Missing required file: $file" >&2; exit 1; }
done

for number in $(seq -w 1 24); do
  for side in left right; do
    file="$site_dir/assets/pages/$number-$side.jpg"
    [[ -f "$file" ]] || { echo "Missing page: $file" >&2; exit 1; }
  done
done

page_count="$(find "$site_dir/assets/pages" -type f -name '*.jpg' | wc -l | tr -d ' ')"
[[ "$page_count" == "48" ]] || { echo "Expected 48 pages, found $page_count" >&2; exit 1; }

OPENSSL_CONF=/dev/null node --check "$site_dir/app.js"
rg -q 'assets/covers/front-cover.jpg' "$site_dir/index.html"
rg -q 'actions/deploy-pages@v4' "$site_dir/.github/workflows/pages.yml"
rg -q 'vendor/page-flip.browser.js' "$site_dir/index.html"
[[ -f "$site_dir/vendor/page-flip.browser.js" ]]
[[ -f "$site_dir/vendor/page-flip.LICENSE" ]]

echo "Verified static flipbook: 2 covers, 48 page leaves, page engine, JavaScript syntax, and Pages workflow."
