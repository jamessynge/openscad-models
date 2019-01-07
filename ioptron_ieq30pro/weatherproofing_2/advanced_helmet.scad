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
use <../../utils/paired_gussets.scad>

// Global resolution
$fs = $preview ? 6 : 1;
$fa = $preview ? 6 : 1;

// Default location is parked.
lat = mount_latitude;
ra_angle = 25;//abs($t - 0.5) * 360 - 90;
dec_angle = 58;//  90 + mount_latitude + $t * 360 * 3.14;
show_arrows=false;


// Copied from basic_helmet
dflt_helmet_ir=ra_bcbp_ir;
dflt_helmet_or=ra_bcbp_or;
dflt_dec_port_ir=dec_hoop_interior_radius;
dflt_dec_port_or=dec_hoop_exterior_radius;
dflt_cws_port_d=cw_shaft_diam*2;

rtp_diam = m4_nut_diam2*1.5;
rtp_height = m4_nut_diam2;


distance = 20 * (cos($t*360) + 1);



if (!$preview) {
  translate([distance, 0, 0]) color("orange")
    half_helmet(nut_side=true);
  translate([-distance, 0, 0]) color("palegreen")
    half_helmet(nut_side=false);
} else if (true) {
  translate([distance, 0, 0]) color("orange")
    half_helmet(nut_side=true);
  translate([-distance, 0, 0]) color("palegreen")
    half_helmet(nut_side=false);


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
      #half_helmet(nut_side=true);
      #half_helmet(nut_side=false);
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











module half_helmet(nut_side=true) {
  difference() {
    half_basic_helmet(nut_side=nut_side);
//    matching_circular_m4_slotted_gussets_in_body(solid=true, nut_side=nut_side, nut_slot_angle=0, gusset_height=25, do_intersect=true);

    //mirrored([0, 1, 0]) gussets_below_dec_port(solid=true, nut_side=nut_side);

    gussets(solid=true, nut_side=nut_side);
  }

  //mirrored([0, 1, 0]) gussets_below_dec_port(solid=false, nut_side=nut_side);

  gussets(solid=false, nut_side=nut_side);


//  matching_circular_m4_slotted_gussets_in_body(nut_side=nut_side, nut_slot_angle=0, gusset_height=25, do_intersect=false);

  // matching_m4_recessed_gussets()

}

module gussets(solid=false, nut_side=true) {
  mirrored([0, 1, 0]) gussets_below_dec_port(solid=solid, nut_side=nut_side);
  gussets_above_dec_port(solid=solid, nut_side=nut_side);
  gussets_below_cw_port(solid=solid, nut_side=nut_side);
}

module gussets_below_dec_port(solid=false, nut_side=true, do_intersect=false) {
  nut_slot_angle=0;
  gusset_height=40;
  r1=dflt_helmet_ir;
  r2=dflt_helmet_or;
  angle=0;
  nut_depth=10;
  screw_extension=20;
  screw_head_depth=20;
  screw_head_recess=25;

  intersection() {
    translate([0, r1+rtp_diam/4, -ra_bcbp_ex+rtp_diam/2]) {
      rotate([0, 90, 0]) {
        rotate([0, 0, 270]) {
          matching_circular_m4_slotted_gussets(
              nut_side=nut_side, angle=angle, nut_slot_angle=nut_slot_angle,
              nut_depth=nut_depth, screw_extension=screw_extension, gusset_height=gusset_height,
              screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess,
              solid=solid);
        }
      }
    }
    // matching_circular_m4_slotted_gussets_in_place(
    //     nut_side=nut_side, r1=r1, r2=r2, angle=angle,
    //     nut_slot_angle=nut_slot_angle, nut_depth=nut_depth, screw_extension=screw_extension,
    //     gusset_height=gusset_height, screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess, solid=solid);
    if (do_intersect) {
     basic_helmet_solid();
    }
  }
}

module gussets_above_dec_port(solid=false, nut_side=true, do_intersect=false) {
  nut_slot_angle=220;
  gusset_height=35;
  r1=dflt_helmet_ir;
  r2=dflt_helmet_or;
  angle=0;
  nut_depth=10;
  screw_extension=20;
  screw_head_depth=20;
  screw_head_recess=30;


  raise_by = (dec_hoop_exterior_radius + dec_hoop_interior_radius) / 2;


  intersection() {
    translate_to_dec_bearing_plane() {
//    translate([0, r1+rtp_diam/4, -ra_bcbp_ex+rtp_diam/2]) {
      translate([0, raise_by, 2])
      rotate([0, 90, 0]) {
          matching_circular_m4_slotted_gussets(
              nut_side=nut_side, d=rtp_diam+3, angle=angle, nut_slot_angle=nut_slot_angle,
              nut_depth=nut_depth, screw_extension=screw_extension, gusset_height=gusset_height,
              screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess,
              solid=solid);
      }
    }
    if (do_intersect) {
     basic_helmet_solid();
    }
  }
}



module gussets_below_cw_port(solid=false, nut_side=true, do_intersect=false) {
  nut_slot_angle=220;
  gusset_height=35;
  r1=dflt_helmet_ir;
  r2=dflt_helmet_or;
  angle=0;
  nut_depth=10;
  screw_extension=20;
  screw_head_depth=20;
  screw_head_recess=30;


  raise_by = (dec_hoop_exterior_radius + dec_hoop_interior_radius) / 2;


  intersection() {
    translate([0, r1+rtp_diam/4, -ra_bcbp_ex+rtp_diam/2]) {
      rotate([0, 90, 0]) {
        rotate([0, 0, 270]) {
         matching_rtp_m4_recessed_gussets(
              nut_side=nut_side, angle=angle,
              nut_depth=nut_depth,
              screw_head_depth=screw_head_depth,
              screw_head_recess=screw_head_recess,
              solid=solid);
        }
      }
    }
    if (do_intersect) {
     basic_helmet_solid();
    }
  }
}














module basic_helmet_solid() {
  ra_and_dec_simple_shell(solid=true);
}


module half_basic_helmet(nut_side=true) {
  intersection() {
    basic_helmet();
    // Cut to be just the upper or lower half (i.e. nut side or screw side).
    s = 1000;
    translate([(nut_side ? 1 : -1) * s/2,0, 0]) {
      cube(size=s, center=true);
    }
  }
}

module matching_rtp_m4_recessed_gussets_in_body(nut_side=undef, r1=dflt_helmet_ir, r2=dflt_helmet_or, angle=0, solid=false, do_intersect=false) {
  intersection() {
    matching_rtp_m4_recessed_gussets_in_place(nut_side=nut_side, r1=r1, r2=r2, angle=angle, solid=solid);
    if (do_intersect) {
      basic_helmet_solid();
    }
  }
}

module matching_rtp_m4_recessed_gussets_in_place(nut_side=undef, r1=dflt_helmet_ir, r2=dflt_helmet_or, angle=0, solid=false) {
  translate([0, r1-2, -ra_bcbp_ex+rtp_diam/2]) {
    rotate([0, 90, 0]) {
      rotate([0, 0, 180]) {
        matching_rtp_m4_recessed_gussets(nut_side=nut_side, angle=angle, solid=solid);
      }
    }
  }
}

module matching_rtp_m4_recessed_gussets(nut_side=undef, d=rtp_diam, angle=0, solid=false) {
  matching_m4_recessed_gussets(solid=solid, show_nut_gusset=nut_side, show_screw_gusset=!nut_side) {
    round_top_pyramid(d, rtp_height, angle=angle);
  }
}

////////////////////////////////////////////////////////////////////////////////

module matching_rtp_m4_slotted_gussets_in_body(nut_side=undef, r1=dflt_helmet_ir, r2=dflt_helmet_or,  angle=0, nut_slot_angle=0, nut_depth=10, screw_extension=20, gusset_height=40, solid=false, do_intersect=false) {
  intersection() {
    matching_rtp_m4_slotted_gussets_in_place(
        nut_side=nut_side, r1=r1, r2=r2, angle=angle,
        nut_slot_angle=nut_slot_angle, nut_depth=nut_depth, screw_extension=screw_extension,
        gusset_height=gusset_height, solid=solid);
    if (do_intersect) {
      basic_helmet_solid();
    }
  }
}

module matching_rtp_m4_slotted_gussets_in_place(nut_side=undef, r1=dflt_helmet_ir, r2=dflt_helmet_or, angle=0, nut_slot_angle=0, nut_depth=undef, screw_extension=undef, gusset_height=undef, solid=false) {
  translate([0, r1+rtp_diam/4, -ra_bcbp_ex+rtp_diam/2]) {
    rotate([0, 90, 0]) {
      rotate([0, 0, 270]) {
        matching_rtp_m4_slotted_gussets(
            nut_side=nut_side, angle=angle, nut_slot_angle=nut_slot_angle,
            nut_depth=nut_depth, screw_extension=screw_extension, gusset_height=gusset_height,
            solid=solid);
      }
    }
  }
}

module matching_rtp_m4_slotted_gussets(nut_side=undef, angle=0, nut_slot_angle=undef, nut_depth=undef, screw_extension=undef, gusset_height=undef, solid=false) {
  matching_m4_slotted_gussets(
      solid=solid, show_nut_gusset=nut_side, show_screw_gusset=!nut_side,
      nut_slot_angle=nut_slot_angle, nut_depth=nut_depth,
      screw_extension=screw_extension,
      gusset_height=gusset_height) {
    round_top_pyramid(rtp_diam, rtp_height, angle=angle);
  }
}

////////////////////////////////////////////////////////////////////////////////

module matching_circular_m4_slotted_gussets_in_body(nut_side=undef, r1=dflt_helmet_ir, r2=dflt_helmet_or,  angle=0, nut_slot_angle=0, nut_depth=10, screw_extension=20, gusset_height=40, screw_head_depth=20, screw_head_recess=25, solid=false, do_intersect=false) {
  intersection() {
    matching_circular_m4_slotted_gussets_in_place(
        nut_side=nut_side, r1=r1, r2=r2, angle=angle,
        nut_slot_angle=nut_slot_angle, nut_depth=nut_depth, screw_extension=screw_extension,
        gusset_height=gusset_height, screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess, solid=solid);
    if (do_intersect) {
     basic_helmet_solid();
    }
  }
}

module matching_circular_m4_slotted_gussets_in_place(nut_side=undef, r1=dflt_helmet_ir, r2=dflt_helmet_or, angle=0, nut_slot_angle=0, nut_depth=undef, screw_extension=undef, gusset_height=undef, screw_head_depth=undef, screw_head_recess=undef, solid=false) {
  translate([0, r1+rtp_diam/4, -ra_bcbp_ex+rtp_diam/2]) {
    rotate([0, 90, 0]) {
      rotate([0, 0, 270]) {
        matching_circular_m4_slotted_gussets(
            nut_side=nut_side, angle=angle, nut_slot_angle=nut_slot_angle,
            nut_depth=nut_depth, screw_extension=screw_extension, gusset_height=gusset_height,
            screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess,
            solid=solid);
      }
    }
  }
}

module matching_circular_m4_slotted_gussets(nut_side=undef, d=rtp_diam, angle=0, nut_slot_angle=undef, nut_depth=undef, screw_extension=undef, gusset_height=undef, screw_head_depth=undef, screw_head_recess=undef, solid=false) {
  matching_m4_slotted_gussets(
      solid=solid, show_nut_gusset=nut_side, show_screw_gusset=!nut_side,
      nut_slot_angle=nut_slot_angle, nut_depth=nut_depth,
      screw_extension=screw_extension,
      gusset_height=gusset_height,
      screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess) {
    circle(d=d);
  }
}
