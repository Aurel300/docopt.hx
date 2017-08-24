package org.docopt;

class DocoptExit extends DocoptLanguageError {
  public static var usage:String = "";
  
  public function new(?msg:String) {
    super(msg);
    Docopt.println(StringTools.trim((msg != null ? msg + "\n" : "") + usage));
    Docopt.exit(1);
  }
}
