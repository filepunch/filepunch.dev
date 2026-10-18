#!/bin/sh
# Redraws the PNG images in site/ from their sources:
#
#   images/social.html  ->  site/social.png            1200 x 630, link previews
#   images/icon.html    ->  site/apple-touch-icon.png  180 x 180, phone home screens
#   site/favicon.svg    ->  site/favicon.png           32 x 32, browsers without SVG icons
#
# Chrome draws each source, then Pillow cuts the PNG down to a few colors so
# the files stay small. Needs Google Chrome or Chromium (or set CHROME to its
# path) and Python 3 with Pillow. Run it from anywhere: sh images/render.sh
#
# The text in social.png uses the fonts installed on the machine that runs
# this script. It was last drawn with Cantarell, which is in the site's font
# list. Look at the result before you commit it.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
site=$(cd "$here/../site" && pwd)

chrome=${CHROME:-}
if [ -z "$chrome" ]; then
  for c in google-chrome google-chrome-stable chromium chromium-browser; do
    if command -v "$c" >/dev/null 2>&1; then chrome=$c; break; fi
  done
fi
if [ -z "$chrome" ]; then
  echo "render.sh: Chrome or Chromium not found; set CHROME to its path" >&2
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# shot URL WIDTH HEIGHT SCHEME OUT [more Chrome flags]
# SCHEME is 0 to draw the dark colors and 1 to draw the light colors.
shot() {
  url=$1 w=$2 h=$3 scheme=$4 out=$5
  shift 5
  "$chrome" --headless --disable-gpu --no-first-run --no-default-browser-check \
    --hide-scrollbars --disable-lcd-text --force-device-scale-factor=1 \
    --user-data-dir="$tmp/profile" --window-size="$w,$h" \
    --blink-settings=preferredColorScheme="$scheme" "$@" \
    --screenshot="$out" "$url" >/dev/null 2>&1 || true
  if [ ! -s "$out" ]; then
    echo "render.sh: Chrome did not draw $url" >&2
    exit 1
  fi
}

shot "file://$here/social.html" 1200 630 0 "$tmp/social.png"
shot "file://$here/icon.html" 180 180 0 "$tmp/icon.png"
# The light colors are the darker green, which shows on light and dark tabs.
shot "file://$site/favicon.svg" 32 32 1 "$tmp/favicon.png" --default-background-color=00000000

python3 - "$tmp" "$site" <<'EOF'
import os
import sys

from PIL import Image, features

tmp, site = sys.argv[1], sys.argv[2]
# libimagequant is the library behind pngquant. Without it, use Pillow's own.
method = Image.Quantize.LIBIMAGEQUANT if features.check("libimagequant") else Image.Quantize.FASTOCTREE


def shrink(src, dst, size, colors, mode):
    im = Image.open(os.path.join(tmp, src)).convert(mode)
    if im.size != size:
        sys.exit(f"render.sh: {src} is {im.size}, expected {size}")
    im = im.quantize(colors=colors, method=method)
    path = os.path.join(site, dst)
    im.save(path, optimize=True)
    print(f"site/{dst}: {size[0]} x {size[1]}, {os.path.getsize(path)} bytes")


shrink("social.png", "social.png", (1200, 630), 32, "RGB")
shrink("icon.png", "apple-touch-icon.png", (180, 180), 32, "RGB")
shrink("favicon.png", "favicon.png", (32, 32), 16, "RGBA")
EOF
