// Units: mm

use <chamfer.scad>
include <ieq30pro-dimensions.scad>
use <ieq30pro-ra-to-dec.scad>
use <ieq30pro-clutch.scad>

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.5;
// Don't generate larger angles than this many degrees.
$fa = 1;

ioptron_mount($t * 360) {};

module ioptron_mount(ra_angle=0, dec_angle=0) {
  rotate([0, 0, ra_angle])
    translate([0, 0, ra_bearing_gap/2]) {
      ra_and_dec(dec_angle) children();
    };

  ra_bearing();
  
  rotate([180, 0, 0])
    ra_body();
}

module ra_body() {
  // To avoid modeling more of the RA body,
  // we extend the ra3 section longer ... for now.
  ra3_extra_long = ra3_len * 4;
  color(cast_iron_color) {
    cylinder(h=ra2_len, r=ra2_radius);
    translate([0, 0, ra2_len])
      cylinder(h=ra3_extra_long, r=ra3_radius);
  }

  // RA motor/electronics cover dimensions, arranged
  // very much like the DEC motor cover.
  // x is perpendicular to the ground and to the
  // RA axis; y is parallel to the RA axis; z is
  // distance from the RA axis.
  x = 95.1;
  y = 68.5;
  z = 49;   // top of cover to intersection
            //with ra2_diam.
  // Height of top of cover above the ra2_diam.
  ra_cover_height = 24.0;
  ra_z_offset = ra2_radius + ra_cover_height - z;
  
  translate([0,0,0])
    rotate([90,0,0])
      color(plastic_color)
        translate([-x/2, 0.01, ra_z_offset])
          intersection() {
            chamferCube(x,y,z,chamferHeight=12,
              chamferX=[0,0,0,1], chamferY=[0,0,0,0],
              chamferZ=[0,0,0,0]);
            chamferCube(x,y,z,chamferHeight=4,
              chamferX=[0,0,1,0], chamferY=[0,1,1,0],
              chamferZ=[0,0,0,0]);
          };
}

// A little decoration for the model, so that the
// two sides of the RA bearing aren't butted up
// against each other in an unrealistic fashion,
// and to match the way the mount actually looks;
// i.e. there is a very small gap between the two
// sides through which we can see silver colored
// metal.
module ra_bearing() {
  h=3;
  color("silver")
    translate([0, 0, -h/2])
      cylinder(h=h, r=ra2_radius-2);
}

