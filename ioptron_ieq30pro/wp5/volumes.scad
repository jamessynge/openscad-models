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
use <helpers.scad>

include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/paired_bosses.scad>

// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.


module helmet_supports_outer_limits() {
  // Approx. the whole inside of the helmet above the RA bearing, but allowing
  // 1mm for the RA bearing.
  ra_bearing_allowance = 1;
  dec_bearing_allowance = 1;

  intersection() {
    union() {
      // Approx. the whole inside of the helmet above the RA bearing.
      translate([0, 0, ra_bearing_allowance])
      cylinder(r=helmet_ir-extrusion_radial_spread, h=helmet_supports_height_above_ra_bearing-ra_bearing_allowance);

      // Approx. the inside of the DEC port.
      translate_to_dec_bearing_plane(z_towards_dec_head=false) {
        cylinder(h=dec2_len+ra1_radius, r=dec_head_port_or-extrusion_radial_spread);
      }
    }
    x = 2 * helmet_ir - 0 * extrusion_radial_spread;
    y0 = -(ra1_radius + dec_len_beyond_ra - cw_cap_bevel_height);
    y1 = ra1_radius + dec2_len - dec_bearing_allowance;
    y = y1 - y0;
    d = helmet_ir + extrusion_radial_spread;
    h = helmet_supports_height_above_ra_bearing - ra_bearing_allowance;
    translate([-d, y0, ra_bearing_allowance]) {
      cube([x, y, h]);
    }
  }
}

// Volume needed for the RA clutch, i.e. to be avoided by WP.
// Relative to ra_and_dec coords.
module ra_clutch_volume(half=true) {
  e = 50;

  hull() {
    translate([-ra1_radius, 0, 0]) {
      rotate([0, -90, 0]) {
        rotate([0, 0, -90]) {
          linear_extrude(height=e) {
            ra_clutch_volume_profile(half=half);
          }
        }
      }
    }
    translate([-ra1_radius/2, 0, 2])
      sphere(r=1);
  }
}

//translate([0, 200, 0]) ra_clutch_volume(half=false);

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
      s = r + clutch_screw_axis_height + ra_clutch_flange_width;
      translate([-ra_clutch_flange_width/2 - 2, 0, 0])
        square(size=s);
    }
  }
}
*translate([200, 200, 0]) ra_clutch_volume_profile();

module dec_motor_avoidance() {
  // A cuboid standing in for the DEC motor.
  translate_to_dec_bearing_plane(z_towards_dec_head=false) {
    w = dec_motor_core_bottom_w + 2;
    h = dec_center_to_dec_motor_top + 1;
    d = ra1_radius + dec2_len + 0.02;
    translate([-w/2+dec_motor_x_offset, -h, -0.01]) {
      cube([w, h, d]);
    }
  }
}

module ra_to_dec_avoidance(drop=1, radial_spread=extrusion_radial_spread) {
  fillet_r = ra_to_dec_fillet_radius;
  h0 = ra1_base_to_dec + fillet_r;
  module fillet_profile() {
    translate([ra1_radius, h0, 0]) {
      circle(r=fillet_r-radial_spread);
    }
  }
  module cross_section_profile() {
    r = ra1_radius + radial_spread;
    difference() {
      translate([-r, -drop, 0]) square([r*2, h0+drop]);
      fillet_profile();
      mirror([1, 0, 0]) fillet_profile();
    }
  }

  intersection() {
    half1 = ra1_radius + 1;
    h1 = half1 * 2;
    rotate([90, 0, 0])
      translate([0, 0, -half1])
        linear_extrude(height=h1, convexity=4)
          cross_section_profile();
    translate([0, 0, -drop])
      cylinder(r=ra1_radius+radial_spread, h=h0+drop);
  }
}

module dec_avoidance(radial_spread=extrusion_radial_spread, extend_dec2=true) {
  // Dec2 body (worm gear cover), against which supports can press, but not
  // too close to the bearing.
  // For the case of sliding a body over the DEC head and Dec2 body, need
  // to continue the dec2 body all the way to the RA axis.
  dec2_cyl_h = dec2_len + (extend_dec2 ? ra1_radius : 0);
  translate_to_dec_bearing_plane(z_towards_dec_head=false) {
    cylinder(r=dec2_radius+radial_spread, h=dec2_cyl_h);
  }

  translate_to_dec_bearing_plane() {
    // A chamfer at the DEC bearing plane, which helps with printing from
    // the DEC bearing plane towards the RA axis.
    d = 3;
    h = 20+d;
    r1 = dec2_radius+radial_spread;
    r2 = r1 + h;
    translate([0, 0, -d])
      cylinder(r1=r1, r2=r2, h=h);
  }

  translate_to_dec12_plane(z_towards_dec_head=false) {
    // Dec1 body, against which supports can press.
    translate([0, 0, -1])
      cylinder(r=dec1_radius+radial_spread, h=ra1_diam+dec_len_beyond_ra+1);

    // Counterweight shaft, which must not be touched.
    cylinder(d=cw_shaft_diam+radial_spread*5, h=3*ra1_diam);
  }

  dec_motor_avoidance();
}


module ra_and_dec_avoidance() {
  ra_to_dec_avoidance();
  dec_avoidance();
}

ra_and_dec_avoidance();