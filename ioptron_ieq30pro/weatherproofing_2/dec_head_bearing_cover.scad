// Ring around the DEC head, as a gutter with the purpose of keeping
// water out of the DEC bearing if the water lands on the DEC head.
// Author: James Synge

// Only approximately the right shape because the DEC head is a bit hard to
// model, so the ieq30pro_dec_head.scad file is only approximately correct.
// Can be made by hand using Sugru or similar moldable plastic.

include <wp2_dimensions.scad>
use <../ieq30pro_dec_head.scad>

// Global resolution
$fs = $preview ? 3 : 1;
$fa = $preview ? 3 : 1;

dec_head_bearing_cover();

if ($preview) translate([200, 0, 0]) {
  dec_head_bearing_cover_basic();
  dec_head();
};

module dec_head_bearing_cover() {
  difference() {
    dec_head_bearing_cover_basic();
    dec_head();
  }
}

module dec_head_bearing_cover_basic() {
  inner_x = dec_head_diam2 / 2;
  outer_x = dec_cover_max_radius;
  w = outer_x - inner_x;
  gap_frac = 0.12;  // Room for the clutch.
  x_scale = 2;
  offset_from_bearing_plane = dec_head_base_height / 3;


  intersection() {
    translate([0, 0, offset_from_bearing_plane]) {
      rotate([0, 0, 360*(gap_frac / 2)]) {
        rotate_extrude(angle=360 * (1-gap_frac)) {
          translate([inner_x, 0, 0]) {
            scale([x_scale, 1, 0]) {
              intersection() {
                square(size=w, center=false);
                circle(w);
              };
            }
          }
        }
      }
    }

    // Cut of the part near the DEC clutch at an angle so that water won't
    // flow back towards the bearing easily.
    cs = max(dec_head_base_radius*4, dec_head_height*3);
    translate([inner_x, 0, 0]) {
      rotate([0, 25, 0]) {
        translate([- cs/2, 0, 0]) {
          cube(size=cs, center=true);
        }
      }
    }
  }
}
