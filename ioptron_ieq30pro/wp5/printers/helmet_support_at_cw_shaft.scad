use <../helmet_supports.scad>

the_scale=1;
scale(the_scale) {
  // Rotate for printing.
  rotate([90, 0, 0]) {
    intersection() {
      helmet_support_over_cw_end();
      cw_shaft_test_region();
    }
  }
}
