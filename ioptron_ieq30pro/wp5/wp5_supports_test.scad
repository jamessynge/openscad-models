// Various modules that contribute to the weatherproofing design.
// Author: James Synge
// Units: mm
include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <../ieq30pro_dec_motor.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

include <../ieq30pro_wp_dimensions.scad>
include <wp5_dimensions.scad>
use <polar_port_and_cap.scad>
use <helpers.scad>

include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/paired_bosses.scad>
use <../../utils/axis_arrows.scad>


// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.

mount_latitude=90;
// ra_angle = 152 + $t * 360;  // For testing boss below CW port.
ra_angle = 30 + $t * 360;  // DEC clutch handle very near RA motor.
dec_angle = 180 + 58 + $t * 360; // DEC clutch handle "down" at closest to RA motor.



ra_and_dec(dec_angle=dec_angle) {

}
