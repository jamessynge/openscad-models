// Design #2 for weatherproofing the iEQ30Pro mount, centered on a helmet (aka
// a shape like R2-D2) over the entire moving RA axis, extending over the
// RA motor and half-way over the DEC head.
//
// This file has the basic shell shape (module ra_and_dec_basic_shell), but
// as a single piece that couldn't be installed. Another module will slice
// this basic shell shape up and add support for fasteners.
//
// Also defines module dec_bearing_outer_hoop()

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


translate([0, 0, 0])
  ra_and_dec_basic_shell();


if ($preview && false)
  decorated_ioptron_mount(ra_angle=ra_angle,
    dec_angle=dec_angle, latitude=lat, show_arrows=show_arrows) {
    union() {
      color("palegreen") ra_motor_hat();
    };
    union() {
      // Moving side of RA bearing.
      #ra_and_dec_basic_shell();
      *dec1_hat();
      *dec_chin_strap();
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

// Find intersections.
*color("red")translate([300, 0, 0]) {
  intersection() {
    dec1_hat();
    dec_chin_strap();
  };
  intersection() {
    ra_and_dec_basic_shell();
    dec1_hat();
  };
  intersection() {
    ra_and_dec_basic_shell();
    dec_chin_strap();
  };
}

module ra_and_dec_basic_shell() {
  color("white") union() {
    difference() {
      ra_and_dec_simple_shell(solid=false);
  
      // Remove the volume needed for the DEC head and its clutch.
      dec_bearing_hoop_attachment_in_place(solid=true);
  
      // Leave a hole for the counterweight shaft.
      translate_to_dec_bearing_plane() {
        translate([0, 0, dec1_len + dec2_len])
          linear_extrude(height=50, convexity=3)
            circle(d=cw_shaft_diam*2, center=true);
      }
    }
  
    // The hole and flange for attaching the dec_bearing_outer_hoop(), i.e.
    // the plate that keeps rain from blowing in through the hole in the side
    // of the ra_and_dec_basic_shell.
    difference() {
      dec_bearing_hoop_attachment_in_place();
      helmet_interior();
    }
  }
}

// The interior of the shell (not including dec_bearing_hoop_attachment) for
// purpose of intersection with / subtraction from other objects.
module helmet_interior() {
  ra_and_dec_simple_shell(solid=true, shell=false);
}

// The core of the design: a hollow cylinder with a hollow hemi-sphere on top
// of it, a shape like that of the body of R2-D2 or quite a few trash cans.
module ra_and_dec_simple_shell(solid=false, shell=true) {
  beyond_dec = dec1_radius * 0.75;
  above_bearing = ra1_base_to_dec + dec1_radius + beyond_dec;
  translate([0, 0, -ra_bcbp_ex]) {
    linear_extrude(height=ra_bcbp_ex+above_bearing, convexity=10) {
      intersection() {
        dec_bearing_hoop_profile(solid=solid, shell=shell);

        // Need to avoid colliding with the DEC clutch when it rotates.
        // This first attempt is a bit too much.
        *translate([0, -ra_bcbp_or, 0])
          square(size=[2*ra_bcbp_or, ra_bcbp_or + ra_to_dec_bearing_plane]);
      }
    }
  };

  translate([0, 0, above_bearing])
    rotate([90,0,0])
      rotate_extrude(angle=180)
        dec_bearing_hoop_profile(half=true, solid=solid, shell=shell);
}

// This is the cross section through the basic shell, an annulus that will
// just surround the ra_motor_hat with a little bit of room to spare.
module dec_bearing_hoop_profile(half=false, solid=false, shell=true) {
  assert(solid || shell);
  intersection() {
    union() {
      if (shell) {
        annulus(r1=ra_bcbp_ir, r2=ra_bcbp_or, solid=solid);
      } else {
        // Caller didn't want the shell, but instead the volume enclosed by
        // the shell.
        circle(r=ra_bcbp_ir);
      }
    }
    union() {
      // Don't always need to go below the ~horizontal plane.
      if (half)
        translate([0, -ra_bcbp_or, 0])
          square(size=[ra_bcbp_or, 2*ra_bcbp_or]);
      };
    }
}

module dec_bearing_hoop_attachment_in_place(solid=false) {
  translate_to_dec_bearing_plane() {
    rotate([0, 180, 0])
      rotate([0, 0, mount_latitude])
        translate([0,0,0])
          dec_bearing_hoop_attachment(solid=solid);
  }
}

// Part between helmet and dec_bearing_outer_hoop; a part of/permanently
// attached to the helmet, with screw holes for attaching the hoop. Planning
// to use threaded metal inserts that can be glued into the 3D printed plastic.
module dec_bearing_hoop_attachment(solid=false) {
  translate([0, 0, -ra1_radius])
    linear_extrude(height=hoop_disc_z+ra1_radius-hoop_disc_wall, convexity=10)
      dec_bearing_hoop_attachment_profile(solid=solid);
}

*translate([-300, 0, 0])
    dec_bearing_hoop_attachment_profile();

module dec_bearing_hoop_attachment_profile(solid=false) {
  if (solid) {
    circle(r=dec_hoop_exterior_radius);
  } else {
    annulus(r1=dec_hoop_interior_radius, r2=dec_hoop_exterior_radius);
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