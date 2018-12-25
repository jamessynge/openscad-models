// Sleeve around the counterweight cap and strap around adjacent RA gear cover.
// Author: James Synge

include <wp1_dimensions.scad>
use <../ieq30pro_ra_and_dec.scad>
use <../../utils/strap.scad>
use <../../utils/misc.scad>

// Global resolution
$fs = $preview ? 3 : $fs;
$fa = $preview ? 3 : 1;

if ($preview) {
  translate([0, 0, 100]) {
    ra_and_dec() {
      union() {
        ra_at_sleeve_strap();
        cw_sleeve(cw_sleeve_thickness, cw_sleeve_length);
      };
    };
  }
}

ra_at_sleeve_strap();

module ra_at_sleeve_strap() {
  remove_for_clutch = ra_clutch_angle / 2;

 // mirror([0,1,0])
 rotate([0,0,270])
  strap(angle=90, radius=ra1_radius, thickness=ra_ring_thickness,
        width=ra1_base_to_dec, gusset_hole_diam=screw_hole_diam,
        gusset_thickness=screw_hole_diam*3, gusset_length=30,
        render_gusset_1=false);

}

translate([0,0,-100])cw_sleeve(cw_sleeve_thickness, cw_sleeve_length);

module cw_sleeve(thickness, length) {
  #
  translate_to_dec12_plane(z_towards_dec_head=false)
    translate([0, 0, ra1_diam])
      linear_extrude(height=length, convexity=2)
        difference() {
          circle(r=dec1_radius+thickness);
          circle(r=dec1_radius);
        }
}