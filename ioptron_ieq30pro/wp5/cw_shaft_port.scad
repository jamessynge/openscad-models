// 
// Author: James Synge
// Units: mm


use <../ieq30pro_ra_and_dec.scad>
use <shaft_port.scad>
include <wp5_dimensions.scad>


cw_shaft_port();

mirror([0, 1, 0])
  cw_shaft_port_solid();


translate([100, 0, 0])
  cw_shaft_port_interior();


module cw_shaft_port_solid(thickness_frac=0.5) {
  translate_to_dec12_plane(z_towards_dec_head=false)
    translate([0, 0, ra1_radius + helmet_ir])
      shaft_port_solid(cw_shaft_port_dims, thickness_frac=thickness_frac);
}

module cw_shaft_port(miter=false, thickness_frac=1) {
  translate_to_dec12_plane(z_towards_dec_head=false)
    translate([0, 0, ra1_radius + helmet_ir])
      shaft_port(cw_shaft_port_dims, miter=miter, thickness_frac=thickness_frac);
}

module cw_shaft_port_interior(thickness_frac=0.999) {
  difference() {
    hull() cw_shaft_port(miter=true, thickness_frac=thickness_frac);
    cw_shaft_port(miter=true);
  }
}