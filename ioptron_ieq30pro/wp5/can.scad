// 
// Author: James Synge
// Units: mm


use <../ieq30pro_ra_and_dec.scad>
use <shaft_port.scad>
include <wp5_dimensions.scad>
use <../../utils/misc.scad>


translate([3*rim_or, 0, 0])
  can_solid();

translate([-3*rim_or, 0, 0])
  can_interior();

difference() {
  can_solid();
  can_interior();
}

module can_solid() {
  translate([0, 0, -(ra_motor_skirt_max_z + ra_bearing_gap)]) {
    cylinder(h=total_can_height, r=helmet_or);
    cylinder(h=ra_motor_skirt_rim, r=rim_or);

    // Add a gutter to deflect water away from the seam between the nut
    // and screw sides of the can.
    lid_avoidance_h = lid_thickness + lid_grip_height;

    linear_extrude(height=total_can_height - lid_avoidance_h, convexity=4)
      mirror([0, 1, 0])
        translate([0, helmet_ir+0.1, 0])
          polygon([
            [2, 0],
            [0.01, ra_motor_skirt_rim-0.5],
            [2, ra_motor_skirt_rim-0.5],
            [ra_motor_skirt_rim + 2, 0],
          ]);
  }
}

module can_interior() {
  translate([0, 0, -(ra_motor_skirt_max_z + ra_bearing_gap + 1)])
    cylinder(h=total_can_height+2, r=helmet_ir);
}
