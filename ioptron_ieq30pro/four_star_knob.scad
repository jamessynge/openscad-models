// Defines a 4-star knob and optional machine screw as found on the
// iEQ30 Pro for securing a dovetail, attachng the mount to the pier/tripod
// and for tightening the latitude adjustment.
// Author: James Synge
// Units: mm

include <ieq30pro_dimensions.scad>

four_star_knob();

module four_star_knob(include_screw=true, zero_is_top=false) {
  total_knob_height = fsk_height + fsk_shoulder_height;
  drop_by = zero_is_top ? 0 : total_knob_height;


  translate([0, 0, -drop_by]) {
    color(plastic_color) {
      union() {
        linear_extrude(height=fsk_height) {
          four_star_knob_profile(fsk_inner_diam, fsk_notch_diam, fsk_outer_diam);
        };
        translate([0, 0, fsk_height])
          cylinder(h=fsk_shoulder_height, d=fsk_shoulder_diam);
      };
    }
    color(bearing_color) {
      translate([0, 0, total_knob_height]) {
        cylinder(h=fsk_screw_len, d=dec_head_clamp_screw_diam);

      }
    }
  }
}

module four_star_knob_profile(inner_diam, notch_diam, outer_diam) {
  assert(inner_diam < outer_diam);
  inner_radius = inner_diam / 2;
  delta = (inner_diam + notch_diam) / 2;

  difference() {
    circle(d=outer_diam);
    // Remove the four notches.
    translate([delta, 0]) circle(d=notch_diam);
    translate([-delta, 0]) circle(d=notch_diam);
    translate([0, delta]) circle(d=notch_diam);
    translate([0, -delta]) circle(d=notch_diam);
  }
}