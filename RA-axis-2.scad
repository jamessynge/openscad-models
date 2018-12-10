use <ioptron-ieq30pro.scad>

echo(version=version());

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.1;
// Don't generate larger angles than this many degrees.
$fa = 3;

ra1_radius = 62;

echo("ra1_radius");
echo(ra1_radius);

module ra_bearing_cover() {
//  color("green")
//    rotate_extrude(angle=135)
//        translate([ra1_radius, 0])
//            polygon([
//                [0, 0],
//                [30, 0],
//                [45, -15],
//                [45, -40],
//                [35, -40],
//                [35, -21],
//                [25, -10],
//                [0, -10]]);
  color("blue")
    rotate([0,0, -70])
    rotate_extrude(angle=135)
        translate([ra1_radius, 0])
            polygon([
                [0, 0],
                [30, 0],
                [40, -10],
                [40, -40],
                [50, -40],
                [50, -5],
                [35, 10],
                [0, 10]]);
}

if ($preview) {
  ioptron_mount($t * 360) {
    ra_bearing_cover();
  }
} else {
  ra_bearing_cover();
}

//rotate([0,0,0]) ra_bearing_cover();
                
                

module ra_body_envelope() {
  rotate([180, 0, 0]) {
    for (angle = [0 : 5 : 360])
      rotate([0,0,angle])
        ra_body();
  }
}

//ra_body_envelope();