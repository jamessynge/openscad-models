#!/bin/bash


SCALE=1

cd "$(dirname "${BASH_SOURCE[0]}")"
echo "Generating scale=${SCALE} STL files for OpenSCAD files in $(pwd)"

mkdir -p ../stl_files

function generate_stl_for() {
  local -r SCAD=$1
  local -r BASE="$(basename "${SCAD}" .scad)"
  local -r TS="$(date +%Y%m%d.%H%M)"
  local -r STL="../stl_files/${BASE}.scale_${SCALE}.${TS}.stl"
  echo
  echo "Processing ${SCAD} to generate ${STL}"
  echo
  (set -x ; time openscad-nightly -o "${STL}" -D the_scale=$SCALE "${SCAD}" )
}

echo '$# ==' $#

if [ $# -eq 0 ] ; then
  for SCAD in *.scad
  do
    generate_stl_for "${SCAD}"
  done
else
  for SCAD in ${*}
  do
    generate_stl_for "${SCAD}"
  done
fi

exit
