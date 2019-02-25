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

module helmet_support_over_dec_end() {
  difference() {
    intersection() {
      union() {
        // Approx. the whole inside of the helmet, above the RA bearing.
        cylinder(r=helmet_ir-0.1, h=helmet_supports_height_above_ra_bearing);

        // Approx. the inside of the DEC port. Could use 
        *dec_head_port_interior();
        translate_to_dec_bearing_plane(z_towards_dec_head=false) {
          cylinder(h=dec2_len+ra1_radius, r=dec_head_port_or-0.1);
        }
      }
      // Cube is 1mm offset from X axis so that there is room for tightening
      // the gap between this support and the one on the other side of the
      // X axis.
      translate([-helmet_ir, 1, 0]) {
        cube([helmet_ir*2, helmet_supports_dec_axis_extent-1, helmet_supports_height_above_ra_bearing]);
      }
    }


    shared_helmet_support_cutouts(use_ra_to_dec=true);

    // Cut out the ra1_to_dec body (well, a cylinder that is standing in
    // for it).
*    difference() {
      translate([0, 0, -0.1]) {
        cylinder(h=ra1_base_to_dec_center, r=ra1_radius+0.1);
      }
    }

    // Cut a hole for the DEC head and DEC bearing cover. Needs to be big enough
    // to slid over both; have added a small amount, which may need adjusting
    // based on printing success.
  *  translate_to_dec_bearing_plane() {
      extra_r = 0.25;
      r = max(dec2_diam, dec_head_base_diam)/2 + extra_r;
      symmetric_z_cylinder(l=ra1_radius*3, r=r);
    }

    // Cut a cuboid for the DEC motor.
 *   translate_to_dec_bearing_plane(z_towards_dec_head=false) {
      w = dec_motor_core_bottom_w + 1;
      h = dec_center_to_dec_motor_top + 0.5;
      d = ra1_radius + dec2_len + 0.2;
      translate([-w/2+dec_motor_x_offset, -h, -0.1]) {
        cube([w, h, d]);
      }
    }

    // Cut out room for the RA clutch; I'm assuming it doesn't need to open
    // further than half way.
 *   translate([0, 0, -0.01]) {
      ra_clutch_volume(half=true);
    }

    // Don't get in the way of the polar scope's line of sight.
 *   cylinder(d=polar_port_cap_diam*1.25, h=can_height_above_ra1_base);

    // Now for something that should probably be handled by subtracting the
    // whole helmet: the gluing supports. There will be other things like these,
    // so should come up with a better way.
    // if (true) {
    //   mirrored([1, 0, 0]) can_gluing_shelf();
    // } else {
    //   basic_helmet();
    // }
  }
}



*intersection() {
  *basic_helmet();
  helmet_support_over_cw_end();

  *ra_and_dec();
}

module helmet_support_over_cw_end() {
  difference() {
    intersection() {
      union() {
        // Approx. the whole inside of the helmet, above the RA bearing.
        cylinder(r=helmet_ir-0.1, h=helmet_supports_height_above_ra_bearing);

      }
      // Cube is 1mm offset from X axis so that there is room for tightening
      // the gap between this support and the one on the other side of the
      // X axis.
      mirror([0, 1, 0])
      translate([-helmet_ir, 1, 0]) {
        cube([helmet_ir*2, helmet_supports_dec_axis_extent-1, helmet_supports_height_above_ra_bearing]);
      }
    }

    shared_helmet_support_cutouts(use_ra_to_dec=true);


    // Cut out the ra1_to_dec body (well, a cylinder that is standing in
    // for it).
*    difference() {
      translate([0, 0, -0.1]) {
        cylinder(h=ra1_base_to_dec_center, r=ra1_radius+0.1);
      }
    }

    // Cut a hole for the CW shaft cap, which this part needs to slide over.
    // Have added a small amount, which may need adjusting
    // based on printing success.
 *   translate_to_dec12_plane(z_towards_dec_head=false) {
      extra_r = 0.25;
      r = max(dec1_diam, cw_cap_diam)/2 + extra_r;
      cylinder(h=dec1_len + cw_cap_total_height + 3, r=r);
    }

    // Cut a cuboid for the DEC motor.
 *   translate_to_dec_bearing_plane(z_towards_dec_head=false) {
      w = dec_motor_core_bottom_w + 1;
      h = dec_center_to_dec_motor_top + 0.5;
      d = ra1_radius + dec2_len + 0.2;
      translate([-w/2+dec_motor_x_offset, -h, -0.1]) {
        cube([w, h, d]);
      }
    }

    // Cut out room for the RA clutch; I'm assuming it doesn't need to open
    // further than half way.
  *  translate([0, 0, -0.01]) {
      ra_clutch_volume(half=true);
    }

    // Don't get in the way of the polar scope's line of sight.
*    cylinder(d=polar_port_cap_diam*1.25, h=can_height_above_ra1_base);

    // Now for something that should probably be handled by subtracting the
    // whole helmet: the gluing supports. There will be other things like these,
    // so should come up with a better way.
    if (true) {
 *     mirrored([1, 0, 0]) can_gluing_shelf();
    } else {
  *    basic_helmet();
    }
  }
}




module shared_helmet_support_cutouts(use_ra_to_dec=false) {
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
    extra_r = 0.25;
    r = max(dec2_diam, dec_head_base_diam)/2 + extra_r;
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

  // Don't get in the way of the polar scope's line of sight.
  cylinder(d=polar_port_cap_diam*1.25, h=can_height_above_ra1_base);



  // Need room for the DEC motor cable to run from the motor to hear the CW shaft.
  cable_chase();
*  translate_to_dec_bearing_plane(z_towards_dec_head=false) {
    z_offset = dec_motor_h-5;
    cable_hole_diam = 20;
    h = dec2_len + ra1_radius + helmet_supports_dec_axis_extent-z_offset;
    translate([-31, -60, z_offset]) {
      rotate([0, 13, 0]) {


      cylinder(d=cable_hole_diam, h=h+1);

      cone_height1 = 20;
      translate([0, 0, h-cone_height1])
        cylinder(d1=cable_hole_diam, d2=cable_hole_diam*1.5, h=cone_height1+10);
      cone_height2 = 10;
      translate([0, 0, h-cone_height2])
        cylinder(d1=cable_hole_diam, d2=cable_hole_diam*2.5, h=cone_height2+10);
    }
    // translate()
  }
}


  // Now for something that should probably be handled by subtracting the
  // whole helmet: the gluing supports. There will be other things like these,
  // so should come up with a better way.
  if (true) {
    mirrored([1, 0, 0]) can_gluing_shelf();
  } else {
    basic_helmet();
  }
}



module cable_chase() {
  cable_hole_diam = 20;
  cable_hole_r = cable_hole_diam/2;
  z_offset = dec_motor_h;
  h_to_center = dec2_len + ra1_radius - z_offset;
  h = dec2_len + ra1_radius + helmet_supports_dec_axis_extent-z_offset;
  leg1_h = polar_port_diam/2 + h_to_center;
  flare_z = h_to_center+helmet_supports_dec_axis_extent-cable_hole_r+0.1;

  module flared_opening_profile() {
    difference() {
      square([cable_hole_diam, cable_hole_r]);
      translate([cable_hole_diam, 0, 0])
        circle(r=cable_hole_r);
    }
  }

  // Need room for the DEC motor cable to run from the motor to hear the CW shaft.
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
