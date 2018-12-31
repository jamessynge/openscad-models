
module cut_at_z(z) {
  projection(cut=true)
    translate([0, 0, -z])
      children();
}