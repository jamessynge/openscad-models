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
include <wp4_dimensions.scad>
use <polar_port_and_cap.scad>

include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/paired_bosses.scad>
use <../../utils/axis_arrows.scad>


// Global resolution
$fs = $preview ? 2 : 1;
$fa = $preview ? 6 : 1;

helmet_thickness = 5;

// Amount by which nut-side will overhang screw-side. Need the overhang to
// be less than the helmet thickness so that there is a flat surface to
// butt up against, which will stop the the two sides from being distorted.
overhang = helmet_thickness / 2;
assert(overhang >= 1);
assert(helmet_thickness - overhang >= 1);


extra_ra_motor_clearance = 5;
extra_body_clearance = 5;

mount_latitude=90;

ra_angle = 152 + $t * 360;
dec_angle = 180 + 238 + $t * 360;

*ioptron_mount(latitude=mount_latitude,ra_angle=ra_angle, dec_angle=dec_angle) {
  union() {}
  union() {
    demo();
    color("red")possible_bosses();

    *interior_avoidance_parts(minkowski_sphere_r=5);

    *simple_interior();

    // *intersection() {
    //   // basic_helmet2();
    //   s = 300;
    //   *translate([0, -s/2, -100]) cube(size=s);
    // }

    // *trim_below_ra_bearing() {
    //   #below_ra_bearing(extra_r=0, extra_descend=10);
    // }
    // #below_ra_bearing(extra_r=0, extra_descend=10);
    // color("green", 0.2)hull()dec2_motor_exclusion();
    // color("skyblue", 0.2)swept_dec_clutch();

    translate_to_dec_bearing_plane(z_towards_dec_head=false) {
    *rotate([0, 0, 180])
      color("red") axis_arrows(total_length=ra1_radius*3);

    }


  }
}









ra_clutch_angle=90;
*
//trim_helmet()
ra_and_dec(include_dec_head=true, ra_clutch_angle=ra_clutch_angle) {
  union() {
    demo();

    // *trim_below_ra_bearing() {
    //   #below_ra_bearing(extra_r=0, extra_descend=10);
    // }
    // #below_ra_bearing(extra_r=3, extra_descend=10);
    // color("green", 0.2)hull()dec2_motor_exclusion();
    // color("skyblue", 0.2)swept_dec_clutch();

  }
}

*translate([500, 0, 0]) {
  cut_along_x() {
    difference() {
      simple_exterior(solid=true, include_polar_port=false);
      offset_3d(r=-overhang, size=400) {
        simple_exterior(solid=true, include_polar_port=false);
      }
    }
  }
}

module cut_along_x(x=0, reverse=false) {
  if (reverse) {
    intersection() {
      union() { children(); }
      s = 300;
      translate([x, -s/2, -s/3])
        cube(size=s, center=false);
    }
  } else {
    difference() {
      union() { children(); }
      s = 300;
      translate([x, -s/2, -s/3])
        cube(size=s, center=false);
    }
  }
}
module demo() {
  // hull() {
  //   trim_below_ra_bearing() {
  //     below_ra_bearing(extra_r=3, extra_descend=10);
  //   }
  //   ra_bearing_to_dec1_hull(extra_r=3);
  // //  #color("green", 0.2)hull()dec2_motor_exclusion();

  //   //hull() 
  //   dec1_motor_exclusion();


  //   translate([0, 0, ra1_base_to_dec_motor_top]) {
  //     top_plate(thickness=2, cutout=false);
  //   }

  //   *hull() {
  //     ra_bearing_to_dec1_hull(extra_r=3);
  //     translate([0, 0, ra1_base_to_dec_motor_top]) {
  //       //top_plate();
  //     }
  //     //hull() dec1_motor_exclusion();
  //   }

  //   swept_dec_clutch_and_dec1_hull();
  // }

  cut_along_x() {
    simple_exterior(solid=false, include_polar_port=true);
  }
*  difference() {
    simple_exterior(solid=false, include_polar_port=true);
    s = 300;
    translate([0, -s/2, -s/3])
      cube(size=s, center=false);

  }
}


translate([50, 0, 0])
difference() {
  simple_exterior();
  difference() {
    rotate([0, -90, 0]) {
      linear_extrude(height=200, convexity=4)
        overhang_cut_profile(overhang=overhang+0.1);
    }
    cylinder(d=polar_port_cap_diam*1.5, h=150);
  }
}

  intersection() {
    difference() {
      simple_exterior();
      cylinder(d=polar_port_cap_diam*1.5, h=150);
    }
    rotate([0, -90, 0]) {
      linear_extrude(height=200, convexity=4)
        overhang_cut_profile(overhang=overhang-0.1);
    }
  }

translate([300, 0, 0])
overhang_cut_profile();



translate([0, 500, 0])
  overhang_cut_body();


module overhang_cut_body(overhang=overhang) {
  difference() {
    rotate([0, -90, 0]) {
      linear_extrude(height=200, convexity=4)
        overhang_cut_profile(overhang=overhang);
    }
    s = polar_port_cap_diam*1.5;
    rotate([0, 0, 45])
      translate([-s/2, -s/2, -100])
        cube([s, s, 300], center=false);
//    cylinder(d=polar_port_cap_diam*1.5, h=150);
  }

}


module overhang_cut_profile(overhang=overhang, solid=true, include_polar_port=false) {
  module extensions() {
    // Extend the profile below the bottom and beyond the DEC head so that
    // so that we don't have funny slivers of material there.
    union() {
      union() {
        x = 50;
        y = 400;
        translate([-x/2 - ra_bcbp_ex + overhang, 0, 0])
          square(size=[x, y], center=true);
      }
      union() {
        x = dec_clutch_handle_max_height*2;
        y = 50;
        translate([ra1_base_to_dec_center+2, y/2 + ra1_radius+dec2_len+dec_bearing_gap+clutch_flange_height, 0]) {
          square(size=[x, y], center=true);
          translate([-x/2, 0, 0])
            square(size=[x, y], center=true);
        }
      }
    }    
  }
  module base() {
    simple_exterior_profile(solid=solid, include_polar_port=include_polar_port);
  }
  offset(r=-overhang) base();
  extensions();
}

module simple_exterior_profile(solid=true, include_polar_port=false) {
  projection(cut=true) {
    rotate([0, 90, 0]) 
      simple_exterior(solid=solid, include_polar_port=include_polar_port);
  }
}


module simple_exterior(solid=false, include_polar_port=true) {

  trim_helmet() {
    difference() {
      hull(){
        minkowski() {
          simple_interior();
          minkowski_sphere(r=helmet_thickness);
        }
      
        minkowski() {
          possible_bosses();
          minkowski_sphere(r=helmet_thickness);
        }
      }
      if (!solid) {
        simple_interior();
        if (include_polar_port) {
          // Cut out the polar port hole, a little smaller than the OD.
          cylinder(d=polar_port_diam-1, h=150);
        }
      }
    }
  }

  if (include_polar_port) {
    // Add the polar port.
    translate([0, 0, 140]) {
      polar_port(h_descend=5, h_above=4, thickness=5, od_extra=3, solid=solid);
    }
  }
}


module possible_bosses() {
  l = 60;
  // Possible boss positions.
  // Below DEC port.
  translate([0, ra_motor_clearance_radius_max + rtp_boss_diam/2+2, -ra2_len - rtp_boss_diam/4])
    rotate([0, 90, 0])
      symmetric_z_cylinder(d=rtp_boss_diam, l=l);

  // Above DEC port, next to DEC motor.
  translate([0, ra1_radius + dec2_len, ra1_base_to_dec_motor_top+rtp_boss_diam/4])
    rotate([0, 90, 0])
      symmetric_z_cylinder(d=rtp_boss_diam, l=l);


  // Below CW port.
  translate([0, -ra_motor_clearance_radius_max - rtp_boss_diam/2 - 2, -ra2_len - rtp_boss_diam/4])
    rotate([0, 90, 0])
      symmetric_z_cylinder(d=rtp_boss_diam, l=l);


  // Between CW port and top-center.
  translate([0, - polar_port_cap_diam, ra1_base_to_dec_motor_top-rtp_boss_radius])
    rotate([0, 90, 0])
      symmetric_z_cylinder(d=rtp_boss_diam, l=l);
}





// This is a starting point for creating the exterior shell, though after the
// addition of some bosses, etc. It does not strictly avoid running into the
// locations that might be occupied by ribs or bosses, so other steps will need
// to deal with those.
module simple_interior(extra_ra_motor_clearance=extra_ra_motor_clearance, extra_body_clearance=extra_body_clearance) {
  extra_r = extra_ra_motor_clearance;
  hull() {
    trim_below_ra_bearing() {
      below_ra_bearing(extra_r=extra_r, extra_descend=10);
    }
    // ra_bearing_to_dec1_hull(extra_r=extra_r);
    simple_ra1_base_avoidance(extra_r=extra_r);
    dec_motor_avoidance(offset=extra_body_clearance);

    *translate([0, 0, ra1_base_to_dec_motor_top]) {
      top_plate(thickness=2, cutout=false);
    }

    //swept_dec_clutch_and_dec1_hull();
    swept_dec_clutch(extra_h=1);

    simple_dec1_body(extra_r=extra_body_clearance);
  }
  below_ra_bearing(extra_r=extra_r, extra_descend=10);
}












// These are the volumes we need to avoid colliding with, which don't contain
// parts filling them (i.e. only sometimes during rotation is there a part
// present).
module strict_interior_avoidance() {
  below_ra_bearing(extra_r=0, extra_descend=10);
  swept_dec_clutch();
}











module interior_avoidance_parts(extra_ra_motor_clearance=extra_ra_motor_clearance, minkowski_sphere_r=0) {
  hull() {
    maybe_minkowski_each(minkowski_sphere_r=minkowski_sphere_r) {
      // Need to avoid hitting the RA motor.
      below_ra_bearing(extra_r=extra_ra_motor_clearance, extra_descend=10);

      // Hull of the dec1 body and the profile of below_ra_bearing at the
      // RA bearing plane.
      ra_bearing_to_dec1_hull(include_cap=false, include_sphere=false, extra_r=extra_ra_motor_clearance);


    }
  }
  maybe_minkowski_each(minkowski_sphere_r=minkowski_sphere_r) {
    simple_dec1_body();
    swept_dec_clutch();
//  swept_dec_clutch_and_dec1_hull();
  }

  dec_motor_avoidance(offset=minkowski_sphere_r);


  // hull() {


  //   below_ra_bearing(extra_r=extra_ra_motor_clearance, extra_descend=10);
  //   ra_bearing_to_dec1_hull(extra_r=3);
  // //  #color("green", 0.2)hull()dec2_motor_exclusion();

  //   //hull() 
  //   dec1_motor_exclusion();


  //   translate([0, 0, ra1_base_to_dec_motor_top]) {
  //     top_plate(thickness=2, cutout=false);
  //   }

  //   *hull() {
  //     ra_bearing_to_dec1_hull(extra_r=3);
  //     translate([0, 0, ra1_base_to_dec_motor_top]) {
  //       //top_plate();
  //     }
  //     //hull() dec1_motor_exclusion();
  //   }

  // }
  //   swept_dec_clutch_and_dec1_hull();
  //   //color("skyblue", 0.2)swept_dec_clutch();
}

module dec_motor_avoidance(offset=5) {
  // Not applying a simple minkowski to this, to avoid encroaching on the
  // dec bearing plane.

  hull() {
    dec_motor_hull();
    if (offset > 0){
      translate([-offset, 0, offset]) dec_motor_hull();
      translate([+offset, 0, offset]) dec_motor_hull();
      translate([+offset, -offset, offset]) dec_motor_hull();
    }
  }
}



// probably not needed, but here for reference
module dome_above_ra_bearing() {
  r=ra_motor_clearance_radius_min;
  r2 = r + 1;
  intersection() {
    scale([1, 1, 1.42]) sphere(r=r);
    translate([-r2, -r2, 0]) cube(size=r2*2, center=false);
  }
}

// This module leaves the plate in the ra_and_dec base plane. The caller will
// raise it up above the DEC motor as appropriate.

module top_plate(thickness=5, outline=5, cutout=true) {
  cap_radius = polar_port_cap_diam / 2;

  // Distance from RA axis towards the counterweight shaft.
  cw_y = polar_port_cap_diam;

  // Distance from RA axis towards DEC head.
  dec_y = ra1_radius + dec2_len;

  width = dec_motor_w;


  length = dec2_len + ra1_radius + polar_port_cap_diam;

  module plate_profile() {
    offset(r=outline) {
      hull() {
        translate([-width/2, cap_radius, 0])
          square([width, dec2_len + ra1_radius - cap_radius]);
        circle(r=cap_radius*1.5);
      }
    }
  }

// translate([-200, 0, 0])
//   difference() {
//     linear_extrude(height=thickness, convexity=4)
//       plate_profile();
//     translate([0, 0, -0.01])
//       linear_extrude(height=thickness+0.02, scale=1.1)
//         rotate([0, 0, 45])
//           square(size=polar_port_cap_diam, center=true);
//   }

  module plate() {
    difference() {
      linear_extrude(height=thickness, convexity=4)
        plate_profile();
      if (cutout) {
        translate([0, 0, -0.01])
          linear_extrude(height=thickness+0.02, scale=1.1)
            rotate([0, 0, 45])
              square(size=polar_port_cap_diam, center=true);
      }
    }
  }

  plate();
}


module simple_dec1_body(include_cap=true, include_sphere=true, extra_r=0) {
  translate_to_dec12_plane(z_towards_dec_head=false) {
    h = dec1_len + (include_cap ? cw_cap_total_height : 0);
    cylinder(h=h, r=dec1_radius+extra_r);
    if (include_sphere) {
      translate([0, 0, h]) {
        sphere(r=dec1_radius+extra_r);
      }
    }
  }
}

// Volume swept out by the DEC clutch as it rotates fully, and the DEC head
// under it.
module swept_dec_clutch(extra_r=0, extra_h=0) {
  r1 = dec_clutch_handle_max_height + extra_r;
  h1 = clutch_screw_axis_height + clutch_handle_base_diam / 2 + extra_h;

//  r2 = dec2_radius + clutch_screw_length + clutch_extrusion - 3;
  r2 = dec2_radius + 18 + extra_r;
  h2 = clutch_screw_axis_height;

  translate_to_dec_head_base() {
    // The volume swept out by the DEC clutch handle.
    translate([0, 0, clutch_flange_height]) {
      my_cylinder(h=h1-clutch_flange_height, r=r1);
    }
    // The volume swept out by the DEC clutch handle base.
    translate([0, 0, 0]) {
      my_cylinder(h=h2, r=r2);
    }
  }
}
*swept_dec_clutch();


module swept_dec_clutch_and_dec1_hull(include_cap=true, include_sphere=true) {
  hull() {
    swept_dec_clutch();
    simple_dec1_body(include_cap=include_cap, include_sphere=include_sphere);
  }
}

// Applying a hull to avoid some problems seen when applying minkowski directly.
module dec_motor_hull() {
  translate_to_dec_bearing_plane(z_towards_dec_head=false) {
    translate([dec_motor_x_offset, -dec_motor_z_offset, 0]) {
      rotate([0, 180, 0]){
        rotate([90, 0, 0]){
          hull() {
            dec_motor();
          }
        }
      }
    }
  }
}

// Helmet shouldn't intrude in this volume.
module dec2_motor_exclusion(margin=3) {
  translate_to_dec_bearing_plane(z_towards_dec_head=false) {
    minkowski() {
      cylinder(r=dec2_radius, h=dec2_len);
      minkowski_sphere(r=margin);
    }

    minkowski() {
      // Yuck, too many changes of position. Probably means that
      // translate_to_dec_bearing_plane doesn't match up with the way
      // I was thinking of the coordinates when designing other parts.
      translate([dec_motor_x_offset, -dec_motor_z_offset, 0])
        rotate([0, 180, 0])
          rotate([90, 0, 0])
            hull()
              dec_motor();
      minkowski_sphere(r=margin);
    }
  }
}






// Helmet shouldn't intrude in this volume.
module dec1_motor_exclusion(margin=3) {
  minkowski() {
    simple_dec1_body(include_cap=false);
    minkowski_sphere(r=margin);
  }


  translate_to_dec_bearing_plane(z_towards_dec_head=false) {
    //   translate([0, 0, dec2_len])
    //     cylinder(r=dec1_radius, h=dec1_len);
    //   minkowski_sphere(r=margin);
    // }

    minkowski() {
      // Yuck, too many changes of position. Probably means that
      // translate_to_dec_bearing_plane doesn't match up with the way
      // I was thinking of the coordinates when designing other parts.
      translate([dec_motor_x_offset, -dec_motor_z_offset, 0])
        rotate([0, 180, 0])
          rotate([90, 0, 0])
            hull()
              dec_motor();
      minkowski_sphere(r=margin);
    }
  }
}

module simple_ra1_base_avoidance(extra_r=0) {
  cylinder(r=ra_motor_clearance_radius_min+extra_r, h=ra1_base_to_dec);
}


module ra_bearing_to_dec1_hull(include_cap=true, include_sphere=true, extra_r=0) {
  hull() {
    simple_ra1_base_avoidance(extra_r=extra_r);
    simple_dec1_body(include_cap=include_cap, include_sphere=include_sphere);



    // translate_to_dec12_plane(z_towards_dec_head=false) {
    //   cylinder(r=dec1_radius+extra_r, h=dec1_len+cw_cap_total_height);
    // }include_cap=include_cap, include_sphere=include_sphere

  }
}





// We assume here that we're starting on the ra_and_dec side of the RA bearing,
// so measurements include ra_bearing_gap.
module below_ra_bearing(ir_max=ra_motor_clearance_radius_max, ir_min=ra_motor_clearance_radius_min, taper=true, extra_r=0, descend=ra_bcbp_ex, extra_descend=0) {
  r1 = (taper ? ir_min : ir_max) + extra_r;
  r2 = ir_max + extra_r;
  z1 = min(ra_bcbp_ex, ra_motor_max_clearance_z);
  z2 = descend;
  rotate([180, 0, 0]) {
    cylinder(r1=r1, r2=r2, h=z1);
    if (z1 < z2) {
      h = z2 - z1 + extra_descend;
      translate([0, 0, z1]) {
        cylinder(r=r2, h=h);
      }
    }
  }
}

// Cut the model below our limit.
module trim_below_ra_bearing(descend=ra_bcbp_ex, max_model_width=300) {
  difference() {
    children();
    half = max_model_width / 2;
    translate([0, 0, -half - descend]) cube(size=max_model_width, center=true);
  }
}

// // Cut the model beyond our limit.
// module trim_before_dec_knobs(dz=dec_gap_to_saddle_knob, max_model_width=300) {
//   difference() {
//     children();
//     half = max_model_width / 2;
//     translate_to_dec_head_base() {
//       translate([0, 0, half + dz]) {
//         cube(size=[max_model_width,max_model_width, 100], center=true);
//       }
//     }
//   }
// }

module trim_helmet(ra_descend=ra_bcbp_ex, dec_head_z=dec_gap_to_saddle_knob-dec_bearing_gap, max_model_width=275) {
  half = max_model_width / 2;
  y = ra1_radius+dec2_len+dec_bearing_gap+dec_head_z;
  echo(y);
  intersection() {
    union() {
      children();
    }
    translate([-half, -max_model_width+y, -ra_descend]) {
      cube(size=max_model_width, center=false);
    }
  }
}
