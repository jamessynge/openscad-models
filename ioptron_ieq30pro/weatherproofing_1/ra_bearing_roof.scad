
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

