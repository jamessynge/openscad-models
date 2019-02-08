
include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

include <wp2_dimensions.scad>


use <../../utils/cut.scad>
include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/strap.scad>

// Global resolution
$fs = $preview ? 6 : 1;
$fa = $preview ? 6 : 1;



module alignment_cone(size=10, fn=undef) {
  linear_extrude(height=size, convexity=3, scale=0)
    circle(d=size, $fn=fn);
}

if ($preview) translate([0, -200, 0])alignment_cones(fn=4);
module alignment_cones(size=10, fn=undef) {
  x_offset = (dec1_radius + ra1_radius) / 2;
  z_offset = (ra1_base_to_dec + ra1_base_to_dec_center) / 2;
  translate([0, 0, z_offset])
    rotate([-90, 0, 0]) {
      translate([x_offset, 0, 0]) alignment_cone(size=size, fn=fn);
      translate([-x_offset, 0, 0]) alignment_cone(size=size, fn=fn);
    }
}

// Relative to ra_and_dec coords.
module world_below_dec_axis() {
  cs = 1000;
  half_cs = cs/2;
  translate([0, 0, ra1_base_to_dec_center - half_cs])
    cube(size=cs, center=true);
}

module extra_long_dec_body_cylinder(extra_radius=0) {
  translate([0, 0, ra1_base_to_dec_center])
    rotate([90, 0, 0])
      symmetric_z_cylinder(r=dec1_radius+extra_radius, l=2*dec1_len);
}

// Volume needed for the RA clutch, i.e. to be avoided by WP.
// Relative to ra_and_dec coords.
module ra_clutch_volume(half=true) {
  e = 50;
  translate([-ra1_radius, 0, 0])
  rotate([0, -90, 0])
    rotate([0, 0, -90])
        linear_extrude(height=e)
          ra_clutch_volume_profile(half=half);
}
translate([0, 200, 0]) ra_clutch_volume();

module ra_clutch_volume_profile(half=true) {
  r = clutch_handle_length+5;
  intersection() {
    union() {
      translate([0, clutch_screw_axis_height, 0])
        intersection() {
          circle(r=r);
          translate([-r, 0, 0])
            square(size=2*r);
        }
      translate([-r, 0, 0])
        square([2*r, clutch_screw_axis_height]);
    }
    if (half) {
      s = r + clutch_screw_axis_height + clutch_flange_width;
      translate([-clutch_flange_width/2, 0, 0])
        square(size=s);
    }
  }
}
translate([200, 200, 0]) ra_clutch_volume_profile();


// For intersection with the dec1_hat to add a draft angle to allow reliable
// connection with the cw_chin_strap_helmet_support, and to cut out space
// for the dec1_hat from the cw_chin_strap_helmet_support.
module dec1_hat_draft_angle_body(height=200, raise_by=dec1_hat_ra_bearing_gap) {
  translate([0, 0, raise_by])
  intersection() {
    union() {
      inset = 5;
      x1 = -ra1_radius;
      x2 = x1 + inset;
      x4 = ra1_radius;
      x3 = x4 - inset;
      // Deliberately going too far beyond the ra_and_dec body.
      y1 = -ra1_diam;
      y2 = 0;
      y3 = ra1_radius;

      linear_extrude(height=height, convexity=3)
        polygon([
          [x2, y1],
          [x3, y1],
          [x4, y2],
          [x4, y3],
          [x1, y3],
          [x1, y2],
          ]);
    }
    union() {
      cs = 3*ra1_diam; // Very large relative to the dec1_hat.
      translate([0, 0, cs/2])
        rotate([-2, 0, 0])
          cube(size=cs, center=true);
    }
  }
}
translate([-200, -200, 0]) dec1_hat_draft_angle_body();
