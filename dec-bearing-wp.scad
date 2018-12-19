include <ieq30pro-dimensions.scad>
use <dec-bearing-utils.scad>

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
bolt_len=10;  // Not a real size, just used for
              // difference().

// This is a radius that would clear
// clutch regardless of clutch handle
// position.
dec_roof_interior_radius =
  dec2_radius + dec_clutch_handle_max_height + 3;
dec_roof_outer_radius1 = dec_roof_interior_radius + 21;
dec_roof_outer_radius2 = dec_roof_interior_radius + 21;




// Trying to get better protection
// for bottom of motor cover, which
// is a bit exposed.
dmcc_extra_z=dec_motor_z_offset;


dec_motor_cover_cover();
dec_motor_cover_strap();
*dec_bearing_upper_roof();
//dec_bearing_roof_extrusion();

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
    
    nut_slot1();
    mirror([1,0,0]) nut_slot1();
    
    dec_motor_void();
    dec_bearing_void();
    dec_bearing_roof_screw_holes();
  }
}

module dec_motor_cover_strap() {
  narrows_to = dec2_radius + 3;

  difference() {
    union() {
      dmcc_strap_gusset();
      mirror([1,0,0]) dmcc_strap_gusset();
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

    // Remove the portion that is above the y=-2
    // plane, thus allowing for the bolts to be
    // tightened.
    // of the RA bearing; this avoids hitting the
    // RA motor cover.
    translate([0,-2,0])
      rotate([-90,0,0])
        linear_extrude(height=1000, convexity=10)
          square(size=1000, center=true);
  }
}

module dec_bearing_upper_roof() {
  difference() {
    union() {
      dec_bearing_roof_extrusion();
      linear_extrude(height=2, convexity=10)
        circle(r=dec_roof_outer_radius1);

      
     #
//  translate([-shell1_outside_x,0,dec2_len])
//    rotate([0,180,0])
//      rotate([-90,0,0])
        fillet_extrusion(15, 50, scale=1); 
    }
  
    // Remove the portion that is below the y=0
    // plane, thus allowing for the bolts to be
    // tightened.
    // of the RA bearing; this avoids hitting the
    // RA motor cover.
    rotate([90,0,0])
      linear_extrude(height=1000, convexity=10)
        square(size=1000, center=true);

    // We put a plate in place that partially
    // intersects
    // with the motor cover (and cover cover).
    // Prevent that.
    hull() dec_motor_cover_cover();
  }
}

module dec_bearing_roof_extrusion() {
  // The "roof" over the bearing plate: A section of
  // a hollow cylinder.

  difference() {
    translate([0, 0, -dec_saddle_height]) {
      difference() {
        union() {
          bar_w = dec_motor_w + (shell2 + dec_motor_gap) * 2;
          translate([-bar_w/2,shell_top_inside_offset,0])
            linear_extrude(height=dec_saddle_height, convexity=10)
              square([bar_w, shell2]);

          cylinder(h=dec_saddle_height,
                  r1=dec_roof_outer_radius1,
                   r2=dec_roof_outer_radius2);
        }
        translate([0, 0, -1])
          cylinder(h=dec_saddle_height+2,
                   r=dec_roof_interior_radius);
      }
    };
    dec_bearing_roof_screw_holes();
  }
}

// This is modelled in part as if it goes right through
// the mount. I'll then use difference() to subtract
// the mount... at some point.
module dec_motor_bearing_cover() {


  // A mating ring (i.e. touching the DEC gear
  // cover), goes most of the way around but
  // avoids the motor. Height is short enough
  // that it doesn't cross the plane of the
  // RA bearing.
  rotate([0, 0, 90 + dec_motor_cover_angle / 2 + 1])
    rotate_extrude(angle=360-dec_motor_cover_angle-2) {
      translate([dec2_radius, 0,  0])
        square([ra1_base_to_dec_gear_cover, dec_bearing_mating_length],
               center=false);
  };
  
  //dec_motor_void();
//  linear_extrude(height=dec_motor_h)
//  offset(delta=1)
//  translate([-dec_motor_w/2,dec_motor_z_offset,0])
//  #square([dec_motor_w, dec_motor_z]);
    
  difference() {
    dec_motor_cover_cover();
  }

  difference() {
    union() {
      // Disc that keeps water from approaching bearing.
      *translate([0,0,-3])
      linear_extrude(height=3.1) {
        difference() {
          circle(r=dec_roof_outer_radius2);
          circle(r=dec2_radius);
        }
      }
      
      dec_motor_cover_cover();
      

    //  
    //  
    //  
    //  rotate_extrude(angle=dec_cover_angle) {
    //    // Move profile into the X-Z plane
    //    rotate([0, 90, 0]) {
    //      
    //    
    //    translate
    //  
    //  


    //  rotate([0,0,360-mount_latitude])
    //  rotate_extrude(angle=mount_latitude) {
    //      translate([dec2_radius, 0,  0])
    //        square([ra1_base_to_dec_gear_cover*2, dec_bearing_mating_length],
    //               center=false);
    //  }


    //  // A big plate to which to attach the roof over the
    //  // DEC bearing gap.
    //  rotate([0, 0, -mount_latitude])
    //  translate([-dec_cover_max_radius, 0, 0])
    //  square([dec_cover_max_diam, dec_cover_max_diam], center=false);
    //  translate([-dec_cover_max_radius, 0, 0])
    //  square([dec_cover_max_diam, dec_cover_max_diam], center=false);

      /////////////////////////////////////////////////////
      // The "roof" over the bearing plate: A section of
      // a hollow cylinder.


      translate([0, 0, -dec_saddle_height]) {
        difference() {
          cylinder(h=dec_saddle_height,
                  r1=dec_roof_outer_radius1,
                   r2=dec_roof_outer_radius2);
          translate([0, 0, -1])
            cylinder(h=dec_saddle_height+2,
                     r=dec_roof_interior_radius);
        }
      }
    };
    // Start of objects that represents the volumes
    // that may NOT be occupied by the weatherproofing.

    // Remove the portion that crosses the plane
    // of the RA bearing; this avoids hitting the
    // RA motor cover.
    rotate([90,0,0])
      translate([0,0,dec_cover_max_radius])
        linear_extrude(height=1000)
          square(size=1000, center=true);
    
    // Based on mount_latitude, remove the portion that is below
    // the horizontal plane through the middle of
    // the DEC axis.
    rotate([90,0,-mount_latitude])
        linear_extrude(height=1000)
          square(size=1000, center=true);
    
    dec_motor_void();

    // Make sure it doesn't intersect with the
    // actual DEC bearing cover.
    dec_bearing_void();
    
    *rotate([0,-90,0]) rotate([90,0,0])
    nut_slot1();
    
 
  };

      //cylinder(h=min(dec2_len, 10), r=dec_cover_max_radius);
      
  
}


// Space to be occupied by the DEC bearing cover.
module dec_bearing_void() {
  cylinder(h=dec2_len, r=dec2_radius+.1);
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
  x_offset = dec_motor_w/2 + dec_motor_gap + shell2 - nut_slot_depth + .001;
  y_offset = nut_height+bolt_len-.001;
  
  translate([x_offset,y_offset,dec2_len/2])
//  rotate([0,90,0]) 
  rotate([90,0,0])
  nut_slot(d=nut_diam, h=nut_height, depth=nut_slot_depth, bolt_diam=bolt_diam,
    bolt_up=bolt_len, bolt_down=10);
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

      if ($preview) {
        // Fake bolt for checking.
        translate([gx/2, gy/2, -gz])
          linear_extrude(height=gz*2)
            circle(d=gd/2);
      }
    }
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
