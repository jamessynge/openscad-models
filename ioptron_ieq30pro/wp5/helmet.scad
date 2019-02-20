// 
// Author: James Synge
// Units: mm

use <../../utils/misc.scad>

include <../ieq30pro_dimensions.scad>
use <../ieq30pro_ra_and_dec.scad>

include <wp5_dimensions.scad>
use <can.scad>
use <helpers.scad>
use <lid.scad>
use <dec_head_port.scad>
use <tear_drop_shaft_port.scad>

// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 3 : 1;  // Minimum size for a fragment.
$fa = $preview ? 8 : 1;  // Minimum angle for a fragment.

rotate([0, 0, 180 * $t])
ra_and_dec() { separated_helmet(); }

*translate([0, 0, 0.1])
#simple_lid();


module separated_helmet() {
  max_distance = 100;
  distance = max(0, max_distance - $t * max_distance);
  dx = distance;
  dz = distance;
  translate([dx, 0, dz])
    basic_helmet_nut_side_top();
  translate([dx, 0, -dz])
    basic_helmet_nut_side_bottom();
  translate([-dx, 0, dz])
   basic_helmet_screw_side_top();
  translate([-dx, 0, -dz])
   basic_helmet_screw_side_bottom();

  translate([0, 0, 2*dz])
    simple_lid();

}



module basic_helmet_nut_side_top() {
  cut_along_x(keep_above=true) {
    basic_helmet(top=true, bottom=false);
  }
}

module basic_helmet_nut_side_bottom() {
  cut_along_x(keep_above=true) {
    basic_helmet(top=false, bottom=true);
  }
}

module basic_helmet_screw_side_top() {
  cut_along_x(keep_above=false) {
    basic_helmet(top=true, bottom=false);
  }
}

module basic_helmet_screw_side_bottom() {
  cut_along_x(keep_above=false) {
    basic_helmet(top=false, bottom=true);
  }
}

module basic_helmet(top=true, bottom=true) {
  assert(top || bottom);

  module solid() {
    can_solid();
    dec_head_port();
  }

  module cutouts() {
    can_interior();
    dec_head_port_interior();
    if (bottom) {
      cw_shaft_port_interior();
    } else {
      cw_shaft_port_solid();
    }
  }

  module diff() {
    difference() {
      solid();
      cutouts();
    }
  }



  if (top != bottom) {
    cut_along_z(z=ra1_base_to_dec_center, keep_above=top) {
      diff();
    }
  } else {
    diff();
  }


*  cut_along_z(z=ra1_base_to_dec_center, keep_above=true)
  difference() {
    union() {
      can_solid();
      dec_head_port();
      if (bottom) {
        cw_shaft_port_solid();
      }
    }

    can_interior();
    dec_head_port_interior();
    if (bottom) {
      cw_shaft_port_interior();
    } else {
      cw_shaft_port_solid();
    }
  }

  if (top) {
    lid_alignment_tab();
  }

  if (bottom) {
    mirrored([1, 0, 0])
    can_gluing_shelf(a1=-80, a2=20);

    difference() {
      cw_shaft_port_solid();
      cw_shaft_port_interior();
    }
  }
}

module helmet_hcut_supports() {
  translate([0, 0, ra1_base_to_dec_center]) {

  }
}

module cw_shaft_port_solid() {
  translate_to_dec12_plane(z_towards_dec_head=false)
    translate([0, 0, ra1_radius + helmet_ir])
      rotate([0, 0, -90])
        tear_drop_shaft_port(cw_shaft_port_dims, solid=true);
}

module cw_shaft_port_interior() {
  translate_to_dec12_plane(z_towards_dec_head=false)
    translate([0, 0, ra1_radius + helmet_ir])
      rotate([0, 0, -90])
        tear_drop_shaft_port(cw_shaft_port_dims, interior_only=true);
}


module lid_alignment_tab() {
  tab_size = lid_tab_slot_degrees * 0.95;

  translate([0, 0, can_height_above_ra1_base-lid_grip_height])
    rotate([0, 0, - tab_size/2])
      rotate_extrude(angle=tab_size, convexity=4)
        translate([helmet_ir-lid_thickness, 0, 0])
          square([lid_thickness + ra_motor_skirt_thickness/2, lid_grip_height]);
}



// tear_drop_shaft_port(test_dims);
// translate([0, -70, 0])
//   tear_drop_shaft_port(test_dims, interior_only=true);
// translate([0, 70, 0])
//   tear_drop_shaft_port(test_dims, solid=true);

