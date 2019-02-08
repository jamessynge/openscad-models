include <../ieq30pro_dimensions.scad>
include <../../utils/metric_dimensions.scad>
include <wp3_dimensions.scad>

use <../ieq30pro_dec_head.scad>

dec_head_envelope();
module dec_head_envelope() {
  for (angle = [0 : 1 : 360])
    rotate([0,0,angle])
      dec_head();
}
