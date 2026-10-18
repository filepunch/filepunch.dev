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

# Runs Chrome. When the timeout command exists, it stops Chrome after $limit
# seconds, so a Chrome that hangs cannot hang this script.
limit=60
run_chrome() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "$limit" "$chrome" "$@"
  else
    "$chrome" "$@"
  fi
}

# shot URL WIDTH HEIGHT SCHEME OUT [more Chrome flags]
# SCHEME is 0 to draw the dark colors and 1 to draw the light colors.
# Chrome's messages go to a log, which is printed when Chrome draws nothing.
shot() {
  url=$1 w=$2 h=$3 scheme=$4 out=$5
  shift 5
  status=0
  run_chrome --headless --disable-gpu --no-first-run --no-default-browser-check \
    --hide-scrollbars --disable-lcd-text --force-device-scale-factor=1 \
    --user-data-dir="$tmp/profile" --window-size="$w,$h" \
    --blink-settings=preferredColorScheme="$scheme" "$@" \
    --screenshot="$out" "$url" >"$tmp/chrome.log" 2>&1 || status=$?
  if [ -s "$out" ]; then
    return 0
  fi
  echo "render.sh: Chrome did not draw $url (exit status $status)" >&2
  if [ "$status" -eq 124 ]; then
    echo "render.sh: Chrome was still running after $limit seconds, so it was stopped" >&2
  fi
  # Chrome puts a socket in TMPDIR, and the path of a socket can only be about
  # 100 bytes long. With a long TMPDIR, Chrome crashes and prints nothing.
  tmpdir=${TMPDIR:-/tmp}
  if [ "$status" -gt 128 ] && [ "${#tmpdir}" -gt 60 ]; then
    echo "render.sh: Chrome crashed. TMPDIR is ${#tmpdir} characters long, and" \
      "Chrome crashes when it is longer than about 60. Try: TMPDIR=/tmp sh $0" >&2
  fi
  if [ -s "$tmp/chrome.log" ]; then
    echo "render.sh: the last lines Chrome printed:" >&2
    tail -n 40 "$tmp/chrome.log" >&2
  else
    echo "render.sh: Chrome printed nothing" >&2
  fi
  exit 1
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


# On the social card, 30 colors look the same as 32 and make the file smaller.
# With fewer than about 28, its glows look speckled when zoomed in.
shrink("social.png", "social.png", (1200, 630), 30, "RGB")
shrink("icon.png", "apple-touch-icon.png", (180, 180), 32, "RGB")
shrink("favicon.png", "favicon.png", (32, 32), 16, "RGBA")
EOF
