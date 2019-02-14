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
      color("palegreen") simple_helmet_core();
      color("skyblue") simple_lid();
    }
  }
} else {
  simple_helmet_core();

  translate([400, 0, 0]) simple_lid();
}

////////////////////////////////////////////////////////////////////////////////
helmet_ir = ra_motor_clearance_radius_max + extra_ra_motor_clearance;
helmet_or = helmet_ir + ra_motor_skirt_thickness;
rim_or = helmet_ir + ra_motor_skirt_rim;






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

  // The outer is optional so that we can slide the screw side (not glued to
  // to the lid) into place without needing to move down and then up.
  module profile(include_outer=true) {
    square([lid_or, lid_thickness]);
    if (include_outer) {
      translate([lid_or - lid_thickness, 0, 0]) grip_profile();
    }
    translate([lid_or - lid_thickness - helmet_thickness, 0, 0])
      mirror([1, 0, 0])
        grip_profile();
  }

  module solid_body() {
    rotate_extrude(angle=180, convexity=4) profile(include_outer=true);
    alignment_gap = 4; // degrees
    rotate([0, 0, 90 + alignment_gap / 2])
    rotate_extrude(angle=360 - alignment_gap, convexity=4)
      profile(include_outer=false);

    rotate_extrude(convexity=4) profile(include_outer=false);
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
