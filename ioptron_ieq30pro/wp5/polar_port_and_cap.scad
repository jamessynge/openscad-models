// A knob for the polar port, with a recess for a 1" diameter, 1/8" thick
// clear plastic disc, allowing the polar scope to be used even when the knob
// is in place.

// Author: James Synge
// Units: mm

include <../ieq30pro_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/threads.scad>

// Global resolution
$fs = $preview ? 2 : 0.5;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.
//$fn = $preview ? 10 : $fn;

module simple_polar_port_and_cap() {
  h_descend = polar_port_height_max - polar_port_height;
  color(cast_iron_color)
    translate([0, 0, -h_descend])
      cylinder(h=polar_port_height_max, d=polar_port_diam);

  color(plastic_color)
    translate([0, 0, polar_port_height])
      cylinder(h=polar_port_cap_height, d=polar_port_cap_diam);
}

if ($preview) translate([0, 60, 0]) simple_polar_port_and_cap();

module polar_port(h_descend=polar_port_interior_height-polar_port_height, h_above=polar_port_height, thickness=3, cut_threads=true, solid=false, od_extra=0) {
  module threads() {
    t_h = h_total+0.2;
    translate([0, 0, -0.1]) {
      if (cut_threads) {
        metric_thread(diameter=polar_port_cap_thread_od+0.1, pitch=1.5, length=t_h, internal=true);
      } else {
        cylinder(d=polar_port_diam-thickness, h=t_h);
      }
    }
  }
h_total = h_descend + h_above;
//  h_descend = h_total - h_above;
  translate([0, 0, -h_descend]) {
    difference() {
      cylinder(d=polar_port_diam+od_extra, h=h_total);
      if (!solid) {
        threads();
      }
    }
  }
}


if ($preview) translate([0, 0, 50]) polar_port(cut_threads=false);


if ($preview) translate([0, 0, 75]) polar_port(cut_threads=true);



// Partly adapted from https://www.thingiverse.com/thing:2220561
module polar_port_cap(print_threads_down=true, see_through=false) {
  taper_shoulder = print_threads_down;
  taper_disc_lip = !print_threads_down;

  // Section heights:
  H0 = 1;    // Bare shaft before threads.
  H1 = 6;    // Height of threads section.
  H2 = 1.8;  // Bare shaft after threads.
  H3 = 1.75; // Height of shoulder section above the threads.
  H4 = 6.2;  // Height of the grip section above the shoulders (the knob).

  TOTAL_H = H0 + H1 + H2 + H3 + H4;

  shaft_od = polar_port_cap_thread_id;
  shaft_id = shaft_od - 2.5;
  shoulder_diam = 27.9;
  disc_tolerance = 0.1;
  disc_diam = in_to_mm(1) + disc_tolerance;
  disc_h = in_to_mm(1/8);

  knob_r = polar_port_cap_diam / 2;
  cutout_r = 3;
  cutout_xy_r = knob_r + cutout_r * 0.60;

  // Profile to be rotate_extrude'd for the grip section: a rectangle with
  // two adjacent corners cut off at approximately a 45 degree angle.
  module knob_profile() {
    y0 = 0;
    y3 = H4;
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
        knob_profile();
      }
      for (i = [0:number_of_cutouts-1]) {
        x = cutout_xy_r * cos(i * cutout_angle);
        y = cutout_xy_r * sin(i * cutout_angle);
        translate([x, y, -1]) {
          cylinder(r=cutout_r, h=2*H4);
        }
      }
    }
  }

  // Section above the shaft, which stops the knob from screwing in too far.
  // For printing threads down / knob up, this section is tapered to make the
  // overhang printable.
  module shoulder() {
    h = H3 + 0.01;
    if (taper_shoulder) {
      cylinder(d1=shaft_od, d2=shoulder_diam, h=h);
    } else {
      cylinder(d=shoulder_diam, h=h);
    }
  }

  module solid_body() {
    cylinder(d=shaft_od, h=H0 + H1 + H2 + H3 + 0.01);
    translate([0, 0, H0]) {
      metric_thread (diameter=polar_port_cap_thread_od-0.2, pitch=1.5, length=H1, leadin=2, leadfac=1);
      translate([0, 0, H1+H2]) {
        shoulder();
        translate([0, 0, H3]) {
          knob();
        }
      }
    }
  }

  module cut_outs() {
    translate([0, 0, -0.01]) {
      cylinder(d=shaft_id, h=TOTAL_H-2);
    }
    if (see_through) {
      lip_bottom = TOTAL_H - disc_h;
      translate([0, 0, lip_bottom]) {
        cylinder(d=disc_diam, h=disc_h+1, $fn=40);
      }
      if (taper_disc_lip) {
        h = (disc_diam - shaft_id) / 2.5;
        translate([0, 0, lip_bottom - h + 0.01]) {
          cylinder(d1=shaft_id, d2=disc_diam, h=h, $fn=40);
        }
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
    translate([0, 0, TOTAL_H])
      rotate([0, 180, 0])
        body();
  }
}

// Simple utility for demos
module demo_cut_along_x(x=0, reverse=false) {
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

// For now, I'm trying out printing in both directions (i.e. threads down and
// threads up). 
// UPDATE: printing threads down didn't work because the bottom layer was
// a bit wider than desired, so instead of the requested taper of the threads,
// the bottom layer had what appeared to be a sheared off thread. Will try
// adding a conical taper and/or extending the height a little so that there is
// a mm or two of bare shaft before the threads.

if ($preview)
  polar_port_cap(print_threads_down=true, see_through=true);

translate([polar_port_cap_diam, 0, 0]) {
//demo_cut_along_x()
  polar_port_cap(print_threads_down=false, see_through=true);
}

if ($preview)
  translate([-polar_port_cap_diam, 0, 0]) polar_port_cap(print_threads_down=false);
