// Need to print some samples with different dimensions as the first draft
// of the DEC head end support was way too tight.

include <../ieq30pro_dimensions.scad>
use <../ieq30pro_ra_and_dec.scad>

echo(version=version());

// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.

echo("dec_motor_cover_angle", dec_motor_cover_angle);

module revolve_text(radius, chars, subtended_angle=360) {
    PI = 3.14159;
    circumference = 2 * PI * radius * subtended_angle / 360;
    chars_len = len(chars);
    font_size = circumference / chars_len;
    step_angle = subtended_angle / chars_len;
    for(i = [0 : chars_len - 1]) {
        rotate([0, 0, -i * step_angle]) 
            translate([0, radius + font_size / 2, 0]) 
                text(
                    chars[i], 
                    font = "Courier New; Style = Bold", 
                    size = font_size, 
                    valign = "bottom", halign = "center"
                );
    }
}

module dec2_measurement(radius=dec2_radius, subtended_angle = 180) {
  tool_thickness = 5;
  text_depth = 0.5;
  difference() {
    rotate_extrude(angle=360-subtended_angle)
      translate([radius, 0])
          square([20, tool_thickness]);

    translate([0, 0, tool_thickness-text_depth])
      rotate([0, 0, 80])
      linear_extrude(height=text_depth*1.1, convexity=10) {
        chars = str("Diameter: ", radius*2, "  ");
        revolve_text(radius=radius, chars=chars, subtended_angle=360-subtended_angle);
      }
    }
  }

if (false && $preview) {
  ra_and_dec($t * 360) {
    union() {}
    dec2_measurement();
  }
} else {
  dec2_measurement();
  // rotate([0, 0, 50])
  // translate([10, 40, 0])
  // dec2_measurement(subtended_angle=180);
}


// radius = dec2_radius+5;
// chars = str("Radius: ", radius, "                   ");

// module revolve_text(radius, chars, subtended_angle=) {
//     PI = 3.14159;
//     circumference = 2 * PI * radius;
//     chars_len = len(chars);
//     font_size = circumference / chars_len;
//     step_angle = 360 / chars_len;
//     for(i = [0 : chars_len - 1]) {
//         rotate(-i * step_angle) 
//             translate([0, radius + font_size / 2, 0]) 
//                 text(
//                     chars[i], 
//                     font = "Courier New; Style = Bold", 
//                     size = font_size, 
//                     valign = "center", halign = "center"
//                 );
//     }
// }

//revolve_text(radius, chars);
