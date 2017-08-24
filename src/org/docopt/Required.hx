package org.docopt;

class Required extends BranchPattern {
  public function new(?children:Array<Pattern>) {
    super(children);
    type = Required;
  }
  
  override public function match(
    left:Array<LeafPattern>, ?collected:Array<LeafPattern>
  ):Match {
    collected = (collected != null ? collected : []);
    var l = left;
    var c = collected;
    for (pattern in children) {
      var match = pattern.match(l, c);
      l = match.left;
      c = match.collected;
      if (!match.matched) {
        return {matched: false, left: left, collected: collected};
      }
    }
    return {matched: true, left: l, collected: c};
  }
}
