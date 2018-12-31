

translate([0,0,0])
screw_gusset(15,15,10,5);


translate([100,0,0]) motor_cover_shell(50, 40, 30, shell_wall=1,
bracing0=10, bracing1=20
);

translate([0, 50, 0])
nut_slot(d=10, h=5, depth=15, bolt_diam=5, bolt_len=20);

translate([20, 50, 0])
nut_slot(d=10, h=5, depth=15, bolt_diam=5, bolt_len=-20);





module screw_gusset(x, y, z, d) {
  linear_extrude(height=z, convexity=10) {
    difference() {
      square([x, y]);
      translate([x/2,y/2,0])
        circle(d=d);
    }
  }
}

color("blue")
translate([0,-10,0]) {
  $fn=20;
  symmetric_z_cylinder(6,20);
}

module symmetric_z_cylinder(d, l) {
  assert(d>0);
  assert(l>0);
  translate([0,0,-l/2])
    cylinder(h=l, d=d);
}



// Helper for creating the hollow box
// around a motor cover. Has 3 sides,
// not counting those due to the non-zero
// thickness of the shell.
// extra_z is below the z=0 plane.
module motor_cover_shell(motor_w, motor_h, motor_z, motor_gap=2, shell_wall=0, shellw=0, shellh=0, shellz=0, extra_z=0, bracing0=0, bracing1=0) {

  shell_w = max(shell_wall, shellw);
  shell_h = max(shell_wall, shellh);
  shell_z = max(shell_wall, shellz);

  assert(shell_w>0);
  assert(shell_z>0);

  inner_w=motor_w + motor_gap*2;
  inner_z=motor_z + motor_gap + extra_z;
  
  outer_w = inner_w + shell_w * 2;
  outer_z = inner_z + shell_z;

  linear_extrude(height=motor_h, convexity=10) {
    translate([-outer_w/2, -extra_z, 0]) {
      difference() {
        square([outer_w, outer_z], center=false);
        translate([shell_w,0,0])
          square([inner_w, inner_z], center=false);
      }
    }
  }
  
  if (bracing0 > 0) {
    // Add some strength at the z=0 plane.
    assert(shell_h>0);
    linear_extrude(height=shell_wall, convexity=10)
      translate([-outer_w/2, motor_z + motor_gap - bracing0, 0]) 
        square([outer_w, bracing0+shell_wall]);
  }

  if (bracing1 > 0) {
    // Add some strength at the z=motor_h plane.
    assert(shell_h>0);
    translate([0,0, motor_h-shell_wall])
      linear_extrude(height=shell_wall, convexity=10)
        translate([-outer_w/2, motor_z + motor_gap - bracing1, 0]) 
          square([outer_w, bracing1+shell_wall]);
  }
}

// Given the width across a six sided nut (flat side to flat side),
// how wide is the nut from point to farthest point (i.e. what is the
// diameter of the smallest circle that will enclose the nut).
function hex_short_to_long_diag(d) = d * 2.0 / sqrt(3.0);

module nut_slot(nut_diam=0, nut_height=0, depth=0, bolt_diam=0, bolt_up=0, bolt_down=0) {
  rotate([0,0,360/12])
    linear_extrude(height=nut_height)
      circle(d=hex_short_to_long_diag(nut_diam), $fn=6);
  linear_extrude(height=nut_height)
    translate([-nut_diam/2, 0, 0])
      square([nut_diam, depth], center=false);

  assert(bolt_diam >= 0);
  assert(bolt_up >= 0);
  assert(bolt_down >= 0);

  if (bolt_diam > 0) {
    if (bolt_up > 0) {
      translate([0,0,nut_height])
        linear_extrude(height=bolt_up)
          circle(d=bolt_diam, $fn=20);
    }
    if (bolt_down > 0) {
      translate([0,0,-bolt_down])
        linear_extrude(height=bolt_down)
          circle(d=bolt_diam, $fn=20);
    }
  }
}

module fillet_outline(radius) {
  intersection() {
    square([radius, radius], center=false);
    translate([radius, radius])
      difference() {
        circle(r=radius*2);
        circle(r=radius);
      };
  }
}

module fillet_extrusion(radius, length, scale=1.0) {
  linear_extrude(height=length, scale=scale)
    fillet_outline(radius);
}
translate([0,-20,0])
fillet_extrusion(5,15,scale=0.5);


module annulus(d1=undef, r1=undef, d2=undef, r2=undef, solid=false) {
  difference() {
    circle(r=r2, d=d2);
    // solid is support for creating solids for CSG operations.
    if (!solid) circle(r=r1, d=d1);
  };
}
