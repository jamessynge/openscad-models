// Defines the black plastic cover that sits over the DEC motor and electronics.
// Looks like a fairly simple shell with some chamfered edges, but I also
// measure a draft angle on it.
// Note that dec_motor() models the motor cover as a solid, taking up all of
// the volume of the motor and its electronics.
// Author: James Synge

// Units: mm

include <ieq30pro_dimensions.scad>
use <../utils/chamfer.scad>


dec_motor();

// *    dec_motor_shell();

// *translate([200, 0, 0])
//   import("ieq30pro_dec_motor.basic_shell.stl", convexity=10);

module dec_motor() {
  // Position the motor cover so the side facing DEC bearing plane is ~on the
  // Y=0 plane, which may be well suited to rendering it in ra_and_dec.
  translate([-dec_motor_core_top_w/2,
             -dec_motor_core_bottom_h + (dec_motor_core_bottom_h-dec_motor_core_top_h)/2,
             dec_motor_core_z]) {
    color(plastic_color) {
      union() {
        translate([0,dec_motor_core_top_h, 0]) {
          rotate([180,0,0]) {
            dec_motor_core();
          }
        }
        // On the side facing towards the polar scope port there is a little
        // bump out.
        dec_motor_bump();
        // Add the chamfered top section: 45 degree slopes all around.
        dec_motor_top();
      }
    }
    if ($preview) { dec_motor_logo(); };
  };

  // z=34.42 from top section to cut off for dec2
}

module dec_motor_core() {
  intersection() {
    // Basic block of the black plastic motor cover.
    sw = dec_motor_core_bottom_w/dec_motor_core_top_w;
    sh = dec_motor_core_bottom_h/dec_motor_core_top_h;
    linear_extrude(height=dec_motor_core_z, scale=[sw, sh])
      square(size=[dec_motor_core_top_w, dec_motor_core_top_h],
             center=false);

    // Remove the 45 degree sloped section at the top near the DEC
    // bearing. Using difference() was problematic w.r.t.
    // the previews, so I've rotated a "universe" cube 180 around
    // the pivot line and used intersection() to remove the excess.
    // I'm going to the trouble of keeping the "universe" cube of
    // modest size because OpenSCAD's "view all" feature seems to
    // take these the size of all objects, even those that don't
    // remain after intersection() operation has removed them.
    cs = 1.5 * max(dec_motor_core_bottom_w, dec_motor_core_bottom_h, dec_motor_core_z);
    translate([0, dec_motor_core_chamfer_h_offset, 0])
      rotate([45, 0, 0])
        translate([-(cs-dec_motor_core_bottom_w)/2,0,-dec_motor_core_z])
          cube(size=cs, center=false);

  }
}

module dec_motor_top() {
  w = dec_motor_top_base_w;
  h = dec_motor_top_base_h;
  // The chamfers appear to be 45 degrees, so the z by which the top is
  // extruded is also the amount of by which the rectangle is reduced in
  // size on all sides during the extrusion.
  delta = dec_motor_top_z;

  sw = (w - 2 * delta) / w;
  sh = (h - 2 * delta) / h;

  translate([w/2, h/2, 0])
    linear_extrude(height=delta, scale=[sw, sh])
      square(size=[w, h], center=true);
}

module dec_motor_bump() {
  drop_from_top = dec_motor_bump_drop_from_core_top;

  w1 = dec_motor_bump_base_w;
  w2 = dec_motor_bump_outer_w;
  h1 = dec_motor_bump_base_h;
  h2 = dec_motor_bump_outer_h;

  sw = w2 / w1;
  sh = h2 / h1;

  rotate([90-dec_motor_draft_angle, 0,0])
    translate([w1/2+ 48.5, -h1/2 - drop_from_top, 0])
      linear_extrude(height=dec_motor_bump_z, scale=[sw, sh])
        square(size=[w1, h1], center=true);
}

module dec_motor_logo() {
  color("white") 
    translate([dec_motor_top_base_w/2,
               dec_motor_top_base_h/2.5,
               dec_motor_top_z])
      linear_extrude(height = 0.05)
        ioptron_logo();
}

module ioptron_logo() {
  font = "Liberation Sans";
  italic_font = str(font, ":style=Italic");
  text("iOptron", size=12, font=italic_font,
       halign="center", valign="bottom", $fn=16);
  translate([0, -4, 0])
    text("iEQ30-Pro", size=6, font=font,
         halign="center", valign="top", $fn=16);
}

// Create a 2mm thick shell from dec_motor(), i.e. remove all but the outermost
// 2mm of the dec_motor() model. This is a quite slow operation (2.5 minutes on
// my laptop), and the resulting preview has lots of rendering artifacts.
// http://forum.openscad.org/I-have-a-suggestion-shell-td1358.html
// https://jweoblog.com/?p=644
module dec_motor_shell() {
  shell_thickness = 2;
  // Steps:
  // 1: Remove DEC motor shaped void from a big cube, producing B.
  // 2: Create Minkowski Sum of B and a sphere whose radius is the desired
  //    shell thickness, producing C. The DEC motor shaped void is a smaller
  //    in C by the shell_thickness.
  // 3: Intersect C and the DEC motor, producing a shell (hollow object) whose
  //    outer surface matches that of the motor.
  color("skyblue")
    intersection() {
      dec_motor();
      minkowski() {
        // Remove DEC motor shaped void from a big cube.
        difference() {
          // Don't include the bottom of dec_motor(), which will thus open
          // up the shell.
          translate([0,0,100+0.01])
            cube(size=200, center=true);
          dec_motor();
        }
        sphere(r=shell_thickness, center=true, $fn=8);
      }
    };
}
