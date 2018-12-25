// Dimensions for weatherproofing design #1.
// Author: James Synge
// Units: mm

include <../ieq30pro_dimensions.scad>

// Thickness of the basic ring around the RA axis.
ra_ring_thickness = ra1_base_to_dec_gear_cover;

cw_sleeve_thickness = ra_ring_thickness;
cw_sleeve_length = 30 + dec1_len_beyond_ra;

// Thickness of the strap around the DEC2 axis (i.e. the DEC gear cover).
// ra1_base_to_dec_gear_cover is the maximum thickness when nearest the
// RA bearing plane. It is possible to have the strap be thicker elsewhere,
// and then thinner near that plane.
dec2_strap_thickness = ra_ring_thickness;

dec2_strap_width = dec2_len;

screw_diam = 4;
screw_hole_diam = screw_diam + 0.2;