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

basic_helmet2_walls = 10;

distance = 40;//40 * (cos($t*360) + 1);

// Global resolution
$fs = $preview ? 10 : 1;
$fa = $preview ? 10 : 1;

if (!$preview) {
  basic_helmet2();
} else if (true) {
  color("orange") translate([distance, 0, 0]) basic_helmet2_nut_side();
  color("limegreen") translate([-distance, 0, 0]) basic_helmet2_screw_side();



*color("pink") translate([0, 300, 0]) basic_helmet2_interior();


//   #basic_helmet2_simple_solid();

// color("purple") basic_helmet2_half_draft_body();

//   rotate([0, -90, 0]) {
// *    color("green") basic_helmet2_simple_solid_slice();

//     *color("blue") basic_helmet2_interior_core_slice();




//   }



// *   translate([0, 0, 10]) thinner_basic_helmet2_simple_solid_slice();
} else {
  ioptron_mount(ra_angle=90) {
    union() {*ra_motor_hat();};
    union() {
      // Intersection for showing how thick things are.
      #intersection() {
        basic_helmet2();
        s = 400;
        translate([s/2, 0, 0]) cube(size=s, center=true);
      }
     * translate([400, 0, 0]) basic_helmet2_interior();
     * translate([-100, 0, 0]) rotate([0,-90,0]) basic_helmet2_simple_solid_slice();
     * translate([-200, 0, 0])  rotate([0,-90,0]) thinner_basic_helmet2_simple_solid_slice();
    };
  }



}

module basic_helmet2_nut_side() {
  basic_helmet2_half(nut_side=true);
}

module basic_helmet2_screw_side() {
  basic_helmet2_half(nut_side=false);
}

module basic_helmet2_half(nut_side) {
  s = 400;
  if (nut_side) {
    difference() {
      basic_helmet2();
      basic_helmet2_half_draft_body(scale=1.3, slice_offset=3);
      translate([-s-20,-s/2,-s/2]) cube(size=s, center=false);
    }
  } else {
    intersection() {
      basic_helmet2();
      basic_helmet2_half_draft_body(scale=1.3, slice_offset=2.5);
      translate([-s-0,-s/2,-s/2]) cube(size=s, center=false);
    }
  }
}

module basic_helmet2() {
  difference() {
    basic_helmet2_simple_solid();
    basic_helmet2_interior();

    translate_to_dec_bearing_plane() {
      mirror([0, 0, 1]) {
        // Cut a hole for the DEC head.
        my_cylinder(r=dec2_radius, h=dec_head_total_height);
      }
    }
  }
}



// module thinner_basic_helmet2_simple_solid_slice() {
//   difference() {
//     *basic_helmet2_simple_solid_slice();
//     offset(delta=basic_helmet2_walls/2) {
//       difference() {
//         s = 400;
//         translate([-ra_bcbp_ex, -s/2, 0])
//           square(size=400, center=false);

//         basic_helmet2_simple_solid_slice();
//       }
//     }
//   }
// }

// // A projection (slice) of the cut line of the helmet.
// module basic_helmet2_simple_solid_slice(x_offset=0) {
//   projection(cut=true) {
//     rotate([0, 90, 0])
//       translate([x_offset, 0, 0])
//         basic_helmet2_simple_solid();
//   }
// }

module minkowski_sphere() {
  sphere(r=basic_helmet2_walls, $fn=$fn);
}

module basic_helmet2_simple_solid() {
  difference() {
    union() {
      minkowski() {
        basic_helmet2_interior_core();
        minkowski_sphere();
      }

      cw_shaft_port_exterior();
    }

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
          *my_cylinder(r=dec2_radius, h=dec_head_total_height);
        }
      }

    }
  }
}

module basic_helmet2_half_draft_body(slice_offset=3, scale=2) {
  rotate([0, -90, 0]) {
    translate([ra1_base_to_dec_center, 0, 0]) {
      linear_extrude(height=200, scale=scale, convexity=10) {
        translate([-ra1_base_to_dec_center, 0, 0]) {
          basic_helmet2_interior_core_slice(slice_offset=slice_offset);
        }
      }
    }
  }
}


translate([200,0,0])
 basic_helmet2_interior_core_slice();


module basic_helmet2_interior_core_slice(slice_offset=3) {
  module the_slice() {
    offset(delta=slice_offset) {
      projection(cut=true) {
        rotate([0, 90, 0]) {
          basic_helmet2_interior_core();
          // We need more than just the core to make good use of the slice.
          swept_dec_clutch(extra_h=20);
          cw_shaft_port_interior();
        }
      }
    }
  }
  the_slice();
  // There is a little part below the DEC head that is sloped inward towards
  // the RA axis, which makes the draft body a bit problematic. Remove that
  // by extending the edge down to the "bottom".
  intersection() {
    s = 200;
    translate([-ra_bcbp_ex, 0, 0]) square(size=s, center=false);
    translate([-ra_bcbp_ex - ra1_base_to_dec_center, 0, 0]) the_slice();
  }
}

module basic_helmet2_interior() {
  basic_helmet2_interior_core();

  // We the extend below_ra_bearing part a bit further so that we
  // can easily cut it off later without running into math problems.
  below_ra_bearing(h_multiplier=2);

  cw_shaft_port_interior();

  *bump_below_cw_shaft();

}


module basic_helmet2_interior_core() {
  hull() basic_helmet2_interior_core_parts();
}

module basic_helmet2_interior_core_parts() {
  // The volume including the RA motor and the RA motor rain plate.
  below_ra_bearing();

  // Mostly cover the ra_and_dec body, with a little poking out near the
  // CW shaft and the motor.
  dome_above_ra_bearing();

  // The volume swept out by the DEC clutch.
  swept_dec_clutch();


  bump_below_cw_shaft();

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

// ONLY for the sake of being able to 3D print this part (with the DEC head end
// being flat on the printer bed, and the CW shaft port at the top), we put
// an angled bump out below the CW shaft.
module bump_below_cw_shaft() {
  s = 30;
  translate([0, -local_helmet_avoidance_ir + s/2, 0])
  rotate([0, 0, 45])
    translate([-s/2,-s/2, -ra_bcbp_ex])
      cube(size=[s, s, ra_bcbp_ex+ra1_base_to_dec_center], center=false);
}



// Volume swept out by the DEC clutch as it rotates fully, and the DEC head
// under it, plus some more to allow the hull above to cover the DEC motor.
module swept_dec_clutch(grow=true, extra_h=0) {
  r = dec_clutch_handle_max_height;
  r2 = grow ? r * 1.15 : r;
  h = clutch_screw_axis_height + clutch_handle_base_diam / 2 + 2;

  translate_to_dec_bearing_plane() {
    // The volume swept out by the DEC clutch.
    translate([0, 0, -(dec_bearing_gap + h)]) {
      my_cylinder(h=h*1.7, r1=r, r2=r2);
      if (extra_h > 0) {
        translate([0, 0, -extra_h + 0.001])
          my_cylinder(r=r, h=extra_h);
      }
    }
  }
}

// Interior of tube surrounding the counterweight shaft as it goes through
// the side of the helmet. Allows us room for a small disc that keeps
// most rain from entering the helmet.
module cw_shaft_port_interior(r1=cw_shaft_diam, h=45) {
  translate_to_dec12_plane() {
    mirror([0, 0, 1]) {
      translate([0, 0, dec1_len+cw_cap_height]) {
        my_cylinder(r1=dec1_radius, r2=cw_shaft_diam, h=h);
      }
    }
  }
}

// Interior of tube surrounding the counterweight shaft as it goes through
// the side of the helmet. Allows us room for a small disc that keeps
// most rain from entering the helmet.
module cw_shaft_port_exterior(r=cw_shaft_diam+basic_helmet2_walls, h=40) {
  translate_to_dec12_plane() {
    mirror([0, 0, 1]) {
      translate([0, 0, dec1_len+cw_cap_height]) {
        my_cylinder(r1=r*1.3, r2=r, h=h);
      }
    }
  }
}
