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

union() {
  difference() {
    can_solid();
    can_interior();
  }
  can_gluing_shelf_lips();
  // can_gluing_shelf();
  // can_resting_shelf();
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
// Defaults are for the nut-side of the helmet.
module can_gluing_shelf(a1=-80, a2=20, z=ra1_base_to_dec_center) {
  module profile() {
    v = can_shelf_height;
    translate([helmet_ir, 0, 0])
    polygon([
      [-v, 0],
      [1, -can_shelf_support_height],
      [1, 0],
      [0, 0],
      [0, v],
      [-v, v],
    ]);
  }
  translate([0, 0, z])
    rotate([0, 0, a1])
      rotate_extrude(angle=a2-a1)
        translate([helmet_ir, 0, 0])
          shelf_lip_profile();
}

translate([200, 200, 0])
  can_gluing_shelf();

// Adaptation of can_gluing_shelf for keeping the can from sliding down
// the sides of the can/helmet. It will rest on top of the interior supports.
module can_resting_shelf(a1=-60, a2=60, z=helmet_supports_height_above_ra_bearing+0.1, shelf_lip_height=can_shelf_height) {
  module profile() {
    // v = can_shelf_height;
    translate([helmet_ir, shelf_lip_height, 0])
    mirror([0, 1, 0])
    shelf_lip_profile(height=shelf_lip_height);
    // polygon([
    //   [-v, 0],
    //   [1, -can_shelf_support_height],
    //   [1, 0],
    //   [0, 0],
    //   [0, v],
    //   [-v, v],
    // ]);
  }

  translate([0, 0, z])
    rotate([0, 0, a1])
      rotate_extrude(angle=a2-a1)
        profile();
}

// The profile of the shelf used to assist in alignment during gluing.
//               +
//               |
//               |XXXXXXX
//               X      X
//               X      X
//               X      X
//  +---------XXXX------X------+
//            X  |     X
//            X  |    X
//            X  |   X
//            X  |  X
//            X  | X
//            X  +X
//            XXXX
//               |
//               |
//               +
module shelf_profile(height=can_shelf_height, support_height=can_shelf_support_height) {
  translate([0, height, 0]) {
    polygon([
      [-height, 0],
      [1, -support_height],
      [1, 0],
      [0, 0],
      [0, height],
      [-height, height],
    ]);
  }
}

translate([30, 0, 0])
  shelf_profile();

// The "shelf" is actually not included in this profile, as that is assumed
// to be the top of the sliced can, so this is really the lip that keeps the
// object that is resting on the top from sliding off in one direction. We
// assume that the lip is on the inside of the can, so most of the profile is
// in the negative-X half of the plane.
module shelf_lip_profile(height=can_shelf_height, width=can_shelf_height, support_height=can_shelf_support_height, outset_factor=0.05, inset_factor=0.3) {
  // Avoid having the lip directly touching the object resting on the shelf by
  // adding a slight setback.
  outset = width * outset_factor;
  // Avoid having the support end right against the can, which might lead to
  // some difficult floating point math.
  inset = width * inset_factor;
  polygon([
    [-outset,0],
    [-outset, height],
    [-width, height],
    [-width, 0],
    [inset/10, -support_height],
    [inset, -support_height],
    [inset, 0],
  ]);
}

shelf_lip_profile();




// An alternating series of vertical edges to help align the upper and lower
// quarters of a half of the can, keeping them in place during gluing.
// Defaults are for the nut-side of the helmet, so use mirror to place on the
// screw-side.
module can_gluing_shelf_lips(start_a=-80, end_a=25, z=ra1_base_to_dec_center, top=true, bottom=true, overlap=false) {
  height=can_shelf_height;
  width=can_shelf_height;
  support_height=can_shelf_support_height;
  ir = helmet_ir;

  module profile(invert) {
    shelf_lip_profile(height=height, width=width, support_height=support_height);
  }

  module one_lip(from_a, to_a, invert) {
    rotate([0, 0, from_a]) {
      rotate_extrude(angle=to_a-from_a) {
        translate([ir, 0, 0]) {
          mirror([0, invert ? 1 : 0, 0]) profile();
        }
      }
    }
  }

  module bevel_cuboid(angle) {
    max_r = ir + width;
    h = 3 * max(height, support_height);
    y = sin(angle) * ir;
    if (angle > 0) {
      assert(y > 0);
      assert(y < ir);
      translate([0, y, -h/2]) {
        cube([max_r, max_r - y, h]);
      }
    } else {
      assert(y < 0);
      assert(y > -ir);
      l = max_r + y;
      assert(l > 0);
      translate([0, -max_r, -h/2]) {
        cube([max_r, l, h]);
      }
    }
  }



  module one_bevelled_lip(from_a, to_a, invert) {
    //echo(str("From ", from_a, " to ", to_a));
    if (to_a < 0) {
      // Need to bevel end of the lip at to_a.
      intersection() {
        one_lip(from_a, to_a, invert);
        bevel_cuboid(to_a);
      }
    } else if (from_a > 0) {
      // Need to bevel end of the lip at from_a.
      intersection() {
        one_lip(from_a, to_a, invert);
        bevel_cuboid(from_a);
      }
    } else {
      // No need to bevel the ends of the lip,
      one_lip(from_a, to_a, invert);
    }
  }

  num_segments = 5;
  da = end_a - start_a;
  seg_da = da / num_segments;
  e = overlap ? -2 : min(2, seg_da/10)/2;
  for (seg = [0:num_segments-1]) {
    is_bottom = (seg % 2) == 0;
    if ((is_bottom && bottom) || (!is_bottom && top)) {
      a1_ = start_a + seg * seg_da;
      a2_ = end_a - (num_segments-1-seg) * seg_da;
      is_first = seg == 0;
      is_last = seg == num_segments-1;
      a1 = a1_ + (is_first ? 0 : e);
      a2 = a2_ - (is_last ? 0 : e);

      translate([0, 0, z])
        one_bevelled_lip(a1, a2, !is_bottom);
    }
  }


  // segment_a = da/3;
  // a0 = start_a;
  // a1 = start_a + segment_a;
  // a3 = end_a;
  // a2 = a3 - segment_a;
  // e = min(2, da/20)/2;

  // translate([0, 0, z]) {
  //   if (bottom) {
  //     one_bevelled_lip(a0, a1-e, false);
  //     one_bevelled_lip(a2+e, a3, false);
  //   }
  //   if (top) {
  //     one_bevelled_lip(a1+e, a2-e, true);
  //   }
  // }
}

















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