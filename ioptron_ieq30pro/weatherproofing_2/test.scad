// Test of building interior of helmet using union(), hull(), etc.

// Author: James Synge

include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

include <wp2_dimensions.scad>
use <../weatherproofing_1/dec_head_bearing_cover.scad>
use <ra_motor_hat.scad>
use <dec1_hat.scad>
use <basic_helmet.scad>
use <wp_utils.scad>

use <../../utils/cut.scad>
include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/strap.scad>

local_helmet_avoidance_ir = dflt_helmet_ir; // ra_motor_collar_radius;

helmet_walls = 10;

// Global resolution
$fs = $preview ? 10 : 1;
$fa = $preview ? 10 : 1;

if (!$preview) {
  helmet2();
} else {
  ioptron_mount(ra_angle=90) {
    union() {*ra_motor_hat();};
    union() {
      // Intersection for showing how thick things are.
      #intersection() {
        helmet2();
        s = 400;
        translate([s/2, 0, 0]) cube(size=s, center=true);
      }
      translate([400, 0, 0]) helmet2_interior();
    };
  }
}

module helmet2() {
  difference() {
    helmet2_simple_solid();
    helmet2_interior();

    union() {
      // Cut below ra_bcbp_ex.
      s = local_helmet_avoidance_ir * 3;
      translate([0, 0, -s/2 - ra_bcbp_ex])
        cube(size=s, center=true);


      translate_to_dec_bearing_plane() {
        mirror([0, 0, 1]) {
          // Can't be too thick between the DEC clutch and the DEC saddle
          // screws; there is only about 1cm of space, so need to trim here.
          z = hoop_disc_z;
          translate([0, 0, s/2 + z]) cube(size=s, center=true);

          // Cut a hole for the DEC head.
          my_cylinder(r=dec2_radius, h=dec_head_total_height);
        }
      }

      // Cut the CW shaft port to a reasonable length.
      *translate_to_dec12_plane() {
        mirror([0, 0, 1]) {
          s = 150;
          translate([-s/2, -s/2, dec1_len+cw_cap_height + 40]) {
            #cube(size=s, center=false);
          }
        }
      }
    }
  }
}

*translate([200, 200, 200]) minkowski_sphere();

module minkowski_sphere() {
  sphere(r=helmet_walls, $fn=$fn);
}

module helmet2_simple_solid() {
  minkowski() {
    hull() helmet2_interior_core();
    minkowski_sphere();
  }

  cw_shaft_port_exterior();
}

module helmet2_interior() {
  hull() helmet2_interior_core();

  // We the extend below_ra_bearing part a bit further so that we
  // can easily cut it off later without running into math problems.
  below_ra_bearing(h_multiplier=2);

  cw_shaft_port_interior();
}

module helmet2_interior_core() {
  // The volume including the RA motor and the RA motor rain plate.
  below_ra_bearing();

  // Mostly cover the ra_and_dec body, with a little poking out near the
  // CW shaft and the motor.
  dome_above_ra_bearing();

  // The volume swept out by the DEC clutch.
  swept_dec_clutch();

  // This cone adds a lot of time to the minkowski calculation.
  // // A little cone so that we get a smooth transition to the CW shaft.
  // cw_shaft_port_transition(h=20);
}

module below_ra_bearing(h_multiplier=1) {
  // We support extend below the RA bearing plane further than necessary so
  // that we can easily cut it off later without running into math problems.
  h = ra_bcbp_ex * h_multiplier;
  e = 0.01;
  translate([0, 0, -h])
    my_cylinder(r=local_helmet_avoidance_ir, h=h+e);
}

module dome_above_ra_bearing() {
  r=local_helmet_avoidance_ir;
  r2 = r + 1;
  intersection() {
    scale([1, 1, 1.42]) sphere(r=r);
    translate([-r2, -r2, 0]) cube(size=r2*2, center=false);
  }
}


// Volume swept out by the DEC clutch as it rotates fully, and the DEC head
// under it, plus some more to allow the hull above to cover the DEC motor.
module swept_dec_clutch(grow=true) {
  r = dec_clutch_handle_max_height;
  r2 = grow ? r * 1.15 : r;
  h = clutch_screw_axis_height + clutch_handle_base_diam / 2 + 2;

  translate_to_dec_bearing_plane() {
    // The volume swept out by the DEC clutch.
    translate([0, 0, -(dec_bearing_gap + h)]) my_cylinder(h=h*1.7, r1=r, r2=r2);
  }
}

// Interior of tube surrounding the counterweight shaft as it goes through
// the side of the helmet. Allows us room for a small disc that keeps
// most rain from entering the helmet.
module cw_shaft_port_interior(r=cw_shaft_diam, h=61) {
  translate_to_dec12_plane() {
    mirror([0, 0, 1]) {
      translate([0, 0, dec1_len+cw_cap_height]) {
        my_cylinder(r=r, h=h);
      }
    }
  }
}

// Interior of tube surrounding the counterweight shaft as it goes through
// the side of the helmet. Allows us room for a small disc that keeps
// most rain from entering the helmet.
module cw_shaft_port_exterior(r=cw_shaft_diam+helmet_walls, h=40) {
  translate_to_dec12_plane() {
    mirror([0, 0, 1]) {
      translate([0, 0, dec1_len+cw_cap_height]) {
        my_cylinder(r1=r*1.3, r2=r, h=h);
      }
    }
  }
}
