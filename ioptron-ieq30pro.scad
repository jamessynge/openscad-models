// Units: mm

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.1;
// Don't generate larger angles than this many degrees.
$fa = 3;

////////////////////////////////////////////////////
// Diameter of dec body at bottom, near CW shaft.
dec1_diam = 67.66;
dec1_radius = dec1_diam / 2;

// Length of declination cylinder with dec1_diam.
dec1_len = 131.9;

// The black cap and the bottom of the dec body, where
// the counterweight shaft is attached.
cw_cap_height = 10;

// There is a countersink in the bottom of the DEC
// body to allow for the counterweight shaft.
cw_cs_diam = 23;
cw_cs_radius = cw_cs_diam / 2;

////////////////////////////////////////////////////
// Diameter of the motor end of the DEC body.

dec2_diam = 98.25;
dec2_radius = dec2_diam / 2;
dec2_len = 25.4;

// Declination motor cover size.
dec_motor_w = 85.4;  // left-right on face with logo.
dec_motor_h = 68.4;  // up-down on face with logo.
dec_motor_z = 62.4;

// Min dist from face with logo to dec1 cylinder.
dec_motor_z2 = 42;
dec_motor_z_offset =
  dec1_radius + dec_motor_z2 - dec_motor_z;

// Distance from edge of RA bearing
// to center of DEC axis.
ra_to_dec_offset = 20.0 + dec1_radius;

dec_body();
//dec_motor();

module dec_body() {
    color("beige") {
        cylinder(h=dec1_len, r=dec1_radius);
        translate([0,0, -dec2_len])
            cylinder(h=dec2_len, r=dec2_radius);
    };
    translate([0, 0, dec1_len])
        union() {
            color("black")
                cylinder(h=cw_cap_height,
                         r=dec1_radius);
            translate([0, 0, cw_cap_height])
                color("red")
                    rotate_extrude()
                        polygon([
                            [cw_cs_radius,0],
                            [dec1_radius,0],
                            [dec1_radius-10, 5],
                            [cw_cs_radius,5]]);
        };
//    rotate([-90,0,0])
      dec_motor();
}

module dec_motor() {
  w=dec_motor_w;
  h=dec_motor_h;
  z=dec_motor_z;
  
  
  translate([-w/2,dec_motor_z_offset,h - dec2_len])
  rotate([-90,0,0])
  {
      color("black")
        cube([dec_motor_w, dec_motor_h, dec_motor_z]);
      color("white")
        translate(
          [dec_motor_w/2, dec_motor_h/3,dec_motor_z])
    //    rotate([0, 90, 0])
          ioptron_logo();    
      };
}

module dec_motor_old() {
  w=dec_motor_w;
  h=dec_motor_h;
  z=dec_motor_z;
  translate([-w/2,0,])
    rotate([-90,0,0]) {
      color("black")
        cube([dec_motor_w, dec_motor_h, dec_motor_z]);
      color("white")
        translate(
          [dec_motor_w/2, dec_motor_h/3,dec_motor_z])
    //    rotate([0, 90, 0])
          ioptron_logo();    
      };
}

module ioptron_logo() {
  font = "Liberation Sans"; //["Liberation Sans", "Liberation Sans:style=Bold", "Liberation Sans:style=Italic", "Liberation Mono", "Liberation Serif"]
  text("iOptron", size=12, font="Liberation Sans:style=Italic",
       halign="center", valign="bottom", $fn=16);
  translate([0, -8, 0])
    text("iEQ30-Pro", size=6, font=font,
         halign="center", valign="top", $fn=16);
}