// Utility module for generating a "port" (the opening for the CW shaft or the
// DEC head). I assume that the body to which it is attached will be printed
// in 4 parts, nut vs. screw side, and bottom vs top side, with the two top
// side parts being printed upside down). This reduces the need to add for
// overhangs.

// Author: James Synge
// Units: mm

use <dict.scad>;

// The $fa, $fs and $fn special variables control the number of facets used to
// generate an arc. $fn is usually 0. When this variable has a value greater
// than zero, the other two variables are ignored and full circle is rendered
// using this number of fragments. The default value of $fn is 0.
$fs = $preview ? 2 : 1;  // Minimum size for a fragment.
$fa = $preview ? 6 : 1;  // Minimum angle for a fragment.



shaft_port_profile(test_dims);

M = [ [ 1  , 0  , 0  , 0   ],
      [ 0  , 1  , 0  , 0   ],  // The "0.7" is the skew value; pushed along the y axis
      [ 0.2  , 0.2  , 1  , 0   ],
      [ 0  , 0  , 0  , 1   ] ] ;
translate([0, 0, 2*GetDepth(test_dims)])
  multmatrix(M) 
    shaft_port(test_dims, fs=undef);

translate([0, 0, -2*GetHeight(test_dims)])
  shaft_port_solid(test_dims);

translate([2*GetOuterDiam(test_dims), 0, 0]) {
  difference() {
    shaft_port(test_dims);
    shaft_port_solid(SetDepth(GetDepth(test_dims)+10, test_dims));
  }
}

// This is used for cutting out the hole in the body into which the port
// is inserted. thickness_frac controls whether the hole is just the inside
// of the port, the outside, or somewhere in between.
module shaft_port_solid(dims, thickness_frac=0.5) {
  SP_ValidateDims(dims);
  hull() shaft_port(dims, thickness_frac=thickness_frac);
}

// This is used for cutting out the hole in the body into which the port
// is inserted. thickness_frac controls whether the hole is just the inside
// of the port, the outside, or somewhere in between.
module shaft_port(dims, thickness_frac=1, fs=undef) {
  SP_ValidateDims(dims);
  $fs = fs == undef ? GetThickness(dims) / 20 : fs;
  rotate_extrude(convexity=10) shaft_port_profile(dims, thickness_frac=thickness_frac);
}


shaft_port_profile(test_dims);



// Y axis (x==0, z==0) is the axis of rotation for rotate_extrude, so we
// measure our radial distances from that axis (i.e. they are x coordinates).
// Height is the amount the profile sticks above the x axis; this is the side
// with the opening.
// Depth is the amount the profile sticks down below the x axis.
// Diameters measure interior diameters of the port at thickness_frac == 1.
module shaft_port_profile(dims, thickness_frac=1) {
  SP_ValidateDims(dims);
  thickness = GetThickness(dims);
  t2 = thickness / 2;
  ir = GetInnerDiam(dims) / 2 + t2;
  mr = GetMidDiam(dims) / 2 + t2;
  or = GetOuterDiam(dims) / 2 + t2;
  h = GetHeight(dims);
  d = GetDepth(dims);

  tf = thickness * GetThickness(dims);
  e = 0.01;
  delta = or - mr;

  // Centerline of the profile, to be offset by thickness.
  p0 = [ir, h];
  p1 = [mr, h];
  p2 = [or /*p1.x + delta*/, p1.y - delta];
  p3 = [or, -d];

  assert(p2.y > p3.y);

  offset(r=thickness * thickness_frac / 2)
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


test_dims =
  SetHeight(20,
    SetDepth(30,
      SetThickness(5,
        SetInnerDiam(30,
          SetMidDiam(40,
            SetOuterDiam(60))))));
echo(test_dims);
SP_ValidateDims(test_dims);
SP_EchoDims(test_dims);
