// Adds ribs and other such to the basic helmet.
// Author: James Synge

include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../ieq30pro_ra_core.scad>

include <wp2_dimensions.scad>

use <dec_bearing_rain_plate.scad>
use <dec_head_bearing_cover.scad>
use <ra_motor_hat.scad>
use <basic_helmet.scad>

use <../../utils/cut.scad>
include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/strap.scad>
use <../../utils/paired_bosses.scad>

// Global resolution
$fs = $preview ? 6 : 1;
$fa = $preview ? 6 : 1;

// Default location is parked.
lat = 90; //mount_latitude;
ra_angle = 25;//abs($t - 0.5) * 360 - 90;
dec_angle = 58;//  90 + mount_latitude + $t * 360 * 3.14;
show_arrows=false;


// Copied from basic_helmet
dflt_helmet_ir=ra_bcbp_ir;
dflt_helmet_or=ra_bcbp_or;
dflt_dec_port_ir=dec_hoop_interior_radius;
dflt_dec_port_or=dec_hoop_exterior_radius;
dflt_cws_port_d=cw_shaft_diam*2;

rtp_diam = rtp_boss_diam;
rtp_height = rtp_boss_height;


distance = 40 * (cos($t*360) + 1);



if (!$preview) {
  scale(0.5) {
    *translate([distance, 0, 0]) color("orange")
      half_helmet_nut_side();
    translate([-distance, 0, 0]) color("palegreen")
      half_helmet_screw_side();
  }
} else if (true) {
  rotate([0, 0, $t * 360]) {
    translate([distance, 0, 0]) //color("orange")
      half_helmet(nut_side=true);
    translate([-distance, 0, 0]) color("palegreen")
      half_helmet(nut_side=false);
  }

  *rotate([0, -90, 0]) basic_helmet_slice(solid=true);

  *translate([3, 0, 0]) rotate([0, -90, 0]) thinner_basic_helmet_slice(solid=true);

  *translate([distance, 500, 0]) color("orange")
    basic_helmet_nut_side();
  *translate([-distance, 500, 0]) color("palegreen")
    basic_helmet_screw_side();

} else if (true) {
  scale(1) {
    translate([distance, 0, 0]) color("orange")
      half_helmet(nut_side=true);
    translate([-distance, 0, 0]) color("palegreen")
      half_helmet(nut_side=false);
  }

  //translate([300, 0, 0]) helmet_interior();

  *translate([0, -400, 0]) color("white") {
    half_helmet(nut_side=true);
    half_helmet(nut_side=false);
  }
} else {
  decorated_ioptron_mount(ra_angle=ra_angle,
    dec_angle=dec_angle, latitude=lat, show_arrows=show_arrows) {
    union() {
      color("palegreen") ra_motor_hat();
    };
    union() {
      // Moving side of RA bearing.
      color("white") half_helmet(nut_side=true);
      *color("white") half_helmet(nut_side=false);
      *dec1_hat();
      *helmet_support_at_cws();
    };
    union() {
      // RA side of DEC bearing.
      
      *color("red")dec_bearing_rain_plate();
    };
    union() {
      // DEC head side of DEC bearing.
      *color("DeepSkyBlue") dec_head_bearing_cover();
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
}

module half_helmet_nut_side() {
  half_helmet(nut_side=true);
}

module half_helmet_screw_side() {
  half_helmet(nut_side=false);
}

module half_helmet(nut_side=true) {
  difference() {
    if (nut_side) {
      basic_helmet_nut_side();
    } else {
      basic_helmet_screw_side();
    }
    bosses(solid=true, nut_side=nut_side);
  }
  bosses(solid=false, nut_side=nut_side);
}

module basic_helmet_nut_side() {
  half_basic_helmet(nut_side=true);

  intersection() {
    difference() {
      half_basic_helmet(nut_side=false);

      rotate([0, -90, 0]) {
        linear_extrude(height=200, convexity=4)
          thinner_basic_helmet_slice(solid=true);
      }

      
    }
    union() {
      s = 400;
      dz = ra_bcbp_ex - helmet_bottom_rib_height;
      translate([-s/2, 0, s/2 - dz]) cube(size=s, center=true);
    }

    union() {
      overhang = 9;
      s=400;
      translate([-overhang, -s/2, -s/2])
        cube(size=s, center=false);
    }
  }
}

module basic_helmet_screw_side() {
  intersection() {
    half_basic_helmet(nut_side=false);

    rotate([0, -90, 0]) {
      linear_extrude(height=200, convexity=4)
        thinner_basic_helmet_slice(solid=true);
    }
  }
}

module half_basic_helmet(nut_side=true, helmet_ir=dflt_helmet_ir, helmet_or=dflt_helmet_or, dec_port_ir=dflt_dec_port_ir, dec_port_or=dflt_dec_port_or, cws_port_ir=dflt_cws_port_ir, cws_port_or=dflt_cws_port_or) {
  intersection() {
    basic_helmet(helmet_ir=helmet_ir, helmet_or=helmet_or, dec_port_ir=dec_port_ir, dec_port_or=dec_port_or, cws_port_ir=cws_port_ir, cws_port_or=cws_port_or);
    // Cut to be just the upper or lower half (i.e. nut side or screw side).
    s = 350;
    translate([(nut_side ? 1 : -1) * s/2, 0, s/4]) {
      cube(size=s, center=true);
    }
  }
}


module bosses(solid=false, nut_side=true) {
  // At the bottom of the cut on the CW shaft side of the helmet.
  bosses_below_cw_port(solid=solid, nut_side=nut_side);
  // Below and above the counterweight port.
  bosses_around_cw_port(
      solid=solid, nut_side=nut_side, do_intersect=!solid,
      z=ra1_base_to_dec_center-(dflt_cws_port_d+rtp_diam)/2 - 3,
      angle=15);
  bosses_around_cw_port(
      solid=solid, nut_side=nut_side, do_intersect=!solid,
      z=ra1_base_to_dec_center+(dflt_cws_port_d+rtp_diam)/2 + 3,
      angle=15);
  // At the top.
  bosses_around_hemisphere(
      solid=solid, nut_side=nut_side, do_intersect=!solid, hemi_angle=0, angle=15);
  // Near DEC port, and opposite side.
  mirrored([0, 1, 0])
    bosses_around_hemisphere(
        solid=solid, nut_side=nut_side, do_intersect=!solid, hemi_angle=-45, angle=15);
}

// Boss at the bottom rim, below the CW shaft port.
module bosses_below_cw_port(solid=false, nut_side=true, do_intersect=false) {
  nut_slot_angle=90;
  boss_height=35;
  r1=dflt_helmet_ir;
  r2=dflt_helmet_or;
  // 30mm from screw head to center of nut, so a 40mm screw will work.
  nut_depth=15;
  screw_head_depth=15;
  screw_extension=15;
  screw_head_recess=38;

  intersection() {
    translate([0, -(r1+rtp_diam/2), -ra_bcbp_ex+rtp_diam/2]) {
      rotate([0, 90, 0]) {
        matching_rect_m4_slotted_bosses(
            nut_side=nut_side, nut_slot_angle=nut_slot_angle,
            nut_depth=nut_depth, screw_extension=screw_extension, boss_height=boss_height,
            screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess,
            solid=solid);
      }
    }
    if (do_intersect) {
     basic_helmet_solid();
    }
  }
}

module bosses_around_cw_port(solid=false, nut_side=true, do_intersect=false, angle=0, z=undef) {
  r1=dflt_helmet_ir;
  r2=dflt_helmet_or;
  nut_depth=15;
  screw_extension=20;
  screw_head_depth=20;
  screw_head_recess=50;
  h = m4_nut_diam2;

  intersection() {
    translate([0, -r1+h*1.25, z]) {
      rotate([0, 90, 0]) {
       matching_rtp_m4_recessed_bosses(
            d=rtp_diam, h=h,
            nut_side=nut_side, angle=angle,
            nut_depth=nut_depth,
            screw_head_depth=screw_head_depth,
            screw_head_recess=screw_head_recess,
            solid=solid);
      }
    }
    if (do_intersect) {
     basic_helmet_solid();
    }
  }
}


module bosses_around_hemisphere(solid=false, nut_side=true, do_intersect=false, hemi_angle=undef, angle=0) {
  r1=dflt_helmet_ir;
  r2=dflt_helmet_or;
  nut_depth=15;
  screw_extension=20;
  screw_head_depth=20;
  screw_head_recess=50;
  h = m4_nut_diam2 * 1.25;

  // COPIED from basic_helmet:
  beyond_dec = dec1_radius * 0.75;
  above_bearing = ra1_base_to_dec + dec1_radius + beyond_dec;


  intersection() {
    translate([0, 0, above_bearing]) {
      rotate([hemi_angle, 0, 0])
      translate([0, 0, dflt_helmet_ir-10]) {
        rotate([270, 0, 0]) {
          rotate([0, 90, 0]) {
            matching_rtp_m4_recessed_bosses(
                d=rtp_diam, h=h,
                nut_side=nut_side, angle=angle,
                nut_depth=nut_depth,
                screw_head_depth=screw_head_depth,
                screw_head_recess=screw_head_recess,
                solid=solid);
          }
        }
      }
    }
    if (do_intersect) {
     basic_helmet_solid();
    }
  }
}






module matching_rtp_m4_recessed_bosses(nut_side=undef, d=rtp_diam, h=rtp_height, nut_depth=undef, angle=0, screw_head_depth=undef, screw_head_recess=undef, solid=false) {
  matching_m4_recessed_bosses(
      solid=solid, show_nut_boss=nut_side, show_screw_boss=!nut_side,
      nut_depth=nut_depth, screw_head_depth=screw_head_depth,
      screw_head_recess=screw_head_recess) {
    round_top_pyramid(d, h, angle=angle);
  }
}

module matching_rtp_m4_slotted_bosses(nut_side=undef, h=rtp_height, angle=0, nut_slot_angle=undef, nut_depth=undef, screw_extension=undef, boss_height=undef, screw_head_depth=undef, screw_head_recess=undef, solid=false) {
  matching_m4_slotted_bosses(
      solid=solid, show_nut_boss=nut_side, show_screw_boss=!nut_side,
      nut_slot_angle=nut_slot_angle, nut_depth=nut_depth,
      screw_extension=screw_extension,
      boss_height=boss_height,
      screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess) {
    round_top_pyramid(diam=rtp_diam, height=h, angle=angle);
  }
}

module matching_circular_m4_slotted_bosses(nut_side=undef, d=rtp_diam, angle=0, nut_slot_angle=undef, nut_depth=undef, screw_extension=undef, boss_height=undef, screw_head_depth=undef, screw_head_recess=undef, solid=false) {
  matching_m4_slotted_bosses(
      solid=solid, show_nut_boss=nut_side, show_screw_boss=!nut_side,
      nut_slot_angle=nut_slot_angle, nut_depth=nut_depth,
      screw_extension=screw_extension,
      boss_height=boss_height,
      screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess) {
    circle(d=d);
  }
}

module matching_rect_m4_slotted_bosses(nut_side=undef, w=rtp_diam, h=rtp_diam, nut_slot_angle=undef, nut_depth=undef, screw_extension=undef, boss_height=undef, screw_head_depth=undef, screw_head_recess=undef, solid=false) {
  matching_m4_slotted_bosses(
      solid=solid, show_nut_boss=nut_side, show_screw_boss=!nut_side,
      nut_slot_angle=nut_slot_angle, nut_depth=nut_depth,
      screw_extension=screw_extension,
      boss_height=boss_height,
      screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess) {
    square(size=[w, h], center=true);
  }
}












