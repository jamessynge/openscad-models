// Dimensions for modelling the iOptron iEQ30 Pro, measured from a single instance.
// Author: James Synge
// Units: mm

cast_iron_color = "bisque";//"gray";//"beige";

// Lighter colors makes it easier to see variations than does black
plastic_color = "gray"; // [0.1,0.1,0.1];
bearing_color = "silver";

polar_scope_color = "slategray";

////////////////////////////////////////////////////////////////////////////////
// Diameter of dec body at bottom, near CW shaft.
dec1_diam = 67.66;
dec1_radius = dec1_diam / 2;

// Diameter of dec body at motor mount, before dec bearing cover (aka. dec2).
dec11_diam = 67.8;

// Length of declination cylinder with ~dec1_diam.
dec1_len = 131.9;

// There is a hatch for accessing the DEC shaft; it protrudes from the dec1
// body a little.
dec1_hatch_offset = 0.3;


////////////////////////////////////////////////////////////////////////////////
// The black cap and the bottom of the dec body, where
// the counterweight shaft is attached.
cw_cap_diam = 68.1;  // Slightly larger than dec1_diam.
cw_cap_height = 10;
cw_cap_bevel_height = 5;
cw_cap_total_height = cw_cap_height + cw_cap_bevel_height;

// There is a countersink in the bottom of the DEC body to allow for the
// counterweight shaft to screw into the body.
cw_cs_diam = 23;
cw_cs_radius = cw_cs_diam / 2;

cw_thread_diam = 16;
cw_thread_radius = cw_thread_diam / 2;

cw_shaft_diam = 20;


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
// RA axis diameter at the bearing, where the moving and stationary parts meet.
ra1_diam = 120;  // +/- 0.3mm.
ra1_radius = ra1_diam / 2;
ra_bearing_gap = 0.6;

////////////////////////////////////////////////////////////////////////////////
// Distance from edge of RA bearing to outside of
// DEC body, center of DEC axis, and outside of
// DEC gear cover.
ra1_base_to_dec = 21.5;
ra1_base_to_dec_center = ra1_base_to_dec + dec1_radius;
ra1_base_to_dec_gear_cover =
    ra1_base_to_dec_center - dec2_radius;

// Radius of the fillets that join the dec1 body to the ra1 body.
ra_to_dec_fillet_radius = ra1_radius - dec1_radius + 2;

////////////////////////////////////////////////////////////////////////////////
// Dimensions for the non-moving portion of the mount. Much less detail is
// needed here, so only a few objects are modeled.

// RA bearing cover diameter and length.
ra2_radius = ra1_radius;
ra2_len = 24.5;  // Varies quite a bit (e.g. by +/- 0.5), not sure why.

// RA body becomes narrower after the bearing cover.
ra3_diam = 78.2;
ra3_radius = ra3_diam / 2;
ra3_len = 16.8;

// Next there is a section that is ~rectangular above the midline, and like
// ra3 below the midline, except it also has "feet" by which the whole piece
// is attached to the base of the mount. Not modelling those feet as they don't
// affect the weatherproofing. Instead, treating this as if it extends all the
// the way back to near the polar scope.
ra4_diam = ra3_diam;
ra4_width = 65.7;
ra4_len = 72;

// Now the section before the polar scope.
ra5_diam = 73.5;
ra5_len = 8;

////////////////////////////////////////////////////////////////////////////////
// Polar scope at bottom of fixed RA body.

ps1_diam = 74.2;
ps1_len = 8.3;

ps2_diam = 60.25;
ps2_len = 15;

// Section 3 is a truncated cone, apparently with a 45 degree slope, so
// the amount that it narrows in radius is the length (cone height).
ps3_od = ps2_diam;
ps3_id = 42.1;
ps3_len = (ps3_od - ps3_id) / 2;

ps4_diam = ps3_id;
ps4_len = 23.7;

// Section 5 is a truncated cone, apparently with a 45 degree slope, so
// the amount that it narrows in radius is the length (cone height).
ps5_od = ps4_diam;
ps5_id = 29.2;
ps5_len = (ps5_od - ps5_id) / 2;




////////////////////////////////////////////////////////////////////////////////
// The polar scope port on the ra_to_dec portion. Naturally it is centered on
// the RA axis.

polar_port_diam = 28.4;
//polar_port_offset = 60;  // To center of port.
polar_port_height = 2.15;  // Above surface of dec1 body.
polar_port_cap_diam = 31.9;
polar_port_cap_height = 8;

////////////////////////////////////////////////////////////////////////////////
// Declination motor cover size.
dec_motor_w = 85.4;  // left-right on face with logo.  OBSOLETE
dec_motor_h = 68.4;  // up-down on face with logo.  OBSOLETE
// dec_motor_z = 62.4;

// Distance away from bearing plane.
dec_motor_setback = 0.01;

// Updated DEC motor sizes, after finding that the above were a little off,
// and that there is a draft angle, so it is smaller on the plane with the
// logo than it is nearest the DEC axis.

// Measurements for the core, not including the truncated pyramid on top that
// features the logo, nor the bump near the polar scope port. The core is a bit
// bigger at the bottom, towards the DEC axis due to a draft angle; this is a
// feature that allows a part to be removed from an injection molding machine.
dec_motor_core_top_w = 85.3;
dec_motor_core_bottom_w = 86.2;
dec_motor_core_top_h = 68.1;
dec_motor_core_bottom_h = 68.7;
dec_motor_core_z = 57.4;

// By inspection, the effective draft angle that I've "recreated" is a little
// less than 0.6 degrees.
dec_motor_draft_angle = 0.55;

// The DEC motor "top" is the truncated pyramid on top that features the logo.
dec_motor_top_base_w = dec_motor_core_top_w;
dec_motor_top_base_h = 59.8;
dec_motor_top_z = 4.45;

dec_motor_z = dec_motor_core_z + dec_motor_top_z;

// In addition to the chamfer of the truncated pyramid, the outer edge next to
// the DEC bearing plane has a bigger chamfer. This is the distance from the
// edge of the core next to the DEC bearing plane to the line through which the
// chamfer cuts. We can use this to remove the excess.
dec_motor_core_chamfer_h_offset = dec_motor_core_top_h - 59.8;

// On the side facing towards the polar scope port there is a little bump out
// which provides room for the stepper motor wiring.
dec_motor_bump_drop_from_core_top = 5.75;
dec_motor_bump_z = 4; // Amount sticks out from core.
dec_motor_bump_base_w = 19.6;
dec_motor_bump_outer_w = dec_motor_bump_base_w - 2*dec_motor_bump_z;
dec_motor_bump_base_h = dec_motor_core_z - dec_motor_bump_drop_from_core_top;
dec_motor_bump_outer_h = dec_motor_bump_base_h - 2*dec_motor_bump_z;

// Its challenging to measure the exact position of the bump, so I took a bunch
// of measurements from both sides.
// 48.5 48.35 47.93 48.25  average 48.26
// 17.21 17.62 17.55 17.32  average 17.42
dec_motor_bump_left_offset = 48.26;
dec_motor_bump_right_offset = 17.42;

////////////////////////////////////////////////////////////////////////////////
// Min distance from face with logo to dec1 cylinder.
dec_motor_z2 = 41.85;
// Based on that, min distance from dec axis to bottom of
// dec_motor... as if it were a solid.
dec_motor_z_offset_based_on_z2 =
  dec1_radius + dec_motor_z2 - dec_motor_z;

// Min distance from face with logo to far side of dec2 cylinder.
dec_motor_z3 = 124.7;
// Based on that, distance from min distance from dec axis to bottom of
// dec_motor.
dec_motor_z_offset_based_on_z3 = dec_motor_z3 - dec2_radius - dec_motor_z;

// Distance from RA bearing to bottom of motor.
ra1_base_to_dec_motor_bottom = 67.19;  // Average of 3 measurements.
// Based on that, distance from min distance from dec axis to bottom of
// dec_motor.
dec_motor_z_offset_based_on_ra1_base =
  ra1_base_to_dec_motor_bottom - ra1_base_to_dec_center;

// Average these ways of determining the distance.
dec_motor_z_offset =
  (dec_motor_z_offset_based_on_z2 + dec_motor_z_offset_based_on_z3 + dec_motor_z_offset_based_on_ra1_base) / 3;

// The DEC motor cover isn't quite symmetricly placed over the DEC axis.
// Distance measurements on one side: 5.84  5.28  5.09 5.13 5.08 5.23
// And the other side: 1.74 1.70 1.84 1.70
dec_motor_x_offset = 1.76;



////////////////////////////////////////////////////////////////////////////////
// RA core (the non-moving portion "below" RA bearing plane) dimensions.
// The RA bearing plane is at z=0, with the motor at x=0, y>0.



////////////////////////////////////////////////////////////////////////////////
// RA motor dimensions, arranged very much like the DEC motor cover. x is
// perpendicular to the ground and to the RA axis; y is parallel to the RA axis;
// z is distance from the RA axis. As with the DEC motor, there is a draft angle
// to the plastic.

ra_motor_w = 95.1;
ra_motor_h = 68.5;
ra_motor_z = 49;   // top of cover to intersection with ra2_diam.

// Height of top of cover above the ra2_diam.
ra_cover_height = 24.0;


// Distance away from bearing plane.
ra_motor_setback = 1.8;


ra_motor_z_offset = ra2_radius + ra_cover_height - ra_motor_z + 2;

// Min distance across RA bearing cover and RA motor (perpendicular to RA axis
// at the ra2/ra3 plane) to center of flat cover above bearing.
ra2_diam_plus_motor_min_at_ra2ra3 = 144;

// Max distance across RA bearing cover and RA motor (perpendicular to RA axis
// at the ra2/ra3 plane) to corner farthest from opposite side of RA axis.
ra2_diam_plus_motor_max_at_ra2ra3 = 150;

// Max distance across RA bearing cover and RA motor (perpendicular to RA axis)
// to corner farthest from opposite side of RA axis (this is a bit of a guess
// because the tallest point on the motor w.r.t. the RA axis is beyond the
// ra2/ra3 plane, away from the RA bearing plane.
ra2_diam_plus_motor_max = 155;

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
clutch_screw_axis_height = clutch_base_height - clutch_base_diameter / 2;

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

dec_head_total_height = dec_head_base_height + dec_head_height;

// Saddle, where the dovetail plate is secured by two screws.
dec_saddle_depth = 13.8;
dec_saddle_width1 = 44; // At top of saddle
dec_saddle_width2 = 46.5; // At bottom of saddle
dec_saddle_height = dec_head_total_height - dec_saddle_depth;
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

// The same for the RA axis.
ra_clutch_handle_min_height = ra1_radius + 18.6; 
ra_clutch_handle_max_height = ra1_radius + 26.6; 

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

dec1_body_len_beyond_ra = dec1_len - ra1_diam;
dec_len_beyond_ra = dec1_body_len_beyond_ra + cw_cap_height + cw_cap_bevel_height;

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