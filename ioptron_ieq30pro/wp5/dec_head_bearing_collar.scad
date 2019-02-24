// Collar around the DEC head, as a gutter with the purpose of keeping
// water out of the DEC bearing if the water lands on the DEC head.
// Includes two slots for AWG #12 wires, with the plan to experiment with
// a DIY slip ring for powering the cameras.
// Author: James Synge
// Units: mm

// Only approximately the right shape because the DEC head is a bit hard to
// model, so the ieq30pro_dec_head.scad file is only approximately correct.
// However, my trial print of the earlier dec_head_bearing_cover.scad were
// successful (a good fit).

include <wp5_dimensions.scad>
use <../ieq30pro_dec_head.scad>
use <../../utils/misc.scad>

// Global resolution
$fs = $preview ? 4 : 2;
$fa = $preview ? 3 : 3;

dec_head_bearing_collar();

if ($preview) {
  *translate([200, 0, 0]) {
    dec_head_bearing_collar();
    dec_head();
  }
}

module dec_head_bearing_collar() {
  // Coords are at or below X axis.

  x0 = dec_head_diam2 / 2;
  x1 = dec_head_base_radius + 0.02; // To avoid z-fighting.
  x3 = 135/2; // dec_cover_max_radius;

  y0 = 0;
  y1 = -(dec_head_base_height + 0.01); // To avoid z-fighting.
  y2 = -clutch_base_height * 2/3;

  x2 = x3 - abs(y2)/2;

  // Radial offsets of the two wire slots.
  w1 = dec_head_base_radius + (x3 - x1) / 3;
  w2 = dec_head_base_radius + (x3 - x1) * 2 / 3;

  module basic_profile() {
    polygon([
      [x0, y1],
      [x1, y1],
      [x1, y0],
      [x3, y0],
      [x2, y2],
      [x0, y2],
    ]);
  }

  module awg12_wire_slot() {
    //$fs=0.1;
    official_diam = 2.06;
    diam = 2.1;
    bd = diam/5;

    difference() {
      union() {
        translate([-diam/2, -diam])
          square([diam, diam+0.1]);
    
        translate([0, -diam, 0]) {
          circle(d=diam, $fs=0.2);
        }
      }
      // Need little bump-outs to hold the wire in the slot.
      mirrored([1, 0, 0])
        translate([-diam/2, -diam*0.6, 0])
          rotate([0, 0, 45])
            square(size=bd, center=true);
    }
  }

  module awg12_wire_slot_access(r, a) {
    $fs=0.2;
    y = sin(a) * r;
    x = cos(a) * -r;
    h = abs(y2) * 3;
    translate([x, y, 0]) {
      // Add a tilt so that both holes are in the flat part of the collar.
      rotate([0, -15, 0]) {
        symmetric_z_cylinder(d=3, l=h);
      }
    }    
  }

  module full_profile() {
    difference() {
      basic_profile();
      translate([w1, 0, 0]) awg12_wire_slot();
      translate([w2, 0, 0]) awg12_wire_slot();
    }
  }

  module bevel_cutter() {
    // Cut of the part near the DEC clutch at an angle so that water won't
    // flow back towards the bearing easily.
    cs = max(dec_head_base_radius*4, dec_head_height*3);
    translate([x0, 0, 0]) {
      rotate([0, 25, 0]) {
        translate([- cs/2, 0, 0]) {
          cube(size=cs, center=true);
        }
      }
    }
  }

  module extrude_collar(angle=360) {
    rotate_extrude(angle=angle, convexity=10) {
      full_profile();
    }
  }

  module full_collar() {
    gap_frac = 0.12;  // Room for the clutch.
//    re_angle = 360 * (1-gap_frac);
    gap_angle = dec_clutch_angle * 3/2;
    re_angle = 360 - gap_angle;
    difference() {
      rotate([0, 0, gap_angle/2])
        extrude_collar(angle=re_angle);

      // Bevel it to encourage water that has dripped onto the outer surface
      // to flow to the edge that is further from the DEC bearing.
      s = 300;
      translate([s/2+x2, 0, 0])
        rotate([0, -25, 0])
          cube(size=s, center=true);

      // Cut a couple of holes for accessing the wire slots.
      awg12_wire_slot_access(w1, 5);
      awg12_wire_slot_access(w2, -5);

    }
  }

  if ($preview) {
    color("grey") difference() {
      rotate([180, 0, 0])
        full_collar();
      dec_head();
    }
  } else {
    translate([0, 0, -y2])
      full_collar();
  }
}
