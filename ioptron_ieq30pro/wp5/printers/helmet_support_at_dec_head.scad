use <../helmet_supports.scad>

the_scale=1;
scale(the_scale)
  rotate([-90, 0, 0])  // Rotate for printing.
    helmet_support_over_dec_end();