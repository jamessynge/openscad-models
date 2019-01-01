// Sleeve around the counterweight cap and strap around adjacent RA gear cover.
// Author: James Synge

include <../weatherproofing_1/wp1_dimensions.scad>
include <wp2_dimensions.scad>
include <ra_and_dec_basic_shell.scad>
use <../ieq30pro_ra_and_dec.scad>

include <../../utils/metric_dimensions.scad>
use <../../utils/misc.scad>
use <../../utils/strap.scad>


// Global resolution
$fs = $preview ? 5 : 1;
$fa = $preview ? 6 : 1;



if ($preview && false) {
  translate([300, 0, 0]) {
    ra_and_dec() {
      #dec1_hat_extrusion_in_position();
    };
  }
}

dec1_hat();

*dec1_hat(over_port=true, remainder=false, sleeve=false);
*dec1_hat(over_port=false, remainder=true, sleeve=false);
*dec1_hat(over_port=false, remainder=false, sleeve=true);



module dec1_hat(over_port=true, remainder=true, sleeve=true) {
  difference() {
    intersection() {
      dec1_hat_extrusion_in_position(
        over_port=over_port, remainder=remainder, sleeve=sleeve);
      helmet_interior();
    }
    ra_and_dec(include_cw_shaft=false);
    dec1_hat_nut_slots(show_gusset=false);
  }
}

module move_to_hat_position() {
  translate([0,ra1_radius,0])
    rotate([90,0,0])
      children();
}

module undo_move_to_hat_position() {
  rotate([-90,0,0])
    translate([0,-ra1_radius,0])
      children();
}



module dec1_hat_extrusion_in_position(over_port=true, remainder=true, sleeve=true) {
  move_to_hat_position()
    color("RosyBrown")
      dec1_hat_extrusion(over_port=over_port, remainder=remainder, sleeve=sleeve);
}


//translate([0,0,-200]) dec1_hat_extrusion();
module dec1_hat_extrusion(over_port=true, remainder=true, sleeve=true) {
  if (over_port) dec1_hat_over_port();
  translate([0, 0, dec1_hat_over_port_len]) {
    if (over_port) dec1_hat_end_polar_port();
    translate([0, 0, dec1_hat_transition_len]) {
      if (remainder) {
        linear_extrude(height=dec1_hat_remainder_len, convexity=3)
          dec1_hat_profile(include_polar_port=false);
      }
      translate([0, 0, dec1_hat_remainder_len]) {
        if (sleeve)
          dec1_hat_sleeve();
      }
    }
  }

  cw_chin_strap();
}

module dec1_hat_nut_slots(show_gusset=false, gusset_z=25) {
  dec1_hat_nut_slot_near_clutch(show_gusset=show_gusset, gusset_z=gusset_z);
  mirror([1,0,0]) dec1_hat_nut_slot_near_clutch(show_gusset=show_gusset, gusset_z=gusset_z);
}

// Space to be occupied by a nut, to receive a bolt from the dec_chin_strap.
module dec1_hat_nut_slot_near_clutch(show_gusset=false, gusset_z=25) {
  inset_from_radii = 2*m4_nut_diam1;
  nut_slot_depth = m4_nut_diam2 + 5;
  offset_towards_dec_bearing = 25;

  translate([-(ra1_radius-inset_from_radii),
             offset_towards_dec_bearing,
             ra1_base_to_dec_center-nut_slot_depth])
    rotate([0, 0, 30])
      rotate([90,0,0])
        nut_slot_and_screw_gusset(
          show_gusset=show_gusset,
          nut_diam=m4_nut_diam1,
          nut_height=m4_nut_height,
          depth=nut_slot_depth+1,
          bolt_diam=m4_hole_diam,
          bolt_up=10,
          bolt_down=100,
          gusset_w=20,
          gusset_h=nut_slot_depth*2,
          gusset_z=gusset_z,
          gusset_dist=-13,
          fn=$fn);
}


if ($preview) translate([150, 500, 0])
  dec1_hat_sleeve();

module dec1_hat_sleeve(length=dec1_len - ra1_diam) {
  translate([0, ra1_base_to_dec+dec1_radius,0])
  linear_extrude(height=length, convexity=2) {
    annulus(d1=cw_sleeve_id, d2=cw_sleeve_od);
  }
  linear_extrude(height=length, convexity=2)
    below_dec_axis();
}

//translate([0, 100, 0])
// *rotate([180,0,0])
// undo_move_to_hat_position()
// difference() {
//   move_to_hat_position()
//     dec1_hat_over_port();
//   ra_and_dec();
// }

module dec1_hat_over_port(include_extensions=true) {
  intersection() {
    union() {
      h1 = (dec1_len + polar_port_cap_diam) / 2;
      h2 = 5;
      linear_extrude(height=h1, convexity=3) dec1_hat_profile();
      translate([0, 0, h1]) dec1_hat_end_polar_port();
    }


  translate([0, 0, ra1_radius]) {
    rotate([0, 0, 180])
    rotate([90, 0, 0]) {
      linear_extrude(height=ra1_base_to_dec_center + dec2_diam) {
        circle(r=ra1_radius);
        translate([0, ra1_radius, 0])
          square(size=[ra1_diam, ra1_diam], center=true);
      }
    }
  }

  }

}

if ($preview) translate([0, 500, 0]) dec1_hat_end_polar_port();

module dec1_hat_end_polar_port() {
  linear_extrude(height=dec1_hat_transition_len, convexity=3)
    dec1_hat_profile_difference();
}

module dec1_hat_profile_difference() {
  intersection() {
    difference() {
      union() {
        offset(r=dec1_hat_outer_offset) ra_to_dec_profile_at_ra_axis(include_polar_port=true);
        below_dec_axis();
      }
      offset(r=dec1_hat_inner_offset) ra_to_dec_profile_at_ra_axis(include_polar_port=false);
    }
    translate([-ra1_radius, ra1_base_to_dec, 0]) {
      square([ra1_diam, ra1_diam*2], center=false);
    }
  }
}

if ($preview) translate([0, 350, 0]) dec1_hat_profile(include_polar_port=true);
if ($preview) translate([150, 350, 0]) color("green") dec1_hat_profile(include_polar_port=false);
module dec1_hat_profile(include_polar_port=true) {
  intersection() {
    difference() {
      union() {
        offset(r=dec1_hat_outer_offset)
          ra_to_dec_profile_at_ra_axis(include_polar_port=include_polar_port);
        below_dec_axis();
      }
      offset(r=dec1_hat_inner_offset) ra_to_dec_profile_at_ra_axis(include_polar_port=include_polar_port);
    }
    translate([-ra1_radius, ra1_base_to_dec, 0]) {
      square([ra1_diam, ra1_diam*2], center=false);
    }
  }
}

module below_dec_axis() {
  translate([-ra1_radius, 0, 0])
    square([ra1_diam, ra1_base_to_dec_center], center=false);
}

if ($preview) translate([0, 200, 0])ra_to_dec_profile_at_ra_axis();
if ($preview) translate([150, 200, 0])color("pink") ra_to_dec_profile_at_ra_axis(include_polar_port=false);
module ra_to_dec_profile_at_ra_axis(include_polar_port=true) {
  intersection() {
    union() {
      projection(cut=true) {
        rotate([-90, 0, 0])
          ra_and_dec(include_polar_port=include_polar_port, include_cw_shaft=false);
      }
      translate([0, ra1_base_to_dec + dec1_radius])
        square(size=cw_shaft_diam, center=true);
    }
    translate([-ra1_radius, 0, 0]) {
      square([ra1_diam, ra1_diam*2], center=false);
    }
  }
}

module cw_chin_strap_lower_quarter_fillets() {
  cw_chin_strap_lower_quarter_fillet();
  mirror([1, 0, 0])
    cw_chin_strap_lower_quarter_fillet();
}

module cw_chin_strap_lower_quarter_fillet() {
  r = ra_to_dec_fillet_radius;
  translate([ra1_radius, ra1_base_to_dec + r, 0]) {
    intersection() {
      circle(r=r-dec1_hat_inner_offset-2, center=true);
      translate([-r, -r, 0]) square(size=r, center=false);
    }

    r2 = r / 2;
    translate([r2-r+7, r2, 0])
    difference() {
      translate([-r2, -r2, 0]) square(size=r2, center=false);
      circle(r=r2, center=true);

    }
  }
}

if ($preview) translate([0, 700, 0])
  cw_chin_strap_profile();

module cw_chin_strap_profile() {
    x = ra1_diam;
    y = dec1_len - ra1_radius;
  difference() {
    translate([0, -y/2]) square([x, y], center=true);
    circle(r=ra1_radius);
    square([ra1_diam+1, 40], center=true);
  }
}

if ($preview) translate([150, 700, 0])
  cw_chin_strap();

module cw_chin_strap() {
  difference() {
    rotate([-90,0,0])
      translate([0, -ra1_radius, 0])
        linear_extrude(height=ra1_base_to_dec+ra_to_dec_fillet_radius, convexity=3)
          cw_chin_strap_profile();
    // Remove the dec1 body.
    translate([0, ra1_base_to_dec_center, ra1_radius]) {
      linear_extrude(height=ra1_diam, convexity=3)
        circle(d=cw_cap_diam, center=true);
    }
  }
}
