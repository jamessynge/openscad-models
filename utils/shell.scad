// Create a shell around the first child, based on its void in the second child.
// If the second child completely encloses the first, then the shell will have a
// solid exterior but be hollow. If the second child cuts through the first
// child, then the shell is open. This can be a quite slow operation and the
// resulting preview may have lots of rendering artifacts.
//
// http://forum.openscad.org/I-have-a-suggestion-shell-td1358.html
// https://jweoblog.com/?p=644

module create_shell(shell_thickness=2, fn=8) {
  // Steps:
  // 1: Remove child(0) shaped void from child(1), producing B.
  // 2: Create Minkowski Sum of B and a sphere whose radius is the desired
  //    shell thickness, producing C. The child(0) shaped void is a smaller
  //    in C by the shell_thickness.
  // 3: Intersect C and child(0), producing a shell (hollow object) whose
  //    outer surface matches that of child(0).

  // Step 3: intersect child(0) and the enlarged child(1)
  intersection() {
    children(0);

    // Step 2: Enlarge the hole in child(1)
    minkowski() {
      // Step 1: Remove child(0) shaped void from child(1).
      difference() {
        children(1);
        children(0);
      }

      sphere(r=shell_thickness, center=true, $fn=fn);
    }
  };
}


create_shell() {
  cube(size=10, center=true);
  cube(size=10, center=false);
};

translate([10, 0, 0])
  intersection() {
    create_shell() {
      cube(size=10, center=true);
      cube(size=20, center=true);
    }
    cube(size=10, center=false);
  };
