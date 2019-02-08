include <../ieq30pro_dimensions.scad>
include <../../utils/metric_dimensions.scad>
include <wp3_dimensions.scad>

use <../ieq30pro_ra_core.scad>

ra_body_envelope();
module ra_body_envelope() {
  for (angle = [0 : 10 : 360])
    rotate([0,0,angle])
      ra_body();
}
