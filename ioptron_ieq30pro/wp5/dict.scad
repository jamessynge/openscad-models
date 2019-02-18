use <../../utils/dictionary.scad>

/////////////////////////////////////////////////////////
////////////////// BEGIN GENERATED CODE /////////////////

// To regenerate, open this file in OpenSCAD and copy
// the ECHO output from the console:
print_dict_helpers(["Depth","Height","InnerDiam","MidDiam","OuterDiam","Thickness",]);

// Keys for the dictionary, used by Set* and Get* methods.
kDepth = "Depth";
kHeight = "Height";
kInnerDiam = "InnerDiam";
kMidDiam = "MidDiam";
kOuterDiam = "OuterDiam";
kThickness = "Thickness";

// Accessors and validators, one per key.
function SetDepth(v, dict=undef) = dict_set(kDepth, v, dict);
function GetDepth(dict, dflt=undef) = dict_get(dict, kDepth, dflt=dflt);
function HasDepth(dict) = dict_has_key(dict, kDepth);
module AssertHasDepth(dict) { assert(HasDepth(dict)); }

function SetHeight(v, dict=undef) = dict_set(kHeight, v, dict);
function GetHeight(dict, dflt=undef) = dict_get(dict, kHeight, dflt=dflt);
function HasHeight(dict) = dict_has_key(dict, kHeight);
module AssertHasHeight(dict) { assert(HasHeight(dict)); }

function SetInnerDiam(v, dict=undef) = dict_set(kInnerDiam, v, dict);
function GetInnerDiam(dict, dflt=undef) = dict_get(dict, kInnerDiam, dflt=dflt);
function HasInnerDiam(dict) = dict_has_key(dict, kInnerDiam);
module AssertHasInnerDiam(dict) { assert(HasInnerDiam(dict)); }

function SetMidDiam(v, dict=undef) = dict_set(kMidDiam, v, dict);
function GetMidDiam(dict, dflt=undef) = dict_get(dict, kMidDiam, dflt=dflt);
function HasMidDiam(dict) = dict_has_key(dict, kMidDiam);
module AssertHasMidDiam(dict) { assert(HasMidDiam(dict)); }

function SetOuterDiam(v, dict=undef) = dict_set(kOuterDiam, v, dict);
function GetOuterDiam(dict, dflt=undef) = dict_get(dict, kOuterDiam, dflt=dflt);
function HasOuterDiam(dict) = dict_has_key(dict, kOuterDiam);
module AssertHasOuterDiam(dict) { assert(HasOuterDiam(dict)); }

function SetThickness(v, dict=undef) = dict_set(kThickness, v, dict);
function GetThickness(dict, dflt=undef) = dict_get(dict, kThickness, dflt=dflt);
function HasThickness(dict) = dict_has_key(dict, kThickness);
module AssertHasThickness(dict) { assert(HasThickness(dict)); }

// Tests that the functions work. Evaluated only if this file is
// opened as the top-level file.assert(72 == GetDepth(SetDepth(72)));
assert(72 == GetDepth(SetDepth(72, SetDepth(0))));
assert(72 == GetDepth(concat([1, 2, 3, 4], SetDepth(72))));
assert(undef == GetDepth([1, 2, kDepth]));
assert(undef == GetDepth([]));
assert(undef == GetDepth());
AssertHasDepth(SetDepth(72));
assert(!HasDepth([1, 2]));

assert(72 == GetHeight(SetHeight(72)));
assert(72 == GetHeight(SetHeight(72, SetHeight(0))));
assert(72 == GetHeight(concat([1, 2, 3, 4], SetHeight(72))));
assert(undef == GetHeight([1, 2, kHeight]));
assert(undef == GetHeight([]));
assert(undef == GetHeight());
AssertHasHeight(SetHeight(72));
assert(!HasHeight([1, 2]));

assert(72 == GetInnerDiam(SetInnerDiam(72)));
assert(72 == GetInnerDiam(SetInnerDiam(72, SetInnerDiam(0))));
assert(72 == GetInnerDiam(concat([1, 2, 3, 4], SetInnerDiam(72))));
assert(undef == GetInnerDiam([1, 2, kInnerDiam]));
assert(undef == GetInnerDiam([]));
assert(undef == GetInnerDiam());
AssertHasInnerDiam(SetInnerDiam(72));
assert(!HasInnerDiam([1, 2]));

assert(72 == GetMidDiam(SetMidDiam(72)));
assert(72 == GetMidDiam(SetMidDiam(72, SetMidDiam(0))));
assert(72 == GetMidDiam(concat([1, 2, 3, 4], SetMidDiam(72))));
assert(undef == GetMidDiam([1, 2, kMidDiam]));
assert(undef == GetMidDiam([]));
assert(undef == GetMidDiam());
AssertHasMidDiam(SetMidDiam(72));
assert(!HasMidDiam([1, 2]));

assert(72 == GetOuterDiam(SetOuterDiam(72)));
assert(72 == GetOuterDiam(SetOuterDiam(72, SetOuterDiam(0))));
assert(72 == GetOuterDiam(concat([1, 2, 3, 4], SetOuterDiam(72))));
assert(undef == GetOuterDiam([1, 2, kOuterDiam]));
assert(undef == GetOuterDiam([]));
assert(undef == GetOuterDiam());
AssertHasOuterDiam(SetOuterDiam(72));
assert(!HasOuterDiam([1, 2]));

assert(72 == GetThickness(SetThickness(72)));
assert(72 == GetThickness(SetThickness(72, SetThickness(0))));
assert(72 == GetThickness(concat([1, 2, 3, 4], SetThickness(72))));
assert(undef == GetThickness([1, 2, kThickness]));
assert(undef == GetThickness([]));
assert(undef == GetThickness());
AssertHasThickness(SetThickness(72));
assert(!HasThickness([1, 2]));

/////////////////// END GENERATED CODE //////////////////
/////////////////////////////////////////////////////////
