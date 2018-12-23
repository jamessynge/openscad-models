// Weatherproofing for the declination (DEC) axis of the iOptron iEQ30 Pro.
// See dec_bearing_wp.md for documentation.

include <ieq30pro_dimensions.scad>
use <dec_bearing_utils.scad>

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.5;
// Don't generate larger angles than this many degrees.
$fa = 3;

// Distance from motor to shell around it.
dec_motor_gap = 2;

// Width of surface mating with DEC bearing cover.
dec_bearing_mating_length = min(dec2_len, 20);

shell1 = 4;
shell2 = 20;
shell_diff = shell2-shell1;
shell_inside_x = dec_motor_w/2 + dec_motor_gap;
shell1_outside_x = dec_motor_w/2 + dec_motor_gap + shell1;
shell2_outside_x = dec_motor_w/2 + dec_motor_gap + shell2;

shell_top_inside_offset = dec_motor_z_offset + dec_motor_z + dec_motor_gap;

// These sizes are arbitrary, and should
// be adjusted to reflect real nut and bolt sizes.
nut_diam = 10;
nut_height = 4;
nut_slot_depth = 20;
bolt_diam=6;
nut_slot_margin = 10; // 
bolt_len=50;  // Not a real size, just used for
              // difference().

// This is a radius that would clear
// clutch regardless of clutch handle
// position.
dec_roof_interior_radius =
  dec_clutch_handle_max_height + 3;
dec_roof_outer_radius1 = dec_roof_interior_radius + 4;
dec_roof_outer_radius2 = dec_roof_interior_radius + 4;

// Trying to get better protection
// for bottom of motor cover, which
// is a bit exposed.
dmcc_extra_z=dec_motor_z_offset;

*dec_motor_cover_cover();
*dec_motor_cover_strap();
dec_bearing_upper_roof();

module dec_motor_cover_cover() {
  // extra_h covers cable plug/jack.
  extra_h=50;

  difference() {
    union() {
      translate([0, dec_motor_z_offset, 0]) {
        motor_cover_shell(
          dec_motor_w, dec_motor_h+30, dec_motor_z,
          extra_z=dmcc_extra_z, motor_gap=dec_motor_gap,
        shell_wall=shell1,
        bracing1=dec_motor_z/2);
      }
      translate([0, dec_motor_z_offset, 0]) {
        extra_z2 = dmcc_extra_z - shell_diff;
        
        motor_cover_shell(
          dec_motor_w, dec2_len, dec_motor_z,
          extra_z=dmcc_extra_z, motor_gap=dec_motor_gap,
          shell_wall=shell2);
      }

      // Add a couple of fillets to keep the two
      // shells in contact down near the DEC bearing
      // cover.
      dmcc_fillet1();
      mirror([1,0,0]) dmcc_fillet1();
      
    }

    // Remove a slot on each side for a 6-sided nut.
    strap_attachment_nut_slots();
    
    dec_motor_void();
    dec_bearing_void();
    dec_bearing_roof_screw_holes();
  }
}

module dec_motor_cover_strap() {
  narrows_to = dec2_radius + 3;

  difference() {
    union() {
      dmcc_strap_gussets();
      intersection() {
        $fn=100;
        difference() {
          cylinder(r=shell2_outside_x, h=dec2_len);
          translate([0,0,-1])
            cylinder(r=dec2_radius, h=dec2_len+2);
        }
        translate([0, 12, 0])
          cylinder(r=shell2_outside_x, h=dec2_len);
      }
    };

    // Remove the portion that is above the y=-1
    // plane, thus allowing for the bolts to be
    // tightened.
    translate([0,-1,0])
      rotate([-90,0,0])
        linear_extrude(height=1000, convexity=10)
          square(size=1000, center=true);

    // Remove a bolt on each side for attaching to
    // the dec_motor_cover_cover.
    strap_attachment_nut_slots();
  }
}

module dec_bearing_upper_roof() {
  difference() {
    union() {
      dec_bearing_hoop();
      
      // disc_thickness = 2;
      // linear_extrude(height=disc_thickness, convexity=10)
      //   circle(r=dec_roof_outer_radius1);
      
      // fillet_length = 50;
      
      // translate([shell2_outside_x,
      //            fillet_length,
      //            disc_thickness])
      //   rotate([90,0,0])
      //     fillet_extrusion(15, fillet_length,
      //                      scale=1); 
      
      // mirror([1,0,0])
      // translate([shell2_outside_x,
      //            fillet_length,
      //            disc_thickness])
      //   rotate([90,0,0])
      //     fillet_extrusion(15, fillet_length,
      //                      scale=1); 
    }
  
    // // Remove the portion that is below the y=0
    // // plane, thus allowing for the bolts to be
    // // tightened.
    // rotate([90,0,0])
    //   linear_extrude(height=1000, convexity=10)
    //     square(size=1000, center=true);

    // We put a plate in place that partially
    // intersects
    // with the motor cover (and cover cover).
    // Prevent that.
    hull() dec_motor_cover_cover();
  }
}

translate([0,0,-200]) dec_bearing_hoop();

module dec_bearing_hoop() {
  // Module for a hoop over the bearing. Too much material, some will need
  // to be removed by the caller.
  // Two hollow discs on either side
  // of the gap for the DEC clutch handle (normal tightened position), with
  // a hollow cylinder joining them; all cut at the plane horizontal to the
  // ground (based on mount_latitude).
  // TODO Add fillets to the inside of the discs where they meet the
  // cylinder.

  disc_thickness = 4;

  difference() {
    union() {
      // Outer disc (nearest to saddle plate).
      min_oz = clutch_handle_base_diam + disc_thickness;
      assert(min_oz <= dec_gap_to_saddle_knob);
      z = (min_oz + dec_gap_to_saddle_knob) / 2;

      translate([0,0,-z])
        linear_extrude(height=disc_thickness, convexity=10)
          difference() {
            circle(r=dec_roof_interior_radius);
            circle(r=dec2_radius);
          };

      zb = dec2_len;
      z2 = zb - disc_thickness;

      // Inner disc, over DEC gear cover. Not yet removing the DMCC.
      translate([0, 0, z2])
        linear_extrude(height=disc_thickness, convexity=10)
          difference() {
            circle(r=dec_roof_interior_radius);
            circle(r=dec2_radius);
          };

      // Cylinder joining them.
      translate([0,0,-z])
        linear_extrude(height=z + zb, convexity=10)
          difference() {
            circle(r=dec_roof_interior_radius + disc_thickness);
            circle(r=dec_roof_interior_radius);
          };
    };

    // Remove the portion that is below the latitude plane, so that
    // the bottom edges of the half discs are parallel to the ground.
    rotate([0, 0, mount_latitude-90])
      rotate([90,0,0])
        linear_extrude(height=1000, convexity=10)
          square(size=1000, center=true);

    // Don't intrude into the RA bearing plane, else will collide
    // with RA motor cover.
    dec_bearing_ra_bearing_void();
  };
}

// Space to be occupied by the DEC bearing cover.
module dec_bearing_void() {
  cylinder(h=dec2_len, r=dec2_radius+.1);
}

// Space that may not be occupied by items attached to the DEC bearing plane
// because of the RA bearing plane.
module dec_bearing_ra_bearing_void() {
  // Remove the portion that is below the latitude plane, so that
  // the bottom of the half disc
  // plane, thus allowing for the bolts to be
  // tightened.

  translate([0, -ra1_base_to_dec_center, 0])
    rotate([90,0,0])
      linear_extrude(height=1000, convexity=10)
        square(size=1000, center=true);
}

// Space to be occupied by motor and cable,
// so not by weatherproofing.
module dec_motor_void() {
  extra_h=20;  // Don't make it impossible for
               // the plug to fit in.
  w=dec_motor_w;
  h=dec_motor_h + extra_h;
  z=dec_motor_z;
  translate([0,0,-dec_motor_setback])
  linear_extrude(height=h)
    offset(delta=dec_motor_gap)
      translate([-w/2,dec_motor_z_offset,0])
        square([w, z]);
}

// Space to be occupied by a nut and bolt for
// attaching the dec_motor_cover_cover to
// a band around the other half of the DEC axis.
module nut_slot1() {
  x_offset = (shell2_outside_x + dec2_radius) / 2;
  y_offset = nut_height+nut_slot_margin;

  translate([x_offset, y_offset, dec2_len/2])
    rotate([90,0,0])
      nut_slot(d=nut_diam, h=nut_height,
               depth=nut_slot_depth,
               bolt_diam=bolt_diam,
               bolt_up=bolt_len,
               bolt_down=10);
}

module strap_attachment_nut_slots() {
  nut_slot1();
  mirror([1,0,0]) nut_slot1();
}

module dmcc_fillet1() {
  translate([-shell1_outside_x,0,dec2_len])
    rotate([0,180,0])
      rotate([-90,0,0])
        fillet_extrusion(15, 50, scale=0.01);
}

module dmcc_strap_gusset() {
  gx = shell2_outside_x - dec2_radius;
  gy = dec2_len;
  gz = 30;
  gd = bolt_diam;

  translate([-shell2_outside_x,0,0])
    rotate([90,0,0]) {
      screw_gusset(gx, gy, gz, gd);
    }
}

module dmcc_strap_gussets() {
  dmcc_strap_gusset();
  mirror([1,0,0]) dmcc_strap_gusset();
}

module dec_bearing_roof_screw_hole1() {
  dx = shell_inside_x + shell2/2;
  dy = shell_top_inside_offset + shell2/2;
  translate([dx,dy,0])  
    symmetric_z_cylinder(
      bolt_diam,
      2 * (dec_saddle_height + dec2_len));
}

//dec_bearing_roof_screw_holes();
module dec_bearing_roof_screw_holes() {
  dec_bearing_roof_screw_hole1();
  mirror([1,0,0]) dec_bearing_roof_screw_hole1();
}
