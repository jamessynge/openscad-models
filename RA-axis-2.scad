use <ioptron-ieq30pro.scad>

echo(version=version());

// rotate_extrude() always rotates the 2D shape 360 degrees
// around the Z axis. Note that the 2D shape must be either
// completely on the positive or negative side of the X axis.
//color("red")
//    rotate_extrude(angle=180)
//        translate([62, 0])
//            square([25,10]);

//color("blue")
//    rotate_extrude()
//        polygon([
//            [77, 0],
//            [99, 20],
//            [99, 40],
//            [77, 10]]);

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


ioptron_mount($t * 360) {
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