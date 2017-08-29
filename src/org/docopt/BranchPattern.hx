package org.docopt;

class BranchPattern extends Pattern {
  public function new(?children:Array<Pattern>) {
    super();
    type = BranchPattern;
    hasChildren = true;
    this.children = (children != null ? children : []);
  }
  
  override public function toString():String {
    return '$type(' + children.map(function(c) {
        return c == null ? "null" : c.toString();
      }).join(", ") + ")";
  }
  
  override private function fixIdentities(?uniq:Array<Pattern>):Void {
    uniq = (uniq != null ? uniq : Docopt.listSet(flat(), Pattern.equal));
    for (i in 0...children.length) {
      var child = children[i];
      if (child.hasChildren) {
        child.fixIdentities(uniq);
      } else {
        var uc = Docopt.listIn(uniq, child, Pattern.equal);
        if (uc == null) {
          throw "child not in uniq";
        }
        children[i] = uc;
      }
    }
  }
  
  override public function flat(?types:Array<PatternType>):Array<Pattern> {
    if (types != null && types.indexOf(type) != -1) {
      return [this];
    }
    var ret = [];
    for (child in children) {
      ret = ret.concat(child.flat(types));
    }
    return ret;
  }
}
