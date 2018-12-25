// Models the essential aspects of the iOptron iEQ30 Pro
// mount w.r.t. designing weatherproofing for the
// RA and DEC bearings.
//
// 
// Module ioptron_mount() REQUIRES four children.
// The first is rendered on the plane of the
// RA bearing, with z>0 being towards the fixed
// base of the mount (i.e. where the motor is)
// and with y>0 being towards the RA motor.
// The remaining 3 children are passed to the
// to module ra_and_dec().
// See ieq30pro-ra-to-dec.scad for details on
// the coordinates for those children.

// Units: mm

use <../utils/chamfer.scad>
include <ieq30pro_dimensions.scad>
use <ieq30pro_ra_and_dec.scad>
use <../utils/axis_arrows.scad>

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.5;
// Don't generate larger angles than this many degrees.
$fa = 1;

ioptron_mount($t * 360, $t * 360) {
  color("gold") {
    echo("executing ioptron_mount child 1");
    translate([ra1_radius*2,ra1_radius,10])
      linear_extrude(height=20) square(size=10);
    axis_arrows(total_length=ra1_radius*2);
  };    

  color("blue") {
    echo("executing ioptron_mount child 2");
    linear_extrude(height=4) {
      difference() {
        circle(r=ra1_radius + 10);
        circle(r=ra1_radius + 5);
      };
      translate([ra1_radius+10,0,0])
        square(size=10, center=true);
    };
    axis_arrows(total_length=ra1_radius*1.5);
  };
  
  color("yellow") {
    echo("executing ioptron_mount child 3");
    r = dec_head_base_diam/2;
    linear_extrude(height=4) {
      difference() {
        circle(r=r + 10);
        circle(r=r + 5);
      };
      translate([r+10,0,0])
        square(size=10, center=true);
    };
    axis_arrows(total_length=r*1.5);
  };

  color("red") {
    echo("executing ioptron_mount child 4");
    r = dec_head_base_diam/2;
    linear_extrude(height=4) {
      difference() {
        circle(r=r + 10);
        circle(r=r + 5);
      };
      translate([r+10,0,0])
        square(size=10, center=true);
    };
    axis_arrows(total_length=r*1.5);
  };

  color("green") {
    echo("executing ioptron_mount child 5");
    r = dec_head_base_diam/2;
    translate([20,10,10]) sphere(r=10);
    axis_arrows(total_length=r);
  };
};

module ioptron_mount(ra_angle=0, dec_angle=0) {
  echo("ioptron_mount has", $children, "children");
  assert($children == 5);

  rotate([0, 0, ra_angle]) {
    translate([0, 0, ra_bearing_gap/2]) {
      ra_and_dec(dec_angle) {
        children(1);
        children(2);
        children(3);
        children(4);
      };
    };
  };

  ra_bearing();
  
  rotate([180, 0, 0]) {
    translate([0, 0, ra_bearing_gap/2]) {
      ra_body();
      rotate([0,0,180])
        children(0);
    };
  };
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
  h=ra_bearing_gap+1;
  color(bearing_color)
    translate([0, 0, -h/2])
      cylinder(h=h, r=ra2_radius-2);
}

