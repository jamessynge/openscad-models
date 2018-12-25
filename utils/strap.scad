
// Global resolution
if ($preview) {
  // Don't generate smaller facets than this many mm.
  $fs = 1;
  // Don't generate larger angles than this many degrees.
  $fa = 1;
}

strap(120, 50, 5, 10, 4, 10, 20);
module strap(angle=120, radius=50, thickness=5, width=10, gusset_hole_diam=4, gusset_thickness=10, gusset_length=20,
             render_gusset_1=true, render_gusset_2=true) {
  difference() {
    strap_body(angle, radius, thickness, width, gusset_hole_diam, gusset_thickness, gusset_length, render_gusset_1, render_gusset_2);
    if (render_gusset_1) {
      translate([radius, 0, 0])
        strap_gusset_hole(gusset_thickness, width, gusset_hole_diam, gusset_length);
    }
    if (render_gusset_2) {
      rotate([0, 0, angle])
        mirror([0, 1, 0])
          translate([radius, 0, 0])
            strap_gusset_hole(gusset_thickness, width, gusset_hole_diam, gusset_length);
    }
  }
}

module strap_body(angle, radius, thickness, width, gusset_hole_diam, gusset_thickness, gusset_length, render_gusset_1, render_gusset_2) {
  rotate_extrude(angle=angle) 
    strap_profile(radius, thickness, width);
  if (render_gusset_1) {
    translate([radius, 0, 0])
      strap_gusset(gusset_thickness, width, gusset_hole_diam, gusset_length);
  }
  if (render_gusset_2) {
    rotate([0, 0, angle])
      mirror([0, 1, 0])
        translate([radius, 0, 0])
          strap_gusset(gusset_thickness, width, gusset_hole_diam, gusset_length);
  }
}

module strap_profile(radius, thickness, width) {
  translate([radius, 0, 0])
    polygon(points=[
      [0,0],
      [thickness, 0],
      [thickness, width],
      [0, width]
      ]);
}

module strap_gusset(thickness, width, hole_diam, length) {
  translate([0, length, 0])
    rotate([90, 0, 0])
      // convexity param fixes rendering artifact when applying difference
      // to the strap_gusset_hole.
      linear_extrude(height=length, convexity=2)
        strap_gusset_profile(thickness, width, hole_diam);
}

module strap_gusset_profile(thickness, width, hole_diam) {
  difference() {
    square(size=[thickness, width], center=false);
    translate([thickness/2, width/2, 0]) circle(d=hole_diam);
  }
}

module strap_gusset_hole(thickness, width, hole_diam, length) {
  translate([thickness/2, length+0.01, width/2, ])
    rotate([90, 0, 0])
      cylinder(h=length+0.02, d=hole_diam, $fs=0.5);
}