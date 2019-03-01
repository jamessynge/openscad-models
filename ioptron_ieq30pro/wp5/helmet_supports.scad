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
use <can.scad>
use <dec_head_bearing_collar.scad>
use <dec_head_port.scad>
use <helmet.scad>
use <helpers.scad>

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
extrusion_radial_spread = 0.2;

ra_and_dec(dec_angle=dec_angle, include_dec_head_clamp_screws=false) {
  union() {
    translate([0, distance, 0])
      helmet_support_over_dec_end();
    translate([0, -distance, 0])
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

module helmet_support_over_dec_end() {
  difference() {
    intersection() {
      helmet_supports_outer_limits();
      // Cube is 1mm offset from X axis so that there is room for tightening
      // the gap between this support and the one on the other side of the
      // X axis.
      translate([-helmet_ir, 1, 0]) {
        cube([helmet_ir*2, helmet_supports_dec_axis_extent-1, helmet_supports_height_above_ra_bearing]);
      }
    }

    shared_helmet_support_cutouts(use_ra_to_dec=true);
  }
}

module helmet_support_over_cw_end() {
  difference() {
    intersection() {
      helmet_supports_outer_limits();
      // Cube is 1mm offset from X axis so that there is room for tightening
      // the gap between this support and the one on the other side of the
      // X axis.
      mirror([0, 1, 0])
      translate([-helmet_ir, 1, 0]) {
        cube([helmet_ir*2, helmet_supports_dec_axis_extent-1, helmet_supports_height_above_ra_bearing]);
      }
    }

    shared_helmet_support_cutouts(use_ra_to_dec=true);
  }
}

module helmet_supports_outer_limits() {
  // Approx. the whole inside of the helmet above the RA bearing, but allowing
  // 1mm for the RA bearing.
  ra_bearing_allowance = 1;
  dec_bearing_allowance = 1;

  intersection() {
    union() {
      // Approx. the whole inside of the helmet above the RA bearing, but allowing
      // 1mm for the RA bearing.
      cylinder(r=helmet_ir-extrusion_radial_spread, h=helmet_supports_height_above_ra_bearing);

      // Approx. the inside of the DEC port.
      translate_to_dec_bearing_plane(z_towards_dec_head=false) {
        cylinder(h=dec2_len+ra1_radius, r=dec_head_port_or-extrusion_radial_spread);
      }
    }
    x = 2 * helmet_ir - 2 * extrusion_radial_spread;
    y = helmet_ir + ra1_radius + dec2_len - dec_bearing_allowance - extrusion_radial_spread;
    d = helmet_ir + extrusion_radial_spread;
    h = helmet_supports_height_above_ra_bearing - ra_bearing_allowance;
    translate([-d, -d, 0]) {
      cube([x, y, h]);
    }
  }
}

module shared_helmet_support_cutouts(use_ra_to_dec=false) {
  // Cut below some limit, so that we don't risk hitting the RA motor.
  translate([0, 0, 1]) {
    mirror([0, 0, 1]) {
      cylinder(h=helmet_or, r=helmet_or*2);
    }
  }

  // And we can't extend above the space allotted within the helmet.
  translate([0, 0, helmet_supports_height_above_ra_bearing])
    cylinder(h=helmet_or, r=helmet_or*2);

  // Cut out the ra1_to_dec body.
  if (use_ra_to_dec) {
    // Raise it up a bit so that there is room for a little slop in my
    // measurements (sadly needed).
    translate([0, 0, 0.5])
      ra_to_dec(include_clutch=false, include_polar_port=false);
  }
  // And an approximation also.
  translate([0, 0, -1]) {
    h = 1.1 + (use_ra_to_dec ? ra1_base_to_dec : ra1_base_to_dec_center);
    cylinder(h=h, r=ra1_radius+0.1);
  }

  // Cut a cuboid for the DEC motor.
  translate_to_dec_bearing_plane(z_towards_dec_head=false) {
    w = dec_motor_core_bottom_w + 1;
    h = dec_center_to_dec_motor_top + 0.5;
    d = ra1_radius + dec2_len + 0.02;
    translate([-w/2+dec_motor_x_offset, -h, -0.01]) {
      cube([w, h, d]);
    }
  }

  // Cut a hole for the DEC head and DEC bearing cover. Needs to be big enough
  // so the support can slide over both; have added a small amount, which may
  // need adjusting based on printing success.
  translate_to_dec_head_base(z_towards_dec_head=false) {
    body_r = max(dec2_diam, dec_head_base_diam)/2;  // 97.66/2 at writing.
    extra_r = 0.25;
    r = body_r + extra_r;  // diameter = 98.16.
    h = dec_bearing_gap + dec2_len + ra1_radius;
    cylinder(h=h, r=r);
  }

  // Cut a hole for the DEC body and CW shaft cap.
  // Have added a small amount, which may need adjusting
  // based on printing success.
  translate_to_dec12_plane(z_towards_dec_head=false) {
    extra_r = 0.25;
    r = max(dec1_diam, cw_cap_diam)/2 + extra_r;
    cylinder(h=dec1_len + cw_cap_total_height + 3, r=r);
  }

  // Cut out room for the RA clutch; I'm assuming it doesn't need to open
  // further than half way.
  translate([0, 0, -0.01]) {
    ra_clutch_volume(half=true);
  }

  // Don't get in the way of the polar scope's line of sight. We don't need to
  // have the assembly be big up top, so we can make the hole the size of the
  // ra_to_dec circle.
  //cylinder(d=ra1_diam, h=can_height_above_ra1_base);

  translate([0, 0, ra1_base_to_dec_center]) {
    top_diam = (helmet_ir*2 + ra1_diam) / 2;
    h_total = helmet_supports_height_above_ra_bearing - ra1_base_to_dec_center + 0.1;
    h1 = 15;
    scale([1, 0.9, 1]) {
      cylinder(d1=0, d2=top_diam, h=h1);
      translate([0, 0, h1])
        cylinder(d=top_diam, h=h_total-h1);
    }
  }

  // Need room for the DEC motor cable to run from the motor to hear the CW shaft.
  cable_chase();

  // Now for something that should probably be handled by subtracting the
  // whole helmet: the gluing supports. There will be other things like these,
  // so should come up with a better way.
  if (true) {
    mirrored([1, 0, 0]) can_gluing_shelf();
  } else {
    basic_helmet();
  }


  mirrored([0, 1, 0])
  translate([-70, 0, ra1_base_to_dec_center+20])
    screw_hole();



  mirrored([0, 1, 0])
  translate([65, 0, 15])
    screw_hole();


  mirrored([1, 0, 0])
  mirrored([0, 1, 0])
  translate([75, 0, helmet_supports_height_above_ra_bearing-15])
    screw_hole();
}

// Experiment with building up the parts we might need, then cutting away,
// rather than assuming a large solid to be cut.
module minimal_helmet_positive() {
  //thickness = ra_motor_skirt_thickness;
  thickness = helmet_ir;
  module cw_collar() {
    collar_ir = max(cw_cap_diam/2, dec1_radius) + extrusion_radial_spread;
    collar_or = collar_ir + thickness;
    translate_to_dec12_plane(z_towards_dec_head=false) {
      translate([0, 0, ra1_diam]) {
        linear_extrude(height=dec_len_beyond_ra, convexity=10) {
          annulus(r1=collar_ir, r2=collar_or);
        }
      }
    }
  }
  module cw_collar2() {
    collar_ir = max(cw_cap_diam/2, dec1_radius) + extrusion_radial_spread;
    collar_or = collar_ir + thickness;
    translate_to_dec12_plane(z_towards_dec_head=false) {
      translate([0, 0, ra1_diam]) {
        linear_extrude(height=dec_len_beyond_ra, convexity=10) {
          annulus(r1=collar_ir, r2=collar_or);
        }
      }
    }
  }
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
  module ra_to_dec_collar() {
    collar_ir = ra1_radius + extrusion_radial_spread;
    collar_or = collar_ir + thickness;
    linear_extrude(height=ra1_base_to_dec, convexity=10) {
      annulus(r1=collar_ir, r2=collar_or);
    }
  }

  intersection() {
    union() {
      cw_collar();
      dec_gear_cover_collar();
      ra_to_dec_collar();
    }
    helmet_supports_outer_limits();
  }
}

*difference() {
minimal_helmet_positive();
shared_helmet_support_cutouts();

}

// Need room for the DEC motor cable to run from the motor to near the CW shaft.
// This provides a somewhat curving path with a flared end above the CW shaft,
// flared so that the cable doesn't get scraped by a sharp edge.
module cable_chase() {
  cable_hole_diam = 20;
  cable_hole_r = cable_hole_diam/2;
  z_offset = dec_motor_h;
  h_to_center = dec2_len + ra1_radius - z_offset;
  h = dec2_len + ra1_radius + helmet_supports_dec_axis_extent-z_offset;
  leg1_h = polar_port_diam/2 + h_to_center;
  flare_z = h_to_center+helmet_supports_dec_axis_extent-cable_hole_r+0.1;

  module flared_opening_profile() {
    polygon([
      [0, 0],
      [cable_hole_r, 0],
      [cable_hole_diam, cable_hole_r],
      [0, cable_hole_r],
      ]);

    // Can't print this beautiful flared opening. Sigh.
    *difference() {
      square([cable_hole_diam, cable_hole_r]);
      translate([cable_hole_diam, 0, 0])
        circle(r=cable_hole_r);
    }
  }

  translate_to_dec_bearing_plane(z_towards_dec_head=false) {
    translate([0, -60, z_offset]) {
      translate([-31, 0, 0]) {
        translate([0, 0, -10])
          cylinder(d=cable_hole_diam, h=leg1_h+10);
      }

      translate([0, 0, flare_z])
        rotate_extrude(convexity=4)
           flared_opening_profile();

      hull() {
        translate([-31, 0, leg1_h]) {
          sphere(r=cable_hole_r);
        }
        translate([0, 0, flare_z]) {
          sphere(r=cable_hole_r);
        }
      }
    }
  }
}
  
*cable_chase();


// Volume needed for the RA clutch, i.e. to be avoided by WP.
// Relative to ra_and_dec coords.
module ra_clutch_volume(half=true) {
  e = 50;
  translate([-ra1_radius+5, 0, 0])
  rotate([0, -90, 0])
    rotate([0, 0, -90])
        linear_extrude(height=e)
          ra_clutch_volume_profile(half=half);
}
*translate([0, 200, 0]) ra_clutch_volume();

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

// Screw hole axis is parallel to the Y axis, and ends at the X axis.
// Hole is very long, but spreads out at a specified distance from the X
// axis in the pyramid shape, then continues as a square profile. This supports
// inserting a square profiled object, with a pyramid top, into it (e.g.
// a nut slot or a washer/screw head "platform").

module screw_hole(hole_diam=m4_hole_diam, pyramid1_start=15, square1_sides=m4_washer_diam+1, pyramid2_start=25, square2_sides=m4_washer_diam*1.5) {
  rotate([-90, 0, 0]) {
    cylinder(d=hole_diam, h=helmet_or, $fs=hole_diam/10);
    translate([0, 0, pyramid1_start+square1_sides]) {
      mirror([0, 0, 1])
        linear_extrude(height=square1_sides/2, scale=0)
          square(square1_sides, center=true);
      linear_extrude(height=helmet_or)
        square(square1_sides, center=true);
    }
    if (pyramid2_start != undef && pyramid2_start >= pyramid1_start) {
      translate([0, 0, pyramid2_start+square2_sides]) {
        mirror([0, 0, 1])
          linear_extrude(height=square2_sides/2, scale=0)
            square(square2_sides, center=true);
        linear_extrude(height=helmet_or)
          square(square2_sides, center=true);
      }
    }
  }
}


module screw_head_support(hole_diam=m4_hole_diam, square_sides=m4_washer_diam+0.5, height=5) {
  difference() {
    union() {
      linear_extrude(height=height) {
        square(square_sides, center=true);
      }
      translate([0, 0, height]) {
        linear_extrude(height=square_sides/2, scale=0) {
          square(square_sides, center=true);
        }
      }
    }
    translate([0, 0, -1])
      cylinder(d=hole_diam, h=helmet_or, $fs=hole_diam/10);
  }
}

*translate([320, 0, 0])
  screw_head_support();

module nut_holder(hole_diam=m4_hole_diam, square_sides=m4_washer_diam+0.5, height=m4_nut_height*2, nut_flats_diam=m4_nut_diam1, nut_height=m4_nut_height, nut_inset_height=m4_nut_height) {
  nut_hole_scale_factor = 1.02;
  nut_circle_diam = hex_short_to_long_diag(nut_flats_diam) * nut_hole_scale_factor;

  difference() {
    linear_extrude(height=height) {
      square(square_sides, center=true);
    }
    translate([0, 0, -1])
      cylinder(d=hole_diam, h=helmet_or, $fs=hole_diam/10);
    translate([0, 0, height-nut_inset_height*0.95])
      cylinder(d=nut_circle_diam, h=nut_height, $fn=6);

  }
}

*translate([340, 0, 0])
  nut_holder();

module dovetail_insert(bar_length=30, bar_width=10, head_length=10, angle=45, fillet_radius=2, thickness=5) {
  module quarter_profile() {
    p0 = [0, 0];
    p1 = [bar_width/2, 0];
    p2 = [p1.x, bar_length/2];
    p3 = [p2.x + head_length * tan(angle), p2.y + head_length];
    p4 = [0, p3.y];
    polygon([p0, p1, p2, p3, p4]);
  }
  module half_profile() {
    quarter_profile();
    mirror([1, 0, 0])
      quarter_profile();
  }
  module full_profile() {
    half_profile();
    mirror([0, 1, 0]) {
      half_profile();
    }
  }
  module rounded_profile() {
    if (fillet_radius > 0) {
      offset(r=-fillet_radius) {
        offset(r=2*fillet_radius) {
          offset(delta=-fillet_radius) {
            full_profile();
          }
        }
      }
    } else {
      full_profile();
    }
  }

  linear_extrude(height=thickness, convexity=4)
    rounded_profile();
}

translate([95, 0, 0]) {
  $fs = 0.5;
  scale(1)
    dovetail_insert();
}
