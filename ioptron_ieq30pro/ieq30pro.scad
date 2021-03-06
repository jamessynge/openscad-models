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
use <ieq30pro_ra_core.scad>
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
  echo("decorated_ioptron_mount ra_angle: ", ra_angle);
  ioptron_mount(ra_angle=ra_angle, dec_angle=dec_angle, latitude=latitude) {
    union() {
      if (show_arrows) color("gold") axis_arrows(total_length=ra1_radius*2);
      if ($children > 0) children(0);
    };

    union() {
      if (show_arrows) color("blue") axis_arrows(total_length=ra1_radius*1.9);
      if ($children > 1) children(1);
    };
    
    union() {
      if (show_arrows) color("yellow") axis_arrows(total_length=dec_head_base_diam*0.75);
      if ($children > 2) children(2);
    };

    union() {
      if (show_arrows) color("red") axis_arrows(total_length=dec_head_base_diam*0.75);
      if ($children > 3) children(3);
    };

    union() {
      if (show_arrows) color("green") axis_arrows(total_length=dec_head_base_diam/2);
      if ($children > 4) children(4);
    };
  };
}

module ioptron_mount(ra_angle=0, dec_angle=0, latitude=20) {
  if ($children > 5) {
    echo("ioptron_mount has", $children, "children, too many");
    assert($children <= 5);
  }

  echo("ioptron_mount ra_angle: ", ra_angle);

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
        rotate([0, 0, 180]) {
          ra_body() {
             union() if ($children > 0) children(0);
          }
        }
      };
    };
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

