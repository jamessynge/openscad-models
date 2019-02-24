// Dimensions for weatherproofing that are common to all designs (i.e.
// they are limits implied by the shape of the mount).
// Author: James Synge
// Units: mm

include <ieq30pro_dimensions.scad>
include <../utils/metric_dimensions.scad>


// Radius that must be cleared at the ra2/ra3 plane by something attached to
// ra_and_dec body. This isn't the maximum such radius, as the RA motor is
// slightly taller behind that.
ra_motor_clearance_radius_at_ra2ra3 = ra2_diam_plus_motor_max_at_ra2ra3 - ra2_radius;

// Radius that must be cleared by something attached to ra_and_dec body to never
// touch the RA motor.
ra_motor_clearance_radius_max = ra2_diam_plus_motor_max - ra2_radius;

// Radius that must be cleared by something attached to ra_and_dec body to never
// touch the RA motor at the RA bearing.
ra_motor_clearance_radius_min = ra2_radius + 25;

// The closest distance to the RA bearing plate at which
// ra_motor_clearance_radius_max applies.
ra_motor_max_clearance_z = ra2_len + ra3_len / 2;


// Minimum distance from RA bearing plane (not including the gap) to the
// latitude adjusting base. A skirt (hoop around the RA core and motor) any
// larger longer than this will collide with the base.
ra_motor_skirt_max_z = 50;


// OBSOLETE, use one of the two values.
// // Distance from the RA or DEC base to the top of the handle's base, assuming
// // the clutch handle is in the locked position, i.e. down near the bearing.
base_to_clutch_handle_diam_top = max(dec_base_to_clutch_handle_diam_top, ra_base_to_clutch_handle_diam_top);

// Distance from the DEC head base to the mid point between the DEC clutch
// and the knobs of the DEC saddle plate; this can be used as the middle of
// a rain plate, allowing the maximum room for the clutch and the knobs.
dec_head_rain_plate_mid_z = (base_to_clutch_handle_diam_top + dec_gap_to_saddle_knob) / 2;
