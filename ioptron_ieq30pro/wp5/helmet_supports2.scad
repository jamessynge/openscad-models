// Experiment with making the support out of multiple parts, to be screwed
// together.

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
use <can.scad>
use <dec_head_bearing_collar.scad>
use <dec_head_port.scad>
use <helmet.scad>
use <helpers.scad>
use <volumes.scad>

include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/paired_bosses.scad>
use <../../utils/axis_arrows.scad>


// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.

mount_latitude=90;
// ra_angle = 152 + $t * 360;  // For testing boss below CW port.
ra_angle = 30 + $t * 360;  // DEC clutch handle very near RA motor.
dec_angle = 180 + 58 + 00000 * $t * 360; // DEC clutch handle "down" at closest to RA motor.

distance = 100; //200 * (cos(360 * $t) / 2 + 1/2);

// Assume that a part will be this much larger in OD, and this much smaller in ID.
// This means that we should assume the helmet_ir is effectively this much
// smaller, and the support should be double that smaller.
extrusion_radial_spread = 0.3;

ra_and_dec(dec_angle=dec_angle, include_dec_head_clamp_screws=false) {
  union() {
    *translate([0, distance, 0])
      helmet_support_over_dec_end();
    *translate([0, -distance, 0])
      helmet_support_over_cw_end();
    *basic_helmet();
  }
  union() {}
  union() {
    *dec_head_bearing_collar();
  }
}

*difference() {
  can_solid();
  can_interior();
}
*difference() {
  union() {
    helmet_support_over_dec_end();
    helmet_support_over_cw_end();
  }
  basic_helmet();
  *ra_and_dec();
}
*intersection() {
  *basic_helmet();
  helmet_support_over_cw_end();
  *ra_and_dec();
}

thickness = helmet_ir;

module cw_collar() {
intersection() {
    collar_ir = max(cw_cap_diam/2, dec1_radius) + extrusion_radial_spread;
    collar_or = collar_ir + thickness;
    translate_to_dec12_plane(z_towards_dec_head=false) {
      translate([0, 0, ra1_diam]) {
        linear_extrude(height=dec_len_beyond_ra, convexity=10) {
          annulus(r1=collar_ir, r2=collar_or);
        }
      }
    }
    helmet_supports_outer_limits();
  }
}

cw_collar();


module dec_gear_cover_collar() {
  collar_ir = max(dec2_diam, dec_head_base_diam)/2 + extrusion_radial_spread;
  collar_or = collar_ir + thickness;
  translate_to_dec12_plane(z_towards_dec_head=true) {
    translate([0, 0, 0]) {
      linear_extrude(height=dec2_len-1, convexity=10) {
        annulus(r1=collar_ir, r2=collar_or);
      }
    }
  }

  // body_r = max(dec2_diam, dec_head_base_diam)/2;  // 97.66/2 at writing.
  // extra_r = 0.25;
  // r = body_r + extra_r;  // diameter = 98.16.
  // h = dec_bearing_gap + dec2_len + ra1_radius;
  // cylinder(h=h, r=r);


}

difference() {
  intersection() {
    dec_gear_cover_collar();
    helmet_supports_outer_limits();
  }
  dec_motor_avoidance();
}


module ra_to_dec_collar() {
  collar_ir = ra1_radius + extrusion_radial_spread;
  collar_or = collar_ir + thickness;
  linear_extrude(height=ra1_base_to_dec, convexity=10) {
    annulus(r1=collar_ir, r2=collar_or);
  }
}

 *intersection() {
    union() {
      *cw_collar();
      dec_gear_cover_collar();
      *ra_to_dec_collar();
    }
    *helmet_supports_outer_limits();
  }

*difference() {
minimal_helmet_positive();
*shared_helmet_support_cutouts();

}