use <misc.scad>
include <metric_dimensions.scad>
use <paired_bosses.scad>

//echo("cos($t)", cos($t));
distance = 5 * (cos($t*360) + 1);

translate([0, distance, 0]) color("red")
  example(nut_side=true);
translate([0, -distance, 0]) color("green")
  example(nut_side=false);

*translate([0, 0, -40])
  intersection() {
    color("red") example(nut_side=true);
    color("green") example(nut_side=false);
  };

module example(nut_side=true) {
  r1 = 100;
  r2 = 105;
  angle = 20;
  difference() {
    example_body(nut_side=nut_side, r1=r1, r2=r2);
    // Remove from the ring the bosses, which really means removing the holes
    // for the screws.
    mirrored(v=[1,0,0]) {
      matching_rtp_m4_bosses_in_body(nut_side=nut_side, r1=r1, r2=r2, angle=angle, solid=true);
    }
  }
  // The actual bosses.
  mirrored(v=[1,0,0]) {
    matching_rtp_m4_bosses_in_body(nut_side=nut_side, r1=r1, r2=r2, angle=angle, solid=false, do_intersect=true);
  }
}

module example_body(nut_side=undef, r1=undef, r2=undef, solid=false) {
  d2 = r2 * 2;
  translate([0, 0, -15]) {
    if (solid) {
      linear_extrude(height=30, convexity=3)
        circle(r=r2);
    } else {
      intersection() {
        // The whole ring of the helmet.
        linear_extrude(height=30, convexity=3)
          annulus(r1=r1, r2=r2);
        // Cut to be just the upper or lower half (i.e. nut side or screw side).
        if (nut_side) {
          translate([-r2, 0.01, 0])
            cube(size=d2, center=false);
        } else {
          translate([-r2, -d2, 0])
            cube(size=d2, center=false);
        }
      }
    }
  }
}

module matching_rtp_m4_bosses_in_body(nut_side=undef, r1=undef, r2=undef, angle=0, solid=false, do_intersect=false) {
  intersection() {
    matching_rtp_m4_bosses_in_place(nut_side=nut_side, r1=r1, r2=r2, angle=angle, solid=solid);
    if (do_intersect) {
      example_body(nut_side=nut_side, r1=r1, r2=r2, solid=true);
    }
  }
}

module matching_rtp_m4_bosses_in_place(nut_side=undef, r1=undef, r2=undef, angle=0, solid=false) {
  translate([r1-7, 0, 0]) {
    rotate([-90, 0, 0]) {
      rotate([0, 0, 90]) {
        matching_rtp_m4_bosses(nut_side=nut_side, angle=angle, solid=solid);
      }
    }
  }
}

module matching_rtp_m4_bosses(nut_side=undef, angle=0, solid=false) {
  rtp_diam = m4_nut_diam2*1.5;
  rtp_height = m4_nut_diam2;
  matching_m4_recessed_bosses(solid=solid, show_nut_boss=nut_side, show_screw_boss=!nut_side) {
    round_top_pyramid(rtp_diam, rtp_height, angle=angle);
  }
}
