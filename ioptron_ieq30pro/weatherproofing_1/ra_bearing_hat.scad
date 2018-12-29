// Sleeve around the counterweight cap and strap around adjacent RA gear cover.
// Author: James Synge

include <wp1_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../../utils/strap.scad>
use <../../utils/misc.scad>

// Global resolution
$fs = $preview ? 6 : 1;
$fa = $preview ? 6 : 1;



if ($preview && false) {
  translate([0, 0, 200]) {
    ra_and_dec() {
      #dec1_hat_extrusion_in_position();
    };
  }
  translate([0, -200, 200]) dec1_hat();
}

*dec1_hat(over_port=true, remainder=false, sleeve=false);
*dec1_hat(over_port=false, remainder=true, sleeve=false);
*dec1_hat(over_port=false, remainder=false, sleeve=true);

*dec1_hat_sleeve(length=10);


module dec1_hat(over_port=true, remainder=true, sleeve=true) {
  difference() {
    dec1_hat_extrusion_in_position(over_port=over_port, remainder=remainder, sleeve=sleeve);
    ra_and_dec();
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
      dec1_hat_extrusion(over_port=over_port, remainder=remainder, sleeve=sleeve);
}

*translate([0,0,-200]) dec1_hat_extrusion();
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
}

module dec1_hat_sleeve(length=cw_sleeve_length) {
  translate([0, ra1_base_to_dec+dec1_radius,0])
  linear_extrude(height=length, convexity=2)
    difference() {
      circle(d=cw_sleeve_od);
      circle(d=cw_sleeve_id);
    }
}

//translate([0, 100, 0])
*rotate([180,0,0])
undo_move_to_hat_position()
difference() {
  move_to_hat_position()
    dec1_hat_over_port();
  ra_and_dec();
}

module dec1_hat_over_port(include_extensions=true) {
  h1 = (dec1_len + polar_port_cap_diam) / 2;
  h2 = 5;
  linear_extrude(height=h1, convexity=3) dec1_hat_profile();
  translate([0, 0, h1]) dec1_hat_end_polar_port();
}

*translate([0, 0, -250]) dec1_hat_end_polar_port();

module dec1_hat_end_polar_port() {
  linear_extrude(height=dec1_hat_transition_len, convexity=3)
    dec1_hat_profile_difference();
}

module dec1_hat_profile_difference() {
  intersection() {
    difference() {
      offset(r=dec1_hat_outer_offset) ra_to_dec_profile_at_ra_axis(include_polar_port=true);
        offset(r=dec1_hat_inner_offset) ra_to_dec_profile_at_ra_axis(include_polar_port=false);
    }
    translate([-ra1_radius, ra1_base_to_dec, 0]) {
      square([ra1_diam, ra1_diam*2], center=false);
    }
  }
}

*translate([0, 0, -300]) dec1_hat_profile(include_polar_port=true);
*translate([0, 0, -350]) dec1_hat_profile(include_polar_port=false);
module dec1_hat_profile(include_polar_port=true) {
  intersection() {
    difference() {
      offset(r=dec1_hat_outer_offset) ra_to_dec_profile_at_ra_axis(include_polar_port=include_polar_port);
      offset(r=dec1_hat_inner_offset) ra_to_dec_profile_at_ra_axis(include_polar_port=include_polar_port);
    }
    translate([-ra1_radius, ra1_base_to_dec, 0]) {
      square([ra1_diam, ra1_diam*2], center=false);
    }
  }
}

*translate([0, 0, -400])ra_to_dec_profile_at_ra_axis();
*translate([0, 0, -450])ra_to_dec_profile_at_ra_axis(include_polar_port=false);
module ra_to_dec_profile_at_ra_axis(include_polar_port=true) {
  intersection() {
    union() {
      projection(cut=true) {
        rotate([-90, 0, 0])
          ra_and_dec(include_polar_port=include_polar_port);
      }
      translate([0, ra1_base_to_dec + dec1_radius])
        square(size=cw_shaft_diam, center=true);
    }
    translate([-ra1_radius, 0, 0]) {
      square([ra1_diam, ra1_diam*2], center=false);
    }
  }
}

// *intersection() {
//   translate([-ra1_radius, 0, 0])
//     ioptron_mount_profile();
//   square(size=100, center=false);
// }

// *translate([-300,0,0])
//   ioptron_mount_profile();
// module ioptron_mount_profile() {
//   size=400;
//   intersection() {
//     union() {
//       projection(cut=true) {
//         ioptron_mount_biggest_ra_projection();
//       }
//       // translate([0, ra1_base_to_dec + dec1_radius])
//       //   square(size=cw_shaft_diam, center=true);
//     }
//     translate([-size/0, 0, 0]) {
//       square(size=size, center=false);
//     }
//   }
// }

ra_motor_bearing_hat_profile();
module ra_motor_bearing_hat_profile() {
  difference() {
    offset(r=10) ra_motor_biggest_profile();
    offset(r=5) ra_motor_biggest_profile();
  }
}

translate([0, 0, 100]) ra_motor_biggest_profile();
module ra_motor_biggest_profile() {
  intersection() {
    translate([-ra1_radius, 0, 0])
      ioptron_mount_biggest_ra_projection();
    square(size=100, center=false);
  }
}

translate([0, 0, 200]) ioptron_mount_biggest_ra_projection();
module ioptron_mount_biggest_ra_projection() {
  projection(cut=true)
    rotate([0, 90+30, 0])
      ioptron_mount(ra_angle=90+30, latitude=0);
}
