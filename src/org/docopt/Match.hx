package org.docopt;

typedef Match = {
     matched:Bool
    ,left:Array<LeafPattern>
    ,collected:Array<LeafPattern>
  };