// Design for weatherproofing the iEQ30Pro mount.
// Author: James Synge

include <../ieq30pro_dimensions.scad>
use <../ieq30pro.scad>
use <../ieq30pro_dec_head.scad>
use <dec_bearing.scad>
use <../../utils/axis_arrows.scad>

echo(version=version());

// Global resolution
if ($preview) {
  // Don't generate smaller facets than this many mm.
  $fs = 2;
  // Don't generate larger angles than this many degrees.
  $fa = 10;
}

show_arrows = false;
show_axis_hints = false;

// Default location is parked.
lat = mount_latitude;
ra_angle = 90 ;// + $t * 360;
dec_angle = 90 + mount_latitude + $t * 360;
show_arrows=false;

// Distance from motor to shell around it.
dec_motor_gap = 2;

// Width of surface mating with DEC bearing cover.
dec_bearing_mating_length = min(dec2_len, 20);


decorated_ioptron_mount(ra_angle=ra_angle,
  dec_angle=dec_angle, latitude=lat, show_arrows=show_arrows) {
  union() {
  };
  union() {
  };
  union() {
    color("lime")dec_motor_cover_cover();
    color("red")dec_motor_cover_strap();
    #color("violet") dec_bearing_upper_roof();
  };
  union() {
    color("DeepSkyBlue") dec_head_bearing_cover();
  };
  union() {
  };
};


*rotate([90-mount_latitude,0,0])
ioptron_mount(ra_angle=ra_angle, dec_angle=dec_angle) {
  union() {
    echo("executing ioptron_mount child 1");
    color("gold") {
      if (show_axis_hints)
        translate([ra1_radius*2,ra1_radius,10])
          linear_extrude(height=20) square(size=10);
      if (show_arrows)
        axis_arrows(total_length=ra1_radius*2);
    };
  };

  union() {
    echo("executing ioptron_mount child 2");
    color("blue") {
      if (show_axis_hints)
        linear_extrude(height=4) {
          difference() {
            circle(r=ra1_radius + 10);
            circle(r=ra1_radius + 5);
          };
          translate([ra1_radius+10,0,0])
            square(size=10, center=true);
        };
      if (show_arrows)
        axis_arrows(total_length=ra1_radius*1.5);
    }
  };

  union() {
    echo("executing ioptron_mount child 3");
    color("lime")dec_motor_cover_cover();
    color("red")dec_motor_cover_strap();
    color("violet") dec_bearing_upper_roof();
    //dec_motor_bearing_cover();
    color("yellow") {
      if (show_axis_hints) {
        linear_extrude(height=4) {
          difference() {
            circle(r=dec_head_base_radius + 10);
            circle(r=dec_head_base_radius + 5);
          };
          translate([dec_head_base_radius+10,0,0])
            square(size=10, center=true);
        };
      };
      if (show_arrows)
        axis_arrows(total_length=dec_head_base_radius*1.5);
    };
  };

  union() {
    echo("executing ioptron_mount child 4");
    color("DeepSkyBlue") dec_head_bearing_cover();
    color("red") {
      if (show_axis_hints) {
        linear_extrude(height=4) {
          difference() {
            circle(r=dec_head_base_radius + 10);
            circle(r=dec_head_base_radius + 5);
          };
          translate([dec_head_base_radius+10,0,0])
            square(size=10, center=true);
        };
      };
      if (show_arrows)
        axis_arrows(total_length=dec_head_base_radius*1.5);
    }
  };

  union() {
    echo("executing ioptron_mount child 5");
    color("green") {
      if (show_axis_hints) {
        translate([20,10,10]) sphere(r=10);
      }
      if (show_arrows)
        axis_arrows(total_length=dec_head_base_radius);
    };
  };
};

*translate([0,0,-140]) dec_head_bearing_cover() ;

module dec_head_bearing_cover() {
  // TODO Need to rotate this so that the clutch hole is aligned correctly.
  difference() {
    translate([0,0,dec_head_base_height]) {
      cylinder(h=10, r1=dec_cover_max_radius, r2=dec_head_base_diam/2);
    }

    dec_head();
  }
}
