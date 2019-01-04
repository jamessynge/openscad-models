// Design #2 for weatherproofing the iEQ30Pro mount, centered on a helmet (aka
// a shape like R2-D2) over the entire moving RA axis, extending over the
// RA motor and half-way over the DEC head.
//
// This file has the basic shell shape (module basic_helmet), but
// as a single piece that couldn't be installed. Another module will slice
// this basic shell shape up and add support for fasteners.
//
// Also defines module dec_bearing_rain_plate()

// Author: James Synge

include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

include <wp2_dimensions.scad>
use <../weatherproofing_1/dec_head_bearing_cover.scad>

use <../../utils/cut.scad>
include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/strap.scad>

// Global resolution
$fs = $preview ? 6 : 1;
$fa = $preview ? 6 : 1;

// Default location is parked.
lat = mount_latitude;
ra_angle = 90 + $t * 360;
dec_angle = 90 + mount_latitude + $t * 360;
show_arrows=false;


if ($preview) {
  decorated_ioptron_mount(ra_angle=ra_angle,
    dec_angle=dec_angle, latitude=lat, show_arrows=show_arrows) {
    union() {
    };
    union() {
      // Moving side of RA bearing.
    };
    union() {
      // RA side of DEC bearing.
      color("red")dec_bearing_rain_plate();
    };
    union() {
      // DEC head side of DEC bearing.
      color("DeepSkyBlue") dec_head_bearing_cover();
    };
    union() {
      // Saddle plate
    };
  };
} else {
  dec_bearing_rain_plate();
}

module dec_bearing_rain_plate() {
  rotate([0, 0, -(90-mount_latitude)])
  difference() {
    // Outer disc (nearest to saddle plate).
    translate([0,0,-hoop_disc_z]) {
      linear_extrude(height=hoop_disc_wall, convexity=10) {
        difference() {
          annulus(r1=dec2_radius, r2=dec_hoop_exterior_radius);
          translate([-dec2_radius, -dec_hoop_exterior_radius, 0])
            square(size=[dec2_diam, dec_hoop_exterior_radius], center=false);
        };
      }
    };
  }
}