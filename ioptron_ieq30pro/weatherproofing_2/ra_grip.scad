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



if ($preview && false)
translate([200, 200, 0])
decorated_ioptron_mount(ra_angle=ra_angle,
  dec_angle=dec_angle, latitude=lat, show_arrows=show_arrows) {
  union() {
    color("palegreen") ra_motor_hat();
  };
  union() {
    // // Moving side of RA bearing.
    // difference() {
    //   color("white")ra_basic_helmet(solid=false);
    //   // Remove the volume needed for the DEC head and its clutch.

    //   dec_clutch_void();

    // }

    // difference() {
    //   translate_to_dec_bearing_plane() {
    //     rotate([0, 180, 0])
    //       rotate([0, 0, mount_latitude])
    //         translate([0,0,0])
    //           color("white")dec_bearing_hoop_attachment();
    //   }
    //   ra_basic_helmet(solid=true);
    // }

    dec_chin_strap();
    dec1_hat();




//    cw_chin_strap();

  };
  union() {
    // RA side of DEC bearing.
    // color("red")dec_bearing_outer_hoop();
  };
  union() {
    // DEC head side of DEC bearing.
    color("DeepSkyBlue") dec_head_bearing_cover();
  };
  union() {
    // Saddle plate
  };
};

if ($preview) dec1_hat();
dec_chin_strap();

module dec_chin_strap() {

  difference() {
    linear_extrude(height=ra1_base_to_dec_center, convexity=3)
      dec_chin_strap_profile();
    ra_and_dec(include_cw_shaft=false);
    dec1_hat_nut_slot_near_clutch(show_gusset=false);
    mirror([1, 0, 0]) dec1_hat_nut_slot_near_clutch(show_gusset=false);
  }

  dec1_hat_nut_slot_near_clutch(show_gusset=true);
  mirror([1, 0, 0]) dec1_hat_nut_slot_near_clutch(show_gusset=true);
}

*translate([200, 0,0]) dec_chin_strap_profile();

module dec_chin_strap_profile() {
    x = ra1_diam;
    y = ra1_radius+dec2_len;
  difference() {
    translate([0, y/2]) square([x, y], center=true);
    circle(r=ra1_radius);
    square([ra1_diam+1, 40], center=true);
  }
}


// module cw_chin_strap() {
//   // The first profile is in the plane of the RA bearing.
//   linear_extrude(height=ra1_base_to_dec, convexity=3)
//     cw_chin_strap_profile1();

//   // // The second is parallel to the plane of the DEC bearing, but is at the
//   // // counterweight end of the DEC body.


//   // #
//   // rotate([90, 0, 0])
//   // cw_chin_strap_profile2();

// }


// *translate([200, 0,0])
//   cw_chin_strap_profile1();

// module cw_chin_strap_profile1() {
//     x = ra1_diam;
//     y = dec1_len - ra1_radius;
//   difference() {
//     translate([0, -y/2]) square([x, y], center=true);
//     circle(r=ra1_radius);
//     square([ra1_diam+1, 40], center=true);
//   }
// }

// *translate([0, 200, 0])
//   cw_chin_strap_profile2();

// // Goes around dec1 at counterweight end, and has side parts that
// // extend to dec_chin_strap.
// module cw_chin_strap_profile2() {
//   id = dec1_radius+2;
//   od = id + 5;
//   difference() {
//       union() {
//         translate([0, ra1_base_to_dec_center, 0])
//           circle(r=od);
//         cw_chin_strap_lower_quarter_fillet();
//         mirror([1, 0, 0])
//           cw_chin_strap_lower_quarter_fillet();
//       }

//     translate([0, ra1_base_to_dec_center, 0])
//       circle(r=id);
//   }
// }

// module cw_chin_strap_lower_quarter_fillet() {
//   r = ra_to_dec_fillet_radius;
//   translate([ra1_radius, ra1_base_to_dec + r, 0]) {
//     intersection() {
//       circle(r=r-2, center=true);
//       translate([-r, -r, 0]) square(size=r, center=false);
//     }

//     r2 = r / 2;
//     translate([r2-r+7, r2, 0])
//     difference() {
//       translate([-r2, -r2, 0]) square(size=r2, center=false);
//       circle(r=r2, center=true);

//     }
//   }
// }
