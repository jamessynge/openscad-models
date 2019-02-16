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

if ($preview) {
  ioptron_mount(latitude=mount_latitude,ra_angle=ra_angle, dec_angle=dec_angle) {
    union() {}
    //cut_along_y(reverse=true)
    union() {
      #color("palegreen") simple_helmet_core();
      color("skyblue") simple_lid();


//translate([0,200, 0])
      color("green") simple_cw_port(nut_side=true);
      color("red") simple_cw_port(nut_side=false);

    }
  }
} else {
  *simple_helmet_core();

  translate([400, 0, 0]) simple_lid();
}

////////////////////////////////////////////////////////////////////////////////
helmet_ir = ra_motor_clearance_radius_max + extra_ra_motor_clearance;
helmet_or = helmet_ir + ra_motor_skirt_thickness;
rim_or = helmet_ir + ra_motor_skirt_rim;

// Size of the notch in the helmet for an alignment tab in the lid.
lid_tab_slot_degrees = 4; // degrees




module simple_helmet_core() {
  // The basic can, minus the space needed for the DEC head.
  module basic_can() {
    difference() {
      simple_ra_motor_skirt();
      hull() simple_dec_head_skirt();
    }
  }
  // The DEC head covering.
  module dec_head_covering() {
    difference() {
      simple_dec_head_skirt();
      simple_helmet_interior_avoidance();
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
        translate([0, y-2, z])
          sphere(r=2);
        dhc_part();
      }
      hull() dec_head_covering();
      simple_helmet_interior_avoidance();
    }
  }

  basic_can();
  dec_head_covering();
  dec_head_covering_print_support();
}







module simple_helmet_interior_avoidance(extra_ir=extra_ra_motor_clearance) {
  z = ra_motor_skirt_max_z + ra_bearing_gap;
  ir = ra_motor_clearance_radius_max + extra_ir;
  translate([0, 0, -z - 0.1]) {
    cylinder(h=400, r=ir);
  }
}

module simple_ra_motor_skirt(extra_ir=extra_ra_motor_clearance, thickness=ra_motor_skirt_thickness, rim=ra_motor_skirt_rim) {
  z = ra_motor_skirt_max_z + ra_bearing_gap;
  ir = ra_motor_clearance_radius_max + extra_ir;
  skirt_or = ir + thickness;
  rim_or = ir + rim;
  translate([0, 0, -z]) {
    difference() {
      z2 = z + helmet_min_height_above_ra_bearing + helmet_extra_height_above_dec_skirt;
      union() {
        cylinder(h=z2 , r=skirt_or);
        cylinder(h=rim, r=rim_or);
      }
      simple_helmet_interior_avoidance(extra_ir=extra_ir);
      // translate([0, 0, -0.1])
        // cylinder(h=z2+0.2, r=ir);
    }
  }
}

module simple_dec_head_skirt() {

  module profile() {
    s = ra1_radius + dec_bearing_gap + dec_bearing_gap + dec_head_height;
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

  translate_to_dec_head_base()
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


// Goals:
// * Printable, which means that there can't be horizontal overhangs.
// * Add a raised lip at the outside edge so that water will tend to flow
//   back towards the helmet and then down rather than into the opening.
// * Eventually add a collar to be clipped onto the CW shaft that surrounds
//   the port, so that most water doesn't even make it to the port.
module simple_cw_port(nut_side=true) {
  length = 30;  // Just for the extrusion, will probably be cut down.
  thickness = dec_head_thickness;
  inside = 30;
  outside = inside + thickness * 2;

  module profile() {
    
    difference() {
      square(size=outside, center=true);
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
     rotate([0, 0, -135])
       translate([0, sqrt(halfsq + halfsq) - 0*thickness/2, 0])
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

  translate_to_dec12_plane() {

  translate([0, 0, -ra1_radius - helmet_ir]) {
      rotate([0, 0, 0]) {
        gusset();
        linear_extrude(height=length, convexity=4) {
          if (nut_side) {
            nut_side_profile();
          } else {
            screw_side_profile();
          }
        }
      }
    }
  }
}
// Goals:
// * Printable, which means that there can't be horizontal overhangs.
// * Add a raised lip at the outside edge so that water will tend to flow
//   back towards the helmet and then down rather than into the opening.
// * Eventually add a collar to be clipped onto the CW shaft that surrounds
//   the port, so that most water doesn't even make it to the port.
module simple_cw_port_old() {
  length = 50;  // Just for the extrusion, will probably be cut down.
  exterior_scale = 1.25;
  exterior_radius = 15;
  rim_size = 3;
  interior_radius = 10;
  interior_scale = 1.25;

  // Profile for the hollow inside of the port, which will have a tear drop
  // shape, i.e. the top will be above the basic circle's cumference to
  // allow the top to be printed (i.e. not a serious overhang).
  module teardrop_profile(r=undef, top_slope=30) {
    assert(r != undef);
    assert(top_slope > 10);
    assert(top_slope < 60);

    hull() {
      circle(r=r);
      hypotenuse = r / sin(90 - top_slope);
      translate([0, hypotenuse - 0.001, 0])
        circle(r=0.001);
    }
  }

  module rim() {
    far_d = (exterior_radius * 2) * exterior_scale;
    d = far_d + rim_size;


    cz = length-rim_size;
    cy = d/2 - exterior_radius;//d - exterior_radius * 2;


//     = rim_size + exterior_radius * (exterior_scale - 1);

    
    translate([0, cy, cz])
      cylinder(d=d, h=max(rim_size, 1));
  }


  module exterior() {
    translate([0, -exterior_radius, 0])
      hull() {
        linear_extrude(height=length, convexity=4, scale=exterior_scale)
          translate([0, exterior_radius, 0])
            circle(r=exterior_radius);
        linear_extrude(height=length, convexity=4)
          translate([0, exterior_radius, 0])
            teardrop_profile(r=exterior_radius);
        translate([0, -length/2, 0])
          sphere(r=exterior_radius/20);
        // Rim at outer edge

      };
    rim();
  }

  module interior() {
    r=interior_radius;
    translate([0, r+2, -1])
      linear_extrude(height=length+2, convexity=8, scale=interior_scale)
        translate([0, -r, 0])
        teardrop_profile(r=r);
  }

  difference() {
    exterior();
    interior();
  }
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

module cut_along_y(y=0, reverse=false) {
  if (reverse) {
    intersection() {
      union() { children(); }
      s = 300;
      translate([-s/2, y, -s/3])
        cube(size=s, center=false);
    }
  } else {
    difference() {
      union() { children(); }
      s = 300;
      translate([-s/2, y, -s/3])
        cube(size=s, center=false);
    }
  }
}

// module simple_ra1_base_avoidance(extra_r=extra_ra_motor_clearance) {
//   cylinder(r=ra_motor_clearance_radius_min+extra_r, h=ra1_base_to_dec);
// }
