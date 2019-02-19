// Utility module for generating a "port" (the opening for the CW shaft or the
// DEC head). Unlike shaft_port.scad, this produces an asymmetric port, with
// the top surface being ~flat (can't be printed upside down due to overhang).
// It is intended to be printed in one of two ways, though both are cut
// vertically (nut/sky side and screw/ground side):
// 1) integrated into each bottom quarter of the helmet, with an appropriate
//    hole cut in the top part;
// 2) separately, printed on its outside face (which is flat), with the z-axis
//    being the DEC axis, rising toward the RA axis of the mount.

// Author: James Synge
// Units: mm

use <../../utils/misc.scad>
use <dict.scad>;
use <helpers.scad>;
include <wp5_dimensions.scad>

// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.



test_dims =
  SetHeight(20,
    SetDepth(30,
      SetThickness(5,
        SetInnerDiam(30,
          SetMidDiam(35,
            SetOuterDiam(40))))));

module experiment3() {
  above = GetHeight(test_dims);
  below = GetDepth(test_dims);
  h = above + below;
  shaft_id = GetInnerDiam(test_dims);
  shaft_ir = shaft_id / 2;
  port_od = GetOuterDiam(test_dims);
  port_or = port_od / 2;

  // This results in a 45 degree angle for the overhang, which many 3D printers
  // can handle.
  cutout_r = port_or + above;


  // TODO Add a dimension related to how much bigger the outer shaft gets.
  slope = 0.1;
  td_ratio = 1.15;

  module tear_drop_shaft() {
    translate([0, 0, -below-1])
      tear_drop_extrusion(r=shaft_ir, h=h+2, td_ratio=td_ratio);
  }

  module tear_drop_port() {
    translate([0, 0, -below])
      tear_drop_extrusion(r=port_or, h=below, td_ratio=td_ratio);
    tear_drop_extrusion(r=port_or, h=above, td_ratio=td_ratio, slope=slope);
  }

  *translate([0, 0, -above-0.01])
  difference() {
    tear_drop_port();
    tear_drop_shaft();
  }

  module cyl(diam) {
    translate([0, 0, -below])
      cylinder(d=diam, h=h);
  }

  module can_ext() {
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=helmet_or, l=2*GetOuterDiam(test_dims));
  }
  module can_mid() {
    r = (helmet_ir + helmet_or) / 2;
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=r, l=2*GetOuterDiam(test_dims));
  }
  module can_int() {
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=helmet_ir, l=2*GetOuterDiam(test_dims));
  }
  module can_cutout() {
    intersection() {
      difference() {
        cyl(cutout_r*2);
        can_int();
      }
     can_ext();
    }
  }



  *difference() {
    union() {
    tear_drop_port();
    can_cutout();
    }
    tear_drop_shaft();
  }
  module can_cutout_below() {
    intersection() {
      can_cutout();
      translate([0, -port_or, -below])
        cube([cutout_r, port_od, h]);
    }
  }



  module asym_solid() {
    hull() {
      tear_drop_port();
      can_cutout_below();
    }
  }

  difference() {
    asym_solid();
    can_int();
    tear_drop_shaft();


  }












if (false) {
  shaft_port_profile(test_dims);

  M = [ [ 1  , 0  , 0  , 0   ],
        [ 0  , 1  , 0  , 0   ],  // The "0.7" is the skew value; pushed along the y axis
        [ 0.2  , 0.2  , 1  , 0   ],
        [ 0  , 0  , 0  , 1   ] ] ;
  translate([-100, -100, 0])
    cut_along_x()
    multmatrix(M) 
      shaft_port(test_dims, fs=undef);

  translate([0, 0, -2*GetHeight(test_dims)])
    shaft_port_solid(test_dims);

  translate([100, 100, 0]) {
    difference() {
      shaft_port(test_dims);
      extra_deep = SetDepth(GetDepth(test_dims)+10, test_dims);
      shaft_port_solid(extra_deep);
    }
  }

  shaft_port_profile(test_dims);
  mirror([1, 0, 0])
  shaft_port_profile(test_dims, miter=true);
}

module experiment() {
  above = GetHeight(test_dims);
  below = GetDepth(test_dims);
  h = above + below;

  module cyl(diam) {
    translate([0, 0, -below])
      cylinder(d=diam, h=h);
  }
  module outer_cyl(top_only=false) {
    cyl(GetOuterDiam(test_dims));
  }
  module mid_cyl() {
    cyl(GetMidDiam(test_dims));
  }
  module inner_cyl() {
    cyl(GetInnerDiam(test_dims));
  }

  module can_ext() {
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=helmet_or, l=2*GetOuterDiam(test_dims));
  }
  module can_int() {
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=helmet_ir, l=2*GetOuterDiam(test_dims));
  }
  module can_cutout() {
    intersection() {
      difference() {
        outer_cyl();
        can_int();
      }
     can_ext();
    }
  }
  module can_cutout_below() {
    intersection() {
      can_cutout();
      md = GetMidDiam(test_dims);
      translate([0, -md/2, -below])
        cube([md, md, h]);
    }
  }

  module asym_solid() {
    hull() {
      mid_cyl();
      can_cutout_below();
    }

  }

  scale([1, 1, 1])
    cut_along_x()
      mid_cyl();


  *asym_solid();


*  union() {

  can_cutout();
  difference() {
    mid_cyl();
    can_int();
  }

  cut_along_x() {
    difference() {
      outer_cyl();
    can_int();

    }
  }


}
}

module experiment2() {
  above = GetHeight(test_dims);
  below = GetDepth(test_dims);
  h = above + below;

  module cyl(diam) {
    translate([0, 0, -below])
      cylinder(d=diam, h=h);
  }
  module outer_cyl() {
    cyl(GetOuterDiam(test_dims));
  }
  module mid_cyl() {
    cyl(GetMidDiam(test_dims));
  }
  module inner_cyl() {
    cyl(GetInnerDiam(test_dims));
  }

  module mid_to_outer_cylinder() {
    translate([0, 0, -below])
      cylinder(d1=GetMidDiam(test_dims), d2=GetOuterDiam(test_dims), h=h);
  }

  module tear_drop_profile(r=undef, ratio=1.15) {
    small_r = min(r/20, 0.1);
    dx = r * ratio - small_r;
    hull() {
      circle(r=r);
      translate([-dx, 0, 0])
        circle(r=small_r);
    }
  }

  //translate([70, 0, 0]) tear_drop_profile(r=10);

  module tear_drop_inner() {
    translate([0, 0, -below-1])
      linear_extrude(height=h+2, convexity=4)
        tear_drop_profile(r=GetInnerDiam(test_dims)/2);
  }
  //translate([70, 0, 0]) tear_drop_inner();





  module can_ext() {
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=helmet_or, l=2*GetOuterDiam(test_dims));
  }
  module can_mid() {
    r = (helmet_ir + helmet_or) / 2;
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=r, l=2*GetOuterDiam(test_dims));
  }
  module can_int() {
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=helmet_ir, l=2*GetOuterDiam(test_dims));
  }
  module can_cutout() {
    intersection() {
      difference() {
        cyl(GetOuterDiam(test_dims)*2);
        can_int();
      }
     can_ext();
    }
  }
  module can_cutout_below() {
    intersection() {
      can_cutout();
      d = GetOuterDiam(test_dims);
      translate([0, -d/2, -below])
        cube([d, d, h]);
    }
  }

  module asym_solid() {
    hull() {
      mid_to_outer_cylinder();
      can_cutout_below();
    }

  }


//mid_to_outer_cylinder();


  *scale([1, 1, 1])
    cut_along_x()
      mid_cyl();


  difference() {
  asym_solid();
can_mid();
tear_drop_inner();
  }

*union() {
  can_cutout();
  difference() {
    mid_cyl();
    can_int();
  }

  cut_along_x() {
    difference() {
      outer_cyl();
      can_int();
    }
  }


}
}

test_dims =
  SetHeight(20,
    SetDepth(30,
      SetThickness(5,
        SetInnerDiam(30,
          SetMidDiam(35,
            SetOuterDiam(40))))));

module experiment3() {
  above = GetHeight(test_dims);
  below = GetDepth(test_dims);
  h = above + below;
  shaft_id = GetInnerDiam(test_dims);
  shaft_ir = shaft_id / 2;
  port_od = GetOuterDiam(test_dims);
  port_or = port_od / 2;

  // This results in a 45 degree angle for the overhang, which many 3D printers
  // can handle.
  cutout_r = port_or + above;


  // TODO Add a dimension related to how much bigger the outer shaft gets.
  slope = 0.1;
  td_ratio = 1.15;

  module tear_drop_shaft() {
    translate([0, 0, -below-1])
      tear_drop_extrusion(r=shaft_ir, h=h+2, td_ratio=td_ratio);
  }

  module tear_drop_port() {
    translate([0, 0, -below])
      tear_drop_extrusion(r=port_or, h=below, td_ratio=td_ratio);
    tear_drop_extrusion(r=port_or, h=above, td_ratio=td_ratio, slope=slope);
  }

  *translate([0, 0, -above-0.01])
  difference() {
    tear_drop_port();
    tear_drop_shaft();
  }

  module cyl(diam) {
    translate([0, 0, -below])
      cylinder(d=diam, h=h);
  }

  module can_ext() {
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=helmet_or, l=2*GetOuterDiam(test_dims));
  }
  module can_mid() {
    r = (helmet_ir + helmet_or) / 2;
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=r, l=2*GetOuterDiam(test_dims));
  }
  module can_int() {
    rotate([0, -90, 0])
    translate([-helmet_or, 0, 0])
    symmetric_z_cylinder(r=helmet_ir, l=2*GetOuterDiam(test_dims));
  }
  module can_cutout() {
    intersection() {
      difference() {
        cyl(cutout_r*2);
        can_int();
      }
     can_ext();
    }
  }



  *difference() {
    union() {
    tear_drop_port();
    can_cutout();
    }
    tear_drop_shaft();
  }
  module can_cutout_below() {
    intersection() {
      can_cutout();
      translate([0, -port_or, -below])
        cube([cutout_r, port_od, h]);
    }
  }



  module asym_solid() {
    hull() {
      tear_drop_port();
      can_cutout_below();
    }
  }

  difference() {
    asym_solid();
    can_int();
    tear_drop_shaft();


  }

  // module tear_drop_extrusion(r, slope=0, cutter=false, td_ratio=undef) {
  //   below_ = below + (cutter ? 1 : 0);
  //   h_ = h + (cutter ? 2 : 0);

  //   if (slope <= 0) {
  //     translate([0, 0, -below_])
  //       linear_extrude(height=h_, convexity=4)
  //         tear_drop_profile(r=r);
  //   } else {
  //     // We apply the slope only to the negative X portion of the body.

  //     translate([0, 0, -below_]) {
  //         cut_along_x(keep_above=true)
  //       linear_extrude(height=h_, convexity=4) {
  //           tear_drop_profile(r=r);
  //       }
  //     }


  //     translate([0, 0, -below_]) {
  //       cut_along_x(keep_above=false)
  //       linear_extrude(height=h_, convexity=4, scale=[1.3, 1]) {
  //           tear_drop_profile(r=r, td_ratio=1.1);
  //       }
  //     }


  //     // This has a radius (ignoring the tear drop point) of r at the can
  //     // outer wall, and of (r + slope*above) at the distance `above`
  //     // outside the can outer wall. Compute the radius at the distance
  //     // `below` inside the can outer wall.

  //   }





  // }

// tear_drop_extrusion(10, 1.1);

  //translate([70, 0, 0]) tear_drop_inner();

//   // This has diameter (ignoring the tear drop point) of InnerDiam
//   // at the can outer wall, and of OuterDiam at the distance `above`
//   // from the can outer wall.
//   module tear_drop_port() {
//     // Compute the diameter at the 
//     slope = (GetOuterDiam(test_dims)/2 - GetInnerDiam(test_dims)/2) / above;
//   //  d1 = 

//     translate([0, 0, -below-1])
//       linear_extrude(height=h+2, convexity=4)
//         tear_drop_profile(r=GetInnerDiam(test_dims)/2);
//   }













//   module cyl(diam) {
//     translate([0, 0, -below])
//       cylinder(d=diam, h=h);
//   }
//   module outer_cyl() {
//     cyl(GetOuterDiam(test_dims));
//   }
//   module mid_cyl() {
//     cyl(GetMidDiam(test_dims));
//   }
//   module inner_cyl() {
//     cyl(GetInnerDiam(test_dims));
//   }

//   module mid_to_outer_cylinder() {
//     translate([0, 0, -below])
//       cylinder(d1=GetMidDiam(test_dims), d2=GetOuterDiam(test_dims), h=h);
//   }




//   module can_ext() {
//     rotate([0, -90, 0])
//     translate([-helmet_or, 0, 0])
//     symmetric_z_cylinder(r=helmet_or, l=2*GetOuterDiam(test_dims));
//   }
//   module can_mid() {
//     r = (helmet_ir + helmet_or) / 2;
//     rotate([0, -90, 0])
//     translate([-helmet_or, 0, 0])
//     symmetric_z_cylinder(r=r, l=2*GetOuterDiam(test_dims));
//   }
//   module can_int() {
//     rotate([0, -90, 0])
//     translate([-helmet_or, 0, 0])
//     symmetric_z_cylinder(r=helmet_ir, l=2*GetOuterDiam(test_dims));
//   }
//   module can_cutout() {
//     intersection() {
//       difference() {
//         cyl(GetOuterDiam(test_dims)*2);
//         can_int();
//       }
//      can_ext();
//     }
//   }
//   module can_cutout_below() {
//     intersection() {
//       can_cutout();
//       d = GetOuterDiam(test_dims);
//       translate([0, -d/2, -below])
//         cube([d, d, h]);
//     }
//   }

//   module asym_solid() {
//     hull() {
//       mid_to_outer_cylinder();
//       can_cutout_below();
//     }

//   }


// //mid_to_outer_cylinder();


//   *scale([1, 1, 1])
//     cut_along_x()
//       mid_cyl();


//   difference() {
//   asym_solid();
// can_mid();
// tear_drop_inner();
//   }

// *  union() {

//   can_cutout();
//   difference() {
//     mid_cyl();
//     can_int();
//   }

//   cut_along_x() {
//     difference() {
//       outer_cyl();
//     can_int();

//     }
//   }


// }
}


// translate([-100, 100, -GetDepth(test_dims)])
  experiment3();


// This is used for cutting out the hole in the body into which the port
// is inserted. thickness_frac controls whether the hole is just the inside
// of the port, the outside, or somewhere in between.
module shaft_port_solid(dims, miter=true, thickness_frac=0.5, fs=undef) {
  SP_ValidateDims(dims);
  hull() shaft_port(dims, miter=miter, thickness_frac=thickness_frac, fs=fs);
}

// This is used for cutting out the hole in the body into which the port
// is inserted. thickness_frac controls whether the hole is just the inside
// of the port, the outside, or somewhere in between.
module shaft_port(dims, miter=false, thickness_frac=1, fs=undef) {
  SP_ValidateDims(dims);
  rotate_extrude(convexity=10)
    shaft_port_profile(dims, miter=miter, thickness_frac=thickness_frac, fs=fs);
}



// Y axis (x==0, z==0) is the axis of rotation for rotate_extrude, so we
// measure our radial distances from that axis (i.e. they are x coordinates).
// Height is the amount the profile sticks above the x axis; this is the side
// with the opening.
// Depth is the amount the profile sticks down below the x axis.
// Diameters measure interior diameters of the port at thickness_frac == 1.
module shaft_port_profile(dims, miter=false, thickness_frac=1, fs=undef) {
  SP_ValidateDims(dims);
  thickness = GetThickness(dims);
  t2 = thickness / 2;
  ir = GetInnerDiam(dims) / 2 + t2;
  mr = GetMidDiam(dims) / 2 + t2;
  or = GetOuterDiam(dims) / 2 + t2;
  h = GetHeight(dims);
  d = GetDepth(dims);

  e = 0.01;
  delta = or - mr;

  module profile() {
    // Centerline of the profile, to be offset by thickness.
    p0 = [ir, h];
    p1 = [mr, h];
    p2 = [or /*p1.x + delta*/, p1.y - delta];
    p3 = [or, -d];

    assert(p2.y > p3.y);

    polygon([
      [p0[0], p0[1]+e],
      [p1[0]+e, p1[1]+e],
      [p2[0]+e, p2[1]+e],
      [p3[0]+e, p3[1]],
      [p3[0]-e, p3[1]],
      [p2[0]-e, p2[1]-e],
      [p1[0]-e, p1[1]-e],
      [p0[0], p0[1]-e],
    ]);
  }

  tf2 = thickness_frac * t2;

  $fs = fs == undef ? max(0.1, min(thickness / 20, $fs)) : fs;
  if (miter) {
    offset(delta=tf2)
      profile();
  } else {
    offset(r=-3)
      offset(delta=+3)
        offset(r=tf2)
          profile();
  }




  // // Centerline of the profile, to be offset by thickness.
  // p0 = [ir, h];
  // p1 = [mr, h];
  // p2 = [or /*p1.x + delta*/, p1.y - delta];
  // p3 = [or, -d];

  // assert(p2.y > p3.y);

  // offset(r=thickness * thickness_frac / 2)
  //   polygon([
  //     [p0[0], p0[1]+e],
  //     [p1[0]+e, p1[1]+e],
  //     [p2[0]+e, p2[1]+e],
  //     [p3[0]+e, p3[1]],
  //     [p3[0]-e, p3[1]],
  //     [p2[0]-e, p2[1]-e],
  //     [p1[0]-e, p1[1]-e],
  //     [p0[0], p0[1]-e],
  //   ]);
}

module SP_ValidateDims(dims) {
  assert(is_num(GetDepth(dims)));
  assert(is_num(GetHeight(dims)));
  assert(is_num(GetInnerDiam(dims)));
  assert(is_num(GetMidDiam(dims)));
  assert(is_num(GetOuterDiam(dims)));
  assert(is_num(GetThickness(dims)));
}

module SP_EchoDims(dims) {
  echo(str("Depth=", GetDepth(dims)));
  echo(str("Height=", GetHeight(dims)));
  echo(str("InnerDiam=", GetInnerDiam(dims)));
  echo(str("MidDiam=", GetMidDiam(dims)));
  echo(str("OuterDiam=", GetOuterDiam(dims)));
  echo(str("Thickness=", GetThickness(dims)));
}


echo(test_dims);
SP_ValidateDims(test_dims);
SP_EchoDims(test_dims);
