use <../helmet_supports.scad>

the_scale=1;
scale(the_scale) {
  for (i = [0:3]) {
    translate([20 * i, 0, 0])
      screw_head_support();
  }

  for (i = [0:3]) {
    translate([20 * i, 20, 0])
      nut_holder();
  }

  for (i = [0:3]) {
    translate([20 * i, 40, 0])
      screw_head_support();
  }
}
