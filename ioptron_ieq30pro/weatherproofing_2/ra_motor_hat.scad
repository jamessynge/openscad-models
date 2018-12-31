// Model for weatherproofing the RA motor and electronics, with a focus on
// providing a rain shield that the RA bearing cover can mate with: not
// touching, but rather surrounding when in the parked position.
// Author: James Synge

include <wp2_dimensions.scad>

include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

use <../../utils/cut.scad>
use <../../utils/misc.scad>
use <../../utils/strap.scad>

// Global resolution
$fs = $preview ? 6 : 1;
$fa = $preview ? 6 : 1;

ra_body();
ra_motor_hat();

module ra_motor_hat(solid=false) {
  plate();
  translate([0, ra_motor_z_offset, ra_motor_collar_z0])
    ra_me_shell_1(40, solid=solid);
}

module plate() {
  r = ra_motor_collar_radius;
  z0 = ra_motor_collar_z0;
  z1 = ra_motor_collar_z1;
  e = z1 - z0;

  translate([0, 0, z0])
    linear_extrude(height=e)
     intersection() {
      circle(r=r);
      union () {
        y = 25;
        translate([-r, y, 0]) square([r*2, r - y], center=false);

        translate([r/2, 0, 0]) square([r/2, r],center=false);
        translate([-r, 0, 0]) square([r/2, r],center=false);
      }
    }
}





module ra_me_shell_1_trimmed(el, solid=false) {
  intersection() {
    ra_me_shell_1(el, solid=solid);

    *translate([-ra_motor_w-10, 0, 0])
      rotate([0, 45, 0])
      translate([-100, 0, 0])
      rotate([45, 0, 0])
      cube(size=200, center=false);


    union () {
      w = ra_motor_w+14;
      h = 100;
      z = 100;
      r = 15;

        difference() {
          cube([w, 150, 150], center=true);
          *translate([(w)/2-5, (100)/2-3, 0])
            sphere(r=r);

          ch = 60;
          
          translate([-w/2, ra_cover_height*2, 5])
          rotate([0, 0, -50])
          rotate([90,0, 0])
          translate([0, 0, -ch/2])
          cylinder(r=r, h=ch);

          translate([w/2, ra_cover_height*2, 5])
          rotate([0, 0, 50])
          rotate([90,0, 0])
          translate([0, 0, -ch/2])
          cylinder(r=r, h=ch);
        }
    }
  }
}

module ra_me_shell_1(el, solid=false) {
  linear_extrude(height=el, convexity=3) ra_me_shell_profile_1(solid=solid);
}


*translate([200, 0, 0]) ra_me_shell_profile_1();
module ra_me_shell_profile_1(solid=false) {
  difference() {
    offset(r=7) ra_me_profile_1();
    if (!solid) offset(r=2) ra_me_profile_1();
  }
}

*translate([400, 0, 0]) ra_me_profile_1();
module ra_me_profile_1() {
  cut_at_z(ra2_len + ra3_len) {
    ra_motor_and_electronics();
  }
}



// ra_motor_and_electronics();

//translate([200, 0, 0])

// translate([-200, 0, 0])
// projection(cut=false)
//   rotate([0, 90, 0])
//     ra_motor_and_electronics();

