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

local_helmet_avoidance_ir = ra_motor_collar_radius;

// Global resolution
$fs = $preview ? 10 : 1;
$fa = $preview ? 10 : 1;

*minkowski() {
  union() {
    ra_and_dec(include_dec_head=false, include_cw_shaft=false);
  };
  sphere(r=5);
}

ioptron_mount() {
  union() {};
  #helmet_interior3();



}


module helmet_interior2() {
  // The volume including the RA motor and the RA motor rain plate.
  below_ra_bearing();

  // See if we can sweep a semi-circle by 90 degrees and properly cover
  // the CW shaft end of the dec body.
  sweep_semi_circle(radius=local_helmet_avoidance_ir, angle=180);


  translate_to_dec_bearing_plane() {
    // The volume swept out by the DEC clutch.
    swept_dec_clutch();

    // A fake DEC head, up to the point of the DEC rain plate.
    short_dec_head_core();
  }
}

module helmet_interior3() {
  hull() {
    // The volume including the RA motor and the RA motor rain plate.
    below_ra_bearing();

    // Mostly cover the ra_and_dec body, with a little poking out near the
    // CW shaft and the motor.
    sweep_semi_circle(radius=local_helmet_avoidance_ir, angle=180);

    translate_to_dec_bearing_plane() {
      // The volume swept out by the DEC clutch.
      swept_dec_clutch();
    }


    translate_to_dec12_plane() {
      mirror([0, 0, 1])
        cylinder(d=dec1_diam, h=dec1_len+cw_cap_total_height);
    }
  }


  // intersection() {
  //   union() {

  //   }
  //   s = 3 * local_helmet_avoidance_ir;
  //   translate([0, 0, s/2])
  //     cube(size=s, center=true);
  // }
}

*helmet_interior3();


module helmet_interior2_below_axis() {
  intersection() {
    union() {
      translate([0, 0, -(ra_bcbp_ex - 0.01)])
        cylinder(r=local_helmet_avoidance_ir, h=ra_bcbp_ex);

      // See if we can sweep a semi-circle by 90 degrees and properly cover
      // the CW shaft end of the dec body.



//      sweep_semi_circle(radius=local_helmet_avoidance_ir, angle=180);

      translate_to_dec_bearing_plane() {
        // The volume swept out by the DEC clutch.
        swept_dec_clutch();
      }
    }
    s = 3 * local_helmet_avoidance_ir;
    translate([0, 0, -s/2])
      cube(size=s, center=true);
  }
}
*hull()helmet_interior2_below_axis();

*helmet_interior2();

module helmet_interior2_above_axis() {
  intersection() {
    union() {
      // See if we can sweep a semi-circle by 90 degrees and properly cover
      // the CW shaft end of the dec body.
      sweep_semi_circle(radius=local_helmet_avoidance_ir, angle=180);

    }
    s = 3 * local_helmet_avoidance_ir;
    translate([0, 0, s/2])
      cube(size=s, center=true);
  }
      translate_to_dec_bearing_plane() {
        // The volume swept out by the DEC clutch.
        swept_dec_clutch();
      }
}
*hull()helmet_interior2_above_axis();

module below_ra_bearing() {
  translate([0, 0, -(ra_bcbp_ex - 0.01)])
    cylinder(r=local_helmet_avoidance_ir, h=ra_bcbp_ex);
}

module sweep_semi_circle(radius=local_helmet_avoidance_ir, angle=90) {
  scale([1, 1, 1.42])
  rotate([0, 0, -90])
  rotate([90, 0, 0])
  rotate_extrude(angle=angle) {
    intersection() {
      circle(r=radius);
      w = radius + 1;
      h = 2 * w;
      translate([0, -w, 0]) {
        square(size=[w, h], center=false);
      }
    }
  }
}

*translate([300, 0, 0]) sweep_semi_circle();

module swept_dec_clutch(grow=true) {
  r = dec_clutch_handle_max_height;
  r2 = grow ? r * 1.15 : r;
  h = clutch_screw_axis_height + clutch_handle_base_diam / 2;
  translate([0, 0, -(dec_bearing_gap + h)]) cylinder(h=h*1.7, r1=r, r2=r2);
}