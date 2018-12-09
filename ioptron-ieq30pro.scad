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

rotate([0,0,$t*360])
    ra_and_dec();

module ra_and_dec() {
  // Translate and rotate so that the RA bearing
  // circle is on the z=0 plane, centered at the
  // origin of the plane.
  rotate([90,0,0])
  translate(
    [0,dec1_radius+ra2_base_to_dec,-ra2_radius]) {
    dec_body();
    ra_to_dec();
  }
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

// Chamfer one edge of a cube. The cube has dimensions
// x,y,z. The edge to be chamfered (one of 12)
// is indicated by the axis it is parallel to
// (only one), and whether it is through the
// origin of the other two axes.
module chamfer_cube_edge(
    sx,sy,sz,
    chamfer_angle=45,
    chamfer_depth=0,
    par_x=false,par_y=false,par_z=false,
    or_x=true,or_y=true,or_z=true) {
  epsilon = 0.01;
  smax = max(sx, sy, sz) + epsilon*2;
//  cs2 = sqrt(chamfer_size * chamfer_size * 2);
//  cxlen = sx + 0.02;
  cxoff = 0;
  cyoff = 0;
  czoff = 0;
//  cylen = sy + 0.02;
//  czlen = sz + 0.02;
//  czoff = -0.01;
  if (par_x) {
    assert(par_y==false);
    assert(par_z==false);
//    cylen=chamfer_size;
    cxoff = -epsilon;
    if (or_y) {
      cyoff = -sy/2;
    } else {
      cyoff = sy/2;
    }
  }
  if (par_y) {
    assert(par_x==false);
    assert(par_z==false);
  }
  if (par_z) {
    assert(par_x==false);
    assert(par_y==false);
  }

  echo("offsets");
  echo(cxoff);
  echo(cyoff);
  echo(czoff);

  
  translate([cxoff, cyoff, czoff])
    cube([smax, smax, smax]);
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
  */
module chamferCube(sizeX, sizeY, sizeZ, chamferHeight = 1, chamferX = [1, 1, 1, 1], chamferY = [1, 1, 1, 1], chamferZ = [1, 1, 1, 1]) {
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
