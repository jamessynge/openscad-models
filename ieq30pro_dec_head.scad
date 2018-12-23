// Defines the moving portion of the DEC axis,
// which has the dovetail saddle for holding a
// telescope atop the mount.

// dec_head accepts up to two children:
//
// 1) The first is centered on the plane of the base
//    of the dec_head, with z=0 and the clutch is
//    on the y-axis at x=0.
//
// 2) The second is placed into the plane of the
//    dovetail saddle, with the x-axis aligned with
//    the long direction of a dovetail, and with the
//    clutch down (i.e. x=0, y negative).

// Units: mm

use <chamfer.scad>
include <ieq30pro_dimensions.scad>
use <ieq30pro_clutch.scad>
use <axis_arrows.scad>

dec_head() {
  color("red") {
    echo("executing dec_head child 1");
    r = dec_head_base_diam/2;
    linear_extrude(height=4) {
      difference() {
        circle(r=r + 10);
        circle(r=r + 5);
      };
      translate([r+10,0,0])
        square(size=10, center=true);
    };
    axis_arrows(total_length=r*1.5);
  };

  color("green") {
    echo("executing dec_head child 2");
    r = dec_head_base_diam/2;
    translate([20,10,10]) sphere(r=10);
    axis_arrows(total_length=r);
  };
};

module dec_head() {
  echo("dec_head has", $children, "children");

  base_r = dec_head_base_diam / 2;
  inner_r = dec_head_diam1 / 2;
  color(cast_iron_color) {
    difference() {
      union() {
        cylinder(h=dec_head_base_height, r=base_r);
      
        translate([0,0,dec_head_base_height])
          linear_extrude(
              height=dec_head_height,
              scale=dec_head_scale)
            dec_head_extrusion_profile();
      };
      dec_saddle_inverse();
      dec_slot_inverse();
      dec_head_clamp_screw_holes();
    };
  };

  translate([inner_r-2,0,0])
    rotate([90,0,90])
      clutch();
  
  if ($children > 0) {
    rotate([0, 0, 90]) {
      echo("dec_head rendering child 0");
      !children(0);

      if ($children > 1) {
        raise_by = dec_head_base_height
          + dec_head_height - dec_saddle_depth + 0.01;
        translate([0,0,raise_by]) {
          echo("dec_head rendering child 1");
          children(1);
        }
      }
    }
  }
}

module dec_saddle_inverse() {
  hw1 = dovetail_width / 2;
  hw2 = dec_saddle_width2 / 2;
  hw3 = dec_saddle_width1 / 2;
  dw = dec_saddle_width2 - dec_saddle_width1;
  raise_by = dec_head_base_height + dec_head_height
      - dec_saddle_depth + 0.01;
  
  translate([0,0,raise_by])
    rotate([90, 0, 0])
      translate([0,0,-dec_head_base_diam])
        linear_extrude(height=dec_head_base_diam*2)
          // Profile of a dovetail plate on one side, but
          // vertical on the other wide (where the mount
          // has screws to secure a dovetail plate).
          polygon([
            [0,0],
            [hw1, 0],
            [hw1 - dw, dec_saddle_depth],
            [-hw3, dec_saddle_depth],
            [-hw3, 0]
          ]);
}

module dec_slot_inverse() {
  r = dec_slot_corner_radius;
  hw = dec_slot_width / 2 - r;
  hl = dec_slot_len / 2 - r;
  raise_by = dec_head_base_height + dec_head_height
      - dec_saddle_depth + 0.01;

  translate([0,0,raise_by])
  linear_extrude(height=dec_saddle_depth)
    hull() {
      translate([hw,hl]) circle(r=r);
      translate([hw,-hl]) circle(r=r);
      translate([-hw,-hl]) circle(r=r);
      translate([-hw,hl]) circle(r=r);
    };
}

module dec_head_extrusion_profile() {
  s = dec_head_square/2;
  intersection() {
    union() {
      circle(r=dec_head_diam1/2);
      translate([-s, -s])
        square(size=[s, dec_head_square]);
    };
    circle(r=dec_head_base_diam/2);
  };
}

module dec_head_clamp_screw_holes() {
  raise_by = dec_head_base_height + dec_head_height
      - dec_head_clamp_screw_depth;
  y = dec_head_clamp_screw_spacing / 2;
  translate([0,y,raise_by])
    rotate([0, -90, 0])
      cylinder(h=dec_head_base_diam/2,
               r=dec_head_clamp_screw_diam/2);

  translate([0,-y,raise_by])
    rotate([0, -90, 0])
      cylinder(h=dec_head_base_diam/2,
               r=dec_head_clamp_screw_diam/2);
}
