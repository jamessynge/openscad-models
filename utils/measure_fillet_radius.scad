
include <../ioptron_ieq30pro/ieq30pro_dimensions.scad>

echo(str("ra_to_dec_fillet_diam = ", ra_to_dec_fillet_diam));
echo(str("ra_to_dec_fillet_radius_alt = ", ra_to_dec_fillet_radius_alt));
echo(str("ra_to_dec_fillet_radius = ", ra_to_dec_fillet_radius));

// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.

// module pie_profile(angle=75, radius=30) {
//   points = [
//       for(a = [0:1:angle]) [radius * cos(a), radius * sin(a)]
//   ];
//   polygon(concat([[0, 0]], points));
// }
// translate([60, 0, 0])
// pie_profile();

module pie_slice(angle=75, radius=30, thickness=50, text_depth=0.5) {
  module pie_profile(angle=75, radius=30) {
    points = [
        for(a = [0:1:angle]) [radius * cos(a), radius * sin(a)]
    ];
    polygon(concat([[0, 0]], points));
  }

  module label() {
    rotate([0, 0, angle/2])
    translate([radius*0.55, 0, -text_depth]) {
      linear_extrude(height=text_depth, convexity=10) {
        text(str("r=", radius),
             font = "Courier New; Style = Bold", 
             size = radius/6, 
             valign = "center",
             halign = "center");
      }
    }
  }

  difference() {
    linear_extrude(height=thickness, convexity=10) {
      pie_profile(angle=angle, radius=radius);
    }
    translate([0, 0, thickness])
      label();
  }
}

if (false) {
  start_r = 26.75;
  end_r = 29.0;
  r_step = 0.25;

  for (i = [0:30]) {
    r = start_r + i * r_step;
    if (r <= end_r) {
      u = i % 4;
      v = floor(i / 4);
      x = u * end_r * 1.1;
      y = v * end_r * 1.1;
      translate([x, y, 0]) {
        pie_slice(radius=r, thickness=r);
      }
    }
  }
}

// Instead of a pie_slice shape, this tool is a cylinder with two flat faces
// cut parallel to its axis of rotation, parallel to each other, each the same
// distance from the axis but on opposite sides. They leave a curved surface
// that subtends the same angle as above in pie_slice.
module cut_cylinder(angle=75, radius=30, thickness=50, text_depth=0.5) {
  module profile(angle=75, radius=30) {
    intersection() {
      circle(r=radius);
      h = radius * sin(angle/2) * 2;
      square([radius*3, h], center=true);
    }
  }
  *profile(angle=angle, radius=radius);

  module label() {
    translate([0, 0, -text_depth]) {
      linear_extrude(height=text_depth+0.1, convexity=20) {
        text(str("r=", radius),
             font = "Courier New; Style = Bold", 
             size = radius/4, 
             valign = "center",
             halign = "center");
      }
    }
  }

  translate([0, 0, 2]) {
    difference() {
      union() {
        mirror([0, 0, 1]) {
          // A little taper/chamfer so that we don't get a bulge at the bottom.
          linear_extrude(height=2, convexity=20, scale=1-1/radius) {
            profile(angle=angle, radius=radius);
          }
        }
        linear_extrude(height=thickness-4, convexity=20) {
          profile(angle=angle, radius=radius);
        }
        translate([0, 0, thickness-4]) {
          // A little taper/chamfer so that we don't get a bulge at the top.
          linear_extrude(height=2, convexity=20, scale=1-1/radius) {
            profile(angle=angle, radius=radius);
          }
        }
      }
      translate([0, 0, thickness-2]) {
        label();
      }
    }
  }
}

if (true) {
  start_r = 26.75;
  end_r = 29.0;
  r_step = 0.25;

  for (i = [0:30]) {
    r = start_r + i * r_step;
    if (r <= end_r) {
      u = i % 3;
      v = floor(i / 3);
      x = u * end_r * 2.1;
      y = v * end_r * 1.4;
      translate([x, y, 0]) {
        cut_cylinder(radius=r, thickness=r);
      }
    }
  }
}