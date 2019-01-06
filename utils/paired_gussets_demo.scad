use <misc.scad>
include <metric_dimensions.scad>
use <paired_gussets.scad>

//echo("cos($t)", cos($t));
distance = 5 * (cos($t*360) + 1);

translate([0, distance, 0]) color("red")
  example(nut_side=true);
translate([0, -distance, 0]) color("green")
  example(nut_side=false);

translate([0, 0, -40])
  intersection() {
    color("red") example(nut_side=true);
    color("green") example(nut_side=false);
  };

module example(nut_side=true) {
  r1 = 100;
  r2 = 105;
  difference() {
    translate([0, 0, -15]) {
      intersection() {
        // The whole ring of the helmet.
        linear_extrude(height=30, convexity=3)
          annulus(r1=r1, r2=r2);
        // Cut to be just the upper or lower half (i.e. nut side or screw side).
        if (nut_side) {
          translate([-r2, 0.01, 0])
            cube(size=r2*2, center=false);
        } else {
          translate([-r2, -r2*2, 0])
            cube(size=r2*2, center=false);
        }
      }
    }
    // Remove from the ring the gussets, which really means removing the holes
    // for the screws.
    mirrored(v=[1,0,0])
      matching_m4_gussets_in_place(id=r1, od=r2, show_nut_gusset=nut_side, show_screw_gusset=!nut_side, do_intersect=false);
  }
  // The actual gussets.
  mirrored(v=[1,0,0])
    matching_m4_gussets_in_place(id=r1, od=r2, show_nut_gusset=nut_side, show_screw_gusset=!nut_side);
}


module mirrored(v=undef) {
  children();
  mirror(v=v) children();
}


module matching_m4_gussets_in_place(id=undef, od=undef, show_nut_gusset=true, show_screw_gusset=true, solid=false, do_intersect=true) {
  intersection() {
    translate([id-7, 0, 0])
      rotate([-90, 0, 0])
        rotate([0, 0, 90])
          matching_m4_gussets(solid=!do_intersect, show_nut_gusset=show_nut_gusset, show_screw_gusset=show_screw_gusset);
    if (do_intersect) {
      translate([0, 0, -15])
        cylinder(r=od, h=30);
    }
  }
}

module matching_m4_gussets(show_nut_gusset=true, show_screw_gusset=true, angle=10, solid=false) {
  rtr_diam = m4_nut_diam2*1.5;
  rtr_height = m4_nut_diam2;
  cone_height = 5;
  cone_diam1 = m4_hole_diam*2.25;
  cone_diam2 = m4_hole_diam*1.75;
  if (show_nut_gusset) {
    //translate([0, 0, 3])  // For visualization / debugging. TODO REMOVE
    //translate([0, 0.05, 0])  // Try (un)
    generic_recessed_nut_gusset(
        solid=solid, screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
        nut_height=m4_nut_height, nut_depth=6+cone_height,
        cone_height=-(cone_height+.1), cone_diam1=cone_diam1+.1,
        cone_diam2=cone_diam2+.1) {
      round_top_pyramid(diam=rtr_diam, height=rtr_height, angle=angle);
    }
  }
  if (show_screw_gusset) {
    //translate([0, 0, -3])  // For visualization / debugging. TODO REMOVE
    //translate([0, -0.05, 0])
    generic_screw_gusset(
        solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
        screw_head_depth=15, screw_head_recess=45,
        cone_height=cone_height-.1, cone_diam1=cone_diam1-.1, cone_diam2=cone_diam2-.1) {
      round_top_pyramid(diam=rtr_diam, height=rtr_height, angle=angle);
    }
  }
}

module round_top_rectangle(diam=undef, height=undef) {
  circle(d=diam);
  translate([-diam/2, -height, 0])
    square(size=[diam, height]);
}

module round_top_pyramid(diam=undef, height=undef, angle=20) {
  assert(angle <= 45);
  circle(d=diam);
  r = diam / 2;
  // Lazy approach. Should just use some trigonometry to compute polygon.
  if (angle > 0) {
    intersection() {
      extra_wide = 30*diam;
      translate([-extra_wide/2, -height])
        square([extra_wide, height+r]);
      union() {
        translate([-diam/2, -height, 0])
          square(size=[diam, height]);
        extra_tall = 10*height;
        intersection() {
          rotate([0, 0, angle])
            translate([-extra_wide+r,-extra_tall,0])
              square([extra_wide,extra_tall]);
          translate([-r,-extra_tall+r,0])
            square([extra_wide,extra_tall]);
        }
        intersection() {
          rotate([0, 0, -angle])
            translate([-r,-extra_tall,0])
              square([extra_wide,extra_tall]);
          translate([-extra_wide+r,-extra_tall+r,0])
            square([extra_wide,extra_tall]);
        }
      }
    }
  } else {
    translate([-diam/2, -height, 0])
      square(size=[diam, height]);
  }
}

*translate([0, 0, 40])
  round_top_pyramid(diam=20, height=40, angle=45);