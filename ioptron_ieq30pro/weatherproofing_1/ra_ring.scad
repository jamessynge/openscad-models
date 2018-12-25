// Ring around the RA axis, providing a structure to which other pieces can
// be attached.
// Author: James Synge

include <wp1_dimensions.scad>
use <../ieq30pro_ra_and_dec.scad>

ra_and_dec() {
  ra_ring_at_dec2();
};

translate([0,0,-50]) {
  ra_ring_at_dec2();
};

module ra_ring_at_dec2() {
  difference() {
      rotate_extrude(angle=180-15)
        ra_ring_profile();
    ra_and_dec();
  }
}

module ra_ring_profile() {
  translate([ra1_radius, 0, 0])
    polygon(points=[
      [0,0],
      [ra_ring_thickness, 0],
      [ra_ring_thickness, ra1_base_to_dec],
      [0, ra1_base_to_dec]
      ]);
}

module dec_motor_cover_strap(expansion_gap=1, gusset_length=strap_gusset_length) {
  narrows_to = dec2_radius + 3;

  difference() {
    union() {
      dmcc_strap_gussets(gusset_length=gusset_length);
      intersection() {
        $fn=100;
        difference() {
          cylinder(r=shell2_outside_x, h=shell2_depth);
          translate([0,0,-1])
            cylinder(r=dec2_radius, h=shell2_depth+2);
        }
        translate([0, 12, 0])
          cylinder(r=shell2_outside_x, h=shell2_depth);
      }
    };

    // Remove the portion that is above the y=-expansion_gap
    // plane, thus allowing for the bolts to be
    // tightened.
    translate([0,-expansion_gap,0])
      rotate([-90,0,0])
        linear_extrude(height=1000, convexity=10)
          square(size=1000, center=true);

    // Remove a bolt on each side for attaching to
    // the dec_motor_cover_cover.
    strap_attachment_nut_slots();
  }
}

module dmcc_strap_gusset(gx=10, gy=10, gusset_length=30) {
  gx = shell2_outside_x - dec2_radius;
  gy = shell2_depth;
  gd = bolt_diam;

  translate([-shell2_outside_x,0,0])
    rotate([90,0,0]) {
      screw_gusset(gx, gy, gusset_length, gd);
    }
}

translate([0, 150, 0]) dmcc_strap_gussets();

module dmcc_strap_gussets(gusset_length=30) {
  dmcc_strap_gusset(gusset_length=gusset_length);
  mirror([1,0,0]) dmcc_strap_gusset(gusset_length=gusset_length);
}