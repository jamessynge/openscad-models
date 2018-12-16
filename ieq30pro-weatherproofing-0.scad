include <ieq30pro-dimensions.scad>
use <ioptron-ieq30pro.scad>
use <axis-arrows.scad>

echo(version=version());

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.9;
// Don't generate larger angles than this many degrees.
$fa = 10;

show_arrows = false;
show_axis_hints = false;

// Default location is parked.
latitude = 42;
ra_angle = 90 + $t * 360;
dec_angle = 90 + latitude + $t * 360;

// Distance from motor to shell around it.
dec_motor_gap = 2;

// Width of surface mating with DEC bearing cover.
dec_bearing_mating_length = min(dec2_len, 20);
  
rotate([latitude,0,0])
ioptron_mount(ra_angle=ra_angle, dec_angle=dec_angle) {
  union() {
    echo("executing ioptron_mount child 1");
    color("gold") {
      if (show_axis_hints)
        translate([ra1_radius*2,ra1_radius,10])
          linear_extrude(height=20) square(size=10);
      if (show_arrows)
        axis_arrows(total_length=ra1_radius*2);
    };
  };

  union() {
    echo("executing ioptron_mount child 2");
    color("blue") {
      if (show_axis_hints)
        linear_extrude(height=4) {
          difference() {
            circle(r=ra1_radius + 10);
            circle(r=ra1_radius + 5);
          };
          translate([ra1_radius+10,0,0])
            square(size=10, center=true);
        };
      if (show_arrows)
        axis_arrows(total_length=ra1_radius*1.5);
    }
  };

  union() {
    echo("executing ioptron_mount child 3");
    dec_motor_bearing_cover();
    color("yellow") {
      if (show_axis_hints) {
        linear_extrude(height=4) {
          difference() {
            circle(r=dec_head_base_radius + 10);
            circle(r=dec_head_base_radius + 5);
          };
          translate([dec_head_base_radius+10,0,0])
            square(size=10, center=true);
        };
      };
      if (show_arrows)
        axis_arrows(total_length=dec_head_base_radius*1.5);
    };
  };

  union() {
    echo("executing ioptron_mount child 4");
    *dec_head_bearing_cover();
    color("red") {
      if (show_axis_hints) {
        linear_extrude(height=4) {
          difference() {
            circle(r=dec_head_base_radius + 10);
            circle(r=dec_head_base_radius + 5);
          };
          translate([dec_head_base_radius+10,0,0])
            square(size=10, center=true);
        };
      };
      if (show_arrows)
        axis_arrows(total_length=dec_head_base_radius*1.5);
    }
  };

  union() {
    echo("executing ioptron_mount child 5");
    color("green") {
      if (show_axis_hints) {
        translate([20,10,10]) sphere(r=10);
      }
      if (show_arrows)
        axis_arrows(total_length=dec_head_base_radius);
    };
  };
};

*translate([400,0,0]) 
    dec_motor_bearing_cover();


module screw_gusset(x, y, z, d) {
  linear_extrude(height=z) {
    difference() {
      square([x, y]);
      translate([x/2,y/2,0])
        circle(d=d);
    }
  }
}

translate([200,0,0])
screw_gusset(15,15,10,5);

// Helper for creating the hollow box
// around a motor cover. Has 3 sides,
// not counting those due to the non-zero
// thickness of the shell.
// extra_z is below the z=0 plane.
module motor_cover_shell(motor_w, motor_h, motor_z, motor_gap=2, shell_wall=0, shellw=0, shellh=0, shellz=0, extra_z=0, bracing0=0, bracing1=0) {

  shell_w = max(shell_wall, shellw);
  shell_z = max(shell_wall, shellz);

  assert(shellw>0);
  assert(shellz>0);

  inner_w=motor_w + motor_gap*2;
  inner_z=motor_z + motor_gap + extra_z;
  
  outer_w = inner_w + shell_w * 2;
  outer_z = inner_z + shell_z;

  linear_extrude(height=motor_h, convexity=10) {
    translate([-outer_w/2, -extra_z, 0]) {
      difference() {
        square([outer_w, outer_z], center=false);
        translate([shell_w,0,0])
          square([inner_w, inner_z], center=false);
      }
    }
  }
  
  if (bracing_z1 > 0) {
    // Add some strength at the z=0 plane.
  assert(shellh>0);
    linear_extrude(height=shell_wall, convexity=10)
      translate([-outer_w/2, motor_z + motor_gap - bracing_z1, 0]) 
        square([outer_w, bracing_z1+shell_wall]);
  }

  if (bracing1 > 0) {
    // Add some strength at the z=motor_h plane.
  assert(shellh>0);
    translate([0,0, motor_h-shell_wall])
      linear_extrude(height=shell_wall, convexity=10)
        translate([-outer_w/2, motor_z + motor_gap - bracing1, 0]) 
          square([outer_w, bracing1+shell_wall]);
  }
//    
//  
//  square([dec_motor_w+2*
  
}

//translate([400,0,0]) motor_cover_shell(dec_motor_w, dec_motor_h, dec_motor_z, shell_wall=1,
//bracing_z1=10, bracing1=20
//);

module dec_bearing_void() {
  cylinder(h=dec2_len, r=dec2_radius+.1);
}

// Space to be occupied by motor and cable,
// so not by weatherproofing.
module dec_motor_void() {
  extra_h=10;
  w=dec_motor_w;
  h=dec_motor_h + extra_h;
  z=dec_motor_z;
  translate([0,0,-dec_motor_setback])
  linear_extrude(height=h)
    offset(delta=dec_motor_gap)
      translate([-w/2,dec_motor_z_offset,0])
        square([w, z]);
}

module dec_motor_cover_cover() {
  // extra_h covers cable plug/jack.
  extra_h=50;

  // Trying to get better protection
  // for bottom of motor cover, which
  // is a bit exposed.
  extra_z=dec_motor_z_offset;

  shell1 = 4;
  shell2 = 20;
  shell_diff = shell2-shell1;

  difference() {
    union() {
      translate([0, dec_motor_z_offset, 0]) {
        motor_cover_shell(
          dec_motor_w, dec_motor_h+30, dec_motor_z,
          extra_z=extra_z, motor_gap=dec_motor_gap,
        shell_wall=shell1,
          bracing_z1=0, bracing1=0*dec_motor_z/2);
      }

      translate([0, dec_motor_z_offset-shell_diff, 0]) {
        extra_z2 = extra_z - shell_diff;
        
        motor_cover_shell(
          dec_motor_w, dec2_len, dec_motor_z,
          extra_z=extra_z2, motor_gap=dec_motor_gap,
          shell_wall=shell2);
      }
    }
    dec_motor_void();
  }

  
    // -1 so that the strap that attaches to this
    // won't be too close, i.e. so that the screw can
    // pull them together.


//  w=dec_motor_w + dec_motor_gap*2;
//  h=dec_motor_h + extra_h;
//  z=dec_motor_z + dec_motor_gap*2;
//  *translate([0,0,-dec_motor_setback])
//  linear_extrude(height=h)
//    offset(delta=4)
//      translate([-w/2,dec_motor_z_offset,0])
//        square([w, z]);

//  shell = 4;
//  
//  linear_extrude(height=h)
//  translate([-w/2 - shell, dec_motor_z_offset,0])
//    difference() {
//      square([w+shell*2, z+shell], center=false);
//      translate([shell,0,0])
//        square([w, z], center=false);
//    }

}


// This is modelled in part as if it goes right through
// the mount. I'll then use difference() to subtract
// the mount... at some point.
module dec_motor_bearing_cover() {

  // This is a radius that would clear
  // clutch regardless of clutch handle
  // position.
  dec_roof_interior_radius =
    dec2_radius + dec_clutch_handle_max_height + 3;
  dec_roof_outer_radius1 = dec_roof_interior_radius + 5;
  dec_roof_outer_radius2 = dec_roof_interior_radius + 15;

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
    
  
      dec_motor_cover_cover();

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


    //  rotate([0,0,360-latitude])
    //  rotate_extrude(angle=latitude) {
    //      translate([dec2_radius, 0,  0])
    //        square([ra1_base_to_dec_gear_cover*2, dec_bearing_mating_length],
    //               center=false);
    //  }


    //  // A big plate to which to attach the roof over the
    //  // DEC bearing gap.
    //  rotate([0, 0, -latitude])
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
    
    // Based on latitude, remove the portion that is below
    // the horizontal plane through the middle of
    // the DEC axis.
    rotate([90,0,-latitude])
        linear_extrude(height=1000)
          square(size=1000, center=true);
    
    dec_motor_void();

    // Make sure it doesn't intersect with the
    // actual DEC bearing cover.
    dec_bearing_void();
    
  };

      //cylinder(h=min(dec2_len, 10), r=dec_cover_max_radius);
      
  
}

module dec_head_bearing_cover() {
  translate([0,0,dec_head_base_height]) {
    cylinder(h=10, r1=dec_cover_max_radius, r2=dec_head_base_diam/2);
//    cylinder(h=10, r=dec_head_base_diam/2+5);
  }
}

module ra_bearing_cover() {
//  color("green")
//    rotate_extrude(angle=135)
//        translate([ra1_radius, 0])
//            polygon([
//                [0, 0],
//                [30, 0],
//                [45, -15],
//                [45, -40],
//                [35, -40],
//                [35, -21],
//                [25, -10],
//                [0, -10]]);
  color("blue")
    rotate([0,0, -70])
    rotate_extrude(angle=135)
        translate([ra1_radius, 0])
            polygon([
                [0, 0],
                [30, 0],
                [40, -10],
                [40, -40],
                [50, -40],
                [50, -5],
                [35, 10],
                [0, 10]]);
}





//
//if ($preview) {
//  ioptron_mount($t * 360 + 90) {
//    #ra_bearing_cover();
//  }
//} else {
//  ra_bearing_cover();
//}
               

module ra_body_envelope() {
  rotate([180, 0, 0]) {
    for (angle = [0 : 5 : 360])
      rotate([0,0,angle])
        ra_body();
  }
}

//ra_body_envelope();