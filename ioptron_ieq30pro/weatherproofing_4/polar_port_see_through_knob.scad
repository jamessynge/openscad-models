// A knob for the polar port, with a recess for a 1" diameter, 1/8" thick
// clear plastic disc, allowing the polar scope to be used even when the knob
// is in place.

// Author: James Synge
// Units: mm

include <../ieq30pro_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/threads.scad>

// Global resolution
$fs = $preview ? 10 : 1;
$fa = $preview ? 10 : 1;
$fn = $preview ? 100 : $fn;

// Partly adapted from https://www.thingiverse.com/thing:2220561
module polar_port_see_through_knob(print_threads_down=true) {
  taper_port_lip = print_threads_down;
  taper_disc_lip = !print_threads_down;

  total_h = 15;
  h0 = 6; // Height of threads section.
  h1 = 7.9; // Height of knob section above shaft, which is above the threads.
  h2 = 6.1; // Height of the grip section of the knob.

  shaft_od = 23;
  shaft_id = 20;
  port_lip_diam = 27.9;
  disc_diam = in_to_mm(1);
  disc_h = in_to_mm(1/8);

  knob_r = polar_port_cap_diam / 2;
  cutout_r = 3;
  cutout_xy_r = knob_r + cutout_r * 0.60;

  // Profile to be rotate_extrude'd for the grip section.
  module top_profile() {
    y0 = 0;
    y3 = h2;
    y1 = y3 / 5;
    y2 = y3 - y1;
    x0 = 0;
    x2 = knob_r;
    x1 = x2 - y1;
    polygon([[x0, y0], [x1, y0], [x2, y1], [x2, y2], [x1, y3], [x0, y3]]);
  }

  module knob() {
    // To be equally spaced around the top of the knob's perimeter.
    number_of_cutouts = 12;
    cutout_angle = 360 / number_of_cutouts;
    difference() {
      rotate_extrude() {
        top_profile();
      }
      for (i = [0:number_of_cutouts-1]) {
        x = cutout_xy_r * cos(i * cutout_angle);
        y = cutout_xy_r * sin(i * cutout_angle);
        translate([x, y, -1]) {
          cylinder(r=cutout_r, h=2*h2);
        }
      }
    }
  }

  // Section above the shaft, which stops the knob from screwing in too far.
  // For printing threads down / knob up, it helps to taper this section.
  module port_lip() {
    h = h1 - h2 + 0.01;
    if (taper_port_lip) {
      cylinder(d1=shaft_od, d2=port_lip_diam, h=h);
    } else {
      cylinder(d=port_lip_diam, h=h);
    }
  }

  module solid_body() {
    metric_thread (diameter=24.7, pitch=1.5, length=6, leadin=2);
    cylinder(d=shaft_od, h=total_h);
    translate([0, 0, total_h - h1]) {
      port_lip();
    }
    translate([0, 0, total_h - h2]) {
      knob();
    }
  }

  module cut_outs() {
    translate([0, 0, -0.01]) {
      cylinder(d=shaft_id, h=total_h*2);
    }
    lip_bottom = total_h - disc_h;
    translate([0, 0, lip_bottom]) {
      cylinder(d=disc_diam+1, h=disc_h+1, $fn=40);
    }
    if (taper_disc_lip) {
      h = (disc_diam - shaft_id) / 2.5;
      translate([0, 0, lip_bottom - h + 0.01]) {
        cylinder(d1=shaft_id, d2=disc_diam+1, h=h, $fn=40);
      }
    }
  }

  module body() {
    difference() {
      solid_body();
      cut_outs();
    }
  }

  if (print_threads_down) {
    body();
  } else {
    translate([0, 0, total_h])
      rotate([0, 180, 0])
        body();
  }
}

// For now, I'm trying out printing in both directions (i.e. threads down and
// threads up). 

polar_port_see_through_knob(print_threads_down=true);

translate([40, 0, 1]) polar_port_see_through_knob(print_threads_down=false);

// if ($preview) {
//   $fn = 100;
//   rotate([0, 180, 0]) {
//     intersection() {
//       union() {
//         translate([0, 0, 1]) polar_port_see_through_knob();
//         translate([40, 0, 1]) polar_port_see_through_knob(taper_disc_lip=true);
//       }
//       s = 150;
//       translate([0, s/2, 0]) cube(size=s, center=true);
//     }
//   }
// } else {
//   rotate([0, 180, 0]) 
//         translate([0, 0, 1]) polar_port_see_through_knob();
//         translate([40, 0, 1]) polar_port_see_through_knob(taper_disc_lip=true);
// }
