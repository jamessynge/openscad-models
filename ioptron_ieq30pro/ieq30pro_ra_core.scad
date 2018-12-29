// Models the non-moving portion of the RA axis of the iEQ30 Pro, along with
// the plastic enclosing the motor and electronics, and the polar scope cap
// at the bottom of the axis (the top being where the moving portion of
// the RA axis attaches).
// Author: James Synge
// Units: mm

// ra_core accepts up to ??? children:
//
//

// Units: mm

include <ieq30pro_dimensions.scad>
use <four_star_knob.scad>
use <../utils/axis_arrows.scad>
use <../utils/chamfer.scad>

//ra_body();

module ra_body() {
  // To avoid modeling more of the RA body,
  // we extend the ra3 section longer ... for now.
  ra3_extra_long = ra3_len * 4;
  color(cast_iron_color) {
    cylinder(h=ra2_len, r=ra2_radius);
    translate([0, 0, ra2_len])
      cylinder(h=ra3_extra_long, r=ra3_radius);
  }

  ra_motor_and_electronics();
}

// A little decoration for the model, so that the
// two sides of the RA bearing aren't butted up
// against each other in an unrealistic fashion,
// and to match the way the mount actually looks;
// i.e. there is a very small gap between the two
// sides through which we can see silver colored
// metal.
module ra_bearing() {
  h=ra_bearing_gap+1;
  color(bearing_color)
    translate([0, 0, -h/2])
      cylinder(h=h, r=ra2_radius-2);
}

module ra_motor_and_electronics() {
  ra_z_offset = ra2_radius + ra_cover_height - ra_motor_z;
  rotate([90,0,0])

        translate([-x/2, 0.01, ra_z_offset])
    ra_motor();
}

*translate([200, 0, 0]) ra_motor();


module ra_motor() {
  // RA motor/electronics cover dimensions, arranged
  // very much like the DEC motor cover.
  // x is perpendicular to the ground and to the
  // RA axis; y is parallel to the RA axis; z is
  // distance from the RA axis.
  x = ra_motor_w;
  y = ra_motor_h;
  z = ra_motor_z;   // top of cover to intersection
            //with ra2_diam.
  
      color(plastic_color)
          intersection() {
            chamferCube(x,y,z,chamferHeight=12,
              chamferX=[0,0,0,1], chamferY=[0,0,0,0],
              chamferZ=[0,0,0,0]);
            chamferCube(x,y,z,chamferHeight=4,
              chamferX=[0,0,1,0], chamferY=[0,1,1,0],
              chamferZ=[0,0,0,0]);
          };
}


ra_motor2();

module ra_motor2() {
  h1 = 96;
  d1 = 5;
  h2 = h1 - 2*d1;
  d2 = 18 + d1;
  h3 = h1 - 2 * d2;

  // The chamfer produced by offset() isn't quite what is desired at the back
  // of the motor, so intersect with a big cube to cut off a bit better.
  intersection() {
    union() {
      hull() {
        linear_extrude(height=h1) ra_motor_profile1();
        translate([0,0,d1]) 
          linear_extrude(height=h2) ra_motor_profile2();
        translate([0,0,d2]) 
          linear_extrude(height=h3) ra_motor_profile3();
      }
      ra_motor_bump();
    }
  ra_motor_profile1_hl = 42.15;  // ra_motor_profile1.hl
  
  translate([-5, ra_motor_profile1_hl, 0])
  rotate([0, 0, -45])
  translate([0, -50, 0])
  cube([100, 100, 100], center=false);
  }



}

module ra_motor_bump() {
  z = 5;
  w1 = 21.75;
  w2 = w1 - 2 * z;
  h1 = 42.15;  // ra_motor_profile1.hl
  h2 = h1 - 2 * z;

  sw = w2 / w1;
  sh = h2 / h1;

//  rotate([0,0,-2])
  rotate([0, -90, -0.5])
  translate([w1/2+z+44.5, h1/2 + 1, z-0.1])
  linear_extrude(height=z, scale=[sw, sh])
    square(size=[w1, h1], center=true);
}

*color("red") translate([0, 0, 0]) ra_motor_profile1();
module ra_motor_profile1() {
  wb = 65.1;
  wm = 64.6;
  wt = 30;

  wdiff = wb - wm;
  wdhalf = wdiff / 2;

  hr = 30;
  hm = 41.6;
  hl = 42.15;

  x1 = 0;
  x2 = x1 + wdhalf * 1.5;
  x3 = x2 + wt;
  x4 = wb - wdhalf;
  x5 = wb;

  polygon([
    [x1,0],
    [x5,0],
    [x4,hr],
    [x3,hm],
    [x2,hl],
    [x1,0],
    ]);
}

*color("blue") translate([0, 0, -5]) ra_motor_profile2();
module ra_motor_profile2() {
  wb = 65.1;
  intersection() {
    offset(delta=5, chamfer=true) ra_motor_profile1();
    // scale([1.5, 1.5, 1.5]) ra_motor_profile1();
    translate([wb, 0, 0])
    scale([1.5, 1.5, 1.5]) translate([-wb,0,0]) ra_motor_profile1();
  }
}

*translate([0, 0, -24.3]) ra_motor_profile3();
module ra_motor_profile3() {
  wb = 65.1;
  wm = 64.3;
  wt = 50.1;

  wdiff = wb - wm;
  wdhalf = wdiff / 2;

  hr = 33.5;
  hm = 46.3;
  hl = 46.5;

  x1 = 0;
  x2 = x1 + wdhalf * 1.5;
  x3 = x2 + wt;
  x4 = wb - wdhalf;
  x5 = wb;

  polygon([
    [x1,0],
    [x5,0],
    [x4,hr],
    [x3,hm],
    [x2,hl],
    [x1,0],
    ]);
}
