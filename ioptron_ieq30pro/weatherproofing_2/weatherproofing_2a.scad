// Design #2 for weatherproofing the iEQ30Pro mount.
// Author: James Synge

include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

include <wp2_dimensions.scad>
use <../weatherproofing_1/dec_head_bearing_cover.scad>
use <ra_motor_hat.scad>
use <dec1_hat.scad>
use <ra_grip.scad>
use <ra_and_dec_basic_shell.scad>

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


*translate([0, 0, 0])
  ra_and_dec_basic_shell();


if ($preview)
  decorated_ioptron_mount(ra_angle=ra_angle,
    dec_angle=dec_angle, latitude=lat, show_arrows=show_arrows) {
    union() {
      color("palegreen") ra_motor_hat();
    };
    union() {
      // Moving side of RA bearing.
      ra_and_dec_basic_shell();
      dec1_hat();
      dec_chin_strap();
    };
    union() {
      // RA side of DEC bearing.
      color("red")dec_bearing_outer_hoop();
    };
    union() {
      // DEC head side of DEC bearing.
      color("DeepSkyBlue") dec_head_bearing_cover();
    };
    union() {
      // Saddle plate
    };
  };

*translate([300, 0, 0])
  intersection() {
    // Moving side of RA bearing.
    ra_and_dec_basic_shell();
    dec1_hat();
    dec_chin_strap();
  };

