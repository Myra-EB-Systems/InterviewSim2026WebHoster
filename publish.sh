#!/bin/bash
# Copies a Unity WebGL build of the Mock Interview into this GitHub Pages repo.
#   bash publish.sh [path to the WebGL build folder] [output folder]
# With an output folder (e.g. ../InterviewSim/Builds/WebGL-Site) it makes a complete local test copy of
# the site there instead of updating this repo; serve it with  python -m http.server 8642 --bind 127.0.0.1
# Default build folder: ../InterviewSim/Builds/WebGL (made by Myra ▸ Interview ▸ Build WebGL).
# GitHub refuses files over 100 MB, so the big .data file is split into 45 MB parts listed in
# Build/data-parts.json; index.html downloads the parts and joins them in the browser.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
src="${1:-$here/../InterviewSim/Builds/WebGL}"
out="${2:-$here}"
if [ "$out" != "$here" ]; then
  mkdir -p "$out"
  cp "$here/index.html" "$here/style.css" "$out/"
  rm -rf "$out/assets"; cp -r "$here/assets" "$out/assets"
fi
[ -f "$src/Build/WebGL.loader.js" ] || { echo "No WebGL build at $src"; exit 1; }

rm -rf "$out/Build" "$out/StreamingAssets"
mkdir -p "$out/Build"
cp "$src/Build/WebGL.loader.js" "$src/Build/WebGL.framework.js.unityweb" "$src/Build/WebGL.wasm.unityweb" "$out/Build/"
cp -r "$src/StreamingAssets" "$out/StreamingAssets"
rm -rf "$out/StreamingAssets/Whisper"   # desktop speech models; the browser does speech itself

data="$src/Build/WebGL.data.unityweb"
split -b 45m -d -a 2 "$data" "$out/Build/WebGL.data.part"
size=$(stat -c %s "$data")
parts=$(cd "$out/Build" && ls WebGL.data.part* | sed 's/.*/"&"/' | paste -sd, -)
echo "{ \"size\": $size, \"v\": \"$(date +%Y%m%d%H%M%S)\", \"parts\": [ $parts ] }" > "$out/Build/data-parts.json"

touch "$out/.nojekyll"
echo "Copied build from $src"
ls -l "$out/Build"
