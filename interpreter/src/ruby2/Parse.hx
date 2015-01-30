package ruby2;
import ruby2.ast.*;

class Parse {
  public static var serverUrl = 'http://localhost:3003';

  public static function fromString(rawCode:String, ?serverUrl:String):Ast {
    if(serverUrl == null) serverUrl = Parse.serverUrl;
    var jsonString = ruby2.Http.post(serverUrl, rawCode);
    var json       = haxe.Json.parse(jsonString);
    return fromJson(json);
  }

  static function fromJson(ast:Dynamic):Ast {
    if(ast == null) return new DefaultAst({begin_loc: -1, end_loc: -1});
    return switch(ast.type) {
      case "nil"                   : new NilAst({begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "true"                  : new TrueAst({begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "false"                 : new FalseAst({begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "self"                  : new SelfAst({begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "integer"               : new IntegerAst({value: Std.parseInt(ast.value), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "float"                 : new FloatAst({value: Std.parseFloat(ast.value), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "string"                : new StringAst({value: ast.value, begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "expressions"           : new ExprsAst({expressions: ast.expressions.map(fromJson), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "set_local_variable"    : new SetLvarAst({name: ast.name, value: fromJson(ast.value), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "get_local_variable"    : new GetLvarAst({name: ast.name, begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "set_instance_variable" : new SetIvarAst({name: ast.name, value: fromJson(ast.value), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "get_instance_variable" : new GetIvarAst({name: ast.name, begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "send"                  : new SendAst({target    : fromJson(ast.target),
                                                  message   : ast.message,
                                                  arguments : ast.args.map(fromJson),
                                                  begin_loc : begin_loc(ast),
                                                  end_loc   : end_loc(ast)});
      case "constant"              : new ConstAst({name: ast.name, ns: fromJson(ast.namespace), begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case "class"                 : new OpenClassAst({ns         : fromJson(ast.name_lookup),
                                                       superclass : fromJson(ast.superclass),
                                                       body       : fromJson(ast.body),
                                                       begin_loc  : begin_loc(ast), end_loc: end_loc(ast)});
      case "method_definition"     : new DefAst({name:       ast.name,
                                                 parameters: ast.args.map(toParam),
                                                 body:       fromJson(ast.body),
                                                begin_loc: begin_loc(ast), end_loc: end_loc(ast)});
      case _                       : throw("CAN'T PARSE: " + ast);
    }
  }

  private static function toParam(param:Dynamic):DefAst.Parameter {
    switch(param.type) {
      case "required_arg": return new DefAst.Parameter(param.name, Required, begin_loc(param), end_loc(param));
      case "rest_arg":     return new DefAst.Parameter(param.name, Rest, begin_loc(param), end_loc(param));
      case _: throw("Unknown arg type!: " + param);
    }
  }

  private static function begin_loc(ast:Dynamic) {
    return ast.location.begin;
  }
  private static function end_loc(ast:Dynamic) {
    return ast.location.end;
  }
}
