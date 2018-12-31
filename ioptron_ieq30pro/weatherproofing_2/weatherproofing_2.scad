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

use <../../utils/cut.scad>
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




decorated_ioptron_mount(ra_angle=ra_angle,
  dec_angle=dec_angle, latitude=lat, show_arrows=show_arrows) {
  union() {
    color("palegreen") ra_motor_hat();
  };
  union() {
    // Moving side of RA bearing.
    difference() {
      color("white")ra_basic_helmet(solid=false);
      // Remove the volume needed for the DEC head and its clutch.

      dec_clutch_void();

    }

    difference() {
      translate_to_dec_bearing_plane() {
        rotate([0, 180, 0])
          rotate([0, 0, mount_latitude])
            translate([0,0,0])
              color("white")dec_bearing_hoop_attachment();
      }
      ra_basic_helmet(solid=true);
    }


    // translate([0, ra1_radius + dec2_len + dec_bearing_gap +, ra1_base_to_dec + dec1_radius])
      // rotate([90, 90, 0])
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

module ra_basic_helmet(solid=false) {
  beyond_dec = dec1_radius * 0.75;
  above_bearing = ra1_base_to_dec + dec1_radius + beyond_dec;
  translate([0, 0, -ra_bcbp_ex]) {
    linear_extrude(height=ra_bcbp_ex+above_bearing, convexity=10) {
      intersection() {
        dec_bearing_hoop_profile(solid=solid);

        // Need to avoid colliding with the DEC clutch when it rotates.
        // This first attempt is a bit too much.
        *translate([0, -ra_bcbp_or, 0])
          square(size=[2*ra_bcbp_or, ra_bcbp_or + ra_to_dec_bearing_plane]);
      }
    }
  };

  translate([0, 0, above_bearing])
    rotate([90,0,0])
      rotate_extrude(angle=90+mount_latitude)
        dec_bearing_hoop_profile(solid=solid);
}



module dec_bearing_hoop_profile(solid=false) {
  intersection() {
    annulus(r1=ra_bcbp_ir, r2=ra_bcbp_or, solid=solid);
    // Don't need to go below the ~horizontal plane.
    translate([0, -ra_bcbp_or, 0])
      square(size=[ra_bcbp_or, 2*ra_bcbp_or]);
    };
}


module dec_clutch_void(minimal=true) {
  z = hoop_disc_z; 
  // Move from RA bearing to DEC bearing.
  translate([0, ra1_radius + dec2_len + dec_bearing_gap, ra1_base_to_dec + dec1_radius])
    rotate([-90, 0, 0]) {
      linear_extrude(height=z, convexity=10)
        circle(r=dec_clutch_handle_max_height);
    }
}

module dec_bearing_outer_hoop() {
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



// Part between helmet and dec_bearing_outer_hoop; a part of/permanently
// attached to the helpment, with screw holes for attaching the hoop. Planning
// to use threaded metal inserts that can be glued into the 3D printed plastic.
module dec_bearing_hoop_attachment() {
  translate([0, 0, -ra1_radius])
    linear_extrude(height=hoop_disc_z+ra1_radius-hoop_disc_wall, convexity=10)
      dec_bearing_hoop_attachment_profile();
}


*translate([-300, 0, 0])
    dec_bearing_hoop_attachment_profile();



module dec_bearing_hoop_attachment_profile() {
  difference() {
    annulus(r1=dec_hoop_interior_radius, r2=dec_hoop_exterior_radius);
    translate([0, -dec_hoop_exterior_radius, 0])
      square(size=dec_hoop_exterior_radius, center=false);
    rotate([0, 0, -(90-mount_latitude)])
      translate([0, -dec_hoop_exterior_radius, 0])
        square(size=dec_hoop_exterior_radius, center=false);

    // TODO fix this adjustment to match the way the helment is handled
    // (i.e. a latitude adjustment).
    translate([0, -dec_hoop_exterior_radius + 25, 0])
      square(size=dec_hoop_exterior_radius, center=false);

  }
}
