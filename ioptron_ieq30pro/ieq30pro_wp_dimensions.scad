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
