

use <../../utils/misc.scad>
use <../../utils/paired_bosses.scad>
include <../../utils/metric_dimensions.scad>

include <../ieq30pro_dimensions.scad>
use <../ieq30pro_ra_and_dec.scad>

include <wp5_dimensions.scad>
use <dict.scad>
use <helpers.scad>



rtp_diam = rtp_boss_diam;
rtp_height = rtp_boss_height;

cws_port_d = GetInnerDiam(cw_shaft_port_dims);

distance = 20;
translate([distance, 0, 0])
bosses();
translate([-distance, 0, 0])
bosses(nut_side=false);


module bosses(solid=false, nut_side=true, on_lid=false) {
  // At the bottom of the cut on the CW shaft side of the helmet.
  bosses_below_cw_port(solid=solid, nut_side=nut_side);
  // Below and above the counterweight port.
  bosses_around_cw_port(
      solid=solid, nut_side=nut_side,
      z=ra1_base_to_dec_center-(cws_port_d+rtp_diam)/2 - 3,
      angle=15);
  bosses_around_cw_port(
      solid=solid, nut_side=nut_side,
      z=ra1_base_to_dec_center+(cws_port_d+rtp_diam)/2 + 3,
      angle=15);
  // At the top.
  bosses_around_hemisphere(
      solid=solid, nut_side=nut_side, hemi_angle=0, angle=15);
  // Near DEC port, and opposite side.
  mirrored([0, 1, 0])
    bosses_around_hemisphere(
        solid=solid, nut_side=nut_side, hemi_angle=-45, angle=15);
}

// Boss at the bottom rim, below the CW shaft port.
module bosses_at_bottom_rim(solid=false, nut_side=true) {
  nut_slot_angle=90;
  boss_height=35;
  r1=helmet_ir;
  r2=helmet_or;
  // 30mm from screw head to center of nut, so a 40mm screw will work.
  nut_depth=15;
  screw_head_depth=15;
  screw_extension=15;
  screw_head_recess=38;

  intersection() {
    translate([0, -(r1+rtp_diam/2), -can_height_below_ra1_base+rtp_diam/2]) {
      rotate([0, 90, 0]) {
        matching_rect_m4_slotted_bosses(
            nut_side=nut_side, nut_slot_angle=nut_slot_angle,
            nut_depth=nut_depth, screw_extension=screw_extension, boss_height=boss_height,
            screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess,
            solid=solid);
      }
    }
  }
}


// Boss at the top, just below the lid.
module bosses_below_lid(solid=false, nut_side=true) {
  nut_slot_angle=160;
  boss_height=35;
  r1=helmet_ir;
  r2=helmet_or;
  // 30mm from screw head to center of nut, so a 40mm screw will work.
  nut_depth=15;
  screw_head_depth=15;
  screw_extension=15;
  screw_head_recess=38;

  intersection() {
    translate([0, -(r2 - rtrt_boss_diam*0.75), can_height_above_ra1_base - rtrt_boss_diam-2-lid_grip_height]) {
      rotate([0, 90, 0]) {
        mirror([1, 0, 0])
        matching_rtrt_m4_slotted_bosses(
            nut_side=nut_side, nut_slot_angle=nut_slot_angle,
            nut_depth=nut_depth, screw_extension=screw_extension, boss_height=boss_height,
            screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess,
            solid=solid);
      }
    }
  }
}








module bosses_around_cw_port(solid=false, nut_side=true, angle=0, z=undef) {
  r1=helmet_ir;
  r2=helmet_or;
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
  }
}


module bosses_around_hemisphere(solid=false, nut_side=true, hemi_angle=undef, angle=0) {
  r1=helmet_ir;
  r2=helmet_or;
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
      translate([0, 0, helmet_ir-10]) {
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

module matching_rtrt_m4_slotted_bosses(nut_side=undef, angle=45, nut_slot_angle=undef, nut_depth=undef, screw_extension=undef, boss_height=undef, screw_head_depth=undef, screw_head_recess=undef, solid=false) {
  matching_m4_slotted_bosses(
      solid=solid, show_nut_boss=nut_side, show_screw_boss=!nut_side,
      nut_slot_angle=nut_slot_angle, nut_depth=nut_depth,
      screw_extension=screw_extension,
      boss_height=boss_height,
      screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess) {
    round_top_right_trapezoid(diam=rtrt_boss_diam, height=rtrt_boss_height, angle=angle);
  }
}











