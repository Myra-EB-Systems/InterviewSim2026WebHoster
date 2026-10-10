#!/bin/bash
# Copies a Unity WebGL build of the Mock Interview into this GitHub Pages repo.
#   bash publish.sh [path to the WebGL build folder]
# Default build folder: ../InterviewSim/Builds/WebGL (made by Myra ▸ Interview ▸ Build WebGL).
# GitHub refuses files over 100 MB, so the big .data file is split into 45 MB parts listed in
# Build/data-parts.json; index.html downloads the parts and joins them in the browser.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
src="${1:-$here/../InterviewSim/Builds/WebGL}"
[ -f "$src/Build/WebGL.loader.js" ] || { echo "No WebGL build at $src"; exit 1; }

rm -rf "$here/Build" "$here/StreamingAssets"
mkdir -p "$here/Build"
cp "$src/Build/WebGL.loader.js" "$src/Build/WebGL.framework.js.unityweb" "$src/Build/WebGL.wasm.unityweb" "$here/Build/"
cp -r "$src/StreamingAssets" "$here/StreamingAssets"
rm -rf "$here/StreamingAssets/Whisper"   # desktop speech models; the browser does speech itself

data="$src/Build/WebGL.data.unityweb"
split -b 45m -d -a 2 "$data" "$here/Build/WebGL.data.part"
size=$(stat -c %s "$data")
parts=$(cd "$here/Build" && ls WebGL.data.part* | sed 's/.*/"&"/' | paste -sd, -)
echo "{ \"size\": $size, \"parts\": [ $parts ] }" > "$here/Build/data-parts.json"

touch "$here/.nojekyll"
echo "Copied build from $src"
ls -l "$here/Build"
