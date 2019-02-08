use <advanced_helmet2.scad>
include <../ieq30pro_dimensions.scad>

the_scale=1;
scale(the_scale) {
  intersection() {
    half_helmet_screw_side();
    s = 1000;
    translate([-s/2, -s/2, -s + 29.5])
      cube(size=s, center=false);
  }
}
