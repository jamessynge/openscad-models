# TO DOs for Weatherproofing Design

* Put each part in its own file, move necessary shared modules to wp_utils
  and dimensions to wp2_dimensions.

## TO DOs for the helmet

## TO DOs for the helmet supports

* Fix the rectangular hole in the cw_chin_strap_helmet_support.

* Adjust cw_chin_strap_helmet_support so that it extends all the way to the 
  helmet_support_at_dec_head, with a bolt connecting them (e.g. nut_slot).

* Use a full ra_clutch_volume, apply to both cw_chin_strap_helmet_support and
  helmet_support_at_dec_head.

* Add drainage channels to the supports at the two ends of the DEC axis,
  radiating out from the axis, supporting a range of latitudes. The channels
  are really just furrows in the outer surface of the supports.

* Break up helmet_support_at_dec_head to ensure it can be installed at low
  latitudes.

## TO DOs for the RA motor cover

* Determine real measurements/shape of the lower RA motor/electronics package.

# DONE

* Add a rib to the helmet at the bottom. There is some risk of accumulating
  water, so consider a rib shape to compensate.

* Cut the helmet vertically with a plane through both the RA and DEC axes.
  Design a rib for joining the two halves such that the two halves will
  (sort of) stick together (e.g. with a groove along the cut in one side and
  a ridge on the other side).

* Design a screw & threaded insert connection for two halves of the helmet.
  The screws would insert from the lower half (when parked), making it harder
  for water to get into the holes (NOT impossible... consider printing little
  blocks with short handles to go in on top of the screw heads).

* Trim the rib at the bottom of the helmet to not intersect the DEC rain plate.

* Figure out how to deter water from entering at the cut in the helmet.
  E.g. an o-ring or a furrow/hump.

* Come up with a way to put a draft angle on the overhang of the nut-side of
  the helmet, where it goes over the screw-side. Ideally we'd make the screw-
  side slightly smaller (e.g. 0.2mm) so that they don't bind up and prevent the
  two sides mating properly.

* Consider removing the rain plate as a separate part, and instead integrate
  it with the helmet. It would not be latitude dependent, and would not need
  to be installed (with very little room to get the screws into place, let
  alone tighten them). This does mean that the DEC clutch would be completely
  inaccessible once the helmet is in place. Removing the rain plate would allow
  the DEC attachment hoop to have much thinner walls.

# OBSOLETE

* Place holes around the hoop support for glue-in threaded inserts; place around
  six around the whole circumference, but use a function to decide which of them
  to include based on latitude. Insert corresponding holes into the DEC bearing
  rain shield (dec_bearing_rain_plate). Consider using countersink style
  connections (ala the alignment cones) to guide the rain shield into the
  correct location.

* Add a rib inside the helmet just above the interior supports
  (i.e. cw_chin_strap_helmet_support and helmet_support_at_dec_head),
  which should be help stiffen the helmet and help guide the placement of the
  helmet when installing.