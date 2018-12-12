// Units: mm

cast_iron_color = "beige";

////////////////////////////////////////////////////
// Diameter of dec body at bottom, near CW shaft.
dec1_diam = 67.66;
dec1_radius = dec1_diam / 2;

// Length of declination cylinder with dec1_diam.
dec1_len = 131.9;

// The black cap and the bottom of the dec body, where
// the counterweight shaft is attached.
cw_cap_height = 10;
cw_cap_bevel_height = 5;

// There is a countersink in the bottom of the DEC
// body to allow for the counterweight shaft.
cw_cs_diam = 23;
cw_cs_radius = cw_cs_diam / 2;

cw_thread_diam = 16;
cw_thread_radius = cw_thread_diam / 2;

////////////////////////////////////////////////////
// Diameter of the motor end of the DEC body.

dec2_diam = 97.4;  // +/- 0.3mm.
dec2_radius = dec2_diam / 2;
dec2_len = 25.4;

////////////////////////////////////////////////////
// Declination motor cover size.
dec_motor_w = 85.4;  // left-right on face with logo.
dec_motor_h = 68.4;  // up-down on face with logo.
dec_motor_z = 62.4;

////////////////////////////////////////////////////
// Min dist from face with logo to dec1 cylinder.
dec_motor_z2 = 42;
dec_motor_z_offset =
  dec1_radius + dec_motor_z2 - dec_motor_z;

////////////////////////////////////////////////////
// RA axis diameter at the bearing, where the moving
// and stationary parts meet.
ra1_diam = 120;  // +/- 0.3mm.
ra1_radius = ra1_diam / 2;

////////////////////////////////////////////////////
// Distance from edge of RA bearing to outside and
// center of DEC axis.
ra1_base_to_dec = 21.5;
ra1_base_to_dec_center = ra1_base_to_dec + dec1_radius;

////////////////////////////////////////////////////
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

// Functions to enable access from other files
// that "use" this file.
function ra_cover_radius() = ra1_radius;
function dec_cover_radius() = dec2_radius;

////////////////////////////////////////////////////
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

////////////////////////////////////////////////////
// Dimensions for the DEC head (i.e. the part
// rotated by the DEC motor, which has the dove tail
// saddle for holding the telescope).

dec_head_base_diam = 97.66;
dec_head_diam1 = 89.5;
dec_head_diam2 = 87.67;  // After draft angle.
dec_head_height1 = 32.5;
dec_head_height2 = 46.3;



