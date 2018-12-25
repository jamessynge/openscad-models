// Strap around lower portion of DEC axis (nearest the RA axis bearing,
// not nearest to the ground). Provides attachment points for connecting to
// other pieces.
// Author: James Synge

include <wp1_dimensions.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../../utils/strap.scad>
use <../../utils/misc.scad>

// Global resolution
$fs = $preview ? 3 : $fs;
$fa = $preview ? 3 : 1;

if ($preview) {
  translate([0, 0, 100])
    ra_and_dec() {
      ra_and_dec2_strap();
    };
}

ra_and_dec2_strap();

module ra_and_dec2_strap() {
  difference() {
    union() {
      ra_strap_at_dec2();
      dec2_strap_at_ra();
    }
    ra_and_dec();
  }
}
echo("ra_clutch_angle", ra_clutch_angle);

module ra_strap_at_dec2() {
  remove_for_clutch = ra_clutch_angle / 2;

  strap(angle=90, radius=ra1_radius, thickness=ra_ring_thickness,
        width=ra1_base_to_dec, gusset_hole_diam=screw_hole_diam,
        gusset_thickness=screw_hole_diam*3, gusset_length=30,
        render_gusset_2=false);

    rotate([0, 0, 90])
      strap(angle=60, radius=ra1_radius, thickness=ra_ring_thickness,
            width=ra1_base_to_dec + 10, gusset_hole_diam=screw_hole_diam,
            gusset_thickness=screw_hole_diam*3, gusset_length=30,
            render_gusset_1=false,
            render_gusset_2=false);
}

//module



module dec2_strap_at_ra() {
  translate_to_dec2() {
    translate([0, 0, -(dec2_len-dec2_strap_width)]) {
      strap(angle=180, radius=dec2_radius, thickness=dec2_strap_thickness,
            width=dec2_strap_width, gusset_hole_diam=screw_hole_diam,
            gusset_thickness=screw_hole_diam*3, gusset_length=30);
    }
  }
}