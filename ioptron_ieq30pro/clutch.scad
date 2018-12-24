include <ieq30pro_dimensions.scad>

clutch(abs(($t*90)-45)+90*0.75);

module clutch(handle_angle=0) {
  r = clutch_base_diameter/2;
  raise_by = clutch_base_height - r;
  translate([0,raise_by,0]) {
    // Extrusion out of the base
    color(cast_iron_color)
      clutch_base();

    // Handle, shaft and screw.
    translate([0,0,clutch_screw_length])
      rotate([0, 0, handle_angle])
        clutch_handle();
  };
};

module clutch_base() {
  linear_extrude(height=clutch_extrusion)
    union() {
      r = clutch_base_diameter/2;
      circle(r=r);

      w1 = clutch_flange_width;
      h1 = clutch_flange_height;
      w2 = clutch_base_diameter;
      h2 = clutch_base_height - r;

      translate([-w1/2, -h2, 0])
        square([w1,h1]);

      translate([-w2/2, -h2, 0])
        square([w2,h2]);
    };
};

module clutch_handle() {
  color(plastic_color) {
    radius = clutch_handle_base_diam / 2;
    hw = clutch_handle_width / 2;
    linear_extrude(height=clutch_handle_depth1)
      union() {
        circle(r=radius);
        translate([0,-hw])
          square([clutch_handle_length,
                  clutch_handle_width]);
      };

    len2 = clutch_handle_length - radius;
    drop = clutch_handle_depth2-clutch_handle_depth1;
    translate([0,0,-drop])
      linear_extrude(height=clutch_handle_depth2)
        translate([radius,-hw])
          square([len2, clutch_handle_width]);
  };
  
  // The screw head, mostly for decoration.
  color("silver") {
    r = clutch_screw_head_diam/2;
    w = r * 1.4;
    h = w/5;
    translate([0,0,clutch_handle_depth1])
      linear_extrude(height=1)
        difference() {
          circle(r=r);
          square([w,h], center=true);
          square([h,w], center=true);
        }
  };

  // The shaft that is rotated by the handle,
  // of which a little is visible between the
  // handle and the body of the axis.
  color("gold") {
    r = clutch_screw_head_diam/2;
    h = 10;
    translate([0,0, -(h-1)])
      linear_extrude(height=h)
        circle(r=r);
  }
};

