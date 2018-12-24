include <wp1_dimensions.scad>

// Ring around the DEC head (the part rotated by the DEC axis, contains the
// saddle plate). Only approximately the right shape because the DEC head
// module is only approximately correct.

Can be applied by hand using Sugru or similar moldable
// plastic.
module dec_head_bearing_cover() {
  translate([0,0,dec_head_base_height]) {
    cylinder(h=10, r1=dec_cover_max_radius, r2=dec_head_base_diam/2);
  }
}
