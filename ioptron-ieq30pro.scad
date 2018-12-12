// Units: mm

use <chamfer.scad>
include <ieq30pro-dimensions.scad>
include <ieq30pro-clutch.scad>

// Global resolution
// Don't generate smaller facets than this many mm.
$fs = 0.5;
// Don't generate larger angles than this many degrees.
$fa = 1;

ioptron_mount($t * 360) {};

translate([200,0,0]) dec_head();

module dec_head() {
//  linear_extrude
  color(cast_iron_color)
    cylinder(h=dec_head_base_height, r=dec_head_base_diam/2);
}


module ioptron_mount(ra_angle=0) {
  rotate([0, 0, ra_angle])
    translate([0, 0, ra_bearing_gap/2]) {
      ra_and_dec() {
        children();
      }
    };

  ra_bearing();
  
  rotate([180, 0, 0])
    ra_body();
}

module ra_body() {
  // To avoid modeling more of the RA body,
  // we extend the ra3 section longer ... for now.
  ra3_extra_long = ra3_len * 4;
  color(cast_iron_color) {
    cylinder(h=ra2_len, r=ra2_radius);
    translate([0, 0, ra2_len])
      cylinder(h=ra3_extra_long, r=ra3_radius);
  }

  // RA motor/electronics cover dimensions, arranged
  // very much like the DEC motor cover.
  // x is perpendicular to the ground and to the
  // RA axis; y is parallel to the RA axis; z is
  // distance from the RA axis.
  x = 95.1;
  y = 68.5;
  z = 49;   // top of cover to intersection
            //with ra2_diam.
  // Height of top of cover above the ra2_diam.
  ra_cover_height = 24.0;
  ra_z_offset = ra2_radius + ra_cover_height - z;
  
  translate([0,0,0])
    rotate([90,0,0])
      color("black")
        translate([-x/2, 0.01, ra_z_offset])
          intersection() {
            chamferCube(x,y,z,chamferHeight=12,
              chamferX=[0,0,0,1], chamferY=[0,0,0,0],
              chamferZ=[0,0,0,0]);
            chamferCube(x,y,z,chamferHeight=4,
              chamferX=[0,0,1,0], chamferY=[0,1,1,0],
              chamferZ=[0,0,0,0]);
          };
}

// A little decoration for the model, so that the
// two sides of the RA bearing aren't butted up
// against each other in an unrealistic fashion,
// and to match the way the mount actually looks;
// i.e. there is a very small gap between the two
// sides through which we can see silver colored
// metal.
module ra_bearing() {
  h=3;
  color("silver")
    translate([0, 0, -h/2])
      cylinder(h=h, r=ra2_radius-2);
}

module ra_and_dec() {
  // Translate and rotate so that the RA bearing
  // circle is on the z=0 plane, centered at the
  // origin of the plane.
  rotate([90,0,0])
  translate(
    [0,dec1_radius+ra1_base_to_dec,-ra1_radius]) {
    dec_body();
    ra_to_dec();
  }
  // TODO Change coordinates of ra_and_dec so
  // that it rests on the z=0 plane natively.
  // this will make it easier to add children
  // to both the RA axis base and to the DEC
  // head.
  children();
}

module dec_body() {
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
      color("black")
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
      color("black") {
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

module ra_to_dec() {
  h1 = ra1_base_to_dec;
  h2 = 45 - h1;
  fillet_radius = ra1_radius - dec1_radius + 2;
  translate([0, -dec1_radius, ra1_radius])
    rotate([-90,0,0]) {
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
