// Dimensions for weatherproofing design #4.
// Author: James Synge
// Units: mm

include <../ieq30pro_dimensions.scad>
include <../ieq30pro_wp_dimensions.scad>
include <../../utils/metric_dimensions.scad>
use <dict.scad>

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

lid_thickness = 5;
lid_grip_height = 5;
helmet_extra_height_above_dec_skirt = lid_thickness + lid_grip_height + 4;


total_can_height = ra_motor_skirt_max_z + ra_bearing_gap + helmet_min_height_above_ra_bearing + helmet_extra_height_above_dec_skirt;


cw_shaft_port_dims =
  SetHeight(10,
    SetDepth(10,
      SetThickness(5,
        SetInnerDiam(30,
          SetMidDiam(40,
            SetOuterDiam(55))))));

dec_head_port_or = dec_clutch_handle_max_height + extra_dec_clutch_clearance*3 + dec_head_thickness;


dec_head_port_dims =
  SetHeight(dec_head_rain_plate_mid_z,
    SetDepth(dec_bearing_gap + dec2_len + ra1_radius,
      SetThickness(dec_head_thickness,
        SetInnerDiam(dec_head_avoidance_radius*2,
          SetMidDiam(dec_clutch_handle_max_height*2,
            SetOuterDiam(dec_head_port_or*2))))));

helmet_ir = ra_motor_clearance_radius_max + extra_ra_motor_clearance;
helmet_or = helmet_ir + ra_motor_skirt_thickness;
rim_or = helmet_ir + ra_motor_skirt_rim;

// Size of the notch in the helmet for an alignment tab in the lid.
lid_tab_slot_degrees = 4; // degrees