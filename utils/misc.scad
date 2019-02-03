include <metric_dimensions.scad>


translate([100,0,0]) motor_cover_shell(50, 40, 30, shell_wall=1,
bracing0=10, bracing1=20
);


color("blue")
translate([0,-10,0]) {
  $fn=20;
  symmetric_z_cylinder(6,20);
}

module symmetric_z_cylinder(d=undef, l=undef, r=undef, convexity=2) {
  assert((d>0 && r==undef) || (d==undef && r>0));
  assert(l!=undef && l>0);
  translate([0,0,-l/2])
    linear_extrude(height=l, convexity=convexity)
      circle(d=d, r=r);
}

module my_cylinder(r=undef, d=undef, r1=undef, r2=undef, h=undef, convexity=undef) {
  assert(r == undef || r1 == undef);
  R = r == undef ? r1 : r;
  assert(R == undef || d == undef);
  scale = (r1 != undef && r2 != undef) ? r2/r1 : 1;
  linear_extrude(height=h, convexity=convexity, scale=scale)
      circle(r=R, d=d);
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



translate([0, 0, 50]) nut_slot(nut_diam=10, nut_height=5, depth=15, bolt_diam=5, bolt_up=8, bolt_down=16);

module nut_slot(nut_diam=0, nut_height=0, depth=0, bolt_diam=0, bolt_up=0, bolt_down=0, fn=undef) {
  translate([0, 0, -nut_height/2]) {
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
            circle(d=bolt_diam, $fn=fn);
      }
      if (bolt_down > 0) {
        translate([0,0,-bolt_down])
          linear_extrude(height=bolt_down)
            circle(d=bolt_diam, $fn=fn);
      }
    }
  }
}

module nut(nut_hex_diam=undef, screw_diam=undef, nut_height=undef) {
  linear_extrude(height=nut_height) {
    difference() {
      circle(d=hex_short_to_long_diag(nut_hex_diam), $fn=6);
      circle(d=screw_diam, $fn=30);
    }
  }
}

module screw_boss(x, y, z, d, center=false, fn=undef) {
  xlate = center ? [0, 0, -z/2] : [x/2, y/2, 0];
  translate(xlate) {
    linear_extrude(height=z, convexity=10) {
      difference() {
        square([x, y], center=true);
        circle(d=d, $fn=fn);
      }
    }
  }
}
translate([0,0,0]) screw_boss(15,15,10,5, center=true);
translate([0,0,20]) screw_boss(15,15,10,5);

module demo_screw(shaft_diam, shaft_length, head_diam, head_height) {
  color("silver") {
    cylinder(d=head_diam, h=head_height);
    translate([0, 0, head_height])
      cylinder(d=shaft_diam, h=shaft_length);
  }
}

// Space to be occupied by a nut (show_boss=false) or a screw boss (show_boss=true)
// for the corresponding bolt.
module nut_slot_and_screw_boss(show_boss=true, nut_diam=0, nut_height=0, depth=0, bolt_diam=0, bolt_up=0, bolt_down=0, boss_w=0, boss_h=0, boss_z=0, boss_dist=0, fn=undef) {
  // x_offset = (shell2_outside_x + dec2_radius) / 2;
  // y_offset = nut_height+nut_slot_margin;

  if (show_boss) {
    z_dist = boss_dist == 0 ? 0 : (nut_height + boss_z) / 2 + abs(boss_dist);
    z_offset = boss_dist > 0 ? z_dist : -z_dist;
    translate([0, 0, z_offset])
      screw_boss(boss_w, boss_h, boss_z, bolt_diam, center=true, fn=fn);
  } else {
    nut_slot(nut_diam=nut_diam, nut_height=nut_height,
                   depth=depth,
                   bolt_diam=bolt_diam,
                   bolt_up=bolt_up,
                   bolt_down=bolt_down, fn=fn);
  }
}

module test_nut_slot_and_screw_boss(show_boss=true, below=false) {
  boss_dist = below ? -5 : 10;
  nut_slot_and_screw_boss(show_boss=show_boss, nut_diam=10, nut_height=5, depth=15, bolt_diam=5, bolt_up=30, bolt_down=20, boss_w=20, boss_h=12, boss_z=10, boss_dist=boss_dist, fn=20);
}

translate([-50, 0, 0]) {
  test_nut_slot_and_screw_boss(show_boss=true, below=false);
  test_nut_slot_and_screw_boss(show_boss=false, below=false);
  test_nut_slot_and_screw_boss(show_boss=true, below=true);
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


module mirrored(v=undef) {
  children();
  mirror(v=v) children();
}

// From OpenSCAD documentation/examples at:
//   https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Tips_and_Tricks#Filleting_objects
module offset_3d(r=1, size=1e12) {
  n = $fn==undef ? 12: $fn;
  if(r==0) {
    children();
  }  else {
    if( r>0 ) {
      minkowski() {
        children();
        sphere(r, $fn=n);
      }
    } else {
      size2 = size*[1,1,1];
      size1 = size2*0.99;
      difference() {
        cube(size2, center=true);
        minkowski() {
          difference(){
            cube(size1, center=true);
            children();
          }
          sphere(-r, $fn=n);
        }
      }
    }
  }
}
