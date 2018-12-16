include <ieq30pro-dimensions.scad>

// Distance from motor to shell around it.
dec_motor_gap = 2;

// Width of surface mating with DEC bearing cover.
dec_bearing_mating_length = min(dec2_len, 20);




    dec_motor_bearing_cover();


translate([200,0,0])
screw_gusset(15,15,10,5);








module screw_gusset(x, y, z, d) {
  linear_extrude(height=z) {
    difference() {
      square([x, y]);
      translate([x/2,y/2,0])
        circle(d=d);
    }
  }
}


// Helper for creating the hollow box
// around a motor cover. Has 3 sides,
// not counting those due to the non-zero
// thickness of the shell.
// extra_z is below the z=0 plane.
module motor_cover_shell(motor_w, motor_h, motor_z, motor_gap=2, shell_wall=0, shellw=0, shellh=0, shellz=0, extra_z=0, bracing0=0, bracing1=0) {

  shell_w = max(shell_wall, shellw);
  shell_z = max(shell_wall, shellz);

  assert(shellw>0);
  assert(shellz>0);

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
  
  if (bracing_z1 > 0) {
    // Add some strength at the z=0 plane.
  assert(shellh>0);
    linear_extrude(height=shell_wall, convexity=10)
      translate([-outer_w/2, motor_z + motor_gap - bracing_z1, 0]) 
        square([outer_w, bracing_z1+shell_wall]);
  }

  if (bracing1 > 0) {
    // Add some strength at the z=motor_h plane.
  assert(shellh>0);
    translate([0,0, motor_h-shell_wall])
      linear_extrude(height=shell_wall, convexity=10)
        translate([-outer_w/2, motor_z + motor_gap - bracing1, 0]) 
          square([outer_w, bracing1+shell_wall]);
  }
//    
//  
//  square([dec_motor_w+2*
  
}