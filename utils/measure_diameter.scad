
// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.

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

module measure_diameter(diameter=100, subtended_angle = 180) {
  radius = diameter/2;
  tool_thickness = 3.5;
  text_depth = 0.5;
  difference() {
    rotate_extrude(angle=360-subtended_angle)
      translate([radius, 0])
          square([20, tool_thickness]);

    translate([0, 0, tool_thickness-text_depth])
      rotate([0, 0, 80])
      linear_extrude(height=text_depth*1.1, convexity=10) {
        chars = str("Diameter: ", diameter, "  ");
        revolve_text(radius=radius, chars=chars, subtended_angle=360-subtended_angle);
      }
    }
  }

the_diameter=120;
measure_diameter(diameter=the_diameter);
