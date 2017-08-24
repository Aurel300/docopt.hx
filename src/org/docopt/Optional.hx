package org.docopt;

class Optional extends BranchPattern {
  public function new(?children:Array<Pattern>) {
    super(children);
    type = Optional;
  }
  
  override public function match(
    left:Array<LeafPattern>, ?collected:Array<LeafPattern>
  ):Match {
    collected = (collected != null ? collected : []);
    for (pattern in children) {
      var match = pattern.match(left, collected);
      left = match.left;
      collected = match.collected;
    }
    return {matched: true, left: left, collected: collected};
  }
}
