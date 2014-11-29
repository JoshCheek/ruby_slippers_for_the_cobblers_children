package dir;

class ModuleStyleMethods {
  // Class here lets it take any arg type
  // the question mark means it is optional, so can call like method on ModuleStyleMethods
  public static function zomg(self:Dynamic, message:String) {
    trace('Module style: ' + message);
  }
}
