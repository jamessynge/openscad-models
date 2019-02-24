#!/bin/bash

SCALE=0.333

cd "$(dirname "${BASH_SOURCE[0]}")"
echo "Generating scale=${SCALE} STL files for each OpenSCAD files in $(pwd)"

mkdir -p ../stl_files

for SCAD in *.scad
do
  STL="../stl_files/$(basename "${SCAD}" .scad).$(date +%Y%m%d.%H%M).stl"
  echo
  echo "Processing ${SCAD} to generate ${STL}"
  echo
  (set -x ; time openscad-nightly -o "${STL}" -D the_scale=$SCALE "${SCAD}" )
done
