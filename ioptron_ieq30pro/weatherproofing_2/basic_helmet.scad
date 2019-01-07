// Design #2 for weatherproofing the iEQ30Pro mount, centered on a helmet (aka
// a shape like R2-D2) over the entire moving RA axis, extending over the
// RA motor and half-way over the DEC head.
//
// This file has the basic shell shape (module basic_helmet), but
// as a single piece that couldn't be installed. Another module will slice
// this basic shell shape up and add support for fasteners.

// Author: James Synge

include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

use <dec_bearing_rain_plate.scad>
use <dec_head_bearing_cover.scad>
use <ra_motor_hat.scad>
include <wp2_dimensions.scad>

use <../../utils/cut.scad>
include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/strap.scad>

// Global resolution
$fs = $preview ? 6 : 3;
$fa = $preview ? 6 : 1;

// Default location is parked.
lat = mount_latitude;
ra_angle = 25;//abs($t - 0.5) * 360 - 90;
dec_angle = 58;//  90 + mount_latitude + $t * 360 * 3.14;
show_arrows=false;

dflt_helmet_ir=ra_bcbp_ir;
dflt_helmet_or=ra_bcbp_or;
dflt_dec_port_ir=dec_hoop_interior_radius;
dflt_dec_port_or=dec_hoop_exterior_radius;
dflt_cws_port_d=cw_shaft_diam*2;



if ($preview) {
  decorated_ioptron_mount(ra_angle=ra_angle,
    dec_angle=dec_angle, latitude=lat, show_arrows=show_arrows) {
    union() {
      color("palegreen") ra_motor_hat();
    };
    union() {
      // Moving side of RA bearing.
      basic_helmet();
      *dec1_hat();
      *helmet_support_at_cws();
    };
    union() {
      // RA side of DEC bearing.
      
      #color("red")dec_bearing_rain_plate();
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
      helmet_support_at_cws();
    };
    intersection() {
      basic_helmet();
      dec1_hat();
    };
    intersection() {
      basic_helmet();
      helmet_support_at_cws();
    };
  }

  *translate([400, -400, 0]) basic_helmet();
  *translate([800, -400, 0]) dec_bearing_hoop_profile();
} else {
  basic_helmet();
}

module basic_helmet(helmet_ir=dflt_helmet_ir, helmet_or=dflt_helmet_or, dec_port_ir=dflt_dec_port_ir, dec_port_or=dflt_dec_port_or, cws_port_d=dflt_cws_port_d) {
  color("white") union() {
    difference() {
      ra_and_dec_simple_shell(helmet_ir=helmet_ir, helmet_or=helmet_or, solid=false);
  
      // Remove the volume needed for the DEC head and its clutch.
      dec_bearing_hoop_attachment_in_place(dec_port_ir=dec_port_ir, dec_port_or=dec_port_or, solid=true);
  
      // Leave a hole for the counterweight shaft.
      translate_to_dec_bearing_plane() {
        translate([0, 0, dec1_len + dec2_len])
          linear_extrude(height=50, convexity=3)
            circle(r=cws_port_ir);
      }
    }
  
    // The hole and flange for attaching the dec_bearing_rain_plate(), i.e.
    // the plate that keeps rain from blowing in through the hole in the side
    // of the basic_helmet.
    difference() {
      dec_bearing_hoop_attachment_in_place(dec_port_ir=dec_port_ir, dec_port_or=dec_port_or);
      helmet_interior(helmet_ir=helmet_ir, helmet_or=helmet_or);
    }

    // Tube around the counterweight shaft.
    translate_to_dec_bearing_plane() {
      translate([0, 0, dec2_len+ra1_radius+helmet_ir])
        linear_extrude(height=20, convexity=3)
          annulus(r1=cws_port_ir, r2=cws_port_or);
    }

  }
}

// The interior of the shell (not including dec_bearing_hoop_attachment) for
// purpose of intersection with / subtraction from other objects.
module helmet_interior(helmet_ir=dflt_helmet_ir, helmet_or=dflt_helmet_or, inner_offset=0.0) {
  ra_and_dec_simple_shell(solid=true, shell=false, inner_offset=inner_offset);
}

module basic_helmet_solid() {
  ra_and_dec_simple_shell(solid=true);
}

// The core of the design: a hollow cylinder with a hollow hemi-sphere on top
// of it, a shape like that of the body of R2-D2 or quite a few trash cans.
module ra_and_dec_simple_shell(helmet_ir=dflt_helmet_ir, helmet_or=dflt_helmet_or, solid=false, shell=true, inner_offset=0.0) {
  rotate([0, 0, -90]) {
    beyond_dec = dec1_radius * 0.75;
    above_bearing = ra1_base_to_dec + dec1_radius + beyond_dec;
    cylinder_height = ra_bcbp_ex + above_bearing;
    translate([0, 0, -ra_bcbp_ex]) {
      linear_extrude(height=ra_bcbp_ex, convexity=10) {
        dec_bearing_hoop_profile(
            helmet_ir=helmet_ir, helmet_or=helmet_or, half=false, solid=solid,
            shell=shell, inner_offset=inner_offset, show_cut_rib=false);
      }
      if (shell) {
        // Rib to reinforce bottom of the shell, and allow room for gussets.
        linear_extrude(height=helmet_bottom_rib_height, convexity=10) {
          dec_bearing_hoop_profile(
              helmet_ir=helmet_ir, helmet_or=helmet_ir+helmet_bottom_rib_thickness,
              half=false, solid=solid, shell=shell,
              inner_offset=inner_offset, show_cut_rib=false);
        }
      }
    };
    linear_extrude(height=above_bearing, convexity=10) {
      dec_bearing_hoop_profile(
          helmet_ir=helmet_ir, helmet_or=helmet_or, half=false, solid=solid,
          shell=shell, inner_offset=inner_offset);
    }
    translate([0, 0, above_bearing])
      rotate([90,0,0])
        rotate_extrude(angle=180)
          dec_bearing_hoop_profile(
              helmet_ir=helmet_ir, helmet_or=helmet_or, half=true,
              solid=solid, shell=shell, inner_offset=inner_offset);
  }
}

// This is the cross section through the basic shell, an annulus that will
// just surround the ra_motor_hat with a little bit of room to spare.
module dec_bearing_hoop_profile(helmet_ir=dflt_helmet_ir, helmet_or=dflt_helmet_or, half=false, solid=false, shell=true, inner_offset=0.0, show_cut_rib=true) {
  assert(solid || shell);
  assert(inner_offset >= 0);
  r1 = helmet_ir - inner_offset;
  rib_thickness = 2 * (helmet_or - helmet_ir);
  intersection() {
    union() {
      if (shell) {
        annulus(r1=r1, r2=helmet_or, solid=solid);
        if (show_cut_rib && !solid) {
          mirrored([1, 0, 0]) {
            intersection() {
              h = helmet_or;
              translate([helmet_or-rib_thickness, -h/2, 0])
                square([rib_thickness, h]);
              circle(r=helmet_or);
            }
          }
        }
      } else {
        // Caller didn't want the shell, but instead the volume enclosed by
        // the shell.
        intersection() {
          circle(r=r1);
          if (show_cut_rib) {
            w = 2 * (helmet_or-rib_thickness);
            h = helmet_or*2;
            square([w, h], center=true);
          }
        }
      }
    }
    union() {
      // Don't always need to go below the ~horizontal plane.
      if (half)
        translate([0, -helmet_or, 0])
          square(size=[helmet_or, 2*helmet_or]);
      };
    }
}

module dec_bearing_hoop_attachment_in_place(dec_port_ir=dflt_dec_port_ir, dec_port_or=dflt_dec_port_or, solid=false) {
  translate_to_dec_bearing_plane() {
    rotate([0, 180, 0])
      dec_bearing_hoop_attachment(dec_port_ir=dec_port_ir, dec_port_or=dec_port_or, solid=solid);
  }
}

// Part between helmet and dec_bearing_rain_plate; a part of/permanently
// attached to the helmet, with screw holes for attaching the hoop. Planning
// to use threaded metal inserts that can be glued into the 3D printed plastic.
module dec_bearing_hoop_attachment(dec_port_ir=dflt_dec_port_ir, dec_port_or=dflt_dec_port_or, solid=false) {
  translate([0, 0, -ra1_radius])
    linear_extrude(height=hoop_disc_z+ra1_radius-hoop_disc_wall, convexity=10)
      dec_bearing_hoop_attachment_profile(dec_port_ir=dec_port_ir, dec_port_or=dec_port_or, solid=solid);
}

*translate([-300, 0, 0])
    dec_bearing_hoop_attachment_profile();

module dec_bearing_hoop_attachment_profile(dec_port_ir=dflt_dec_port_ir, dec_port_or=dflt_dec_port_or, solid=false) {
  if (solid) {
    circle(r=dec_port_or);
  } else {
    annulus(r1=dflt_dec_port_ir, r2=dec_port_or);
  }
}
