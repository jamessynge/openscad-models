// Dimensions for weatherproofing design #4.
// Author: James Synge
// Units: mm

include <../ieq30pro_dimensions.scad>
include <../ieq30pro_wp_dimensions.scad>
include <../../utils/metric_dimensions.scad>

extra_ra_motor_clearance = 5;

ra_motor_skirt_thickness = 5;
ra_motor_skirt_rim = 10;

// DEC Head related dims.

extra_dec_clutch_clearance = 3;
extra_dec_head_clearance = 2;
dec_head_thickness = 5;

// Radius to leave empty so the clutch doesn't hit the helmet.
dec_head_clutch_avoidance_radius = dec_clutch_handle_max_height + extra_dec_clutch_clearance;

// Radius to leave empty so that there is room for the DEC head.
dec_head_avoidance_radius = dec_head_base_radius + extra_dec_head_clearance;




helmet_min_height_above_ra_bearing = ra1_base_to_dec_center + dec_head_clutch_avoidance_radius + dec_head_thickness;

lid_grip_height = 5;
helmet_extra_height_above_dec_skirt = 5 + lid_grip_height;

lid_thickness = 5;