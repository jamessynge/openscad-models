// Author: James Synge
// Units: mm

include <../ieq30pro_dimensions.scad>
include <../ieq30pro_wp_dimensions.scad>
include <wp5_dimensions.scad>

use <can.scad>
use <polar_port_and_cap.scad>
use <helpers.scad>

// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.


simple_lid();
if ($preview)
#translate([0, 0, -5]) can_solid();


module simple_lid(extra_ir=extra_ra_motor_clearance, helmet_thickness=ra_motor_skirt_thickness, lid_thickness=lid_thickness, grip_height=lid_grip_height) {

  ir = ra_motor_clearance_radius_max + extra_ir;
  skirt_or = ir + helmet_thickness;
  lid_or = skirt_or + lid_thickness;

  module grip_profile() {
    y0 = 0;
    y1 = lid_thickness;
    y2 = y1+grip_height;
    x0 = 0;
    x2 = lid_thickness;
    x1 = x2 * 0.2;
    polygon([
      [x0, y0],
      [x2, y0],
      [x2, y2],
      [x1, y2],
      [x0, y1],
    ]);
  }
  module outer_grip() {
    translate([lid_or - lid_thickness, 0, 0]) grip_profile();
  }
  module inner_grip() {
    translate([lid_or - lid_thickness - helmet_thickness, 0, 0])
      mirror([1, 0, 0])
        grip_profile();
  }

  // The outer is optional so that we can slide the screw side (not glued to
  // to the lid) into place without needing to move down and then up.
  module profile(include_outer=true, include_inner=true, include_tab=false) {
    square([lid_or, lid_thickness]);
    if (include_tab) {
      hull() {
        outer_grip();
        inner_grip();
      }
    } else {
      if (include_outer) {
        outer_grip();
      }
      if (include_inner) {
        inner_grip();
      }      
    }
  }

  module solid_body() {
    // The outer lip/grip goes half way around.
    rotate_extrude(angle=180, convexity=4) profile(include_outer=true, include_inner=false);

    // The inner lip/grip goes all the way around, minus a slot for an
    // alignment tab on the inside of the top of the helmet.
    tab_size = lid_tab_slot_degrees;
    rotate([0, 0, 90 + tab_size/2])
      rotate_extrude(angle=360 - tab_size, convexity=4)
        profile(include_outer=false, include_inner=true);
  }

  module move_into_place(extra_h=0) {
    raise_by = can_height_above_ra1_base + lid_thickness + extra_h;
    translate([0, 0, raise_by]) {
      rotate([0, 180, 0]) {
        rotate([0, 0, 90]) {
          children();
        }
      }
    }
  }

  module undo_move_into_place(extra_h=0) {
    raise_by = can_height_above_ra1_base + lid_thickness + extra_h;
    rotate([0, 0, -90]) {
      rotate([0, 180, 0]) {
        translate([0, 0, -raise_by]) {
          children();
        }
      }
    }
  }

  module body() {
    move_into_place() {
      difference() {
        solid_body();
        *difference() {
          can_solid();
          can_interior();
        }
      }
    }
  }


  if ($preview) {
    // Nudge up so not directly on the can/helmet.
    translate([0, 0, 0.1]) {
      move_into_place() {
        solid_body();
      }
    }
    // translate([0, 0, helmet_min_height_above_ra_bearing + helmet_extra_height_above_dec_skirt + lid_thickness+.1]) {
    //   rotate([0, 180, 0])
    //     rotate([0, 0, 90])
    //       solid_body();
  } else {
//    undo_move_into_place()
      solid_body();
  }
}
