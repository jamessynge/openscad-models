#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"
echo "Generating STL files for measuring circle diameters."

mkdir -p ../stl_files

function generate_stl_for_diameter() {
  local -r DIAMETER="$1"
  local -r SCAD="measure_diameter.scad"
  local -r BASE="$(basename "${SCAD}" .scad)"
  local -r STL="../stl_files/${BASE}.diameter_${DIAMETER}.stl"
  echo
  echo "Processing ${SCAD} to generate ${STL}"
  echo
  (set -x ; time openscad-nightly -o "${STL}" -D the_diameter=$DIAMETER "${SCAD}" )
}

for DIAMETER in ${*}
do
  generate_stl_for_diameter "${DIAMETER}"
done
