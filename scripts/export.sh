#!/usr/bin/env bash
# Regenerate every STL in stl/ from the OpenSCAD sources.
# Needs OpenSCAD 2021.01 or newer and the Liberation Sans / Liberation Mono fonts.
# JOBS sets how many renders run at once (default 4; the tube needs ~2 GB on its own).
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p stl/coins stl/tube

coins=(merlin percival assassin morgana mordred oberon loyal_servant minion
       lady_of_the_lake loyalty_good loyalty_evil success fail marker)

{
  echo "tube scad/tube.scad stl/tube/tube.stl"
  echo "lid scad/tube.scad stl/tube/lid.stl"
  for c in "${coins[@]}"; do echo "$c scad/coins.scad stl/coins/$c.stl"; done
} | xargs -P "${JOBS:-4}" -L 1 sh -c 'openscad -q -D "part=\"$0\"" -o "$2" "$1"'
echo "STLs written to stl/"
