include <../ieq30pro_dimensions.scad>
include <../../utils/metric_dimensions.scad>
include <wp3_dimensions.scad>

use <../ieq30pro_ra_core.scad>

*ra_body_envelope();
module ra_body_envelope() {
  for (angle = [0 : 10 : 360])
    rotate([0,0,angle])
      ra_body();
}

module body_slices_hulled() {
  step = 3;
  for (z = [0 : step : 60]) {
    hull() {
      intersection() {
        ra_body();
        translate([0, 0, z]) {
          cube(size=[200, 200, step], center=true);
        }
      }
    }
  }
}
body_slices_hulled();
module rotated_body90() {

module rotated_body90() {
  for (angle = [0 : 5 : 90]) {
    
  }



}