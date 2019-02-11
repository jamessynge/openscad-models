// Experiment with a new helmet design, per README.md and TODO.md
// Author: James Synge
// Units: mm
include <../ieq30pro_dimensions.scad>
//use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

include <../ieq30pro_wp_dimensions.scad>
include <wp4_dimensions.scad>

include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>




// Global resolution
$fs = $preview ? 10 : 1;
$fa = $preview ? 10 : 1;



ra_clutch_angle=90;
ra_and_dec(include_dec_head=true, ra_clutch_angle=ra_clutch_angle) {
  s = 300;
  intersection() {
    // basic_helmet2();
    translate([0, -s/2, -100]) cube(size=s);

  }
}
