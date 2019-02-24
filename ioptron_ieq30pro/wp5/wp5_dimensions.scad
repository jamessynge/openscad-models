// Dimensions for weatherproofing design #4.
// Author: James Synge
// Units: mm

include <../ieq30pro_dimensions.scad>
include <../ieq30pro_wp_dimensions.scad>
include <../../utils/metric_dimensions.scad>
use <dict.scad>


rtp_boss_diam = m4_washer_diam * 1.5;
rtp_boss_height = m4_nut_diam2;

rtrt_boss_diam = m4_washer_diam * 1.5;
rtrt_boss_height = 0;  // Height in excess of that required for the diam.

extra_ra_motor_clearance = 5;

ra_motor_skirt_thickness = 5;
ra_motor_skirt_rim = rtp_boss_diam;

// DEC Head related dims.

extra_dec_clutch_clearance = 3;
extra_dec_head_clearance = 2;
dec_head_thickness = 5;

// Radius to leave empty so the clutch doesn't hit the helmet.
dec_head_clutch_avoidance_radius = dec_clutch_handle_max_height + extra_dec_clutch_clearance;

// Radius to leave empty so that there is room for the DEC head.
dec_head_avoidance_radius = dec_head_base_radius + extra_dec_head_clearance;

// NOTE: not sure where the *3 comes from. Why isn't that just *1 (i.e. no
// multiplier.)
dec_head_port_or = dec_clutch_handle_max_height + extra_dec_clutch_clearance*3 + dec_head_thickness;




helmet_min_height_above_ra_bearing = ra1_base_to_dec_center + dec_head_port_or;

lid_thickness = 5;
lid_grip_height = 5;
helmet_extra_height_above_dec_skirt = lid_thickness + lid_grip_height + rtp_boss_diam;

can_height_above_ra1_base = helmet_min_height_above_ra_bearing + helmet_extra_height_above_dec_skirt;
can_height_below_ra1_base = ra_motor_skirt_max_z + ra_bearing_gap;
total_can_height = can_height_below_ra1_base + can_height_above_ra1_base;


cw_shaft_port_dims =
  SetHeight(20,
    SetDepth(10,
      SetInnerDiam(30,
        SetOuterDiam(30 + dec_head_thickness*2))));

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

// Alignment cone dimensions.
cone_support_diam = 10;
cone_base_diam = 9;
cone_height = 4.5;
cone_hole_depth = 5; // The hole is a little deeper, with steeper sides, than the cone.

