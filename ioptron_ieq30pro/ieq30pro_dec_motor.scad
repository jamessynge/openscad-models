// Defines the black plastic cover that sits over the DEC motor and electronics.
// Looks like a fairly simple shell with some chamfered edges, but it also seems
// to have a draft angle to it.
// Author: James Synge

// Units: mm

include <ieq30pro_dimensions.scad>
use <../utils/chamfer.scad>


dec_motor();


translate([100, 0, 0])
  difference(){
    dec_motor_shell();
    translate([500,0,0])
    cube(size=1000, center=true);
  }

module dec_motor() {
  wt = 85.3;
  wb = 86.2;
  ht = 68.1;
  hb = 68.7;
  z = 57.4;

  translate([-wt/2,-hb + (hb-ht)/2,z]) {
    color(plastic_color)
      translate([0,ht, 0])
        rotate([180,0,0])
        {
          difference() {
            linear_extrude(height=z, scale=[wb/wt, hb/ht])
              square(size=[wt, ht], center=false);

            cs = 1000;
            h3 = 59.8;
            h4 = ht - h3;

            translate([0, h4, 0])
              rotate([-45, 0, 0])
                translate([0, 0, -cs/2])
                  cube(size=cs, center=true);
          }
        }

    dec_motor_top(wt);

    color(plastic_color)
      dec_motor_bump(z);
  }

  // z=34.42 from top section to cut off for dec2
}

module dec_motor_top(wt) {
  delta_per_side = 4.45;
  w = wt;
  h = 59.8;
  z = delta_per_side;

  color(plastic_color)
  translate([w/2, h/2, 0])
    linear_extrude(height=z, scale=[(w - 2*delta_per_side)/w, (h - 2 * delta_per_side)/h])
      square(size=[w, h], center=true);

  color("white") 
    translate([w/2, h/2.5, z])
      linear_extrude(height = 0.1)
        ioptron_logo();
}

module dec_motor_bump(core_z) {
  drop_from_top = 5.75;

  w1 = 19.6;
  w2 = 11.6;
  dw = w1 - w2;
  sw = w2/w1;

  h1 = core_z - drop_from_top;
  h2 = h1 - dw;
  sh = h2 / h1;

  rotate([90-.6 /*Apparently the draft angle is ~0.6 degrees*/, 0,0])
    translate([w1/2+ 48.5,-h1/2 - drop_from_top ])
      linear_extrude(height=dw/2, scale=[sw, sh])
        square(size=[w1, h1], center=true);
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

module dec_motor_shell() {
  intersection() {
    dec_motor();
    minkowski() {
      difference(){
        cube(size=1000, center=true)
        dec_motor();
      }
      sphere(r=2, center=true);
    }
  }
}