// 
// Author: James Synge
// Units: mm

use <../../utils/misc.scad>

include <../ieq30pro_dimensions.scad>
use <../ieq30pro_ra_and_dec.scad>

include <wp5_dimensions.scad>
use <can.scad>
use <cw_shaft_port.scad>
use <dec_head_port.scad>

ra_and_dec() {
  basic_helmet();
}




module basic_helmet() {
  difference() {
    union() {
      can_solid();
      cw_shaft_port();
      dec_head_port();
    }

    can_interior();
    cw_shaft_port_interior();
    dec_head_port_interior();
  }
}

module helmet_hcut_supports() {
  translate([0, 0, ra1_base_to_dec_center]) {

  }
}