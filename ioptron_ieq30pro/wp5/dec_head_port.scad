// 
// Author: James Synge
// Units: mm


use <../ieq30pro_ra_and_dec.scad>
use <shaft_port.scad>
include <wp5_dimensions.scad>


translate([0, 50, 0])
dec_head_port();

translate([0, -50, 0])
mirror([0, 1, 0])
  dec_head_port_solid();

module dec_head_port_solid() {
  translate_to_dec_bearing_plane()
    shaft_port_solid(dec_head_port_dims);
}

module dec_head_port(thickness_frac=1) {
  translate_to_dec_bearing_plane()
    shaft_port(dec_head_port_dims, thickness_frac=thickness_frac);
}

module dec_head_port_interior() {
  difference() {
    hull() dec_head_port();
    dec_head_port(thickness_frac=1.005);
  }
}