// http://haxe.org/manual/class-field-property.html

typedef User = {
  name:String
}

class UserAccess {
  public  var username(get, never):String;
  private var user:User;

  public function new(user) {
    this.user = user;
  }

  // this gets called when you invoke .username
  // (functions seem to be private visibility by default)
  function get_username() {
    return user.name;
  }
}

class Properties {
  public static function main() {
    var ua = new UserAccess({name: "Josh"});
    trace(ua.username); // Josh
  }
}
