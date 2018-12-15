// Module axis_arrows renders three arrows showing
// the X, Y and Z axes.
//

//// Global resolution
//// Don't generate smaller facets than this many mm.
//$fs = 0.5;
//// Don't generate larger angles than this many degrees.
//$fa = 1;

color("green") axis_arrows();

// Draws an arrow from the origin along the Z axis.
module arrow(total_length=50, shaft_radius=2,
             head_length=15, head_radius=4, message="") {
  shaft_length = total_length-head_length;
  cylinder(h=shaft_length, r=shaft_radius);
  translate([0,0,shaft_length])
    cylinder(h=head_length, r1=head_radius, r2=0);
  if (message != "") {
    echo("message is set");
    translate([0,0,total_length])
      text(message, halign="center", valign="center");
  } else {
    echo("no message");
  }
}

module axis_arrows(total_length=50, shaft_radius=2,
                   head_length=15, head_radius=4) {
  rotate([0,90,0])
    rotate([0,0,90])
      arrow(message="X",
            total_length=total_length,
            shaft_radius=shaft_radius,
            head_length=head_length,
            head_radius=head_radius);
  rotate([-90,180,0])
    arrow(message="Y",
          total_length=total_length,
          shaft_radius=shaft_radius,
          head_length=head_length,
          head_radius=head_radius);
  arrow(message="Z",
        total_length=total_length,
        shaft_radius=shaft_radius,
        head_length=head_length,
        head_radius=head_radius);
}
