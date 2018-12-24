include <../ieq30pro_dimensions.scad>
include <../ieq30pro.scad>

echo(version=version());

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.1;
// Don't generate larger angles than this many degrees.
$fa = 3;

echo("ra1_radius", ra1_radius);

module RA_measurement() {
  color("blue")
    rotate([0,0, -70])
    rotate_extrude(angle=135)
        translate([ra1_radius, 0])
        	square([10,5]);
}

if ($preview) {
  ioptron_mount($t * 360) {
    RA_measurement();
  }
} else {
  RA_measurement();
}
