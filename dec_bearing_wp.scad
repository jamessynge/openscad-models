// Weatherproofing for the declination (DEC) axis of the iOptron iEQ30 Pro.
// See dec_bearing_wp.md for documentation.

include <ieq30pro_dimensions.scad>
use <dec_bearing_utils.scad>

// Global resolution
if ($preview) {
  // Don't generate smaller facets than this many mm.
  $fs = 4;
  // Don't generate larger angles than this many degrees.
  $fa = 10;
}

// Distance from motor to shell around it.
dec_motor_gap = 1;

// Width of surface mating with DEC bearing cover.
dec_bearing_mating_length = min(dec2_len, 20);

shell1 = 6;
shell2 = 22;
shell_diff = shell2-shell1;
shell_inside_x = dec_motor_w/2 + dec_motor_gap;
shell1_outside_x = dec_motor_w/2 + dec_motor_gap + shell1;
shell2_outside_x = dec_motor_w/2 + dec_motor_gap + shell2;

shell_inside_y = dec_motor_z_offset + dec_motor_z + dec_motor_gap;
shell1_outside_y = shell_inside_y + shell1;
shell2_outside_y = shell_inside_y + shell2;

shell1_depth = dec_motor_h+30;
shell2_depth = min(dec2_len, 15);

// These sizes are based on an M4 machine screw and nut.
// They should be adjusted to reflect what you choose to use.
nut_diam = 7 + 0.1;  // Some margin to be able slide the nut in.
nut_height = 4;
nut_slot_depth = 20;
bolt_diam=4 + 0.5;  // 4mm machine screw, plus some margin.
nut_slot_margin = 15; // 
bolt_len=50;  // Not a real size, just used for
              // difference().

strap_gusset_length=30;

// Trying to get better protection
// for bottom of motor cover, which
// is a bit exposed.
dmcc_extra_z=dec_motor_z_offset;

// Dimensions for the hoop et al which attach to the DEC motor cover cover (DMCC).
hoop_disc_wall = 4;
min_hoop_disc_z = clutch_handle_base_diam + hoop_disc_wall;
assert(min_hoop_disc_z <= dec_gap_to_saddle_knob);
hoop_disc_z = (min_hoop_disc_z + dec_gap_to_saddle_knob) / 2;
hoop_depth = hoop_disc_z + dec2_len;


// This is a radius that would clear
// clutch regardless of clutch handle
// position.
dec_roof_interior_radius = dec_clutch_handle_max_height + 3;
dec_roof_exterior_radius = dec_roof_interior_radius + hoop_disc_wall;




color("blue")dec_motor_cover_cover();
*color("violet")dec_motor_cover_strap();
translate([0,0,-50]) color("red")dec_bearing_upper_roof();

module dec_motor_cover_cover() {
  // extra_h covers cable plug/jack.
  extra_h=50;

  difference() {
    union() {
      translate([0, dec_motor_z_offset, 0]) {
        motor_cover_shell(
          dec_motor_w, shell1_depth, dec_motor_z,
          extra_z=dmcc_extra_z, motor_gap=dec_motor_gap,
        shell_wall=shell1,
        bracing1=dec_motor_z/2);
      }
      translate([0, dec_motor_z_offset, 0]) {
        extra_z2 = dmcc_extra_z - shell_diff;
        
        motor_cover_shell(
          dec_motor_w, shell2_depth, dec_motor_z,
          extra_z=dmcc_extra_z, motor_gap=dec_motor_gap,
          shell_wall=shell2);
      }

      // Add a couple of fillets to keep the two
      // shells in contact down near the DEC bearing
      // cover.
      dmcc_fillet1();
      mirror([1,0,0]) dmcc_fillet1();

      // TODO Add a fillet to the inside of shell1 so that
      // the bracing1 section is supported better when printing.      


    }

    // Remove a slot on each side for a 6-sided nut.
    strap_attachment_nut_slots();
    
    dec_motor_void();
    dec_bearing_void();
    dec_bearing_roof_screw_holes();
  }
}

module dec_motor_cover_strap(expansion_gap=1, gusset_length=strap_gusset_length) {
  narrows_to = dec2_radius + 3;

  difference() {
    union() {
      dmcc_strap_gussets(gusset_length=gusset_length);
      intersection() {
        $fn=100;
        difference() {
          cylinder(r=shell2_outside_x, h=shell2_depth);
          translate([0,0,-1])
            cylinder(r=dec2_radius, h=shell2_depth+2);
        }
        translate([0, 12, 0])
          cylinder(r=shell2_outside_x, h=shell2_depth);
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

    // TODO Come up with a simple void module for the DMCC
    // but that is just a tad bigger. Doesn't need
    // to be as detailed.

    dmcc_void(gap=1);

    dec_motor_cover_strap_void();

    dec_bearing_latitude_rain_void();

    // Don't intrude into the RA bearing plane, else will collide
    // with RA motor cover.
    dec_bearing_ra_bearing_void();

    dec_bearing_roof_screw_holes();

    // Remove material that would block installation.
    union() {
      w = 1000;  // Essentially infinite.
      h = shell1_outside_y;
      d = shell1_depth;
      x = -(w + shell_inside_x);
      translate([x, 0, 0]) cube([w, h, d]);
    }
  }
}

// translate([0,0,-50])dec_bearing_hoop_attachment() ;

module dec_bearing_hoop_attachment() {
  // Attaches the hoop to the DMCC.
  roof_thickness = hoop_disc_wall;
  w = shell2_outside_x*2 + roof_thickness;
  h = shell2_outside_y + roof_thickness;
  d = hoop_depth;

  difference() {



    translate([-shell2_outside_x, 0, -hoop_disc_z])
      cube([w, h, d]);

    dec_bearing_hoop_void();

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
  }
}

module dec_bearing_hoop() {
  // Module for a hoop over the bearing. Too much material, some will need
  // to be removed by the caller.
  // Two hollow discs on either side
  // of the gap for the DEC clutch handle (normal tightened position), with
  // a hollow cylinder joining them; all cut at the plane horizontal to the
  // ground (based on mount_latitude).
  // TODO Add fillets to the inside of the discs where they meet the
  // cylinder.


  difference() {
    union() {
      // Outer disc (nearest to saddle plate).
      translate([0,0,-hoop_disc_z])
        linear_extrude(height=hoop_disc_wall, convexity=10)
          difference() {
            circle(r=dec_roof_interior_radius);
            circle(r=dec2_radius);
          };

      zb = hoop_depth - hoop_disc_z;

      // Inner disc over DEC gear cover.
      translate([0,0, zb-hoop_disc_wall])
        linear_extrude(height=hoop_disc_wall, convexity=10)
          difference() {
            circle(r=dec_roof_interior_radius);
            circle(r=dec2_radius);
          };

      // Cylinder joining them.
      translate([0,0,-hoop_disc_z])
        linear_extrude(height=hoop_depth, convexity=10)
          difference() {
            circle(r=dec_roof_interior_radius + hoop_disc_wall);
            circle(r=dec_roof_interior_radius);
          };
    };


    // We put a plate in place that partially
    // intersects
    // with the motor cover (and cover cover).
    // Prevent that.
    // *dec_motor_cover_cover();
    // *hull() dec_motor_cover_strap(expansion_gap=-0.01, gusset_length=dec2_diam);
  };
}

module dec_bearing_hoop_void(h_gap=0.01) {
  translate([0,0,-hoop_disc_z-h_gap])
    cylinder(h=hoop_depth + 2*h_gap,
             r=dec_roof_interior_radius + hoop_disc_wall);
}

// Space to be occupied by the DEC bearing cover.
module dec_bearing_void(radius_gap=0) {
  translate([0,0,-dec_bearing_gap])
   cylinder(h=dec2_len+dec_bearing_gap, r=dec2_radius+radius_gap);
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

//translate([0,0,-200]) dec_motor_cover_strap_void();

// Simpler version of the strap to be used as
// a void.
module dec_motor_cover_strap_void() {
  gl = strap_gusset_length + 2;
  union() {
    cylinder(r=shell2_outside_x, h=shell2_depth);
    translate([-shell2_outside_x, -gl, 0])
      cube([shell2_outside_x*2, gl, shell2_depth]);
  }
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

module dmcc_void(gap=0) {
  if (true) {
    w = 2 * (shell2_outside_x + gap);
    h = shell2_outside_y + gap;
    d = shell2_depth + 2*gap;

    translate([-w/2, 0, -gap])
      cube([w, h, d], center=false);
  }
  if (true) {
    w = 2 * (shell1_outside_x + gap);
    h = shell1_outside_y + gap;
    d = shell1_depth + 2*gap;

    translate([-w/2, 0, -gap])
      cube([w, h, d], center=false);
  }
  // Haven't included the fillet. Not sure if necessary.
      // Add a couple of fillets to keep the two
      // shells in contact down near the DEC bearing
      // cover.
      dmcc_fillet1();
      mirror([1,0,0]) dmcc_fillet1();
}


// Space to be occupied by a nut and bolt for
// attaching the dec_motor_cover_cover to
// a band around the other half of the DEC axis.
module nut_slot1() {
  x_offset = (shell2_outside_x + dec2_radius) / 2;
  y_offset = nut_height+nut_slot_margin;

  translate([x_offset, y_offset, shell2_depth/2])
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

  translate([-shell1_outside_x,0,shell2_depth])
    rotate([0,180,0])
  scale([1,1,2])
      rotate([-90,0,0])
        fillet_extrusion(shell_diff, 50, scale=0.01);
}

module dmcc_strap_gusset(gusset_length=30) {
  gx = shell2_outside_x - dec2_radius;
  gy = shell2_depth;
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
  dx = (shell1_outside_x + shell2_outside_x) / 2;
  dy = (shell1_outside_y + shell2_outside_y) / 2;
  depth = shell2_outside_y - dy + .001;

  translate([dx,dy,(shell2_depth-nut_height)/2])
      nut_slot(d=nut_diam, h=nut_height,
               depth=depth,
               bolt_diam=bolt_diam,
               bolt_up=bolt_len,
               bolt_down=10);
}

module dec_bearing_roof_screw_holes() {
  dec_bearing_roof_screw_hole1();
  mirror([1,0,0]) dec_bearing_roof_screw_hole1();
}
