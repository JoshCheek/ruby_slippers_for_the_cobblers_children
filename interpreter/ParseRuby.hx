class ParseRuby {
  public static function parseCode(rawCode:String):RubyAst {
    var astFor       = new sys.io.Process('../bin/ast_for', [rawCode]);
    var rawJson      = "";
    try { rawJson += astFor.stdout.readLine(); } catch (ex:haxe.io.Eof) { /* no op */ }
    var json:Dynamic = haxe.Json.parse(rawJson);
    return parseJson(json);
  }

  public static function parseJson(ast:Dynamic):RubyAst {
    if(ast == null) return Nil;

    var rubyAst = switch(ast.type) {
      case "nil"                   : Nil;
      case "true"                  : True;
      case "false"                 : False;
      case "self"                  : Self;
      case "integer"               : Integer(ast.value);
      case "float"                 : Float(ast.value);
      case "string"                : String(ast.value);
      case "expressions"           : Expressions(parseJsonArray(ast.expressions));
      case "set_local_variable"    : SetLocalVariable(ast.name, parseJson(ast.value));
      case "get_local_variable"    : GetLocalVariable(ast.name);
      case "set_instance_variable" : SetInstanceVariable(ast.name, parseJson(ast.value));
      case "get_instance_variable" : GetInstanceVariable(ast.name);
      case "send"                  : Send(parseJson(ast.target), ast.message, parseJsonArray(ast.args));
      case "constant"              : Constant(parseJson(ast.namespace), ast.name);
      case "class"                 : RClass(parseJson(ast.name_lookup), parseJson(ast.superclass), parseJson(ast.body));
      case "method_definition"     : MethodDefinition(ast.name, parseJsonArray(ast.args), parseJson(ast.body));
      case "required_arg"          : RequiredArg(ast.name);
      case _                       : Undefined(ast);
    }
    return rubyAst;
  }

  private static function parseJsonArray(array:Array<Dynamic>):Array<RubyAst> {
    return array.map(parseJson);
  }
}
