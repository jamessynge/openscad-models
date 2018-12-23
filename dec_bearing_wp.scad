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

shell_inside_y = dec_motor_z_offset + dec_motor_z + dec_motor_gap;
shell2_outside_y = shell_inside_y + shell2;

// These sizes are arbitrary, and should
// be adjusted to reflect real nut and bolt sizes.
nut_diam = 10;
nut_height = 4;
nut_slot_depth = 20;
bolt_diam=6;
nut_slot_margin = 10; // 
bolt_len=50;  // Not a real size, just used for
              // difference().

// Trying to get better protection
// for bottom of motor cover, which
// is a bit exposed.
dmcc_extra_z=dec_motor_z_offset;

// Dimensions for the hoop et al which attach to the DEC motor cover cover (DMCC).
hoop_disc_wall = 4;
min_hoop_disc_z = clutch_handle_base_diam + hoop_disc_wall;
assert(min_hoop_disc_z <= dec_gap_to_saddle_knob);
hoop_disc_z = (min_hoop_disc_z + dec_gap_to_saddle_knob) / 2;



// This is a radius that would clear
// clutch regardless of clutch handle
// position.
dec_roof_interior_radius = dec_clutch_handle_max_height + 3;
dec_roof_exterior_radius = dec_roof_interior_radius + hoop_disc_wall;




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

module dec_motor_cover_strap(expansion_gap=1, gusset_length=30) {
  narrows_to = dec2_radius + 3;

  difference() {
    union() {
      dmcc_strap_gussets(gusset_length=gusset_length);
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

    // Remove the portion that is above the y=-expansion_gap
    // plane, thus allowing for the bolts to be
    // tightened.
    translate([0,-expansion_gap,0])
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
      dec_bearing_hoop_attachment();
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
    hull() dec_motor_cover_strap(expansion_gap=0, gusset_length=dec2_diam);
  }
}

translate([0,0,-50]) color("blue") dec_bearing_hoop_attachment();

module dec_bearing_hoop_attachment() {
  // Attaches the hoop to the DMCC.

  difference() {
    translate([-shell2_outside_x, 0, -hoop_disc_z])
      cube([shell2_outside_x*2, shell2_outside_y, hoop_disc_z]);

    hull() dec_bearing_hoop();


    // dec_bearing_latitude_void();
    dec_bearing_latitude_rain_void();

    // translate([0, 0, -dec_saddle_height]) {
    //   difference() {
    //     union() {
    //       bar_w = dec_motor_w + (shell2 + dec_motor_gap) * 2;
    //       translate([-bar_w/2,shell_inside_y,0])
    //         linear_extrude(height=dec_saddle_height, convexity=10)
    //           square([bar_w, shell2]);

    //       cylinder(h=dec_saddle_height, r=dec_roof_exterior_radius);
    //     }
    //     translate([0, 0, -1])
    //       cylinder(h=dec_saddle_height+2,
    //                r=dec_roof_interior_radius);
    //   }
    // };
    dec_bearing_roof_screw_holes();
  }
}


translate([0,0,-125]) dec_bearing_hoop_attachment_OLD();
module dec_bearing_hoop_attachment_OLD() {
  // Attaches the hoop to the DMCC.

  color("green") difference() {
    translate([0, 0, -dec_saddle_height]) {
      difference() {
        union() {
          bar_w = dec_motor_w + (shell2 + dec_motor_gap) * 2;
          translate([-bar_w/2,shell_inside_y,0])
            linear_extrude(height=dec_saddle_height, convexity=10)
              square([bar_w, shell2]);

          cylinder(h=dec_saddle_height, r=dec_roof_exterior_radius);
        }
        translate([0, 0, -1])
          cylinder(h=dec_saddle_height+2,
                   r=dec_roof_interior_radius);
      }
    };
    dec_bearing_roof_screw_holes();
  }
}




translate([0,0,-200]) dec_bearing_hoop();

//translate([0,0,-300]) hull() offset(r=1) dec_motor_cover_strap(gusset_length=dec2_diam);
translate([0,0,-300]) hull() dec_motor_cover_strap(gusset_length=dec2_diam);

module dec_bearing_hoop() {
  // Module for a hoop over the bearing. Too much material, some will need
  // to be removed by the caller.
  // Two hollow discs on either side
  // of the gap for the DEC clutch handle (normal tightened position), with
  // a hollow cylinder joining them; all cut at the plane horizontal to the
  // ground (based on mount_latitude).
  // TODO Add fillets to the inside of the discs where they meet the
  // cylinder.

  hoop_disc_wall = 4;

  difference() {
    union() {
      // Outer disc (nearest to saddle plate).
      translate([0,0,-hoop_disc_z])
        linear_extrude(height=hoop_disc_wall, convexity=10)
          difference() {
            circle(r=dec_roof_interior_radius);
            circle(r=dec2_radius);
          };

      zb = dec2_len-0.01;
      z2 = zb - hoop_disc_wall;

      // Inner cylinder (not a thin disc), over DEC gear cover.
      // Not yet removing the DMCC.
      linear_extrude(height=zb, convexity=10)
          difference() {
            circle(r=dec_roof_interior_radius);
            circle(r=dec2_radius);
          };

      // Cylinder joining them.
      translate([0,0,-hoop_disc_z])
        linear_extrude(height=hoop_disc_z + zb, convexity=10)
          difference() {
            circle(r=dec_roof_interior_radius + hoop_disc_wall);
            circle(r=dec_roof_interior_radius);
          };
    };

    dec_bearing_latitude_rain_void();

    // Don't intrude into the RA bearing plane, else will collide
    // with RA motor cover.
    dec_bearing_ra_bearing_void();

    // We put a plate in place that partially
    // intersects
    // with the motor cover (and cover cover).
    // Prevent that.
    hull() union() {
      dec_motor_cover_cover();
      dec_motor_cover_strap(expansion_gap=-0.01, gusset_length=dec2_diam);
    }
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

//#translate([2000,0,0])dec_bearing_latitude_void();

// Space that may not be occupied by items attached to the DEC
// bearing plane because they're below a plane parallel to the
// ground.
module dec_bearing_latitude_void() {
  rotate([0, 0, mount_latitude-90])
    rotate([90,0,0])
      linear_extrude(height=1000, convexity=10)
        square(size=1000, center=true);
}

module dec2_below_latitude_plane() {
  rotate([0, 0, -(90-mount_latitude)])
    translate([0,0,-500])
      linear_extrude(height=1000)
        translate([-dec2_radius,-1000, 0])
          square([dec2_diam, 1000], center=false);
}

//#dec_bearing_latitude_rain_void();
module dec_bearing_latitude_rain_void() {

  rotate([0, 0, 30])
    dec2_below_latitude_plane();
  rotate([0, 0, -30])
    dec2_below_latitude_plane();


  // rotate([0, 0, 90-mount_latitude-15])
    // rotate([0,-90,0])
  // rotate([0, 0, -(90-mount_latitude)])
  //   translate([0,0,-500])
  //     linear_extrude(height=1000)
  //       translate([-dec2_radius,-1000, 0])
  //         square([dec2_diam, 1000], center=false);
  // rotate([0, 0, 90-mount_latitude+15])
  //   rotate([0,-90,0])
  //     linear_extrude(height=1000)
  //       square([1000, dec2_diam], center=true);
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

module dmcc_strap_gusset(gusset_length=30) {
  gx = shell2_outside_x - dec2_radius;
  gy = dec2_len;
  gd = bolt_diam;

  translate([-shell2_outside_x,0,0])
    rotate([90,0,0]) {
      screw_gusset(gx, gy, gusset_length, gd);
    }
}

module dmcc_strap_gussets(gusset_length=30) {
  dmcc_strap_gusset(gusset_length=gusset_length);
  mirror([1,0,0]) dmcc_strap_gusset(gusset_length=gusset_length);
}

module dec_bearing_roof_screw_hole1() {
  dx = shell_inside_x + shell2/2;
  dy = shell_inside_y + shell2/2;
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
