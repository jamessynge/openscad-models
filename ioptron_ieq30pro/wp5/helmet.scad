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
use <bosses.scad>

assert($preview);  // This file isn't for generating STL files.

// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 5 : 1;  // Minimum size for a fragment.
$fa = $preview ? 8 : 1;  // Minimum angle for a fragment.

mount_latitude=90;
// ra_angle = 152 + $t * 360;  // For testing boss below CW port.
ra_angle = 30 + $t * 360;  // DEC clutch handle very near RA motor.
dec_angle = 180 + 58 + $t * 360; // DEC clutch handle "down" at closest to RA motor.

if (false) {
  rotate([0, 0, 180 * $t])
    ra_and_dec(dec_angle=dec_angle)
      animated_separated_helmet();
} else if (false) {
  ra_and_dec(dec_angle=dec_angle)
    basic_helmet(screw_side=false);
} else if (false) {
  animated_separated_helmet();
} else if (false) {
  difference() {
    basic_helmet();
    separated_helmet();
  }
} else {
    basic_helmet(screw_side=false, top=false);
    translate([0, 0, 20])
      basic_helmet(screw_side=false, bottom=false);
    *simple_lid();

}


module animated_separated_helmet() {
  max_distance = 100;
  distance = max(0, max_distance - $t * max_distance);
  separated_helmet(distance);
}


module separated_helmet(distance=0) {
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

  *translate([0, 0, 2*dz])
    simple_lid();

}

// Apparently applying render after intersection or difference can help if
// we're running into "Normalized Tree is growing past X elements" (for X
// equals some very large number). I haven't found it terribly effective,
// but worth keeping track of. Enable this by changing the false to true.
// http://forum.openscad.org/Normalized-tree-is-growing-past-elements-tc13509.html#a13561
module maybe_render() {
  if (false) {
    render() children();
  } else {
    children();
  }
}


module basic_helmet_nut_side_top() {
  maybe_render()
    basic_helmet(nut_side=true, screw_side=false, top=true, bottom=false);
}

module basic_helmet_nut_side_bottom() {
  maybe_render()
    basic_helmet(nut_side=true, screw_side=false, top=false, bottom=true);
}

module basic_helmet_screw_side_top() {
  maybe_render()
    basic_helmet(nut_side=false, screw_side=true, top=true, bottom=false);
}

module basic_helmet_screw_side_bottom() {
  maybe_render()
    basic_helmet(nut_side=false, screw_side=true, top=false, bottom=true);
}

module basic_helmet(nut_side=true, screw_side=true, top=true, bottom=true) {
  assert(top || bottom);

  module x_slicer() {
    if (nut_side != screw_side) {
      maybe_render() {
        cut_along_x(keep_above=nut_side) {
          children();
        }
      }
    } else {
      children();
    }
  }

  module z_slicer() {
    if (top != bottom) {
      maybe_render() {
        cut_along_z(z=ra1_base_to_dec_center, keep_above=top) {
          children();
        }
      }
    } else {
      children();
    }
  }


  module solid() {
    can_solid();
    dec_head_port();
    if (bottom) {
      cw_shaft_port_solid();
    }
  }

  module cutouts() {
    can_interior();
    dec_head_port_interior();
    if (bottom) {
      cw_shaft_port_interior();
      mirrored([0, 1, 0]) {
        if (nut_side) {
          bosses_at_bottom_rim(solid=true, nut_side=true);
        }
        if (screw_side) {
          bosses_at_bottom_rim(solid=true, nut_side=false);
        }
      }
    } else {
      // !bottom.
      cw_shaft_port_solid();
    }
    if (top) {
      mirrored([0, 1, 0]) {
        if (nut_side) {
          bosses_below_lid(solid=true, nut_side=true);
        }
        if (screw_side) {
          bosses_below_lid(solid=true, nut_side=false);
        }
      }
    }
  }

  module basic_body() {
    maybe_render()
    difference() {
      solid();
      cutouts();
    }
  }

  module z_cut_body() {
    z_slicer() basic_body();
  }

  module x_and_z_cut_body() {
    x_slicer() z_cut_body();
  }

  x_and_z_cut_body();

  if (nut_side) {
    can_gluing_shelf_lips(top=top, bottom=bottom);
  }
  if (screw_side) {
    mirror([1, 0, 0])
      can_gluing_shelf_lips(top=top, bottom=bottom);
  }

  if (top) {
    if (nut_side)
      lid_alignment_tab();

    // Omitting for now because the support height and the can interior height
    // are not so well coordinated, and it appears that the lid will hit the
    // shelf. Further, I've modified the gluing shelf so that it goes both
    // up and down, which decreases the need for the resting shelf.
    // if (nut_side) can_resting_shelf();
    // if (screw_side) mirror([1, 0, 0]) can_resting_shelf();

    intersection() {
      mirrored([0, 1, 0]) {
        if (nut_side) {
          bosses_below_lid(solid=false, nut_side=true);
        }
        if (screw_side) {
          bosses_below_lid(solid=false, nut_side=false);
        }
      }
      solid();
    }
  }

  if (bottom) {
    // if (nut_side) can_gluing_shelf();
    // if (screw_side) mirror([1, 0, 0]) can_gluing_shelf();

    x_slicer() {
      difference() {
        cw_shaft_port_solid();
        cutouts();
      }
    }

    mirrored([0, 1, 0]) {
      if (nut_side) {
        bosses_at_bottom_rim(solid=false, nut_side=true);
      }
      if (screw_side) {
        bosses_at_bottom_rim(solid=false, nut_side=false);
      }
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

