// Dimensions for weatherproofing design #2.
// Author: James Synge
// Units: mm

include <../ieq30pro_dimensions.scad>

// Note that this position of the collar assumes that the abs(latitude) is >= 20
// else the RA bearing roof will collide with the mount base.
ra_motor_collar_radius = 102; //100.8;
ra_motor_collar_z0 = ra2_len + ra3_len * 0.1;
ra_motor_collar_z1 = ra2_len + ra3_len * 0.5;


////////////////////////////////////////////////////////////////////////////////
// Cover for the RA bearing, at and below the RA bearing plane.

ra_bcbp_collar_offset = 3;
ra_bcbp_thickness = 5;
ra_bcbp_ir = ra_motor_collar_radius + ra_bcbp_collar_offset;
ra_bcbp_or = ra_bcbp_ir + ra_bcbp_thickness;

ra_bcbp_ex = ra2_len + ra3_len + ra_bearing_gap;


ra_to_dec_bearing_plane = ra1_radius + dec2_len;








// // Thickness of the basic ring around the RA axis.
// ra_ring_thickness = ra1_base_to_dec_gear_cover;


// // Thickness of the strap around the DEC2 axis (i.e. the DEC gear cover).
// // ra1_base_to_dec_gear_cover is the maximum thickness when nearest the
// // RA bearing plane. It is possible to have the strap be thicker elsewhere,
// // and then thinner near that plane.
// dec2_strap_thickness = ra_ring_thickness;

// dec2_strap_width = dec2_len;

// screw_diam = 4;
// screw_hole_diam = screw_diam + 0.2;

// dec1_hat_thickness = ra_ring_thickness;
// dec1_hat_inner_offset = 1;
// dec1_hat_outer_offset = dec1_hat_inner_offset + dec1_hat_thickness;

// dec1_hat_over_port_len = (dec1_len + polar_port_cap_diam) / 2;
// dec1_hat_transition_len = dec1_hat_thickness;
// dec1_hat_remainder_len = ra1_diam - dec1_hat_over_port_len - dec1_hat_transition_len;


// cw_sleeve_od = dec1_diam + 2 * dec1_hat_outer_offset;
// cw_sleeve_id = cw_cap_diam + 0.6;
// assert(cw_sleeve_od > cw_sleeve_id + 2);
// cw_sleeve_length = 30 + dec1_len_beyond_ra;