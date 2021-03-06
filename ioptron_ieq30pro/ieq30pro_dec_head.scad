// Defines the moving portion of the DEC axis, which has the dovetail
// saddle for holding a telescope atop the mount.
// Author: James Synge

// dec_head accepts up to two children:
//
// 1) The first is centered on the plane of the base of the dec_head,
//    with z=0 and the clutch is on the x-axis at y=0.
//
// 2) The second is like the first, but with the z=0 plane raised up 
//    to the plane of the dovetail saddle. I.e. the x and y axes are
//    in the same orientation as above, so the y-axis is aligned with
//    the long direction of a dovetail.

// Units: mm

include <ieq30pro_dimensions.scad>
use <ieq30pro_clutch.scad>
use <four_star_knob.scad>
use <../utils/axis_arrows.scad>

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.5;
// Don't generate larger angles than this many degrees.
$fa = 3;

show_axis_arrows = true;

dec_head(show_axis_arrows=show_axis_arrows);

module dec_head(show_axis_arrows=false, dec_clutch_angle=5, include_clamp_screws=true) {
  // echo("dec_head has", $children, "children");
  base_r = dec_head_base_diam / 2;
  inner_r = dec_head_diam1 / 2;
  color(cast_iron_color) {
    difference() {
      union() {
        cylinder(h=dec_head_base_height, r=base_r);
      
        translate([0,0,dec_head_base_height])
          linear_extrude(
              height=dec_head_height,
              scale=dec_head_scale,
              convexity=10)
            dec_head_extrusion_profile();
      };
      dec_saddle_inverse();
      dec_slot_inverse();
      dec_head_clamp_screw_holes();
    };
  };

  translate([inner_r-2,0,0])
    rotate([90,0,90])
      clutch(handle_angle=dec_clutch_angle);

  if (include_clamp_screws) dec_head_clamp_screws();

  if (show_axis_arrows) {
    color("red") {
      axis_arrows(total_length=dec_head_base_radius * 1.5);
    };
  };
  if ($children > 0) {
    //echo("dec_head rendering child 0");
    children(0);
  }
  raise_by = dec_head_base_height + dec_head_height - dec_saddle_depth + 0.01;
  translate([0, 0, raise_by]) {
    if (show_axis_arrows) {
      color("green") {
        axis_arrows(total_length=dec_head_diam2 * 0.75);
      };
    };
    if ($children > 1) {
      // echo("dec_head rendering child 1");
      children(1);
    }
  }
}

module dec_saddle_inverse() {
  raise_by = dec_head_base_height + dec_head_height - dec_saddle_depth + 0.01;
  shift = dec_saddle_width2/2 + 1.3;  // Manual adjustment to make it look right.

  translate([-shift,0,raise_by])
    rotate([90, 0, 0])
      translate([0,0,-dec_head_base_diam])
        linear_extrude(height=dec_head_base_diam*2) // Overkill on the length
          // The outline of the saddle into which a dovetail may be placed.
          polygon([
            [0,0],
            [dec_saddle_width2, 0],
            [dec_saddle_width1, dec_saddle_depth],
            [0, dec_saddle_depth]
            ]);
}

module dec_slot_inverse() {
  r = dec_slot_corner_radius;
  hw = dec_slot_width_bottom / 2 - r;
  hl = dec_slot_len_bottom / 2 - r;
  raise_by = dec_head_base_height + dec_head_height
      - dec_saddle_depth + 0.01;
  sx = dec_slot_width_top / dec_slot_width_bottom;
  sy = dec_slot_len_top / dec_slot_len_bottom;

  translate([0,0,raise_by])
  linear_extrude(height=dec_saddle_depth, scale=[sx, sy])
    hull() {
      translate([hw,hl]) circle(r=r);
      translate([hw,-hl]) circle(r=r);
      translate([-hw,-hl]) circle(r=r);
      translate([-hw,hl]) circle(r=r);
    };
}

module dec_head_extrusion_profile() {
  intersection() {
    union() {
      circle(r=dec_head_diam1/2);

      h = dec_head_buttress_height_top / dec_head_scale;
      w = dec_head_buttress_half_width_top / dec_head_scale;

      translate([-w, -h/2])
        square(size=[w, h]);
    };
    circle(r=dec_head_base_diam/2);
  };
}



module dec_head_clamp_screw() {
  raise_by = dec_head_base_height + dec_head_height
      - dec_head_clamp_screw_depth;
  x = 2 - dovetail_width/2 - fsk_screw_len;
  y = dec_head_clamp_screw_spacing / 2;

  translate([x,y,raise_by])
    rotate([0, 90, 0]) four_star_knob();
}

module dec_head_clamp_screws() {
  dec_head_clamp_screw();
  mirror([0, 1, 0]) dec_head_clamp_screw();
}

module dec_head_clamp_screw_holes() {
  raise_by = dec_head_base_height + dec_head_height
      - dec_head_clamp_screw_depth;
  y = dec_head_clamp_screw_spacing / 2;
  translate([0,y,raise_by])
    rotate([0, -90, 0])
      cylinder(h=dec_head_base_diam/2,
               r=dec_head_clamp_screw_diam/2);

  translate([0,-y,raise_by])
    rotate([0, -90, 0])
      cylinder(h=dec_head_base_diam/2,
               r=dec_head_clamp_screw_diam/2);
}
