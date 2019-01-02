// Design #2 for weatherproofing the iEQ30Pro mount.
// Defines modules dec_chin_strap and dec1_hat, which grip the moving side
// of the RA axis.

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
use <ra_and_dec_basic_shell.scad>
use <wp_utils.scad>

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
show_arrows=true;



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
    cw_chin_strap_helmet_support();




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

if ($preview) {
  ra_and_dec();
  dec1_hat();
  cw_chin_strap_helmet_support();
}
dec_chin_strap();




module dec_chin_strap() {
  color("MediumAquamarine") {
    difference() {
      intersection() {
        union() {
          dec_chin_core();
        }
        helmet_interior(inner_offset=0.1);
      }
      ra_and_dec(include_cw_shaft=false);
      dec1_hat_nut_slots(show_gusset=false);
      dec1_hat_nut_slots(show_gusset=true,gusset_z=100);
    }
    dec1_hat_nut_slots(show_gusset=true,gusset_z=30);
  }
}


module dec_chin_core() {
  linear_extrude(height=ra1_base_to_dec_center, convexity=3)
    dec_chin_strap_helmet_support_profile();
  linear_extrude(height=helmet_supports_height_above_ra_bearing, convexity=3) {
    difference() {
      dec_chin_strap_helmet_support_profile();
      square([dec2_diam+1, 2*(ra1_radius+dec2_len+1)], center=true);
    }
  }
}

*translate([200, 0,0]) dec_chin_strap_profile();

module dec_chin_strap_profile() {
  x = ra1_diam;
  y = ra1_radius+dec2_len;
  difference() {
    intersection() {
      translate([0, y/2])
        square([x, y], center=true);
      dec_trim_strap_dec_axis_extent();
    }
    circle(r=ra1_radius);
  }
}

module dec_chin_strap_helmet_support_profile() {
  intersection() {
    annulus(r1=ra1_radius, r2=ra_bcbp_ir);
    dec_trim_strap_dec_axis_extent();
  }
}

module dec_trim_strap_dec_axis_extent() {
  limit_w = 2 * ra_bcbp_ir;
  limit_h = ra1_radius+dec2_len-1;
  y_offset = 20;
  h = limit_h - y_offset;
  translate([0, h/2 + y_offset])
    square([limit_w, h], center=true);
}
