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
cw_cap_bevel_height = 5;

// There is a countersink in the bottom of the DEC
// body to allow for the counterweight shaft.
cw_cs_diam = 23;
cw_cs_radius = cw_cs_diam / 2;

cw_thread_diam = 16;
cw_thread_radius = cw_thread_diam / 2;

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
ra1_radius = 62;
ra1_diam = ra1_radius*2;

////////////////////////////////////////////////////
// Distance from edge of RA bearing to outside and
// center of DEC axis.
ra1_base_to_dec = 21.5;
ra1_base_to_dec_center = ra1_base_to_dec + dec1_radius;

////////////////////////////////////////////////////
// Dimensions for the non-moving portion of the
// mount. Much less detail is needed here, so only
// a few objects are modeled.

// RA bearing cover diameter and length.
ra2_radius = ra1_radius;
ra2_len = 24.5;

// RA body becomes narrower.
ra3_radius = ra2_radius - 19.86;
ra3_len = 17.13;

ra_bearing_gap = 0.6;

rotate([0,0,$t*360])
  translate([0, 0, ra_bearing_gap/2])
    ra_and_dec();

ra_bearing();


rotate([180, 0, 0])
//  translate([200, 0, ra_bearing_gap/2])
    ra_body();



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

//          chamferCube(x,y,z,chamferHeight=5,
//            chamferX=[0,0,0,1], chamferY=[0,1,1,0],
//            chamferZ=[0,0,0,0]);
          };

}










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
//          chamferCube(w,h,z,chamferHeight=4,
//            chamferX=[1,1,0,1], chamferY=[0,0,0,0],
//            chamferZ=[0,0,0,0]);
        }
      };
        
//      difference() {
//        cube([w, h, z]);
//        // Chamfer the motor cover, i.e. remove
//        // corners.
//        translate([-0.1, 0, z-sqrt(5*5*2)])
//          rotate([45, 0, 0])
//            cube([w+0.2,10,10]);
//        
//        #chamfer_cube_edge(w,h,z,5,
//          par_x=true, or_y=false, or_z=false);
//        
//        
//        #translate([0, -0.1, z-sqrt(5*5*2)])
//          #rotate([0, 45, 0])
//            cube([10,h+0.2,10]);
//      }
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
  color(cast_iron_color)
    
  translate([0, -dec1_radius, ra1_radius])
    rotate([-90,0,0])
      difference() {
        union() {
          translate([0,0,-h1])
          cylinder(h=h1, r=ra1_radius);
          cylinder(h=h2, r=ra1_radius);
        }
        translate([0,ra1_radius,fillet_radius])
          rotate([90,0,0]) {
            translate([-ra1_radius,0,0])
              cylinder(h=ra1_diam, r=fillet_radius);
            translate([ra1_radius,0,0])
              cylinder(h=ra1_diam, r=fillet_radius);
          }
      }
}

/**
  * chamferCube returns an cube with 45° chamfers on the edges of the
  * cube. The chamfers are diectly printable on Fused deposition
  * modelling (FDM) printers without support structures.
  *
  * @param  sizeX          The size of the cube along the x axis
  * @param  sizeY          The size of the cube along the y axis
  * @param  sizeZ          The size of the cube along the z axis
  * @param  chamferHeight  The "height" of the chamfers as seen from
  *                        one of the dimensional planes (The real
  *                        width is side c in a right angled triangle)
  * @param  chamferX       Which chamfers to render along the x axis
  *                        in clockwise order starting from the zero
  *                        point, as seen from "Left view" (Ctrl + 6)
  * @param  chamferY       Which chamfers to render along the y axis
  *                        in clockwise order starting from the zero
  *                        point, as seen from "Front view" (Ctrl + 8)
  * @param  chamferZ       Which chamfers to render along the z axis
  *                        in clockwise order starting from the zero
  *                        point, as seen from "Bottom view" (Ctrl + 5)
  *
  * Copied from:
  *  https://raw.githubusercontent.com/SebiTimeWaster/Chamfers-for-OpenSCAD/master/Chamfer.scad
  */
module chamferCube(
    sizeX, sizeY, sizeZ,
    chamferHeight = 1,
    chamferX = [1, 1, 1, 1],
    chamferY = [1, 1, 1, 1],
    chamferZ = [1, 1, 1, 1]) {
    chamferCLength = sqrt(chamferHeight * chamferHeight * 2);
    difference() {
        cube([sizeX, sizeY, sizeZ]);
        for(x = [0 : 3]) {
            chamferSide1 = min(x, 1) - floor(x / 3); // 0 1 1 0
            chamferSide2 = floor(x / 2); // 0 0 1 1
            if(chamferX[x]) {
                translate([-0.1, chamferSide1 * sizeY, -chamferHeight + chamferSide2 * sizeZ])
                rotate([45, 0, 0])
                cube([sizeX + 0.2, chamferCLength, chamferCLength]);
            }
            if(chamferY[x]) {
                translate([-chamferHeight + chamferSide2 * sizeX, -0.1, chamferSide1 * sizeZ])
                rotate([0, 45, 0])
                cube([chamferCLength, sizeY + 0.2, chamferCLength]);
            }
            if(chamferZ[x]) {
                translate([chamferSide1 * sizeX, -chamferHeight + chamferSide2 * sizeY, -0.1])
                rotate([0, 0, 45])
                cube([chamferCLength, chamferCLength, sizeZ + 0.2]);
            }
        }
    }
}