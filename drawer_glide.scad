// Units: mm

// Glide dimensions:
glide_length = in_to_mm(14.5);
glide_width = 12; 
glide_depth = 5;



// Screw dimensions
// #6 x 1/2" (https://www.boltdepot.com/Product-Details.aspx?product=3953)

screw_diameter = in_to_mm(0.138);  // 3.5052
screw_head_angle = 82;
screw_head_height = in_to_mm(0.083);  // 2.1082

function in_to_mm(v) = v * 25.4;

// x-y origin (z-axis) is center of the hole.
module countersunk_through_hole(diam, length, head_angle, head_height, cs_depth) {
  assert(diam > 0);
  assert(length >= 0);
  assert(head_angle > 0);
  assert(head_angle < 180);
  assert(head_height > 0);

  radius = diam/2;
  head_dx = head_height * tan(head_angle / 2);

  x0 = 0;
  x1 = radius;
  x2 = x1 + head_dx;

  y0 = -1;  // This is a through-hole, so we go below zero to avoid z-fighting.
  y1 = length;
  y2 = y1 + head_height;
  y3 = y2 + cs_depth;

  rotate_extrude() {
    polygon(points=[
      [x0,y0],
      [x1,y0],
      [x1,y1],
      [x2,y2],
      [x2,y3],
      [x0,y3],
    ]);
  }
}

module num6_countersunk_through_hole() {
  length = 2.5;
  cs_depth = glide_depth - length - screw_head_height + 1;
  countersunk_through_hole(screw_diameter, length, screw_head_angle, screw_head_height, cs_depth);
}


*translate([0, 0, 20])
num6_countersunk_through_hole();

module glide_profile() {
  tip = glide_width*0.75;
  hull() {
    circle(d=tip);
    translate([glide_width, 0, 0])
      circle(d=glide_width);

    translate([glide_length - glide_width/2 - tip/2, 0, 0]) {
      #square(size=glide_width, center=true);
    }
  }
}

module glide() {
  rotate([0, 0, 45]) {
    difference() {
      linear_extrude(height=glide_depth) glide_profile();
      translate([glide_width, 0, 0]) {
        num6_countersunk_through_hole();
      }
      translate([in_to_mm(4.5), 0, 0]) {
        num6_countersunk_through_hole();
      }
      translate([in_to_mm(9), 0, 0]) {
        num6_countersunk_through_hole();
      }
      translate([in_to_mm(13.5), 0, 0]) {
        num6_countersunk_through_hole();
      }
    }
  }
}

glide();