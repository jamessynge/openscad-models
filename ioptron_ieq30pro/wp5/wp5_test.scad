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
use <polar_port_and_cap.scad>
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
dec_angle = 180 + 58 + $t * 360; // DEC clutch handle "down" at closest to RA motor.

if (!$preview) {
  simple_can_core(nut_side=true);

  *translate([400, 0, 0]) simple_lid();
} else if (false) {
  color("palegreen") simple_can_core();
  color("skyblue") simple_lid();

} else if (false) {
  ra_and_dec(dec_angle=dec_angle) {
    cut_along_x(reverse=true)
      union() {
        color("palegreen") simple_can_core();
        color("skyblue") simple_lid();
    
    
        //translate([0,200, 0])
          // color("green") simple_cw_port(nut_side=true);
          // color("red") simple_cw_port(nut_side=false);
      }
  }
} else {
  ioptron_mount(latitude=mount_latitude,ra_angle=ra_angle, dec_angle=dec_angle) {
    union() {}
    cut_along_y(reverse=true)
    union() {
      color("palegreen") simple_can_core();
      color("skyblue") simple_lid();


//translate([0,200, 0])
      // color("green") simple_cw_port(nut_side=true);
      // color("red") simple_cw_port(nut_side=false);

    }
  }
}

////////////////////////////////////////////////////////////////////////////////





module simple_can_core(nut_side=true) {
  // The basic can, minus the space needed for the DEC head and CW port.
  // module basic_can() {
  //   difference() {
  //     simple_can();
  //     hull() simple_dec_head_skirt();
  //     simple_cw_port(interior=true);
  //   }
  // }
  // The DEC head covering.
  module dec_head_covering() {
    difference() {
      simple_dec_head_skirt();
      simple_can_interior_avoidance();
    }
  }

  // The bottom of the DEC head covering can't be printed well because
  // it is a 90 degree overhang. Add a "chin" to the DEC head covering so
  // that it is supported.
  module dec_head_covering_print_support() {
    y = helmet_or;
    z = -ra_motor_skirt_max_z+ra_motor_skirt_rim;
    sx = 100;
    sy = ra_motor_skirt_rim * 2;
    sz = 40;
    s = [sx, sy, sz];

    module selector() {
      
      translate([0, y, z]) cube(size=s, center=true);
    }

    module dhc_part() {
      intersection() {
        dec_head_covering();
        selector();
      }
    }

    difference() {
      hull() {
        translate([0, rim_or-4, z])
          sphere(r=4);
        dhc_part();
      }
      hull() dec_head_covering();
      simple_can_interior_avoidance();
    }
  }

  basic_can();
  dec_head_covering();
  *dec_head_covering_print_support();

  simple_cw_port(nut_side=(nut_side!=false));
  simple_cw_port(nut_side=(nut_side!=true));

  *simple_can_overhang_cutter();
}


*translate([0, 300, 0]) {
  basic_can_half(nut_side=true);
  *simple_cw_port(nut_side=true);
}

module basic_can_half(nut_side=true) {
  if (nut_side) {
    difference() {
      basic_can();
      basic_can_cutter(nut_side=true);
    }
  } else {
    intersection() {
      basic_can();
      basic_can_cutter(nut_side=false);
    }
  }
}

module basic_can_cutter(nut_side=true) {
  if (nut_side) {
    simple_can_overhang_cutter(cutter_thickness_frac=0.35);
  } else {
    simple_can_overhang_cutter(cutter_thickness_frac=0.25);
  }
 simple_cw_port(overhang_cutter=true);
}

// The basic can, minus the space needed for the DEC head and the CW port.
module basic_can() {
  difference() {
    simple_can();
    hull() simple_dec_head_skirt();
    simple_cw_port(can_cutter=true);
    simple_can(interior_solid=true);
  }
*  intersection() {
    difference() {
      simple_can();
      hull() simple_dec_head_skirt();
      simple_cw_port(can_cutter=true);
      if (nut_side) {
        simple_can_overhang_cutter(cutter_thickness_frac=0.35);
      }
    }
    if (!nut_side) simple_can_overhang_cutter(cutter_thickness_frac=0.25);
  }
}


module simple_can_interior_avoidance(extra_ir=extra_ra_motor_clearance) {
  simple_can(extra_ir=extra_ir, interior_solid=true);
}

module simple_can_overhang_cutter(extra_ir=extra_ra_motor_clearance, thickness=ra_motor_skirt_thickness, cutter_thickness_frac=0.5) {
  simple_can(extra_ir=extra_ir, thickness=thickness, cutter_thickness_frac=cutter_thickness_frac, cutter=true);
}

module simple_can(extra_ir=extra_ra_motor_clearance, thickness=ra_motor_skirt_thickness, rim=ra_motor_skirt_rim, cutter=false, interior_solid=false, cutter_thickness_frac=0.5) {
  z = ra_motor_skirt_max_z + ra_bearing_gap;
  z2 = z + helmet_min_height_above_ra_bearing + helmet_extra_height_above_dec_skirt;
  ir = ra_motor_clearance_radius_max + extra_ir;
  skirt_or = ir + thickness;
  rim_or = ir + rim;

  module interior_body(ir=ir) {
    translate([0, 0, -1]) {
      cylinder(h=z2+2, r=ir);
    }
  }

  module exterior_solid(include_rim=true) {
   cylinder(h=z2 , r=skirt_or);
   if (include_rim)
     cylinder(h=rim, r=rim_or);
  }

  module cutter_solid() {
    w_half = ir + thickness * cutter_thickness_frac;
    h = z2 + 2;
    depth = rim_or + 1;
*    translate([-depth, -w_half, -1])
      cube([depth, 2*w_half, h], center=false);

    translate([0, 0, h/2 - 1])
    rotate([0, -90, 0])
    linear_extrude(height=depth, scale=[1, 1.5])
      square(size=[h, 2*w_half], center=true);


//    cut_along_x()
//      interior_body(ir=cutter_r);
  }

  translate([0, 0, -z]) {
    if (cutter) {
      cutter_solid();
    } else if (interior_solid) {
      interior_body();
    } else {
      difference() {
        exterior_solid();
        *interior_body();
        // translate([0, 0, -0.1])
          // cylinder(h=z2+0.2, r=ir);
      }
    }
  }
}






module simple_dec_head_skirt(show_profile=false) {
  thickness = dec_head_thickness;

  module profile() {
    s = ra1_radius + dec2_len + dec_bearing_gap + dec_head_height;
    translate([0, extra_dec_head_clearance + dec_head_thickness/2 - dec_head_rain_plate_mid_z, 0])
    intersection() {
      difference() {
        offset(r=dec_head_thickness)
          offset(r=extra_dec_clutch_clearance)
            square([dec_clutch_handle_max_height, s]);
        offset(r=extra_dec_clutch_clearance)
          square([dec_clutch_handle_max_height, s]);
      }
      translate([dec_head_avoidance_radius, -s/2, 0])
        square(size=s);
    }
  }

  module profile2() {
    s = ra1_radius + dec2_len + dec_bearing_gap + dec_head_height;

    delta = extra_dec_clutch_clearance*3 + thickness;

    // Centerline of the profile, to be offset by thickness.
    p0 = [dec_head_avoidance_radius + thickness/2, dec_head_rain_plate_mid_z];
    p1 = [dec_clutch_handle_max_height, p0[1]];
    p2 = [p1[0] + delta, p1[1] - delta];
    p3 = [p2[0], p2[1] - s];

    e = 0.01;
    offset(r=thickness/2)
    polygon([
      [p0[0], p0[1]+e],
      [p1[0], p1[1]+e],
      [p2[0]+e, p2[1]+e],
      [p3[0]+e, p3[1]],
      [p3[0]-e, p3[1]],
      [p2[0]-e, p2[1]-e],
      [p1[0], p1[1]-e],
      [p0[0], p0[1]-e],
    ]);

    *translate([0, extra_dec_head_clearance + dec_head_thickness/2 - dec_head_rain_plate_mid_z, 0])
    intersection() {
      difference() {
        offset(r=dec_head_thickness)
          offset(r=extra_dec_clutch_clearance)
            square([dec_clutch_handle_max_height, s]);
        offset(r=extra_dec_clutch_clearance)
          square([dec_clutch_handle_max_height, s]);
      }
      translate([dec_head_avoidance_radius, -s/2, 0])
        square(size=s);
    }
  }

  translate_to_dec_head_base()
    rotate_extrude(convexity=4)
      // mirror([0, 1, 0])
      profile2();

  *translate_to_dec_head_base(z_towards_dec_head=false)
    rotate_extrude(convexity=4)
      mirror([0, 1, 0])
        profile();

  // z = ra_motor_skirt_max_z + ra_bearing_gap;
  // ir = ra_motor_clearance_radius_max + extra_ir;
  // skirt_or = ir + thickness;
  // rim_or = ir + rim;
  // translate([0, 0, -z]) {
  //   difference() {
  //     union() {
  //       cylinder(h=z, r=skirt_or);
  //       cylinder(h=rim, r=rim_or);
  //     }
  //     translate([0, 0, -0.1])
  //       cylinder(h=z+0.2, r=ir);
  //   }
  // }
}

*translate([300, 0, 0])
simple_dec_head_skirt(show_profile=true);

// Goals:
// * Printable, which means that there can't be horizontal overhangs.
// * Add a raised lip at the outside edge so that water will tend to flow
//   back towards the helmet and then down rather than into the opening.
// * Eventually add a collar to be clipped onto the CW shaft that surrounds
//   the port, so that most water doesn't even make it to the port.
module simple_cw_port(nut_side=true, can_cutter=false, overhang_cutter=false) {
  length = 30;  // Just for the extrusion, will probably be cut down.
  thickness = dec_head_thickness;
  inside = 30;
  outside = inside + thickness * 2;

  module profile() {
    difference() {
     offset(r=thickness)
        square(size=inside, center=true);
  *    square(size=outside, center=true);
      square(size=inside, center=true);
    }
  }

  module screw_side_match() {
    translate([-thickness, -thickness, 0])
      square(size=outside, center=true);
    rotate([0, 0, -135])
      square(size=outside, center=false);
  }

  module nut_side_profile() {
    difference() {
      profile();
      screw_side_match();
    }
  }

  module screw_side_profile() {
    intersection() {
      profile();
      screw_side_match();
    }
  }

  module gusset() {
    half = outside/2;
    halfsq = half*half;
    dx = nut_side ? -thickness : 0;
     rotate([0, 0, -135]) {
       translate([0, sqrt(halfsq + halfsq) - sqrt(thickness)+0.2, 0]) {
        union() {
          linear_extrude(height=length, scale=[1, 0], convexity=4) {
            translate([dx, 0, 0])
              square([thickness, length]);
          }
          linear_extrude(height=length, convexity=4) {
            translate([dx, -thickness, 0])
              square(size=thickness);
          }
        }
      }
    }
  }

  module body() {
    gusset();
    linear_extrude(height=length, convexity=4) {
      if (nut_side) {
        nut_side_profile();
      } else {
        screw_side_profile();
      }
    }
  }

  module overhang_cutter_profile() {
    projection() rotate([0, 90, 0]) rotate([0, 0, -45]) body();
  }
  module overhang_cutter2() {
    translate([0, -helmet_ir, ra1_base_to_dec_center])
    rotate([0, -90, 0])
    rotate([0, 0, -90])
    linear_extrude(height=helmet_ir, convexity=4, scale=[1, 3])
      overhang_cutter_profile();
  }
  if (overhang_cutter) {
    *hull() {
      translate([0, thickness, 0])
        overhang_cutter2();
      translate([0, -thickness*2, 0]) overhang_cutter2();
    }
    overhang_cutter2();
  }

  translate_to_dec12_plane(z_towards_dec_head=false) {
    translate([0, 0, ra1_radius + helmet_ir]) {
      rotate([0, 0, -45]) {
        if (can_cutter) {
          translate([0, 0, -length]) {
            linear_extrude(height=length*3, convexity=4) {
              square(size=inside, center=true);
            }
          }
        } else {
          body();
        }
      }
    }
  }
}


*translate([400,0, 0]){
  color("green") simple_cw_port(nut_side=true);
  color("red") simple_cw_port(nut_side=false);
}


*if ($preview) translate([300, 0, 0]) color("lime") simple_lid();
module simple_lid(extra_ir=extra_ra_motor_clearance, helmet_thickness=ra_motor_skirt_thickness, lid_thickness=lid_thickness, grip_height=lid_grip_height) {

  ir = ra_motor_clearance_radius_max + extra_ir;
  skirt_or = ir + helmet_thickness;
  lid_or = skirt_or + lid_thickness;

  module grip_profile() {
    y0 = 0;
    y1 = lid_thickness;
    y2 = y1+grip_height;
    x0 = 0;
    x2 = lid_thickness;
    x1 = x2 * 0.2;
    polygon([
      [x0, y0],
      [x2, y0],
      [x2, y2],
      [x1, y2],
      [x0, y1],
    ]);
  }
  module outer_grip() {
    translate([lid_or - lid_thickness, 0, 0]) grip_profile();
  }
  module inner_grip() {
    translate([lid_or - lid_thickness - helmet_thickness, 0, 0])
      mirror([1, 0, 0])
        grip_profile();
  }

  // The outer is optional so that we can slide the screw side (not glued to
  // to the lid) into place without needing to move down and then up.
  module profile(include_outer=true, include_inner=true, include_tab=false) {
    square([lid_or, lid_thickness]);
    if (include_tab) {
      hull() {
        outer_grip();
        inner_grip();
      }
    } else {
      if (include_outer) {
        outer_grip();
      }
      if (include_inner) {
        inner_grip();
      }      
    }
  }

  module solid_body() {
    rotate_extrude(convexity=4) profile(include_outer=false, include_inner=true);
    rotate_extrude(angle=180, convexity=4) profile(include_outer=true, include_inner=false);

    tab_size = lid_tab_slot_degrees * 0.95; // degrees
    rotate([0, 0, 90 - tab_size / 2])
      rotate_extrude(angle=tab_size, convexity=4)
        profile(include_tab=true);

*    rotate_extrude(convexity=4) profile(include_outer=false);
    *difference() {
      union() {
        rotate_extrude(angle=180, convexity=4) profile(include_outer=true);
        rotate_extrude(convexity=4) profile(include_outer=false);
      }
      s = 300;
      translate([0, -s/2, lid_thickness+.001])
        cube(size=s, center=false);
    }
  }

  if ($preview) {
    translate([0, 0, helmet_min_height_above_ra_bearing + helmet_extra_height_above_dec_skirt + lid_thickness+.1]) {
      rotate([0, 180, 0])
        rotate([0, 0, 90])
          solid_body();
    }
  } else {
    solid_body();
  }
}

// module simple_ra1_base_avoidance(extra_r=extra_ra_motor_clearance) {
//   cylinder(r=ra_motor_clearance_radius_min+extra_r, h=ra1_base_to_dec);
// }
