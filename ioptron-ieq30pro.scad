// Units: mm

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.1;
// Don't generate larger angles than this many degrees.
$fa = 3;

cast_iron_color = "beige";

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

////////////////////////////////////////////////////
// Declination motor cover size.
dec_motor_w = 85.4;  // left-right on face with logo.
dec_motor_h = 68.4;  // up-down on face with logo.
dec_motor_z = 62.4;

////////////////////////////////////////////////////
// Min dist from face with logo to dec1 cylinder.
dec_motor_z2 = 42;
dec_motor_z_offset =
  dec1_radius + dec_motor_z2 - dec_motor_z;

////////////////////////////////////////////////////
// RA axis diameter at the bearing, where the moving
// and stationary parts meet.
ra2_radius = 62;
ra2_diam = ra2_radius*2;

////////////////////////////////////////////////////
// Distance from edge of RA bearing to outside and
// center of DEC axis.
ra2_base_to_dec = 21.5;
ra2_base_to_dec_center = ra2_base_to_dec + dec1_radius;

rotate([0,$t*360,0])
  translate([0,0,-ra2_radius])
    ra_and_dec();

module ra_and_dec() {
  dec_body();
  ra_to_dec();
}

module dec_body() {
    color(cast_iron_color) {
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
  dec_motor();
}

module dec_motor() {
  w=dec_motor_w;
  h=dec_motor_h;
  z=dec_motor_z;
  translate([-w/2, dec_motor_z_offset, h - dec2_len + 0.1])
    rotate([-90,0,0]) {
      // TODO Chamfer the motor cover.
      color("black") cube([w, h, z]);
      color("white") translate([w/2, h/3,z])
        ioptron_logo();    
    };
}

module ioptron_logo() {
  font = "Liberation Sans";
  italic_font = str(font, ":style=Italic");
  text("iOptron", size=12, font=italic_font,
       halign="center", valign="bottom", $fn=16);
  translate([0, -8, 0])
    text("iEQ30-Pro", size=6, font=font,
         halign="center", valign="top", $fn=16);
}

module ra_to_dec() {
  h1 = ra2_base_to_dec;
  h2 = 45 - h1;
  fillet_radius = ra2_radius - dec1_radius + 2;
  color(cast_iron_color)
    
  translate([0, -dec1_radius, ra2_radius])
    rotate([-90,0,0])
      difference() {
        union() {
          translate([0,0,-h1])
          cylinder(h=h1, r=ra2_radius);
          cylinder(h=h2, r=ra2_radius);
        }
        translate([0,ra2_radius,fillet_radius])
          rotate([90,0,0]) {
            translate([-ra2_radius,0,0])
              cylinder(h=ra2_diam, r=fillet_radius);
            translate([ra2_radius,0,0])
              cylinder(h=ra2_diam, r=fillet_radius);
          }
      }
}

