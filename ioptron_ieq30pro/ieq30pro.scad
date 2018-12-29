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
$fs = $preview ? 3 : 1;
// Don't generate larger angles than this many degrees.
$fa = $preview ? 3 : 1;

// Default location is parked.
lat = mount_latitude;
ra_angle = 90 + $t * 360;
dec_angle = 180 - lat + $t * 360;

decorated_ioptron_mount(ra_angle=ra_angle,
  dec_angle=dec_angle, latitude=lat, show_arrows=true);

module decorated_ioptron_mount(ra_angle=0, dec_angle=0, latitude=20, show_arrows=true) {
  ioptron_mount(ra_angle=ra_angle, dec_angle=dec_angle, latitude=latitude) {
    color("gold") {
      if (show_arrows) axis_arrows(total_length=ra1_radius*2);
      if ($children > 0) children(0);
    };

    color("blue") {
      if (show_arrows) axis_arrows(total_length=ra1_radius*1.9);
      if ($children > 1) children(1);
    };
    
    color("yellow") {
      if (show_arrows) axis_arrows(total_length=dec_head_base_diam*0.75);
      if ($children > 2) children(2);
    };

    color("red") {
      if (show_arrows) axis_arrows(total_length=dec_head_base_diam*0.75);
      if ($children > 3) children(3);
    };

    color("green") {
      if (show_arrows) axis_arrows(total_length=dec_head_base_diam/2);
      if ($children > 4) children(4);
    };
  };
}

module ioptron_mount(ra_angle=0, dec_angle=0, latitude=20) {
  if ($children > 5) {
    echo("ioptron_mount has", $children, "children, too many");
    assert($children <= 5);
  }

  rotate([90-latitude,0,0]) {
    rotate([0, 0, ra_angle]) {
      translate([0, 0, ra_bearing_gap/2]) {
        ra_and_dec(dec_angle) {
          union() if ($children > 1) children(1);
          union() if ($children > 2) children(2);
          union() if ($children > 3) children(3);
          union() if ($children > 4) children(4);
        };
      };
    };
  
    ra_bearing();
    
    rotate([180, 0, 0]) {
      translate([0, 0, ra_bearing_gap/2]) {
        ra_body();
        rotate([0,0,180])
          union() if ($children > 0) children(0);
      };
    };
  }
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
  x = ra_motor_w;
  y = ra_motor_h;
  z = ra_motor_z;   // top of cover to intersection
            //with ra2_diam.
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

