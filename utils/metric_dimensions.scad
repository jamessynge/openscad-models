// Dimensions a few metric fasteners.
// Author: James Synge
// Units: mm

////////////////////////////////////////////////////////////////////////////////
// Selected metric screw and nut size info (maximum dimensions), ISO 4032.
// For the washers, using standard DIN 125 / ISO 7089:
//    https://www.engineersedge.com/iso_flat_washer.htm

m4_screw_diam = 4;
m4_hole_diam = 4.5;
m4_nut_diam1 = 7;  // Width across the flats
m4_nut_diam2 = 7.66;  // Width across the corners
m4_nut_height = 3.2;
m4_washer_hole_diam = 4.3;
m4_washer_diam = 9;
m4_washer_thickness = 0.8;

m5_screw_diam = 5;
m5_hole_diam = 5.5;
m5_nut_diam1 = 8;  // Width across the flats
m5_nut_diam2 = 8.79;  // Width across the corners
m5_nut_height = 4.7;


// Given the width across a six sided nut (flat side to flat side),
// how wide is the nut from point to farthest point (i.e. what is the
// diameter of the smallest circle that will enclose the nut).
function hex_short_to_long_diag(d) = d * 2.0 / sqrt(3.0);
