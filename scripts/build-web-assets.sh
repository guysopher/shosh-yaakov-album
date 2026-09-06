#!/usr/bin/env bash
set -euo pipefail

site_dir="$(cd "$(dirname "$0")/.." && pwd)"
album_dir="$(cd "$site_dir/.." && pwd)"
asset_scratch_root="${LUPA_SCRATCH_ROOT:-/Users/guyso/Documents/AISlop}"
mkdir -p "$asset_scratch_root"
asset_build_dir="$(mktemp -d "$asset_scratch_root/lupa-asset-build.XXXXXX")"
trap 'rm -rf "$asset_build_dir"' EXIT
export TMPDIR="$asset_build_dir"
mkdir -p "$site_dir/assets/covers" "$site_dir/assets/pages"

swift_bin="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift"
if [[ ! -x "$swift_bin" ]]; then
  swift_bin="$(command -v swift)"
fi

CLANG_MODULE_CACHE_PATH="$asset_build_dir/clang-cache" \
SWIFT_MODULECACHE_PATH="$asset_build_dir/swift-cache" \
  "$swift_bin" "$site_dir/scripts/resize-assets.swift" "$album_dir" "$site_dir"

echo "Built 2 covers and 48 web pages in $site_dir/assets"
