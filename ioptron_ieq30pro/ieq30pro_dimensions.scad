// Dimensions for modelling the iOptron iEQ30 Pro, measured from a single instance.
// Author: James Synge
// Units: mm

cast_iron_color = "bisque";//"gray";//"beige";
plastic_color = [0.1,0.1,0.1];
bearing_color = "silver";

////////////////////////////////////////////////////////////////////////////////
// Diameter of dec body at bottom, near CW shaft.
dec1_diam = 67.66;
dec1_radius = dec1_diam / 2;

// Length of declination cylinder with dec1_diam.
dec1_len = 131.9;

////////////////////////////////////////////////////////////////////////////////
// The black cap and the bottom of the dec body, where
// the counterweight shaft is attached.
cw_cap_height = 10;
cw_cap_bevel_height = 5;

// There is a countersink in the bottom of the DEC body to allow for the
// counterweight shaft to screw into the body.
cw_cs_diam = 23;
cw_cs_radius = cw_cs_diam / 2;

cw_thread_diam = 16;
cw_thread_radius = cw_thread_diam / 2;

cw_shaft_diam = 20;


////////////////////////////////////////////////////////////////////////////////
// The polar scope port on the ra_to_dec portion. Naturally it is centered on
// the RA axis.
polar_port_diam = 28.4;
//polar_port_offset = 60;  // To center of port.
polar_port_height = 2.15;  // Above surface of dec1 body.
polar_port_cap_diam = 31.9;
polar_port_cap_height = 8;

////////////////////////////////////////////////////////////////////////////////
// Diameter of the motor end of the DEC body.

//dec2_diam = 97.4;  // Spec, +/- 0.3mm.
dec2_diam = 97.6;  // Measured on PAN006.
dec2_radius = dec2_diam / 2;
dec2_len = 25.4;

// The inside edge of the DEC bearing cover (towards the RA axis) is tangent
// to the RA bearing cover, but doesn't asymptotically approach the RA
// bearing cover; instead there is a rectangular shoulder where they meet.
dec2_shoulder_width = 39.5;

////////////////////////////////////////////////////////////////////////////////
// Declination motor cover size.
dec_motor_w = 85.4;  // left-right on face with logo.
dec_motor_h = 68.4;  // up-down on face with logo.
dec_motor_z = 62.4;

// Distance away from bearing plane.
dec_motor_setback = 0.01;

////////////////////////////////////////////////////////////////////////////////
// Min dist from face with logo to dec1 cylinder.
dec_motor_z2 = 42;
dec_motor_z_offset =
  dec1_radius + dec_motor_z2 - dec_motor_z;

////////////////////////////////////////////////////////////////////////////////
// RA axis diameter at the bearing, where the moving
// and stationary parts meet.
ra1_diam = 120;  // +/- 0.3mm.
ra1_radius = ra1_diam / 2;

////////////////////////////////////////////////////////////////////////////////
// Distance from edge of RA bearing to outside of
// DEC body, center of DEC axis, and outside of
// DEC gear cover.
ra1_base_to_dec = 21.5;
ra1_base_to_dec_center = ra1_base_to_dec + dec1_radius;
ra1_base_to_dec_gear_cover =
    ra1_base_to_dec_center - dec2_radius;

////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
// Dimensions for the DEC and RA clutches. They are
// mostly identical, except that the DEC clutch
// sticks out farther from the DEC head and its
// screw axis is a bit closer to the bearing gap.
// The model won't include the draft angle of the
// handle.

clutch_flange_width = 28;
clutch_flange_height = 5.75;
clutch_extrusion = 9.2; // from casting diam.
clutch_base_diameter = 18;
clutch_base_height = 19.75;
clutch_screw_length = 10.75; // casting to head.
clutch_screw_head_diam = 8.2;
clutch_handle_base_diam = 20.6;
clutch_handle_length = 38.9; // screw center to end.
clutch_handle_width = 8.75; // At widest.
clutch_handle_depth1 = 10.2;
clutch_handle_depth2 = 13.7;

// Compute the angle of the circle of the DEC gear cover subtended by the
// DEC clutch. See:
//  https://en.wikipedia.org/wiki/Circular_segment
dec_clutch_angle = 2 * asin(clutch_flange_width/dec2_diam);

// Compute the angle of the circle of the RA gear cover subtended by the
// RA clutch. See:
//  https://en.wikipedia.org/wiki/Circular_segment
ra_clutch_angle = 2 * asin(clutch_flange_width/ra1_diam);

////////////////////////////////////////////////////
// Dimensions for the DEC head (i.e. the part
// rotated by the DEC motor, which has the dove tail
// saddle for holding the telescope).

dec_head_base_diam = 97.66;
dec_head_base_radius = dec_head_base_diam / 2;
dec_head_base_height = 3.83;
dec_head_height = 46.3;  // Above base.
dec_head_diam1 = 89.5;  // At top of base (radius is ~4mm less than base).
dec_head_diam2 = 86.9;  // At top, due to draft angle.
dec_head_scale = dec_head_diam2 / dec_head_diam1;

// Saddle, where the dovetail plate is secured by two screws.
dec_saddle_depth = 13.8;
dec_saddle_width1 = 44; // At top of saddle
dec_saddle_width2 = 46.5; // At bottom of saddle
dec_saddle_height =
    dec_head_base_height +
    dec_head_height - dec_saddle_depth;
dovetail_width = 45.25;

// Perpendicular to the direction of the saddle plate is a slot with
// a slight draft angle.
dec_slot_corner_radius = 5;
dec_slot_width_bottom = 60;
dec_slot_width_top = 60.8;
dec_slot_len_bottom = 25;
dec_slot_len_top = 25.8;

// There is a "buttress" added to the extruded profile through which
// the saddle plate screws pass. It is a bit hard to measure its shape,
// so these are bit approximate.
dec_head_buttress_height_top = 72;  // At top of DEC head.
dec_head_buttress_half_width_top = 39.5;  // Eyeballed edge to centerline of saddle.



dec_head_square_top = 72;
dec_head_square = dec_head_square_top / dec_head_scale;


dec_head_clamp_screw_diam = 7.8;  // OD
dec_head_clamp_screw_depth = 6.66;  // Top to centerline.
dec_head_clamp_screw_spacing = 44.4; 

dec_bearing_gap = ra_bearing_gap;


// Minimum distance from the plane of the DEC bearing gap to the saddle screw
// knobs.
dec_gap_to_saddle_knob = 31;

// Min and max distance from DEC axis to outer (top) of DEC axis clutch handle. 
// The minimum is when the clutch handle is turned 90 degrees DEC bearing gap,
// and is thus parallel with the DEC axis itself. The max occurs because the
// handle is straight, so becomes farther and farther away from the DEC bearing
// gap as it is tangent to the circle.

dec_clutch_handle_min_height = dec2_radius + 18.6; 
dec_clutch_handle_max_height = dec2_radius + 26.6; 

////////////////////////////////////////////////////////////////////////////////
// Computed values for the DEC bearing.

// Can't go too large because otherwise we'll
// hit the RA motor cover.
dec_cover_max_radius =
    dec2_radius + ra1_base_to_dec_gear_cover;
dec_cover_max_diam = dec_cover_max_radius * 2;

// Compute the angle of the circle of the
// DEC gear cover subtended by the motor
// cover. See:
//  https://en.wikipedia.org/wiki/Circular_segment
dec_motor_cover_angle = 2 * asin(dec_motor_w/dec2_diam);

dec1_len_beyond_ra = dec1_len + cw_cap_height + cw_cap_bevel_height - ra1_diam;

////////////////////////////////////////////////////////////////////////////////
// Four star knob dimensions.
fsk_inner_diam = 20.2;
fsk_notch_diam = 20.2;
fsk_outer_diam = 26.1;
fsk_height = 11.5;
fsk_shoulder_height = 5.65;
fsk_shoulder_diam = 14.9;
fsk_screw_len = 24.4;

////////////////////////////////////////////////////////////////////////////////

// Latitude (absolute) of the site where the mount will be installed.
// The reason this is absolute is that the mount is rotated to point
// to the nearest celestial pole, so latitudes are always non-negative.
// This needs to be adjusted for each site. High precision is NOT required
// (i.e. +/- 5 degrees shouldn't make any difference).
mount_latitude = 43;

assert(mount_latitude >= 0);
assert(mount_latitude < 90);