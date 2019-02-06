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

basic_helmet2_walls = 5;
lower_rib_thickness = 10;


distance = 40;//40 * (cos($t*360) + 1);

// Global resolution
$fs = $preview ? 10 : 1;
$fa = $preview ? 10 : 1;

if (!$preview) {
  basic_helmet2();
} else if (false) {
  color("orange") translate([distance, 0, 0]) basic_helmet2_nut_side();
  color("limegreen") translate([-distance, 0, 0]) basic_helmet2_screw_side();



*color("pink") translate([0, 300, 0]) basic_helmet2_interior();


//   #basic_helmet2_simple_solid();

// color("purple") basic_helmet2_half_draft_body();

//   rotate([0, -90, 0]) {
// *    color("green") basic_helmet2_simple_solid_slice();

//     *color("blue") basic_helmet2_interior_core_slice();




//   }

} else if (true) {
  ra_and_dec(include_dec_head=false) {
    s = 300;
    intersection() {
      basic_helmet2();
      translate([0, -s/2, -100]) cube(size=s);

    }
  }

  translate([-200, 300, 0])
  ra_and_dec(include_dec_head=false) {
    s = 300;
    intersection() {
      basic_helmet2();
      translate([-s/2, 0, -100]) cube(size=s);

    }
  }

  translate([-400, 600, 0])
  ra_and_dec(include_dec_head=false) {
    s = 300;
    intersection() {
      basic_helmet2();
      translate([-s/2, 40, -100]) cube(size=s);

    }
  }

translate([600, 0, 0]) color("skyblue")
  basic_helmet2_exterior();

translate([300, 0, 0]) color("green")
  basic_helmet2_cut_from_exterior();



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

module basic_helmet2_old() {
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
      // minkowski is fairly fast if the object is convex, but vastly slower
      // if it isn't. So we apply it only to those parts where we need it,
      // and not to the whole basic_helmet2_interior(). If it is neccessary
      // to add other parts to the minkowski sum, consider operating on them
      // separately, and unioning the results.
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

  cw_shaft_port_interior();

  hull() {
    // We the extend below_ra_bearing part a bit further so that we
    // can easily cut it off later without running into math problems.
    below_ra_bearing(h_multiplier=2);

    bump_below_cw_shaft();
  }
}
module basic_helmet2_interior_core() {
  if (true) {
    basic_helmet2_interior_tight_core();
  } else {
    hull() basic_helmet2_interior_core_parts();
  }
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
}

// Use boost_size=true when creating the exterior using minkowski, but not
// when cutting out the inside. That leaves us with a thicker skin in places
// where we need it (e.g. where we want to put the fasteners), but thinner
// elsewhere.
module basic_helmet2_interior_tight_core(boost_size=false) {
  motor_cylinder_x = dec_motor_w/2 - 5 + (boost_size ? -2 : 0);
  motor_cylinder_y = dec_motor_z_offset + dec_motor_core_z - 5 + (boost_size ? 3 : 0);
  dec1_total_len = dec1_len + cw_cap_total_height + (boost_size ? 10 : 0);
  echo(dec1_total_len);

  hull() {
    // Volume that includes the RA clutch. We don't actually have to leave
    // room all the way around, but do so for symmetry.
    my_cylinder(r=ra_clutch_handle_max_height, h=ra1_base_to_dec);

    // Two cylinders to mark the edges of the DEC motor in the hull.
    translate_to_dec_bearing_plane() {
      translate([0, motor_cylinder_y, 0]) {
        mirrored([1, 0, 0]) {
          translate([motor_cylinder_x, 0, 0]) {
            my_cylinder(r=10, h=dec_motor_core_top_h, fn=20);
          }
        }
      }
    }

    // The dec1 body.
    translate_to_dec12_plane() {
      mirror([0,0,1])
        my_cylinder(r=dec1_radius, h=dec1_total_len);
    }

    // The volume including the RA motor and the RA motor rain plate.
    below_ra_bearing(h_offset=-basic_helmet2_walls);

    // The volume swept out by the DEC clutch.
    swept_dec_clutch(grow=false);

    bump_below_cw_shaft(h_offset=-basic_helmet2_walls);




  }
}


module basic_helmet2() {
  difference() {
    basic_helmet2_exterior();

    basic_helmet2_cut_from_exterior();

    // Cut below the z=-ra_bcbp_ex plane.
    s = 300;
    translate([-s/2, -s/2, -(s + ra_bcbp_ex)]) cube(size=s);

    translate_to_dec_bearing_plane() {
      mirror([0, 0, 1]) {
        // Can't be too thick between the DEC clutch and the DEC saddle
        // screws; there is only about 1cm of space, so need to trim here.
        z = hoop_disc_z;
        translate([0, 0, s/2 + z]) cube(size=s, center=true);
      }
    }
  }
}

module basic_helmet2_exterior() {
  motor_cylinder_x = dec_motor_w/2 - 5;
  motor_cylinder_y = dec_motor_z_offset + dec_motor_core_z - 2;
  dec1_total_len = dec1_len + cw_cap_total_height;
  rib_boost = lower_rib_thickness-basic_helmet2_walls;

  minkowski() {
    hull() {
      translate_to_dec_bearing_plane() {
        translate([0, motor_cylinder_y, 0]) {
          // Four spheres to mark the top corners of the DEC motor in the hull,
          mirrored([1, 0, 0]) {
            translate([motor_cylinder_x, 0, 0]) {
              sphere(r=10, $fn=20);
              translate([0, 0, dec_motor_core_top_h])
                sphere(r=10, $fn=20);
            }
          }

          // Two additional spheres to boost the thickness at the top
          // of the motor where we cut.
          translate([0, 0, 0]) {
            sphere(r=15, $fn=20);
            translate([0, 0, dec_motor_core_top_h])
              sphere(r=15, $fn=20);
          }
        }
      }

      // The dec1 body, but with a sphere at the CW end to provide a little
      // space.
      translate_to_dec12_plane() {
        mirror([0,0,1]) {
          my_cylinder(r=dec1_radius, h=dec1_total_len);
          translate([0, 0, dec1_total_len]) {
            sphere(r=dec1_radius);
            *translate([0, -dec1_radius, 0])
              sphere(r=10, $fn=20);
          }
        }
      }

      // The volume swept out by the DEC clutch.
      extra_h = hoop_disc_z - basic_helmet2_walls;
      swept_dec_clutch(grow=false, extra_h=extra_h);

      // The volume including the RA motor and the RA motor rain plate.
      below_ra_bearing(r_offset=rib_boost, descend_offset=-lower_rib_thickness);
      bump_below_cw_shaft(bump_offset=rib_boost, descend_offset=-lower_rib_thickness);
    }
    minkowski_sphere();
  }

  minkowski() {
    hull() {
      // The volume including the RA motor and the RA motor rain plate.
      below_ra_bearing(r_offset=rib_boost);
      bump_below_cw_shaft(bump_offset=rib_boost);
    }
    minkowski_sphere();
  }



  // below_ra_bearing(r_offset=rib_boost, descend_offset=-lower_rib_thickness);
  // bump_below_cw_shaft(bump_offset=rib_boost, descend_offset=-lower_rib_thickness);

  // below_ra_bearing(r=local_helmet_avoidance_ir+lower_rib_thickness);
  // bump_below_cw_shaft(s_offset=rib_boost+3);

  // Exterior of tube surrounding the counterweight shaft as it goes through
  // the side of the helmet. Allows us room for a small disc that keeps
  // most rain from entering the helmet.
  translate_to_dec12_plane() {
    mirror([0, 0, 1]) {
      translate([0, 0, dec1_len+cw_cap_total_height]) {
        r=cw_shaft_diam+lower_rib_thickness;
        h = 50;

        my_cylinder(r=r, h=h);


        *hull() {
          my_cylinder(r=dec1_radius+basic_helmet2_walls, h=0.001);
          translate([0,11,h-0.001])
            my_cylinder(r=cw_shaft_diam+basic_helmet2_walls, h=0.001);
        }
        // scale([1, 1.2, 1])
        // my_cylinder(r1=dec1_radius, r2=cw_shaft_diam, h=h);
      }
    }
  }
}

// The parts to cut out of basic_helmet2_exterior().
// One goal is to try to leave a rim at the bottom (around the RA core/motor)
// which makes some room for fasteners.
module basic_helmet2_cut_from_exterior() {
  motor_cylinder_x = dec_motor_w/2 - 5;
  motor_cylinder_y = dec_motor_z_offset + dec_motor_core_z - 2;
  dec1_total_len = dec1_len + cw_cap_total_height;

  hull() {
    // Four spheres to mark the top corners of the DEC motor in the hull.
    translate_to_dec_bearing_plane() {
      translate([0, motor_cylinder_y, 0]) {
        mirrored([1, 0, 0]) {
          translate([motor_cylinder_x, 0, 0]) {
            sphere(r=10, $fn=20);
            translate([0, 0, dec_motor_core_top_h])
              sphere(r=10, $fn=20);
          }
        }
      }
    }

    // The dec1 body, but with a sphere at the CW end to provide a little
    // space.
    translate_to_dec12_plane() {
        mirror([0,0,1]) {
          my_cylinder(r=dec1_radius, h=dec1_total_len);
          translate([0, 0, dec1_len])
            sphere(r=dec1_radius);
        }
    }

    // The volume swept out by the DEC clutch.
    swept_dec_clutch(grow=false, extra_h=0);

    // The volume including the RA motor and the RA motor rain plate.
    below_ra_bearing(descend_offset=-lower_rib_thickness);

    bump_below_cw_shaft(descend_offset=-lower_rib_thickness);
  }

  hull() {
    // The volume including the RA motor and the RA motor rain plate, extended
    // lower for cutting an opening in the bottom of basic_helmet2_exterior.
    below_ra_bearing(descend_offset=20);
    // Along with a bump for improving 3D print-ability.
    bump_below_cw_shaft(descend_offset=20);
  }

  translate_to_dec_bearing_plane() {
    mirror([0, 0, 1]) {
      // Space for the DEC head.
      my_cylinder(r=dec2_radius, h=dec_head_total_height);
    }
  }

  // Room for the counterweight shaft.
  translate_to_dec12_plane() {
    mirror([0, 0, 1]) {
      translate([0, 0, dec1_len+cw_cap_total_height]) {
        my_cylinder(r=cw_shaft_diam, h=100);
      }
    }
  }
}

module below_ra_bearing(r=local_helmet_avoidance_ir, r_offset=0, descend_offset=0, ascend=0*ra1_base_to_dec_center) {
  // We support extend below the RA bearing plane further than necessary so
  // that we can easily cut it off later without running into math problems.
  descend = ra_bcbp_ex + descend_offset;
  h = descend + ascend;

  translate([0, 0, -descend]) {
    my_cylinder(r=r+r_offset, h=h);
  }
}

// ONLY for the sake of being able to 3D print this part (with the DEC head end
// being flat on the printer bed, and the CW shaft port at the top), we put
// an angled bump out below the CW shaft.
module bump_below_cw_shaft(r=local_helmet_avoidance_ir, bump_size=10, bump_offset=0, descend_offset=0, ascend=ra1_base_to_dec_center) {
  descend = ra_bcbp_ex + descend_offset;
  h = descend + ascend;
  bump = r + bump_size + bump_offset;

  translate([0, 0, -descend]) {
    mirror([0, 1, 0])
      translate([-1, 0, 0])
        cube(size=[1, r+bump_size+bump_offset, h]);
  }
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
module cw_shaft_port_interior(r1=cw_shaft_diam, h=100) {
  translate_to_dec12_plane() {
    mirror([0, 0, 1]) {
      translate([0, 0, dec1_len+cw_cap_total_height]) {
        my_cylinder(r=cw_shaft_diam, h=h);


        *hull() {
          my_cylinder(r=dec1_radius, h=0.001);
          translate([0,11,h-0.001])
            my_cylinder(r=cw_shaft_diam, h=0.001);
        }
        // scale([1, 1.2, 1])
        // my_cylinder(r1=dec1_radius, r2=cw_shaft_diam, h=h);
      }
    }
  }
}

// Exterior of tube surrounding the counterweight shaft as it goes through
// the side of the helmet. Allows us room for a small disc that keeps
// most rain from entering the helmet.
module cw_shaft_port_exterior(r=cw_shaft_diam+basic_helmet2_walls, h=40) {
  translate_to_dec12_plane() {
    mirror([0, 0, 1]) {
      translate([0, 0, dec1_len+cw_cap_total_height]) {
        my_cylinder(r1=r*1.3, r2=r, h=h);
      }
    }
  }
}