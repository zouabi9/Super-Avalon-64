#!/usr/bin/env bash
# Regenerate every STL in stl/ from the OpenSCAD sources.
# Needs OpenSCAD 2021.01 or newer and the Liberation Sans / Liberation Mono fonts.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p stl/coins stl/tube

coins=(merlin percival assassin morgana mordred oberon loyal_servant minion
       lady_of_the_lake loyalty_good loyalty_evil marker_good marker_evil)

jobs=()
for c in "${coins[@]}"; do
  openscad -q -D "part=\"$c\"" -o "stl/coins/$c.stl" scad/coins.scad &
  jobs+=($!)
done
openscad -q -D 'part="tube"' -o stl/tube/tube.stl scad/tube.scad &
jobs+=($!)
openscad -q -D 'part="lid"' -o stl/tube/lid.stl scad/tube.scad &
jobs+=($!)
for j in "${jobs[@]}"; do wait "$j"; done
echo "STLs written to stl/"
