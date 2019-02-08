// Dimensions for weatherproofing design #4.
// Author: James Synge
// Units: mm

include <../ieq30pro_dimensions.scad>
include <../../utils/metric_dimensions.scad>

// Note that this position of the collar assumes that the abs(latitude) is >= 20
// else the RA bearing roof will collide with the mount base.
ra_motor_collar_thickness = 5;
ra_motor_collar_radius = 100.8;
// ra_motor_collar_z0 = ra2_len - ra_motor_collar_thickness / 2;
// ra_motor_collar_z1 = ra_motor_collar_z0 + ra_motor_collar_thickness;
ra_motor_collar_z0 = ra2_len;
ra_motor_collar_z1 = ra_motor_collar_z0 + ra_motor_collar_thickness;


////////////////////////////////////////////////////////////////////////////////
// Cover for the RA bearing, at and below the RA bearing plane.

ra_bcbp_collar_offset = 3;
ra_bcbp_thickness = 5;
ra_bcbp_ir = ra_motor_collar_radius + ra_bcbp_collar_offset;
ra_bcbp_or = ra_bcbp_ir + ra_bcbp_thickness;

ra_bcbp_ex = ra2_len + ra3_len + ra_bearing_gap;

// How far above RA bearing plane before we go from ~cylinder to hemisphere.
helmet_cyl_above_bearing = ra1_base_to_dec + dec1_radius * 1.75;

ra_to_dec_bearing_plane = ra1_radius + dec2_len;

rtp_boss_diam = m4_washer_diam * 1.5;
rtp_boss_height = m4_nut_diam2;

// Dimensions for rib at bottom. Goal is to provide enough room for a slotted
// boss for an M4 screw. Will require that the DEC bearing rain plate be
// notched to allow room for the rib.
// Note that the rib can't be on the inside because it would very nearly collide
// with the plate of the RA motor hat.

helmet_bottom_rib_thickness = rtp_boss_diam;
helmet_bottom_rib_height = rtp_boss_diam;


cws_port_ir = cw_shaft_diam;
cws_port_or = cws_port_ir + ra_bcbp_thickness;

// Misc dimensions, to be moved into wp2_dimensions.
dec1_hat_ra_bearing_gap = ra1_base_to_dec / 2;



helmet_supports_height_above_ra_bearing = ra1_base_to_dec_center + 50;



// Dimensions for the hoop et al which attach to the DEC motor cover cover (DMCC).
hoop_disc_wall = 4;
min_hoop_disc_z = clutch_handle_base_diam + hoop_disc_wall;
assert(min_hoop_disc_z <= dec_gap_to_saddle_knob);
hoop_disc_z = (min_hoop_disc_z + dec_gap_to_saddle_knob) / 2;
hoop_depth = hoop_disc_z + dec2_len;

// This is a radius that will clear clutch regardless of clutch handle position.
dec_hoop_interior_radius = dec_clutch_handle_max_height + 5;
hoop_roof_thickness = 15;
dec_hoop_exterior_radius = dec_hoop_interior_radius + hoop_roof_thickness;


// This is overkill, but will ensure that we don't collide with the clutch.
dec_clutch_z = clutch_handle_base_diam;


// Thickness of the basic ring around the RA axis.
ra_ring_thickness = ra1_base_to_dec_gear_cover;


// // Thickness of the strap around the DEC2 axis (i.e. the DEC gear cover).
// // ra1_base_to_dec_gear_cover is the maximum thickness when nearest the
// // RA bearing plane. It is possible to have the strap be thicker elsewhere,
// // and then thinner near that plane.
// dec2_strap_thickness = ra_ring_thickness;

// dec2_strap_width = dec2_len;

// screw_diam = 4;
// screw_hole_diam = screw_diam + 0.2;


dec1_hat_thickness = 5;
dec1_hat_inner_offset = 1;
dec1_hat_outer_offset = dec1_hat_inner_offset + dec1_hat_thickness;

dec1_hat_over_port_len = (dec1_len + polar_port_cap_diam) / 2;
dec1_hat_transition_len = dec1_hat_thickness;
dec1_hat_remainder_len = ra1_diam - dec1_hat_over_port_len - dec1_hat_transition_len;


cw_sleeve_od = dec1_diam + 2 * dec1_hat_outer_offset;
cw_sleeve_id = dec1_diam + 2 * dec1_hat_inner_offset; // == cw_cap_diam + 0.6;
assert(cw_sleeve_od > cw_sleeve_id + 2);
cw_sleeve_length = 30 + dec_len_beyond_ra;




dflt_helmet_ir=ra_bcbp_ir;
dflt_helmet_or=ra_bcbp_or;
dflt_dec_port_ir=dec_hoop_interior_radius;
dflt_dec_port_or=dec_hoop_exterior_radius;
dflt_cws_port_ir = cws_port_ir;
dflt_cws_port_or = cws_port_or;
