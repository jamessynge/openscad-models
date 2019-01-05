// Support for screwing two parts together where one will hold a nut, and
// a screw will be inserted through the other part into the first part and then
// through the nut to draw the two parts together.

// Author: James Synge
// Units: mm

//
// Dimensions:
//
// screw_hole_diam
//    Diameter of hole for screw (e.g. 4.5mm for an M4 screw).
// nut_hex_diam
//    Width across the flat faces of a hex nut.
// nut_height
//    Height / thickness of the nut.
// nut_gusset_diam
//    Diameter of the body that holds the nut.
// nut_recess
//    How far below the surface of the gusset the nut is recessed. Typically
//    zero to a few millimeters.
// nut_depth
//    Distance from parting plane (z=0 in this model) to the start of the nut.
// screw_head_diam
//    Diameter of the head of the screw. If using a washer with the screw,
//    instead specify the diameter of the washer.
// screw_head_depth
//    Distance from parting plane (z=0 in this model) to the start of the head.
// screw_head_recess
//    How far below the surface of the gusset the head is recessed.
//    Must be >= 0.

include <metric_dimensions.scad>
use <misc.scad>

// Global resolution
$fs = $preview ? 1 : 1;
$fa = $preview ? 5 : 1;

////////////////////////////////////////////////////////////////////////////////

module gusset_alignment_cone(solid=false, screw_hole_diam=undef, cone_height=undef, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {
  assert(cone_height > 0);
  assert(cone_diam1 > 0);
  assert(cone_diam2 > 0);
  assert(cone_diam1 > cone_diam2);
  difference() {
    linear_extrude(height=cone_height, convexity=3, scale=cone_diam2/cone_diam1)
      circle(d=cone_diam1, $fn=cone_fn);
    if (!solid) {
      translate([0, 0, -0.01])
      linear_extrude(height=cone_height+.02, convexity=3)
        circle(d=screw_hole_diam);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// Defines the inside of the gusset for holding a nut in a recessed hole, but
// the outside 2D profile must be passed in as the first and only child.
module generic_recessed_nut_gusset(solid=false, screw_hole_diam=undef, nut_hex_diam=undef, nut_height=undef, nut_recess=0, nut_depth=undef, nut_hole_scale_factor=1.02) {
  assert($children == 1);
  // $fs = min($fs, 2);
  if (solid) {
    h = nut_height + nut_recess + nut_depth;
    linear_extrude(height=h, convexity=3) {
      children(0);
    }
  } else {
    linear_extrude(height=nut_depth, convexity=3) {
      difference() {
        children(0);
        circle(d=screw_hole_diam);
      }
    }
    translate([0, 0, nut_depth]) {
      linear_extrude(height=nut_height + nut_recess, convexity=3) {
        difference() {
          children(0);
          circle(d=nut_hole_scale_factor*hex_short_to_long_diag(nut_hex_diam), $fn=6);
        }
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////

module round_nut_gusset(solid=false, nut_gusset_diam=undef, screw_hole_diam=undef, nut_hex_diam=undef, nut_height=undef, nut_recess=0, nut_depth=undef) {
  generic_recessed_nut_gusset(solid=solid, screw_hole_diam=screw_hole_diam, nut_hex_diam=nut_hex_diam, nut_height=nut_height, nut_recess=nut_recess, nut_depth=nut_depth) {
    circle(d=nut_gusset_diam);
  }
}
// Example:
color("red") {
  round_nut_gusset(
    solid=false, nut_gusset_diam=2*m4_nut_diam1, screw_hole_diam=m4_hole_diam,
    nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height, nut_recess=1,
    nut_depth=10);
  translate([0, 20, 0])
    round_nut_gusset(
      solid=true, nut_gusset_diam=2*m4_nut_diam1, screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
      nut_height=m4_nut_height, nut_recess=1,
      nut_depth=10);
}
if ($preview)
  translate([0, 0, 10])
    nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
        nut_height=m4_nut_height);


module round_top_nut_gusset(
  solid=false, nut_gusset_diam=undef, nut_gusset_height=undef, screw_hole_diam=undef, nut_hex_diam=undef, nut_height=undef, nut_recess=0, nut_depth=undef) {
  generic_recessed_nut_gusset(solid=solid, screw_hole_diam=screw_hole_diam, nut_hex_diam=nut_hex_diam, nut_height=nut_height, nut_recess=nut_recess, nut_depth=nut_depth) {
    union() {
      circle(d=nut_gusset_diam);
      translate([-nut_gusset_diam/2, -nut_gusset_height, 0])
        square(size=[nut_gusset_diam, nut_gusset_height]);
    }
  }
}
// Example:
translate([30, 0, 0]) color("green") {
  round_top_nut_gusset(
    solid=false, nut_gusset_diam=12, nut_gusset_height=12,
    screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
    nut_height=m4_nut_height, nut_recess=-.1, nut_depth=12);

  translate([0, 30, 0])
    round_top_nut_gusset(
      solid=true, nut_gusset_diam=12, nut_gusset_height=12,
      screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
      nut_height=m4_nut_height, nut_recess=1, nut_depth=12);
}
if ($preview)
  translate([30, 0, 12])
    nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
        nut_height=m4_nut_height);

////////////////////////////////////////////////////////////////////////////////

module nut_gusset_alignment_hole(cone_height=undef, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {
  gusset_alignment_cone(
    solid=true, cone_height=cone_height,
    cone_diam1=cone_diam1, cone_diam2=cone_diam2, cone_fn=cone_fn);
}

// Example:
translate([60, 0, 0]) color("orange") {
  difference() {
    round_nut_gusset(
      solid=false, nut_gusset_diam=4*m4_nut_diam1, screw_hole_diam=m4_hole_diam,
      nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height, nut_recess=0.5,
      nut_depth=10);
    translate([0,0,-0.001])
    nut_gusset_alignment_hole(
      cone_height=5, cone_diam1=3*m4_hole_diam, cone_diam2=2*m4_hole_diam, cone_fn=undef);
  }

  translate([0, 30, 0])
  difference() {
    round_top_nut_gusset(
      solid=true, nut_gusset_diam=12, nut_gusset_height=12,
      screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
      nut_height=m4_nut_height, nut_recess=1, nut_depth=12);
    translate([0,0,-0.001])
      nut_gusset_alignment_hole(
        cone_height=5, cone_diam1=2*m4_hole_diam, cone_diam2=1.75*m4_hole_diam, cone_fn=undef);
  }
}
if ($preview)
  translate([60, 0, 10])
    nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
        nut_height=m4_nut_height);


////////////////////////////////////////////////////////////////////////////////

module nut_gusset_alignment_cone(solid=false, screw_hole_diam=undef, cone_height=undef, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {
  // $fs = min($fs, 2);
  mirror([0, 0, 1]) {
    gusset_alignment_cone(
      solid=solid, screw_hole_diam=screw_hole_diam, cone_height=cone_height,
      cone_diam1=cone_diam1, cone_diam2=cone_diam2, cone_fn=cone_fn);
  }
}

// Example:
translate([90, 0, 0]) color("blue") {
  round_top_nut_gusset(
    solid=false,
    nut_gusset_diam=3*m4_hole_diam, nut_gusset_height=3*m4_hole_diam,
    screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
    nut_height=m4_nut_height, nut_depth=12);
  nut_gusset_alignment_cone(
    solid=false, screw_hole_diam=m4_hole_diam, cone_height=5,
    cone_diam1=3*m4_hole_diam, cone_diam2=2*m4_hole_diam, cone_fn=4);

  translate([0, 30, 0]){
    round_top_nut_gusset(
      solid=true,
      nut_gusset_diam=3*m4_hole_diam, nut_gusset_height=3*m4_hole_diam,
      screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
      nut_height=m4_nut_height, nut_recess=1, nut_depth=12);
    nut_gusset_alignment_cone(
      solid=true, screw_hole_diam=m4_hole_diam, cone_height=5,
      cone_diam1=2.5*m4_hole_diam, cone_diam2=1.5*m4_hole_diam, cone_fn=undef);
  }
}
if ($preview)
  translate([90, 0, 12])
    nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
        nut_height=m4_nut_height);

////////////////////////////////////////////////////////////////////////////////
// Defines the inside of the gusset for holding a nut in a slot, but the
// outside 2D profile must be passed in as the first and only child.
module generic_nut_slot(screw_hole_diam=undef, nut_hex_diam=undef, nut_height=undef,
  nut_depth=undef, screw_extension=undef,
   nut_hole_scale_factor=1.02, slot_depth=undef, nut_diam_to_slot_depth_multiplier=1,
    nut_height_scale=1,
   nut_slot_angle=0) {
  // We need to allow for maximum size of the nut and minimum size of the hole
  // (~shrinkage of hole during 3D printing process).
  nut_hex_diam_final = nut_hex_diam * nut_hole_scale_factor;
  nut_height_final = nut_height * nut_hole_scale_factor;
  total_height = nut_depth + nut_height + screw_extension;
  nut_height_extra = nut_height_final - nut_height;

  cylinder(d=screw_hole_diam, h=total_height);
  translate([0, 0, nut_depth - nut_height_extra / 2]) {
    slot_depth_final =
      slot_depth==undef ?
        nut_hex_diam_final*nut_diam_to_slot_depth_multiplier :
        slot_depth;
    linear_extrude(height=nut_height_final, convexity=3) {
      rotate([0, 0, nut_slot_angle]) {
        //rotate([0,0,360/12])
        circle(d=hex_short_to_long_diag(nut_hex_diam_final), $fn=6);
        translate([0, -nut_hex_diam_final/2])
          square(size=[slot_depth_final, nut_hex_diam_final], center=false);
      }
    }
  }
}

translate([120, 0, 0]) color("purple") {
  generic_nut_slot(screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height, 
    nut_depth=10, screw_extension=10, nut_slot_angle=45);
  translate([0, 30, 0]) {
    difference() {
      cylinder(h=20, d=2*m4_nut_diam1);
      translate([0, 0, -0.01])
        generic_nut_slot(screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height, 
          nut_depth=10, screw_extension=10, nut_slot_angle=-45);
    }
  }
}
if ($preview)
  translate([120, 30, 10])
    rotate([0, 0, -45])
    nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
        nut_height=m4_nut_height);

////////////////////////////////////////////////////////////////////////////////
// Creates a screw gusset, but this module only has the code for the inside of
// the gusset, the outside 2D profile must be passed in as the first and only
// child.
// We assume here that the outer profile is large enough to support the screw
// head or washer, and to enclose the hole for the screw head/washer, if
// screw_head_recess>0.

module generic_recessed_screw_gusset(
    solid=false, screw_hole_diam=undef, screw_head_diam=undef, washer_diam=undef,
    screw_head_recess=undef, screw_head_depth=undef, screw_head_scale_factor=1.02,
    cone_height=undef, cone_diam1=undef, cone_diam2=undef, cone_fn=undef
    ) {
  assert($children == 1);
  assert(screw_head_recess==undef || screw_head_recess>0);
  assert(screw_head_diam!=undef || washer_diam>0);
  outer_diam = (screw_head_diam== undef ? washer_diam : screw_head_diam) * screw_head_scale_factor;
  mirror([0, 0, 1]) {
    difference() {
      union() {
        if (solid) {
          h = (screw_head_recess>0 ? screw_head_recess : 0) + screw_head_depth;
          linear_extrude(height=h, convexity=3) {
            children(0);
          }
        } else {
          linear_extrude(height=screw_head_depth, convexity=3) {
            difference() {
              children(0);
              circle(d=screw_hole_diam);
            }
          }
          if (screw_head_recess > 0) {
            translate([0, 0, screw_head_depth]) {
              linear_extrude(height=screw_head_recess, convexity=3) {
                difference() {
                  children(0);
                  circle(d=outer_diam);
                }
              }
            }
          }
        }
      }
      // Make alignment hole if cone_height < 0.
      if (cone_height < 0) {
        gusset_alignment_cone(
            solid=solid, screw_hole_diam=screw_hole_diam,
            cone_height=-cone_height, cone_diam1=cone_diam1,
            cone_diam2=cone_diam2, cone_fn=cone_fn);
      }
    }
  }
  if (cone_height > 0) {
    gusset_alignment_cone(
        solid=solid, screw_hole_diam=screw_hole_diam,
        cone_height=cone_height, cone_diam1=cone_diam1,
        cone_diam2=cone_diam2, cone_fn=cone_fn);
  }
}


module example_generic_recessed_screw_gusset(solid=false) {
  // Without recess or alignment cone.
  generic_recessed_screw_gusset(
    solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
    screw_head_depth=10) {
    circle(d=m4_washer_diam);
  }

  // With alignment cone.
  translate([0, -30, 0])
  generic_recessed_screw_gusset(
    solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
    screw_head_depth=15,
    cone_height=5, cone_diam1=m4_hole_diam*2.25,
        cone_diam2=m4_hole_diam*1.75) {
    circle(d=max(2.5*m4_hole_diam, m4_washer_diam));
  }

  // With recess and alignment cone.
  translate([0, -60, 0])
  generic_recessed_screw_gusset(
    solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
    screw_head_depth=15, screw_head_recess=5,
    cone_height=5, cone_diam1=m4_hole_diam*2.25,
        cone_diam2=m4_hole_diam*1.75) {
    circle(d=max(2.5*m4_hole_diam, 1.5*m4_washer_diam));
  }

}

// Example:
translate([0, -30, 0])
  color("red")
    example_generic_recessed_screw_gusset(solid=false);

translate([30, -30, 0])
  color("red")
    example_generic_recessed_screw_gusset(solid=true);



// screw_hole_diam
//    Diameter of hole for screw (e.g. 4.5mm for an M4 screw).
// nut_hex_diam
//    Width across the flat faces of a hex nut.
// nut_height
//    Height / thickness of the nut.
// nut_gusset_diam
//    Diameter of the body that holds the nut.
// nut_recess
//    How far below the surface of the gusset the nut is recessed. Typically
//    zero to a few millimeters.
// nut_depth
//    Distance from parting plane (z=0 in this model) to the start of the nut.
// screw_head_diam
//    Diameter of the head of the screw. If using a washer with the screw,
//    instead specify the diameter of the washer.
// screw_head_depth
//    Distance from parting plane (z=0 in this model) to the start of the head.
// screw_head_recess
//    How far below the surface of the gusset the head is recessed.
//    Must be >= 0.
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
