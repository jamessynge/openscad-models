// Defines the moving portion of the RA axis,
// which includes the "non-moving" portion of
// the DEC axis of the iOptron iEQ30 Pro.

// ra_to_dec accepts two children:
// 1) attached to the coordinate frame of the moving
//    RA axis, with the bearing of the RA axis centered
//    on the xy plane at z=0, with positive z being
//    where the moving RA axis is located, and negative
//    z being where the stationary portion of the mount
//    is located.
// 2) attached the the coordinate frame of the moving
//    DEC axis, with the bearing of the DEC axis centered
//    on the xy plane at z=0, with positive z being
//    where the moving DEC axis is located, and negative
//    z being where the motor of the DEC axis is located.
// This allows for adding objects to the model by
// a "use" of this file.

// Units: mm

use <chamfer.scad>
include <ieq30pro-dimensions.scad>
use <ieq30pro-clutch.scad>
use <ieq30pro-dec-head.scad>

ra_and_dec($t * 360) {
  translate([0,0,0]) {
    echo("executing ra_and_dec child 1");
    color("blue")
      sphere(r=10);
  };
  color("red") linear_extrude(height=10) {  
    echo("executing ra_and_dec child 2");
    square(10, center=true);
  };
};

module ra_and_dec(dec_angle=0) {
  raise_dec = dec1_radius + ra1_base_to_dec;
  ra_to_dec();

//  echo("ra_and_dec has", $children, "children");

  translate([0, ra1_radius, raise_dec])
    rotate([-90,0,0])
      dec_body(dec_angle) {
        if ($children > 1) {
//          echo("has at least two children");
          children(1);
        }
      };

  // TODO Change coordinates of ra_and_dec so
  // that it rests on the z=0 plane natively.
  // this will make it easier to add children
  // to both the RA axis base and to the DEC
  // head.
  if ($children > 0) {
//    echo("has at least one child");
    #children(0);
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
          translate([0,0,-h1])
            cylinder(h=h1, r=ra1_radius);
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
      clutch();
  };
}

module dec_body(dec_angle=0) {
  rotate([180, 0, 0])
    dec_body_helper();
  translate([0, 0, dec2_len])
    rotate([0, 0, dec_angle])
      children();
}

module dec_body_helper() {
  total_dec_len =
    dec1_len + dec2_len + cw_cap_height +
    cw_cap_bevel_height;
  difference() {
    union() {
      color(cast_iron_color) {
        cylinder(h=dec1_len, r=dec1_radius);
        translate([0,0, -dec2_len])
          cylinder(h=dec2_len, r=dec2_radius);
      };
      // Cap on the end where the CW shaft is
      // screwed into the DEC body.
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
  
  translate([-w/2, dec_motor_z_offset, h - dec2_len + 0.01])
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


