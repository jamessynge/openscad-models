use <../helmet.scad>

the_scale=1;
scale(the_scale)
  rotate([180, 0, 0])  // Rotate for printing.
    basic_helmet_screw_side_top();