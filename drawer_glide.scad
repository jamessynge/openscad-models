// Drawer glide for a mid-1980s Scandinavian dresser. Original was a strip of
// wood stapled to the inside of the dresser case, but eventually the wood
// split at the staples.
// Author: James Synge
// Units: mm

function in_to_mm(v) = v * 25.4;

// Screw dimensions (length doesn't actually vary these three dims).
// #6 x 1/2" (https://www.boltdepot.com/Product-Details.aspx?product=3953)
// #6 x 5/8" (https://www.boltdepot.com/Product-Details.aspx?product=3953)
screw_diameter = in_to_mm(0.138);  // 3.5052
screw_head_angle = 82;
screw_head_height = in_to_mm(0.083);  // 2.1082

// x-y origin (z-axis) is center of the hole.
module countersunk_through_hole(diam, length, head_angle, head_height, cs_depth) {
  assert(diam > 0);
  assert(length >= 0);
  assert(head_angle > 0);
  assert(head_angle < 180);
  assert(head_height > 0);

  radius = diam/2;
  head_dx = head_height * tan(head_angle / 2);

  x0 = 0;
  x1 = radius * 1.05;
  x2 = radius + head_dx;

  y0 = -1;  // This is a through-hole, so we go below zero to avoid z-fighting.
  y1 = length;
  y2 = y1 + head_height;
  y3 = y2 + cs_depth;

  rotate_extrude() {
    polygon(points=[
      [x0,y0],
      [x1,y0],
      [x1,y1],
      [x2,y2],
      [x2,y3],
      [x0,y3],
    ]);
  }
}

module num6_countersunk_through_hole(depth) {
  length = 2.5;
  cs_depth = depth - length - screw_head_height + 1;
  countersunk_through_hole(screw_diameter, length, screw_head_angle, screw_head_height, cs_depth);
}

dflt_glide_length = in_to_mm(14.5);

module glide(glide_length=dflt_glide_length, glide_width=12, glide_depth=5, num_screws=4, first_screw_setback=10, last_screw_setback=15) {
  assert(num_screws >= 2);

  module glide_profile() {
    tip = glide_width*0.75;
    translate([tip/2, 0, 0])
    hull() {
      circle(d=tip);
      translate([glide_width, 0, 0])
        circle(d=glide_width);

      translate([glide_length - glide_width/2 - tip/2, 0, 0]) {
        square(size=glide_width, center=true);
      }
    }
  }

  screw_spacing = (glide_length - first_screw_setback - last_screw_setback) / (num_screws - 1);

  // Rotated to fit across the bed of the Lulzbot Taz 6.
  rotate([0, 0, 45]) {
    difference() {
      linear_extrude(height=glide_depth) glide_profile();
      for (i = [0:num_screws-1]) {
        x = first_screw_setback + i * screw_spacing;
        translate([x, 0, 0]) num6_countersunk_through_hole(depth=glide_depth);
      }

      text_x1 = first_screw_setback + screw_spacing/2;
      translate([text_x1, 0, glide_depth - 0.3]) {
        linear_extrude(height=1, convexity=10) {
          text(text=str("fss=", first_screw_setback), halign="center", valign="center", size=8);
        }
      }

      text_x2 = glide_length - last_screw_setback - screw_spacing/2;
      translate([text_x2, 0, glide_depth - 0.3]) {
        linear_extrude(height=1, convexity=10) {
          text(text=str("lss=", last_screw_setback), halign="center", valign="center", size=8);
        }
      }
    }
  }
}

glide(num_screws=8, first_screw_setback=20, last_screw_setback=20);

if ($preview)
translate([14, -8, 0])
import("orig_4_screw_drawer_glide.stl");

