

module cut_along_x(x=0, keep_above=false) {
  if (keep_above) {
    intersection() {
      union() { children(); }
      s = 300;
      translate([x, -s/2, -s/3])
        cube(size=s, center=false);
    }
  } else {
    difference() {
      union() { children(); }
      s = 300;
      translate([x, -s/2, -s/3])
        cube(size=s, center=false);
    }
  }
}

module cut_along_y(y=0, keep_above=false) {
  if (keep_above) {
    intersection() {
      union() { children(); }
      s = 300;
      translate([-s/2, y, -s/3])
        cube(size=s, center=false);
    }
  } else {
    difference() {
      union() { children(); }
      s = 300;
      translate([-s/2, y, -s/3])
        cube(size=s, center=false);
    }
  }
}

td_ratio_dflt = 1.15;

module tear_drop_profile(r=undef, td_ratio=td_ratio_dflt) {
  small_r = min(r/50, 0.1);
  echo(td_ratio);
  dx = r * td_ratio - small_r;
  hull() {
    circle(r=r);
    translate([-dx, 0, 0])
      circle(r=small_r);
  }
}

module tear_drop_extrusion(h=undef, r=undef, slope=0, td_ratio=td_ratio_dflt) {
  if (slope <= 0) {
    linear_extrude(height=h, convexity=4) {
      tear_drop_profile(r=r);
    }
  } else {
    // We apply the slope only to the negative X portion of the extrusion, so
    // extrude the positive X portion with no scaling.
    cut_along_x(keep_above=true) {
      linear_extrude(height=h, convexity=4) {
          tear_drop_profile(r=r, td_ratio=td_ratio);
      }
    }

    r2 = r + slope * h;
    xscale = r2 / r;

    cut_along_x(keep_above=false) {
      linear_extrude(height=h, convexity=4, scale=[xscale, 1]) {
          tear_drop_profile(r=r, td_ratio=td_ratio);
      }
    }
  }
}


translate([-20, 0, 0])
  tear_drop_profile(r=5);

tear_drop_extrusion(r=5, h=10);

translate([20, 0, 0])
  tear_drop_extrusion(r=5, h=10, slope=0.1);