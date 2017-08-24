package org.docopt;

class Either extends BranchPattern {
  public function new(?children:Array<Pattern>) {
    super(children);
    type = Either;
  }
  
  override public function match(
    left:Array<LeafPattern>, ?collected:Array<LeafPattern>
  ):Match {
    collected = (collected != null ? collected : []);
    var outcomes = [];
    for (pattern in children) {
      var outcome = pattern.match(left, collected);
      if (outcome.matched) {
        outcomes.push(outcome);
      }
    }
    if (outcomes.length > 0) {
      var min = outcomes[0];
      for (outcome in outcomes) {
        if (outcome.left.length < min.left.length) {
          min = outcome;
        }
      }
      return min;
    }
    return {matched: false, left: left, collected: collected};
  }
}
