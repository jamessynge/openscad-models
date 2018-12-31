// Models the non-moving portion of the RA axis of the iEQ30 Pro, along with
// the plastic enclosing the motor and electronics, and the polar scope cap
// at the bottom of the axis (the top being where the moving portion of
// the RA axis attaches).
// Author: James Synge
// Units: mm

// ra_core accepts up to ??? children:
//
//

// Units: mm

include <ieq30pro_dimensions.scad>
use <four_star_knob.scad>
use <../utils/axis_arrows.scad>
use <../utils/chamfer.scad>

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = $preview ? 3 : 1;
// Don't generate larger angles than this many degrees.
$fa = $preview ? 3 : 1;

decorated_ra_body();

module decorated_ra_body(show_arrows=true) {
  ra_body() {
    color("gold") {
      if (show_arrows) axis_arrows(total_length=ra1_radius*4);
      if ($children > 0) children(0);
    }
  }
}

module ra_body() {
  // To avoid modeling more of the RA body,
  // we extend the ra3 section longer ... for now.
  color(cast_iron_color) {
    cylinder(h=ra2_len, r=ra2_radius);
    translate([0, 0, ra2_len]) {
      cylinder(h=ra3_len, r=ra3_radius);
      translate([-ra4_width/2, 0, 0])
        cube([ra4_width, ra_motor_z_offset, ra4_len]);
      translate([0, 0, ra3_len]) {
        intersection() {
          cylinder(h=ra4_len, d=ra4_diam);
          translate([-ra4_width/2, -ra4_width, 0])
            cube([ra4_width, ra4_width, ra4_len]);
        }
        translate([-ra4_width/2, 0, 0])
          cube([ra4_width, ra_motor_z_offset, ra4_len]);

        translate([0, 0, ra4_len]) {
          cylinder(h=ra5_len, d=ra5_diam);
        }
      }
    }
  }

  translate([0,0,ra2_len+ra3_len+ra4_len+ra5_len]) polar_scope();

  translate([0, ra_motor_z_offset, ra_motor_setback])
    ra_motor_and_electronics();

  if ($children > 0) {
    children();
  }
}

// A little decoration for the model, so that the
// two sides of the RA bearing aren't butted up
// against each other in an unrealistic fashion,
// and to match the way the mount actually looks;
// i.e. there is a very small gap between the two
// sides through which we can see silver colored
// metal.
module ra_bearing() {
  h=ra_bearing_gap+1;
  color(bearing_color)
    translate([0, 0, -h/2])
      cylinder(h=h, r=ra2_radius-2);
}

module ra_motor_and_electronics() {
  ra_motor_h1 = 96;
  ra_motor_profile1_wb = 65.1;

  color(plastic_color) {
    ra_motor_and_upper_electronics();
    ra_lower_electronics();
  }
}

module ra_motor_and_upper_electronics() {
  ra_motor();
  ra_electronics();
}

module ra_motor() {
  h1 = 96;
  d1 = 5;
  h2 = h1 - 2*d1;
  d2 = 18 + d1;
  h3 = h1 - 2 * d2;

  // Place the motor's base (part nearest the RA axis) onto the z=0 plane,
  // with the motor rising above that plane.
  ra_motor_profile1_wb = 65.1;

  translate([-h1/2,0,0])
  rotate([0, 90,0])
  translate([-ra_motor_profile1_wb,0,0])
  intersection() {
    union() {
      hull() {
        linear_extrude(height=h1) ra_motor_profile1();
        translate([0,0,d1]) 
          linear_extrude(height=h2) ra_motor_profile2();
        translate([0,0,d2]) 
          linear_extrude(height=h3) ra_motor_profile3();
      }
      ra_motor_bump();
    };

    // The chamfer produced by offset() isn't quite what is desired at the back
    // of the motor, so intersect with a big cube to cut off a bit better.
    ra_motor_profile1_hl = 42.15;  // ra_motor_profile1.hl
    translate([-5, ra_motor_profile1_hl, 0])
      rotate([0, 0, -45])
        translate([0, -50, 0])
          cube([100, 100, 100], center=false);
  }
}

module ra_motor_bump() {
  z = 5;
  w1 = 21.75;
  w2 = w1 - 2 * z;
  h1 = 42.15;  // ra_motor_profile1.hl
  h2 = h1 - 2 * z;

  sw = w2 / w1;
  sh = h2 / h1;

//  rotate([0,0,-2])
  rotate([0, -90, -0.5])
  translate([w1/2+z+44.5, h1/2 + 1, z-0.1])
  linear_extrude(height=z, scale=[sw, sh])
    square(size=[w1, h1], center=true);
}

*color("red") translate([0, 0, 0]) ra_motor_profile1();
module ra_motor_profile1() {
  wb = 65.1;
  wm = 64.6;
  wt = 30;

  wdiff = wb - wm;
  wdhalf = wdiff / 2;

  hr = 30;
  hm = 41.6;
  hl = 42.15;

  x1 = 0;
  x2 = x1 + wdhalf * 1.5;
  x3 = x2 + wt;
  x4 = wb - wdhalf;
  x5 = wb;

  polygon([
    [x1,0],
    [x5,0],
    [x4,hr],
    [x3,hm],
    [x2,hl],
    [x1,0],
    ]);
}

*color("blue") translate([0, 0, -5]) ra_motor_profile2();
module ra_motor_profile2() {
  wb = 65.1;
  intersection() {
    offset(delta=5, chamfer=true) ra_motor_profile1();
    // scale([1.5, 1.5, 1.5]) ra_motor_profile1();
    translate([wb, 0, 0])
    scale([1.5, 1.5, 1.5]) translate([-wb,0,0]) ra_motor_profile1();
  }
}

*translate([0, 0, -24.3]) ra_motor_profile3();
module ra_motor_profile3() {
  wb = 65.1;
  wm = 64.3;
  wt = 50.1;

  wdiff = wb - wm;
  wdhalf = wdiff / 2;

  hr = 33.5;
  hm = 46.3;
  hl = 46.5;

  x1 = 0;
  x2 = x1 + wdhalf * 1.5;
  x3 = x2 + wt;
  x4 = wb - wdhalf;
  x5 = wb;

  polygon([
    [x1,0],
    [x5,0],
    [x4,hr],
    [x3,hm],
    [x2,hl],
    [x1,0],
    ]);
}

module ra_electronics() {
  w = 81.75;
  h = 53.25;  // From original origin of ra_motor_profile1().
  r = 2.15;

  ra_motor_profile1_wb = 65.1;

  translate([0, 0, ra_motor_profile1_wb+h/2-2]) {
    translate([0,0,0]) {
      rotate([-90, 0, 0]) {
        z = 13.9;
        linear_extrude(height=z, scale=0.999) {
          $fs=1;
          offset(r=r) square([w, h], center=true);
        }
        // An approximation of the switch just so that we don't form-fit some
        // weatherproofing over it.
        sw = 15;
        sh = 8.9;
        sz = 2.75;
        translate([(w + r)/2 - sw -2,
          -(h + r) / 2 + sh, z]) {
          cube([sw, sh, sz], center=false);
        }
      }
    }
  }
}

module polar_scope() {
  color(polar_scope_color) {
    cylinder(d=ps1_diam, h=ps1_len);

    translate([0, 0, ps1_len]) {
      cylinder(d=ps2_diam, h=ps2_len);

      translate([0, 0, ps2_len]) {
        cylinder(d1=ps3_od, d2=ps3_id, h=ps3_len);

        translate([0, 0, ps3_len]) {
          cylinder(d=ps4_diam, h=ps4_len);

          translate([0, 0, ps4_len]) {
            cylinder(d1=ps5_od, d2=ps5_id, h=ps5_len);
          }
        }
      }
    }
  }
}

module ra_lower_electronics() {
  z = 13;
  z2 = 5;

  translate([0, -z, 0]) {
    rotate([-90, 0, 0]) {
      linear_extrude(height=z) ra_lower_electronics_profile();
      translate([0, 0, -z2]) {
        s = 0.8;
        linear_extrude(height=z2, scale=[1/s, 1])
          scale([s, 1])
            ra_lower_electronics_profile();
      }
    }
  }
}

module  ra_lower_electronics_profile() {
  intersection() {
    projection() {
      rotate([90, 0, 0]) ra_motor_and_upper_electronics();
    }
    w = 100;
    h = 100;
    translate([-w/2, -h - ra2_len, 0])
      square([w, h], center=false);
  }
}