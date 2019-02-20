// 
// Author: James Synge
// Units: mm


use <../ieq30pro_ra_and_dec.scad>
use <shaft_port.scad>
include <wp5_dimensions.scad>
use <../../utils/misc.scad>

// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.


translate([3*rim_or, 0, 0])
  can_solid();

translate([-3*rim_or, 0, 0])
  can_interior();

difference() {
  can_solid();
  can_interior();
}

module can_solid() {
  lid_avoidance_h = lid_thickness + lid_grip_height;

  module profile() {
    polygon([
      [2, 0],
      [0.01, ra_motor_skirt_rim-0.5],
      [2, ra_motor_skirt_rim-0.5],
      [ra_motor_skirt_rim + 2, 0],
    ]);
  }

  descend = ra_motor_skirt_max_z + ra_bearing_gap;

  translate([0, 0, -descend]) {
    cylinder(h=total_can_height, r=helmet_or);
    cylinder(h=ra_motor_skirt_rim, r=rim_or);

    // Add a gutter to deflect water away from the seam between the nut
    // and screw sides of the can.

    linear_extrude(height=total_can_height - lid_avoidance_h, convexity=4)
      mirror([0, 1, 0])
        translate([0, helmet_ir+0.1, 0])
          profile();

    // Add another gutter to deflect water away from the CW port, minimizing
    // the run-off from higher on the can into the CW port.

    translate([0, 0, descend])
    rotate([0, 0, 200])
    linear_extrude(height=total_can_height - lid_avoidance_h - descend, convexity=4)
//      mirror([0, 0, 0])
        translate([0, helmet_ir+0.1, 0])
          profile();

  }
}

module can_interior() {
  translate([0, 0, -(ra_motor_skirt_max_z + ra_bearing_gap + 1)])
    cylinder(h=total_can_height+2, r=helmet_ir);
}

// A shelf/edge that extends up from a lower quarter to ease the process of
// gluing the upper quarter to it. More sophisticated alignment cones or
// screw/nut bosses can wait (e.g. this might be sufficient).
module can_gluing_shelf(a1=0, a2=80) {
  module profile() {
    v = ra_motor_skirt_thickness;
    translate([helmet_ir, 0, 0])
    polygon([
      [-v, 0],
      [1, -2*(v+1)],
      [1, 0],
      [0, 0],
      [0, v],
      [-v, v],
    ]);
  }
  translate([0, 0, ra1_base_to_dec_center])
    rotate([0, 0, a1])
      rotate_extrude(angle=a2-a1)
        profile();
}

translate([200, 200, 0])
  can_gluing_shelf();

// module can_alignment_cone(upper=true, lower=false) {
//   module support() {
//     // We compute a hull between a sphere embedded in the wall of the can
//     // and a short cylinder that supports (or contains) the cone.
//     // The result is positioned so the top of the cylinder is at z=0, and that
//     // the cylinder is offset from the z axis in x so that it is tangent with
//     // the y axis. Not yet sure if that is the right location for moving to the
//     // wall.

//     ch = max(cone_height, cone_hole_depth);
//     cr = cone_support_diam/2;
//     sd = ch + cone_support_diam

// round_top_pyramid

//     translate([cr, 0, ch])
//       cylinder(h=, d=cone_support_diam);

//   }

// }