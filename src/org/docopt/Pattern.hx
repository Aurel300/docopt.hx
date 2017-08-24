package org.docopt;

class Pattern {
  /**
   * Expand pattern into an (almost) equivalent one, but with single Either.
   * 
   * Example: ((-a | -b) (-c | -d)) => (-a -c | -a -d | -b -c | -b -d)
   * Quirks: [-a] => (-a), (-a...) => (-a -a)
   */
  public static function transform(pattern:Pattern):Either {
    var result = [];
    var groups = [[pattern]];
    while (groups.length > 0) {
      var children = groups.shift();
      var child = [ for (c in children) if (c != null && c.hasChildren) c ][0];
      if (child != null) {
        children.remove(child);
        switch (child.type) {
          case Either:
          for (c in child.children) {
            groups.push([c].concat(children));
          }
          case OneOrMore:
          groups.push(child.children.concat(child.children).concat(children));
          case _:
          groups.push(child.children.concat(children));
        }
      } else {
        result.push(children);
      }
    }
    return new Either([ for (e in result) new Required(e) ]);
  }
  
  public static function equal(a:Pattern, b:Pattern):Bool {
    return a.toString() == b.toString();
  }
  
  public var type:PatternType;
  public var hasChildren:Bool;
  public var children:Array<Pattern>;
  
  public function new() {
    type = None;
    hasChildren = false;
  }
  
  public function toString():String {
    return "";
  }
  
  public function fix():Pattern {
    fixIdentities();
    fixRepeatingArguments();
    return this;
  }
  
  /**
   * Make pattern-tree tips point to same object if they are equal.
   */
  private function fixIdentities(?uniq:Array<Pattern>):Void {
    // override in BranchPattern
  }
  
  /**
   * Fix elements that should accumulate/increment values.
   */
  private function fixRepeatingArguments():Void {
    var either = [ for (child in Pattern.transform(this).children) (cast child:Required).children ];
    for (c in either) {
      for (e in [ for (child in c) if (Docopt.count(c, child, Pattern.equal) > 1) child ]) {
        if (e.type == Argument
            || (e.type == Option && (cast e:Option).argCount > 0)) {
          var ee = (cast e:LeafPattern);
          if (ee.value == null) {
            ee.value = [];
          } else if (!Std.is(ee.value, Array)) {
            ee.value = Docopt.split(ee.value);
          }
        }
        if (e.type == Command
            || (e.type == Option && (cast e:Option).argCount == 0)) {
          (cast e:LeafPattern).value = 0;
        }
      }
    }
  }
  
  public function flat(?types:Array<PatternType>):Array<Pattern> {
    return [this];
  }
  
  public function match(
    left:Array<LeafPattern>, ?collected:Array<LeafPattern>
  ):Match {
    return null;
  }
}
