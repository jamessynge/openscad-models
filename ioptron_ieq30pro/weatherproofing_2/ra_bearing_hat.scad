// xyz
// Author: James Synge

include <wp2_dimensions.scad>
use <ra_motor_hat.scad>

use <../ieq30pro.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

use <../../utils/strap.scad>
use <../../utils/misc.scad>

// Global resolution
$fs = $preview ? 6 : 1;
$fa = $preview ? 6 : 1;



*ra_motor_bearing_hat_profile();
module ra_motor_bearing_hat_profile() {
  difference() {
    offset(r=10) ra_motor_biggest_profile();
    offset(r=5) ra_motor_biggest_profile();
  }
}

color("red")
*translate([0, 0, 100]) ra_motor_biggest_profile();
module ra_motor_biggest_profile() {
  intersection() {
    translate([-ra1_radius, 0, 0])
      ioptron_mount_biggest_ra_projection();
    square(size=100, center=false);
  }
}

color("pink")
translate([0, 0, 200]) ioptron_mount_biggest_ra_projection();
module ioptron_mount_biggest_ra_projection() {
  projection(cut=true)
    base_mount_model_to_cut();
}

*translate([-200, 0, 0]) base_mount_model_to_cut_old();

module base_mount_model_to_cut_old() {
  rotate([0, 90+30, 0])
    ioptron_mount(ra_angle=90+30, latitude=0) {
      ra_motor_hat(solid=true);
    }
}

translate([-0, 0, 0]) base_mount_model_to_cut();

module base_mount_model_to_cut() {
  rotate([27,0,0])
  rotate([0, 90, 0])
  ra_body() {
    ra_motor_hat(solid=true);
  }
}