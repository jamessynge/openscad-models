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

// The closes distance to the RA bearing plate at which
// ra_motor_clearance_radius_max applies.
ra_motor_max_clearance_z = ra2_len + ra3_len / 2;

// Distance from the RA or DEC base to the top of the handle's base, assuming
// the clutch handle is in the locked position, i.e. down near the bearing.
base_to_clutch_handle_diam_top = clutch_screw_axis_height + clutch_handle_base_diam / 2;

// Distance from the DEC head base to the mid point between the DEC clutch
// and the knobs of the DEC saddle plate; this can be used as the middle of
// a rain plate, allowing the maximum room for the clutch and the knobs.
dec_head_rain_plate_mid_z = (base_to_clutch_handle_diam_top + dec_gap_to_saddle_knob) / 2;
