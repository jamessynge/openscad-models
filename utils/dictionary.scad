// Utility functions and methods for working with vectors to be used as
// dictionaries (pairs of key and value). There is no attempt to eliminate
// duplicate values. Instead, we just append at the start, and search from
// the start, so pairs added later supercede older values.
// Author: James Synge

// dict=undef is last parameter to allow ordered chaining
function dict_set(key, value, dict=undef) = (
  dict==undef ? [key, value] : concat([key, value], dict)
);
function dict_get(dict, key, ndx=0, dflt=undef) = (
  dict == undef ? dflt :
    (len(dict) < ndx + 2
       ? dflt
       : (dict[ndx] == key
            ? dict[ndx + 1]
            : dict_get(dict, key, ndx=ndx+2, dflt=dflt)))
);

module assert_is_list(v, name="Parameter") {
  if (!is_list(v)) {
    echo("Parameter is not a list");
    echo(str(name, ": "), v);
  }
  assert(is_list(v));
}

module assert_is_dict(v, name="Parameter") {
  assert_is_list(v, name=name);
  if (len(v) % 2 != 0) {
    echo("Parameter doesn't have an even number of elements (not a dict)");
    echo(str(name, ": "), v);
  }
  assert(len(v) % 2 == 0);
}

function _dict_has_key_helper_(dict, key, sentinel) = (
  sentinel != dict_get(dict, key, dflt=sentinel));

function dict_has_key(dict, key) = (
  _dict_has_key_helper_(dict, key, sentinel=rands(0,1,4))
);

module assert_dict_has_key(dict, key) {
  assert(dict_has_key(dict, key, dflt=sentinel),
         str("Dict doesn't contain key ", key, "; keys are: ",
             [for (i = [0 : 2 : len(dict)]) dict[i]]));
}

module assert_dict_has_keys(dict, keys) {
  assert_is_dict(dict, name="dict");
  assert_is_list(keys);
  for (i = [0 : len(keys) - 1]) {
    assert_dict_has_key(dict, key);
  }
}

function join_strs(vec, delim="", ndx=0) = (
  !is_list(vec)
    ? THIS_IS_NOT_A_VECTOR
    : len(vec) > ndx+1
      ? str(vec[ndx], delim, join_strs(vec, delim=delim, ndx=ndx+1))
      : str(vec[ndx])
);

module print_dict_helpers(keys) {
  keys = quicksort(keys);
  assert_is_list(keys);
  limit = len(keys) - 1;
  for (i = [0 : len(keys) - 1]) {
    assert(is_string(keys[i]), str("keys[", i, "] (",keys[i],") is not a string"));
  }
  function quote(s) = join_strs(["\"", s, "\""]);
  // input : list of comparable values
  // output : those values, in sorted order
  function quicksort(arr) = !(len(arr)>0) ? [] : let(
      pivot   = arr[floor(len(arr)/2)],
      lesser  = [ for (y = arr) if (y  < pivot) y ],
      equal   = [ for (y = arr) if (y == pivot) y ],
      greater = [ for (y = arr) if (y  > pivot) y ]
  ) concat(
      quicksort(lesser), equal, quicksort(greater)
  );

  start = [
    "\n\n",
    "/////////////////////////////////////////////////////////\n",
    "////////////////// BEGIN GENERATED CODE /////////////////\n",
    ];
  finish = [
    "/////////////////// END GENERATED CODE //////////////////\n",
    "/////////////////////////////////////////////////////////\n",
    "\n",
    ];

  regen = concat(
    "\n",
    "// To regenerate, open this file in OpenSCAD and copy\n",
    "// the ECHO output from the console:\n",
    "print_dict_helpers([",
    [for (i = [0 : limit]) str("\"", keys[i], "\",")],
    "]);\n"
  );

  key_decls = concat(
    "\n",
    "// Keys for the dictionary, used by Set* and Get* methods.\n",
    [for (i = [0 : limit]) str("k", keys[i], " = \"", keys[i], "\";\n")]
  );

  function setter(k) = join_strs([
    "function Set", k, "(v, dict=undef) = dict_set(k", k, ", v, dict);\n"
  ]);
  function getter(k) = join_strs([
    "function Get", k, "(dict, dflt=undef) = dict_get(dict, k", k, ", dflt=dflt);\n"
  ]);
  function tester(k) = join_strs([
    "function Has", k, "(dict) = dict_has_key(dict, k", k, ");\n"
  ]);
  function asserter(k) = join_strs([
    "module AssertHas", k, "(dict) { assert(Has", k, "(dict)); }\n"
  ]);
  function all_helpers(k) = (
    join_strs([setter(k), getter(k), tester(k), asserter(k)])
  );

  accessors = concat(
    "\n",
    "// Accessors and validators, one per key.\n",
    [for (i = [0 : limit]) str(all_helpers(keys[i]), "\n")]
    );

  function key_tests(k) = join_strs([
    "assert(72 == Get", k, "(Set", k, "(72)));\n",
    "assert(72 == Get", k, "(Set", k, "(72, Set", k, "(0))));\n",
    "assert(72 == Get", k, "(concat([1, 2, 3, 4], Set", k, "(72))));\n",
    "assert(undef == Get", k, "([1, 2, k", k, "]));\n",
    "assert(undef == Get", k, "([]));\n",
    "assert(undef == Get", k, "());\n",
    "AssertHas", k, "(Set", k, "(72));\n",
    "assert(!Has", k, "([1, 2]));\n",
    ]);

  tests = concat(
    "// Tests that the functions work. Evaluated only if this file is\n",
    "// opened as the top-level file.",
    [for (i = [0 : limit]) str(key_tests(keys[i]), "\n")]
    );

  echo(join_strs(concat(start, regen, key_decls, accessors, tests, finish)));
}

// Tests:
assert_is_dict([1, 2]);
assert_is_dict([]);
assert(join_strs(["abc", "def"]) == "abcdef");
assert(join_strs(["abc", "def"], delim=", ") == "abc, def");

// These fail, and the first assert stops eval.
if (false) {
  assert_is_dict([1]);
  assert_is_dict();  
}
