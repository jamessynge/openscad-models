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


color("green")
    rotate_extrude(angle=135)
        translate([62, 0])
            polygon([
                [0, 0],
                [30, 0],
                [45, 15],
                [45, 40],
                [35, 40],
                [35, 21],
                [25, 10],
                [0, 10]]);