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
// nut_boss_diam
//    Diameter of the body that holds the nut.
// nut_recess
//    How far below the surface of the boss the nut is recessed. Typically
//    zero to a few millimeters.
// nut_depth
//    Distance from parting plane (z=0 in this model) to the start of the nut.
// screw_head_diam
//    Diameter of the head of the screw. If using a washer with the screw,
//    instead specify the diameter of the washer.
// screw_head_depth
//    Distance from parting plane (z=0 in this model) to the start of the head.
// screw_head_recess
//    How far below the surface of the boss the head is recessed.
//    Must be >= 0.

include <metric_dimensions.scad>
use <misc.scad>

// Global resolution
$fs = $preview ? 1 : 1;
$fa = $preview ? 5 : 1;

////////////////////////////////////////////////////////////////////////////////

module boss_alignment_cone(solid=false, screw_hole_diam=undef, cone_height=undef, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {
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
// Creates a screw boss, but this module only has the code for the inside of
// the boss, the outside 2D profile must be passed in as the first and only
// child.
// We assume here that the outer profile is large enough to support the screw
// head or washer, and to enclose the hole for the screw head/washer, if
// screw_head_recess>0.

module generic_screw_boss(
    solid=false, screw_hole_diam=undef, screw_head_diam=0, washer_diam=0,
    screw_head_recess=0, screw_head_depth=undef, screw_head_scale_factor=1.02,
    cone_height=0, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {
  assert($children == 1);
  assert(screw_head_depth>0);
  assert(screw_head_recess>=0);
  assert(screw_head_diam>0 || washer_diam>0);
  assert(cone_height==0 || cone_diam1>0);
  assert(cone_height==0 || cone_diam2>0);

  outer_diam = max(screw_head_diam, washer_diam) * screw_head_scale_factor;
  mirror([0, 0, 1]) {
    difference() {
      union() {
        if (solid) {
          h = screw_head_recess + screw_head_depth;
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
      // Make alignment hole if cone_height < 0, but not if supposed to be
      // solid.
      if (cone_height < 0 && !solid) {
        translate([0, 0, -0.001])
          boss_alignment_cone(
              solid=true, cone_height=-cone_height, cone_diam1=cone_diam1,
              cone_diam2=cone_diam2, cone_fn=cone_fn);
      }
    }
  }
  if (cone_height > 0) {
    boss_alignment_cone(
        solid=solid, screw_hole_diam=screw_hole_diam,
        cone_height=cone_height, cone_diam1=cone_diam1,
        cone_diam2=cone_diam2, cone_fn=cone_fn);
  }
}

module example_generic_screw_boss(solid=false) {
  // Without recess or alignment cone.
  generic_screw_boss(
    solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
    screw_head_depth=10) {
    circle(d=m4_washer_diam);
  }
  // With alignment cone.
  translate([0, -30, 0])
  generic_screw_boss(
    solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
    screw_head_depth=15,
    cone_height=5, cone_diam1=m4_hole_diam*2.25,
        cone_diam2=m4_hole_diam*1.75) {
    circle(d=max(2.5*m4_hole_diam, m4_washer_diam));
  }
  // With recess and alignment cone.
  translate([0, -60, 0])
  generic_screw_boss(
    solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
    screw_head_depth=15, screw_head_recess=5,
    cone_height=-5, cone_diam1=m4_hole_diam*2.25,
        cone_diam2=m4_hole_diam*1.75) {
    circle(d=max(2.5*m4_hole_diam, 1.5*m4_washer_diam));
  }
}

// Example:
translate([0, -30, 0])
  color("red")
    example_generic_screw_boss(solid=false);

translate([30, -30, 0])
  color("red")
    example_generic_screw_boss(solid=true);

////////////////////////////////////////////////////////////////////////////////
// Creates a nut boss for holding a nut in a recessed hole), but
// the outside 2D profile must be passed in as the first and only child.
// We assume here that the outer profile is large enough to enclose the nut with
// enough material so that the rotary forces on the nut don't break through the
// walls.
module generic_recessed_nut_boss(
    solid=false, screw_hole_diam=undef, nut_hex_diam=undef, nut_height=undef,
    nut_recess=0, nut_depth=0, nut_hole_scale_factor=1.02,
    cone_height=0, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {
  assert($children == 1);
  assert(screw_hole_diam > 0);
  assert(screw_hole_diam < nut_hex_diam);
  assert(nut_recess >= 0);
  assert(nut_depth > 0);
  assert(cone_height==0 || cone_diam1!=undef);
  assert(cone_height==0 || cone_diam2!=undef);
  assert(cone_height > 0 || nut_depth > -cone_height);

  if (solid) {
    h = nut_height + nut_recess + nut_depth;
    linear_extrude(height=h, convexity=3) {
      children(0);
    }
  } else {
    difference() {
      linear_extrude(height=nut_depth, convexity=3) {
        difference() {
          children(0);
          circle(d=screw_hole_diam);
        }
      }
      // Make alignment hole if cone_height < 0, but not if supposed to be
      // solid.
      if (cone_height < 0 && !solid) {
        translate([0, 0, -0.001])
          boss_alignment_cone(
              solid=true, cone_height=-cone_height, cone_diam1=cone_diam1,
              cone_diam2=cone_diam2, cone_fn=cone_fn);
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
  if (cone_height > 0) {
    mirror([0, 0, 1]) {
      boss_alignment_cone(
          solid=solid, screw_hole_diam=screw_hole_diam,
          cone_height=cone_height, cone_diam1=cone_diam1,
          cone_diam2=cone_diam2, cone_fn=cone_fn);
    }
  }
}

module example_generic_recessed_nut_boss(solid=false) {
  // Without extra recess or alignment cone.
  generic_recessed_nut_boss(
    solid=solid, screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
    nut_height=m4_nut_height, nut_depth=12) {
    square(size=m4_nut_diam2*1.5, center=true);
  }

  // With alignment cone.
  translate([0, 30, 0])
  generic_recessed_nut_boss(
    solid=solid, screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
    nut_height=m4_nut_height, nut_depth=12,
    cone_height=5, cone_diam1=m4_hole_diam*2.25,
        cone_diam2=m4_hole_diam*1.75) {
    circle(d=max(2.5*m4_hole_diam, m4_washer_diam));
  }
  // With extra recess and alignment hole.
  translate([0, 60, 0])
  generic_recessed_nut_boss(
    solid=solid, screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
    nut_height=m4_nut_height, nut_recess=m4_nut_height*0.1, nut_depth=12,
    cone_height=-5, cone_diam1=m4_hole_diam*2.25,
        cone_diam2=m4_hole_diam*1.75) {
    circle(d=max(2.5*m4_hole_diam, 1.5*m4_washer_diam), $fn=5);
  }
}

// Example:
translate([0, 30, 0])
  color("skyblue")
    example_generic_recessed_nut_boss(solid=false);

translate([30, 30, 0])
  color("skyblue")
    example_generic_recessed_nut_boss(solid=true);


////////////////////////////////////////////////////////////////////////////////
// Creates a nut boss for holding a nut in a slotted hole), but
// the outside 2D profile must be passed in as the first and only child.
// We assume here that the outer profile is large enough to enclose the nut with
// enough material so that the rotary forces on the nut don't break through the
// walls.

module generic_slotted_nut_boss(
    solid=false, screw_hole_diam=undef, boss_height=undef, nut_depth=0, screw_extension=0,
    nut_hex_diam=undef, nut_height=undef, nut_hole_scale_factor=1.02,
    slot_depth=undef, nut_diam_to_slot_depth_multiplier=3, nut_slot_angle=0,
    cone_height=0, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {
  assert($children == 1);
  assert(screw_hole_diam > 0);
  assert(nut_hex_diam > 0);
  assert(screw_hole_diam < nut_hex_diam);
  assert(nut_height > 0);
  assert(nut_depth > 0);
  assert(nut_hole_scale_factor >= 1);
  assert(cone_height==0 || cone_diam1>0);
  assert(cone_height==0 || cone_diam2>0);
  assert(cone_height==0 || cone_diam2<cone_diam1);
  assert(cone_height > 0 || nut_depth > -cone_height);

  // We need to allow for maximum size of the nut and minimum size of the hole
  // (~shrinkage of hole during 3D printing process).
  nut_hex_diam_final = nut_hex_diam * nut_hole_scale_factor;
  nut_rnd_diam = hex_short_to_long_diag(nut_hex_diam_final);
  nut_height_final = nut_height * nut_hole_scale_factor;
  total_height = nut_depth + nut_height + screw_extension;
  nut_height_extra = nut_height_final - nut_height;

  assert(boss_height >= nut_depth + nut_height_final);
  slot_depth_final =
    slot_depth>0 ? slot_depth :
      nut_rnd_diam*nut_diam_to_slot_depth_multiplier;

  difference() {
    linear_extrude(height=boss_height, convexity=3) {
      children(0);
    }
    if (!solid) {
      // Cut out the screw hole.
      linear_extrude(height=total_height, convexity=3) {
        circle(d=screw_hole_diam);
      }
      // Cut out the nut slot.
      translate([0, 0, nut_depth - nut_height_extra / 2]) {
        linear_extrude(height=nut_height_final, convexity=3) {
          rotate([0, 0, nut_slot_angle]) {
            circle(d=hex_short_to_long_diag(nut_hex_diam_final), $fn=6);
            translate([0, -nut_hex_diam_final/2])
              square(size=[slot_depth_final, nut_hex_diam_final], center=false);
          }
        }
      }
      // Make alignment hole if cone_height < 0.
      if (cone_height < 0) {
        translate([0, 0, -0.001])
          boss_alignment_cone(
              solid=true, cone_height=-cone_height, cone_diam1=cone_diam1,
              cone_diam2=cone_diam2, cone_fn=cone_fn);
      }
    }
  }
  if (cone_height > 0) {
    mirror([0, 0, 1]) {
      boss_alignment_cone(
          solid=solid, screw_hole_diam=screw_hole_diam,
          cone_height=cone_height, cone_diam1=cone_diam1,
          cone_diam2=cone_diam2, cone_fn=cone_fn);
    }
  }
  if (solid) {
    // Include the nut slot so that it will be removed from the body from which
    // this whole boss is being removed.
    translate([0, 0, nut_depth - nut_height_extra / 2]) {
      the_nut_slot(
          nut_height=nut_height_final, nut_slot_angle=nut_slot_angle,
          nut_hex_diam=nut_hex_diam_final, slot_depth=slot_depth_final);
    }
  }
}

module the_nut_slot(nut_height=undef, nut_slot_angle=undef, nut_hex_diam=undef, slot_depth=undef) {
  linear_extrude(height=nut_height, convexity=3) {
    rotate([0, 0, nut_slot_angle]) {
      circle(d=hex_short_to_long_diag(nut_hex_diam), $fn=6);
      translate([0, -nut_hex_diam/2])
        square(size=[slot_depth, nut_hex_diam], center=false);
    }
  }
}

module example_generic_slotted_nut_boss(solid=false) {

    // solid=false, screw_hole_diam=undef, nut_depth=0, screw_extension=0,
    // nut_hex_diam=undef, nut_height=undef, nut_hole_scale_factor=1.02,
    // slot_depth=undef, nut_diam_to_slot_depth_multiplier=0.5, nut_slot_angle=0,
    // cone_height=0, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {

  // Without recess or alignment cone.
  generic_slotted_nut_boss(
    solid=solid, screw_hole_diam=m4_hole_diam, boss_height=20, nut_depth=12,
    screw_extension=10, nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height) {
    square(size=m4_nut_diam2*1.5, center=true);
  }

  // With alignment cone.
  translate([0, 30, 0])
    generic_slotted_nut_boss(
      solid=solid, screw_hole_diam=m4_hole_diam, boss_height=20, nut_depth=12,
      screw_extension=10, nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height,
      nut_slot_angle=45,
      cone_height=5, cone_diam1=m4_hole_diam*2.25, cone_diam2=m4_hole_diam*1.75) {
      circle(d=m4_nut_diam2*1.5);
    };

  // With alignment hole.
  translate([0, 60, 0])
    generic_slotted_nut_boss(
      solid=solid, screw_hole_diam=m4_hole_diam, boss_height=20, nut_depth=12,
      screw_extension=10, nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height,
      nut_slot_angle=270,
      cone_height=-5, cone_diam1=m4_hole_diam*2.25, cone_diam2=m4_hole_diam*1.75) {
      square(size=m4_nut_diam2*1.5, center=true);
    };
}

// Example:
translate([60, -90, 0])
  color("palegreen")
    example_generic_slotted_nut_boss(solid=false);

translate([90, -90, 0])
  color("palegreen")
    example_generic_slotted_nut_boss(solid=true);

////////////////////////////////////////////////////////////////////////////////
// matching_m4_recessed_bosses creates a pair of a recessed nut boss and a screw
// boss for a screw on the z-axis (i.e. x=0, y=0), with the nut on the
// z>0 side. A single child must be provided with a 2D profile that can be
// extruded to be the outer surface of the bosses.

module matching_m4_recessed_bosses(show_nut_boss=true, show_screw_boss=true, nut_depth=6, screw_head_depth=15, screw_head_recess=45, solid=false) {
  assert($children == 1);
  cone_height = 5;
  cone_diam1 = m4_hole_diam*2.25;
  cone_diam2 = m4_hole_diam*1.75;
  if (show_nut_boss) {
    generic_recessed_nut_boss(
        solid=solid, screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
        nut_height=m4_nut_height, nut_depth=nut_depth+max(0, -cone_height),
        cone_height=-(cone_height+.1), cone_diam1=cone_diam1+.1,
        cone_diam2=cone_diam2+.1) {
      children(0);
    }
  }
  if (show_screw_boss) {
    generic_screw_boss(
        solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
        screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess,
        cone_height=cone_height-.1, cone_diam1=cone_diam1-.1, cone_diam2=cone_diam2-.1) {
      children(0);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// matching_m4_slotted_bosses creates a pair of a slotted nut boss and
// a screw boss for a screw on the z-axis (i.e. x=0, y=0), with the nut
// on the z>0 side.
// A single child must be provided with a 2D profile that can be extruded to
// be the outer surface of the bosses.
module matching_m4_slotted_bosses(show_nut_boss=true, show_screw_boss=true, nut_slot_angle=0, nut_depth=6, screw_extension=10, boss_height=20, screw_head_depth=15, screw_head_recess=45, solid=false, cone_height=5, slot_depth=undef) {
  assert($children == 1);
  assert(cone_height >= 0);
  assert(nut_depth > -cone_height);  // If have a hole, must not go too deep.
  cone_diam1 = m4_hole_diam*2.5;
  cone_diam2 = m4_hole_diam*1.5;
  nut_boss_cone_height = cone_height > 0 ? -(cone_height+.1) : 0;
  screw_boss_cone_height = cone_height > 0 ? cone_height-.1 : 0;

  if (show_nut_boss) {
    generic_slotted_nut_boss(
        solid=solid, screw_hole_diam=m4_hole_diam, boss_height=boss_height,
        nut_depth=nut_depth, screw_extension=screw_extension,
        nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height,
        nut_slot_angle=nut_slot_angle, slot_depth=slot_depth,
        cone_height=nut_boss_cone_height, cone_diam1=cone_diam1+.1,
        cone_diam2=cone_diam2+.1) {
      children(0);
    }
  }
  if (show_screw_boss) {
    generic_screw_boss(
        solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
        screw_head_depth=screw_head_depth, screw_head_recess=screw_head_recess,
        cone_height=screw_boss_cone_height, cone_diam1=cone_diam1-.1,
        cone_diam2=cone_diam2-.1) {
      children(0);
    }
  }
}

////////////////////////////////////////////////////////////////////////////////

module round_top_rectangle(diam=undef, height=undef) {
  circle(d=diam);
  translate([-diam/2, -height, 0])
    square(size=[diam, height]);
}

// angle: angle of the pyramid sides, where zero is vertical
//        (i.e. not a pyramid).
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









// module round_nut_boss(solid=false, nut_boss_diam=undef, screw_hole_diam=undef, nut_hex_diam=undef, nut_height=undef, nut_recess=0, nut_depth=undef) {
//   generic_recessed_nut_boss(solid=solid, screw_hole_diam=screw_hole_diam, nut_hex_diam=nut_hex_diam, nut_height=nut_height, nut_recess=nut_recess, nut_depth=nut_depth) {
//     circle(d=nut_boss_diam);
//   }
// }
// // Example:
// color("red") {
//   round_nut_boss(
//     solid=false, nut_boss_diam=2*m4_nut_diam1, screw_hole_diam=m4_hole_diam,
//     nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height, nut_recess=1,
//     nut_depth=10);
//   translate([0, 20, 0])
//     round_nut_boss(
//       solid=true, nut_boss_diam=2*m4_nut_diam1, screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
//       nut_height=m4_nut_height, nut_recess=1,
//       nut_depth=10);
// }
// if ($preview)
//   translate([0, 0, 10])
//     nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
//         nut_height=m4_nut_height);


// module round_top_nut_boss(
//   solid=false, nut_boss_diam=undef, nut_boss_height=undef, screw_hole_diam=undef, nut_hex_diam=undef, nut_height=undef, nut_recess=0, nut_depth=undef) {
//   generic_recessed_nut_boss(solid=solid, screw_hole_diam=screw_hole_diam, nut_hex_diam=nut_hex_diam, nut_height=nut_height, nut_recess=nut_recess, nut_depth=nut_depth) {
//     union() {
//       circle(d=nut_boss_diam);
//       translate([-nut_boss_diam/2, -nut_boss_height, 0])
//         square(size=[nut_boss_diam, nut_boss_height]);
//     }
//   }
// }
// // Example:
// translate([30, 0, 0]) color("green") {
//   round_top_nut_boss(
//     solid=false, nut_boss_diam=12, nut_boss_height=12,
//     screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
//     nut_height=m4_nut_height, nut_recess=-.1, nut_depth=12);

//   translate([0, 30, 0])
//     round_top_nut_boss(
//       solid=true, nut_boss_diam=12, nut_boss_height=12,
//       screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
//       nut_height=m4_nut_height, nut_recess=1, nut_depth=12);
// }
// if ($preview)
//   translate([30, 0, 12])
//     nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
//         nut_height=m4_nut_height);

// ////////////////////////////////////////////////////////////////////////////////

// module nut_boss_alignment_hole(cone_height=undef, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {
//   boss_alignment_cone(
//     solid=true, cone_height=cone_height,
//     cone_diam1=cone_diam1, cone_diam2=cone_diam2, cone_fn=cone_fn);
// }

// // Example:
// translate([60, 0, 0]) color("orange") {
//   difference() {
//     round_nut_boss(
//       solid=false, nut_boss_diam=4*m4_nut_diam1, screw_hole_diam=m4_hole_diam,
//       nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height, nut_recess=0.5,
//       nut_depth=10);
//     translate([0,0,-0.001])
//     nut_boss_alignment_hole(
//       cone_height=5, cone_diam1=3*m4_hole_diam, cone_diam2=2*m4_hole_diam, cone_fn=undef);
//   }

//   translate([0, 30, 0])
//   difference() {
//     round_top_nut_boss(
//       solid=true, nut_boss_diam=12, nut_boss_height=12,
//       screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
//       nut_height=m4_nut_height, nut_recess=1, nut_depth=12);
//     translate([0,0,-0.001])
//       nut_boss_alignment_hole(
//         cone_height=5, cone_diam1=2*m4_hole_diam, cone_diam2=1.75*m4_hole_diam, cone_fn=undef);
//   }
// }
// if ($preview)
//   translate([60, 0, 10])
//     nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
//         nut_height=m4_nut_height);


// ////////////////////////////////////////////////////////////////////////////////

// module nut_boss_alignment_cone(solid=false, screw_hole_diam=undef, cone_height=undef, cone_diam1=undef, cone_diam2=undef, cone_fn=undef) {
//   // $fs = min($fs, 2);
//   mirror([0, 0, 1]) {
//     boss_alignment_cone(
//       solid=solid, screw_hole_diam=screw_hole_diam, cone_height=cone_height,
//       cone_diam1=cone_diam1, cone_diam2=cone_diam2, cone_fn=cone_fn);
//   }
// }

// // Example:
// translate([90, 0, 0]) color("blue") {
//   round_top_nut_boss(
//     solid=false,
//     nut_boss_diam=3*m4_hole_diam, nut_boss_height=3*m4_hole_diam,
//     screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
//     nut_height=m4_nut_height, nut_depth=12);
//   nut_boss_alignment_cone(
//     solid=false, screw_hole_diam=m4_hole_diam, cone_height=5,
//     cone_diam1=3*m4_hole_diam, cone_diam2=2*m4_hole_diam, cone_fn=4);

//   translate([0, 30, 0]){
//     round_top_nut_boss(
//       solid=true,
//       nut_boss_diam=3*m4_hole_diam, nut_boss_height=3*m4_hole_diam,
//       screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1,
//       nut_height=m4_nut_height, nut_recess=1, nut_depth=12);
//     nut_boss_alignment_cone(
//       solid=true, screw_hole_diam=m4_hole_diam, cone_height=5,
//       cone_diam1=2.5*m4_hole_diam, cone_diam2=1.5*m4_hole_diam, cone_fn=undef);
//   }
// }
// if ($preview)
//   translate([90, 0, 12])
//     nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
//         nut_height=m4_nut_height);

// ////////////////////////////////////////////////////////////////////////////////
// // Defines the inside of the boss for holding a nut in a slot, but the
// // outside 2D profile must be passed in as the first and only child.
// module generic_nut_slot(screw_hole_diam=undef, nut_hex_diam=undef, nut_height=undef,
//   nut_depth=undef, screw_extension=undef,
//    nut_hole_scale_factor=1.02, slot_depth=undef, nut_diam_to_slot_depth_multiplier=1,
//     nut_height_scale=1,
//    nut_slot_angle=0) {
//   // We need to allow for maximum size of the nut and minimum size of the hole
//   // (~shrinkage of hole during 3D printing process).
//   nut_hex_diam_final = nut_hex_diam * nut_hole_scale_factor;
//   nut_height_final = nut_height * nut_hole_scale_factor;
//   total_height = nut_depth + nut_height + screw_extension;
//   nut_height_extra = nut_height_final - nut_height;

//   cylinder(d=screw_hole_diam, h=total_height);
//   translate([0, 0, nut_depth - nut_height_extra / 2]) {
//     slot_depth_final =
//       slot_depth==undef ?
//         nut_hex_diam_final*nut_diam_to_slot_depth_multiplier :
//         slot_depth;
//     linear_extrude(height=nut_height_final, convexity=3) {
//       rotate([0, 0, nut_slot_angle]) {
//         //rotate([0,0,360/12])
//         circle(d=hex_short_to_long_diag(nut_hex_diam_final), $fn=6);
//         translate([0, -nut_hex_diam_final/2])
//           square(size=[slot_depth_final, nut_hex_diam_final], center=false);
//       }
//     }
//   }
// }

// translate([120, 0, 0]) color("purple") {
//   generic_nut_slot(screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height, 
//     nut_depth=10, screw_extension=10, nut_slot_angle=45);
//   translate([0, 30, 0]) {
//     difference() {
//       cylinder(h=20, d=2*m4_nut_diam1);
//       translate([0, 0, -0.01])
//         generic_nut_slot(screw_hole_diam=m4_hole_diam, nut_hex_diam=m4_nut_diam1, nut_height=m4_nut_height, 
//           nut_depth=10, screw_extension=10, nut_slot_angle=-45);
//     }
//   }
// }
// if ($preview)
//   translate([120, 30, 10])
//     rotate([0, 0, -45])
//     nut(nut_hex_diam=m4_nut_diam1, screw_diam=m4_screw_diam,
//         nut_height=m4_nut_height);

// // module generic_screw_boss(
// //     solid=false, screw_hole_diam=undef, screw_head_diam=undef, washer_diam=undef,
// //     screw_head_recess=undef, screw_head_depth=undef, screw_head_scale_factor=1.02,
// //     cone_height=undef, cone_diam1=undef, cone_diam2=undef, cone_fn=undef
// //     ) {
// //   assert($children == 1);
// //   assert(screw_head_recess==undef || screw_head_recess>0);
// //   assert(screw_head_diam!=undef || washer_diam>0);
// //   outer_diam = (screw_head_diam== undef ? washer_diam : screw_head_diam) * screw_head_scale_factor;
// //   mirror([0, 0, 1]) {
// //     difference() {
// //       union() {
// //         if (solid) {
// //           h = (screw_head_recess>0 ? screw_head_recess : 0) + screw_head_depth;
// //           linear_extrude(height=h, convexity=3) {
// //             children(0);
// //           }
// //         } else {
// //           linear_extrude(height=screw_head_depth, convexity=3) {
// //             difference() {
// //               children(0);
// //               circle(d=screw_hole_diam);
// //             }
// //           }
// //           if (screw_head_recess > 0) {
// //             translate([0, 0, screw_head_depth]) {
// //               linear_extrude(height=screw_head_recess, convexity=3) {
// //                 difference() {
// //                   children(0);
// //                   circle(d=outer_diam);
// //                 }
// //               }
// //             }
// //           }
// //         }
// //       }
// //       // Make alignment hole if cone_height < 0.
// //       if (cone_height < 0) {
// //         boss_alignment_cone(
// //             solid=solid, screw_hole_diam=screw_hole_diam,
// //             cone_height=-cone_height, cone_diam1=cone_diam1,
// //             cone_diam2=cone_diam2, cone_fn=cone_fn);
// //       }
// //     }
// //   }
// //   if (cone_height > 0) {
// //     boss_alignment_cone(
// //         solid=solid, screw_hole_diam=screw_hole_diam,
// //         cone_height=cone_height, cone_diam1=cone_diam1,
// //         cone_diam2=cone_diam2, cone_fn=cone_fn);
// //   }
// // }


// // module example_generic_screw_boss(solid=false) {
// //   // Without recess or alignment cone.
// //   generic_screw_boss(
// //     solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
// //     screw_head_depth=10) {
// //     circle(d=m4_washer_diam);
// //   }

// //   // With alignment cone.
// //   translate([0, -30, 0])
// //   generic_screw_boss(
// //     solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
// //     screw_head_depth=15,
// //     cone_height=5, cone_diam1=m4_hole_diam*2.25,
// //         cone_diam2=m4_hole_diam*1.75) {
// //     circle(d=max(2.5*m4_hole_diam, m4_washer_diam));
// //   }

// //   // With recess and alignment cone.
// //   translate([0, -60, 0])
// //   generic_screw_boss(
// //     solid=solid, screw_hole_diam=m4_hole_diam, washer_diam=m4_washer_diam,
// //     screw_head_depth=15, screw_head_recess=5,
// //     cone_height=5, cone_diam1=m4_hole_diam*2.25,
// //         cone_diam2=m4_hole_diam*1.75) {
// //     circle(d=max(2.5*m4_hole_diam, 1.5*m4_washer_diam));
// //   }

// // }

// // // Example:
// // translate([0, -30, 0])
// //   color("red")
// //     example_generic_screw_boss(solid=false);

// // translate([30, -30, 0])
// //   color("red")
// //     example_generic_screw_boss(solid=true);



// // screw_hole_diam
// //    Diameter of hole for screw (e.g. 4.5mm for an M4 screw).
// // nut_hex_diam
// //    Width across the flat faces of a hex nut.
// // nut_height
// //    Height / thickness of the nut.
// // nut_boss_diam
// //    Diameter of the body that holds the nut.
// // nut_recess
// //    How far below the surface of the boss the nut is recessed. Typically
// //    zero to a few millimeters.
// // nut_depth
// //    Distance from parting plane (z=0 in this model) to the start of the nut.
// // screw_head_diam
// //    Diameter of the head of the screw. If using a washer with the screw,
// //    instead specify the diameter of the washer.
// // screw_head_depth
// //    Distance from parting plane (z=0 in this model) to the start of the head.
// // screw_head_recess
// //    How far below the surface of the boss the head is recessed.
// //    Must be >= 0.
// ////////////////////////////////////////////////////////////////////////////////

// ////////////////////////////////////////////////////////////////////////////////
