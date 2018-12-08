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



// Distance from edge of RA bearing
// to center of DEC axis.
ra_to_dec_offset = 20.0 + dec1_radius;

dec_body();

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

}