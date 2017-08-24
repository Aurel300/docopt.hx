package org.docopt;

class DocoptLanguageError {
  public var msg:String;
  
  public function new(?msg:String) {
    this.msg = (msg != null ? msg : "");
  }
}
