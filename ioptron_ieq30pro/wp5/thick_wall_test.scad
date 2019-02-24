// If I set the walls very thick (rtp_boss_diam), can I fit the bosses into them.
// ANSWER: no, the diameter of the helmet isn't large enough for that to work.

use <../../utils/misc.scad>

include <../ieq30pro_dimensions.scad>
use <../ieq30pro_ra_and_dec.scad>

include <wp5_dimensions.scad>
use <can.scad>
use <helpers.scad>
use <lid.scad>
use <dec_head_port.scad>
use <tear_drop_shaft_port.scad>
use <bosses.scad>


ra_motor_skirt_thickness = rtp_boss_diam;
dec_head_thickness = rtp_boss_diam;


helmet_ir = ra_motor_clearance_radius_max + extra_ra_motor_clearance;
helmet_or = helmet_ir + ra_motor_skirt_thickness;
rim_or = helmet_ir + ra_motor_skirt_rim;

difference() {
  translate([0, 0, -can_height_below_ra1_base])
  linear_extrude(height=total_can_height, convexity=4)
    annulus(r1=helmet_ir, r2=helmet_or);

#screw_bosses(solid=true);
}

module screw_bosses(solid=false, nut_side=true, screw_side=true) {
  mirrored([0, 1, 0]) {
    if (nut_side) {
      bosses_below_cw_port(solid=solid, nut_side=true);
    }
    if (screw_side) {
      bosses_below_cw_port(solid=solid, nut_side=false);
    }
  }
}



