// Defines the moving portion of the RA axis, which includes the
// "non-moving" portion of the DEC axis of the iOptron iEQ30 Pro.
// Author: James Synge

// ra_to_dec REQUIRES four children:
//
// 1) attached to the coordinate frame of the moving
//    RA axis, with the bearing of the RA axis centered
//    on the xy plane at z=0, with positive z being
//    where the moving RA axis is located, and negative
//    z being where the stationary portion of the mount
//    is located. The RA clutch is at x=0, negative y,
//    in keeping with the fact that we want the clutch
//    down when parked.
//
// 2) attached to the coordinate frame of the
//    "non-moving" portion of the DEC axis, with the
//    z-axis being the DEC axis and z=0 the end of
//    the DEC bearing cover, i.e. just before the gap
//    and then the moving DEC head. z>0 is towards the
//    RA axis, and z<0 is towards the DEC head and the
//    telescope (or whatever is attached to the saddle
//    plate). The x axis is parallel to the face of
//    the DEC motor with the logo, with y>0 towards
//    the base of the mount.
//
// 3) attached the rotating bearing plate of the
//    dec_head module; see that file for details
//    of the coordinates. The DEC clutch is at x=0,
//    negative y, in keeping with the fact that we
//    want the clutch down when parked.
//
// 4) attached to the plane of the dovetail saddle
//    of the dec_head module, with the same x-y
//    x-y coordinates as #2.
//
// This allows for adding objects to the model by
// a "use" of this file. If you don't have something to
// pass, pass in `union();`
//
// See also:
//   https://github.com/openscad/openscad/issues/2635
//   https://github.com/openscad/openscad/issues/350

// Units: mm

include <ieq30pro_dimensions.scad>
use <ieq30pro_clutch.scad>
use <ieq30pro_dec_head.scad>
use <../utils/axis_arrows.scad>
use <../utils/chamfer.scad>

// Global resolution
if ($preview) {
  // Don't generate smaller facets than this many mm.
  $fs = 1;
  // Don't generate larger angles than this many degrees.
  $fa = 5;
}

ra_and_dec($t * 360) {
  color("blue") {
    //echo("executing ra_and_dec child 1");
    axis_arrows(total_length=ra1_radius*1.75);
  };

  color("yellow") {
    //echo("executing ra_and_dec child 1");
    r = dec_head_base_diam/2;
    axis_arrows(total_length=r*1.75);
  };

  color("red") {
    //echo("executing ra_and_dec child 2");
    r = dec_head_base_diam/2;
    axis_arrows(total_length=r*1.75);
  };

  color("green") {
    //echo("executing ra_and_dec child 3");
    r = dec_head_diam2/2;
    axis_arrows(total_length=r*1.75);
  };
};

module ra_and_dec(dec_angle=0) {
  if ($children > 4) {
    echo("ra_and_dec has", $children, "children, too many.");
    assert($children <= 4);
  }

  raise_dec = ra1_base_to_dec_center;
  ra_to_dec();

  translate_to_dec12_plane() {
    // echo("ra_and_dec dec_body at angle", dec_angle);
    dec_body(dec_angle) {
      union() { if ($children > 1) children(1); }
      union() { if ($children > 2) children(2); }
      union() { if ($children > 3) children(3); }
    }
  }

  //echo("ra_and_dec rendering child 0");
  union() { if ($children > 0) children(0); }
}

module translate_to_dec12_plane(z_towards_dec_head=true) {
  raise_dec = ra1_base_to_dec_center;
  translate([0, ra1_radius, raise_dec]) {
    rotate([z_towards_dec_head ? -90 : 90,0,0]) {
      children();
    }
  }
}

module translate_to_dec2() {
  raise_dec = ra1_base_to_dec_center;
  translate([0, ra1_radius, raise_dec]) {
    rotate([-90,0,0]) {
      children();
    }
  }
}

module ra_to_dec() {
  h1 = ra1_base_to_dec;
  h2 = 45 - h1;
  fillet_radius = ra1_radius - dec1_radius + 2;

  translate([0,0,h1]) {
    color(cast_iron_color) {
      difference() {
        union() {
          translate([0,0,-h1]) {
            cylinder(h=h1, r=ra1_radius);
          }
          cylinder(h=h2, r=ra1_radius);
        };
        translate([0,ra1_radius,fillet_radius])
          rotate([90,0,0]) {
            translate([-ra1_radius,0,0])
              cylinder(h=ra1_diam, r=fillet_radius);
            translate([ra1_radius,0,0])
              cylinder(h=ra1_diam, r=fillet_radius);
          };
      };
    };
    translate([-(ra1_radius-5), 0, -h1])
      rotate([90,0,270])
      clutch(handle_angle=5);
  };

  // Polar scope port.
  h3 = ra1_base_to_dec + dec1_diam + polar_port_height;
  h4 = h3 - polar_port_height * 3;
  color(cast_iron_color)
    translate([0, 0, h4])
      cylinder(h=h3 - h4, d=polar_port_diam);
  color(plastic_color)
    translate([0, 0, h3])
      cylinder(h=polar_port_cap_height, d=polar_port_cap_diam);
}

module dec_body(dec_angle=0) {
  echo("dec_body has", $children, "children");
  assert($children == 3);

  // Render the "stationary" body of the DEC axis.
  rotate([180, 0, 0]) {
    dec_body_helper();
    translate([0, 0, -dec2_len]) #children(0);
  }

  // Render the parts beyond the bearing cover...

  // Render the bearing between the two DEC
  // axis parts, which is really just decoration.
  hg=dec_bearing_gap/2;
  translate([0, 0, dec2_len+hg]) {
    dec_bearing();
  };

  // Render the moving head of the DEC axis, along
  // with its two children.
  translate([0, 0, dec2_len+dec_bearing_gap])
    rotate([0, 0, dec_angle])
      dec_head() {
        children(1);
        children(2);
      };
}

module dec_body_helper() {
  total_dec_len =
    dec1_len + dec2_len + cw_cap_height +
    cw_cap_bevel_height;
  difference() {
    union() {
      color(cast_iron_color) {
        // The long section of the body attached to
        // the RA axis "flange" (i.e. ra_to_dec).
        cylinder(h=dec1_len, r=dec1_radius);
        // The wide section of the body where the
        // bearing and worm gear are located.
        translate([0,0, -dec2_len])
          cylinder(h=dec2_len, r=dec2_radius);

        // The shoulder between ra_to_dec() and dec2.
        intersection() {
          cylinder(h=dec2_len, r=dec2_radius);
          translate([-dec2_shoulder_width/2, -dec2_radius])
            cube([dec2_shoulder_width, dec2_radius, 10], center=false);
        };

        // On one side only, there is a support below the DEC motor.
        // It has a rounded lower edge which meets dec1 at about the midline.

dec_motor_support1();


      };
      // Cap on the end where the CW shaft is
      // screwed into the DEC body, and a second
      // bearing (I think).
      color(plastic_color)
        translate([0, 0, dec1_len])
          union() {
            cylinder(h=cw_cap_height, r=dec1_radius);
            translate([0, 0, cw_cap_height])
              rotate_extrude()
                polygon([
                  [cw_cs_radius,0],
                  [dec1_radius,0],
                  [dec1_radius-10, cw_cap_bevel_height],
                  [cw_cs_radius,cw_cap_bevel_height]]);
          };
      dec_motor();
    };
    // Remove the hollow center of the counterweight shaft.
    color(cast_iron_color)
      translate([0,0, -dec2_len-1])
        cylinder(h=total_dec_len+2,
                r=cw_thread_radius);
  };
}

module dec_motor() {
  w=dec_motor_w;
  h=dec_motor_h;
  z=dec_motor_z;
  
  translate([-w/2, dec_motor_z_offset, h - dec2_len + dec_motor_setback])
    rotate([-90,0,0]) {
      color(plastic_color) {
        intersection() {
          chamferCube(w,h,z,chamferHeight=12,
            chamferX=[0,0,1,0], chamferY=[0,0,0,0],
            chamferZ=[0,0,0,0]);
          chamferCube(w,h,z,chamferHeight=5,
            chamferX=[0,0,0,1], chamferY=[0,1,1,0],
            chamferZ=[0,0,0,0]);
        }
      };

      color("white") 
        translate([w/2, h/3,z])
          linear_extrude(height = 0.1)
            ioptron_logo();    
    };
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

// A little decoration for the model, so that the
// two sides of the DEC bearing aren't butted up
// against each other in an unrealistic fashion,
// and to match the way the mount actually looks;
// i.e. there is a very small gap between the two
// sides through which we can see silver colored
// metal.
module dec_bearing() {
  h=dec_bearing_gap+1;
  color(bearing_color)
    translate([0, 0, -h/2])
      cylinder(h=h, r=dec_head_base_diam/2-2);
}

module dec_motor_support1() {
  // Radius based on visual inspection.
  r=1.5;
  h=14;
  d=34.6;
  w=dec1_radius + r*0.75;

  color(cast_iron_color) {
    linear_extrude(height=d) {
      intersection() {
        translate([-r, r, 0]) {
          $fs = r/8;
          // $fa = 1;
          offset(r=r) square(size=w, center=false);
        }
        square([w, h], center=false);
      }
    }
  }
}