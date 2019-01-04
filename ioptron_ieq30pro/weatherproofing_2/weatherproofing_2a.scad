// Design #2 for weatherproofing the iEQ30Pro mount.
// Author: James Synge

include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

use <../weatherproofing_1/dec_head_bearing_cover.scad>

include <wp2_dimensions.scad>
use <ra_motor_hat.scad>
use <dec1_hat.scad>
use <helmet_support_at_dec_head.scad>
use <basic_helmet.scad>
use <cw_chin_strap_helmet_support.scad>
use <dec_bearing_rain_plate.scad>

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

if ($preview && false) translate([0, 0, 0]) basic_helmet();

if ($preview)
  decorated_ioptron_mount(ra_angle=ra_angle,
    dec_angle=dec_angle, latitude=lat, show_arrows=show_arrows) {
    union() {
      color("palegreen") ra_motor_hat();
    };
    union() {
      // Moving side of RA bearing.
      #basic_helmet();
      dec1_hat();
      helmet_support_at_dec_head();
      cw_chin_strap_helmet_support();
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

if ($preview && false)
  ra_and_dec(dec_angle=dec_angle) {
    union() {
      // Moving side of RA bearing.
      #basic_helmet();
      dec1_hat();
      helmet_support_at_dec_head();
      cw_chin_strap_helmet_support();
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

if ($preview && false) render() translate([0, 0, 0]) {
  color("red")intersection() {
    dec1_hat();
    helmet_support_at_dec_head();
  };
  color("pink")intersection() {
    dec1_hat();
    basic_helmet();
  };
  color("orange")intersection() {
    dec1_hat();
    cw_chin_strap_helmet_support();
  };
  color("green")intersection() {
    helmet_support_at_dec_head();
    basic_helmet();
  };
  color("blue")intersection() {
    helmet_support_at_dec_head();
    cw_chin_strap_helmet_support();
  };
  color("violet")intersection() {
    basic_helmet();
    cw_chin_strap_helmet_support();
  };
}

*translate([0, 0, 0])
  union() {
    // Moving side of RA bearing.
    basic_helmet();
    dec1_hat();
    helmet_support_at_dec_head();
    cw_chin_strap_helmet_support();
  };
