require 'parser/current'
require 'json'

class RawRubyToJsonable
  # receives raw ruby code (a String)
  # return a data structure that can be directly converted into json
  # meaning String, Array, Hash, Fixnum, Float, nil, true, false
  def self.call(raw_code)
    new(raw_code).call
  end

  def initialize(raw_code)
    self.raw_code = raw_code
  end

  def call
    translate parse raw_code
  end

  private

  attr_accessor :raw_code

  def parse(raw_code)
    buffer                             = Parser::Source::Buffer.new('something')
    buffer.source                      = raw_code
    builder                            = Parser::Builders::Default.new
    builder.emit_file_line_as_literals = false
    parser                             = Parser::CurrentRuby.new builder
    parser.parse buffer
  end

  def assert_children(ast, n)
    num_children = ast.children.size
    return if num_children == n
    raise "Wrong number of children: Expected:#{n.inspect}, Actual:#{num_children.inspect} in #{ast.inspect}"
  end

  def translate(ast)
    return nil if ast.nil?

    case ast.type
    # e.g. "1"
    when :int
      assert_children ast, 1
      {'type'  => 'integer',
       'value' => ast.children[0].to_s
      }
    # e.g. "1.0"
    when :float
      assert_children ast, 1
      {'type'  => 'float',
       'value' => ast.children[0].to_s}
    # e.g. ":abc"
    when :sym
      assert_children ast, 1
      {'type'  => 'symbol',
       'value' => ast.children[0].to_s
      }
    # e.g. ':"a#{1}b"'
    when :dsym
      {'type'     => 'interpolated_symbol',
       'segments' => ast.children.map { |child| translate child }
      }
    # e.g. "'abc'"
    when :str
      assert_children ast, 1
      {'type'  => 'string',
       'value' => ast.children[0].to_s
      }
    # e.g. "%(a#{1}b)"
    when :dstr
      {'type'     => 'interpolated_string',
       'segments' => ast.children.map { |child| translate child }
      }
    # e.g. `echo hello`
    when :xstr
      {'type'     => 'executable_string',
       'segments' => ast.children.map { |child| translate child }
      }
    # e.g. "true"
    when :true
      assert_children ast, 0
      {'type' => 'true'}
    # e.g. "false"
    when :false
      assert_children ast, 0
      {'type' => 'false'}
    # e.g. "nil"
    when :nil
      assert_children ast, 0
      {'type' => 'nil'}
    # e.g. "1;2" and "(1;2)"
    when :begin
      {'type'        => 'expressions',
       'expressions' => ast.children.map { |child| translate child }
      }
    # e.g. "begin;1;2;end"
    when :kwbegin
      {'type'        => 'keyword_begin',
       'expressions' => ast.children.map { |child| translate child }
      }
    # e.g. "a.b(c)"
    when :send
      target, message, *args = ast.children
      {'type'    => 'send',
       'target'  => translate(target),
       'message' => message.to_s,
       'args'    => args.map { |arg| translate arg },
      }
    # e.g. "val = 1"
    when :lvasgn
      assert_children ast, 2
      { 'type'  => 'assign_local_variable',
        'name'  => ast.children[0].to_s,
        'value' => translate(ast.children[1]),
      }
    # e.g. "val = 1; val" NOTE: if you do not set the local first, then it becomes a send instead (ie parser is aware of the local)
    when :lvar
      assert_children ast, 1
      { 'type' => 'lookup_local_variable',
        'name' => ast.children[0].to_s,
      }
    # e.g. "/a/i"
    when :regexp
      *segments, opts = ast.children
      raise "Expected #{opts.inspect} to be a regopt!" unless opts.type == :regopt
      { 'type'     => 'regular_expression',
        'segments' => segments.map { |segment| translate segment },
        'options'  => {
          'ignorecase' => opts.children.include?(:i),
          'extended'   => opts.children.include?(:x),
          'multiline'  => opts.children.include?(:m),
        },
      }
    # e.g. [100, 200, 300]
    when :array
      {'type'     => 'array',
       'elements' => ast.children.map { |child| translate child },
      }
    # e.g. "class A; end"
    when :class
      # (class (const nil :A) nil nil)
      assert_children ast, 3
      location, superclass, body = ast.children

      {'type'        => 'class',
       'name_lookup' => translate(location),
       'superclass'  => translate(superclass),
       'body'        => translate(body),
      }
    # (def :a (args (arg :b)) (int 1))
    when :def
      assert_children ast, 3
      name, args, body = ast.children
      {'type' => 'method_definition',
       'args' => args.children.map { |arg| translate arg },
       'body' => translate(body),
      }
    # e.g. the b in `def a(b) 1 end`
    when :arg
      # (def :a (args (arg :b)) (int 1))
      assert_children ast, 1
      {'type' => 'required_arg',
       'name' => ast.children.first.to_s,
      }
    when :const
      assert_children ast, 2
      namespace, name = ast.children
      {'type'      => 'constant',
       'namespace' => translate(namespace),
       'name'      => name.to_s,
      }
    # e.g. the :: in `class ::A; end`
    when :cbase
      assert_children ast, 0
      {'type' => 'toplevel_constant'}
    # e.g. self
    when :self
      assert_children ast, 0
      {'type' => 'self'}
    # e.g. @abc
    when :ivar
      assert_children ast, 1 # (ivar :@abc)
      {'type' => 'lookup_instance_variable',
       'name' => ast.children.first.to_s }
    # e.g. @abc = 1
    when :ivasgn
      assert_children ast, 2 # (ivasgn :@abc (int 1))
      {'type'  => 'assign_instance_variable',
       'name'  => ast.children.first.to_s,
       'value' => translate(ast.children.last),
      }
    else
      raise "No case for #{ast.inspect}"
    end
  end
end

class App
  def self.call(rack_env)
    new.call(rack_env)
  end

  def call(rack_env)
    body   = rack_env['rack.input'].read
    status = 200
    begin
      json   = RawRubyToJsonable.call(body)
    rescue Parser::SyntaxError
      status = 400
      json   = {name: 'SyntaxError', message: $!.message, backtrace: $!.backtrace}
    end
    [status, {'Content-Type' => 'application/json; charset=utf-8'}, [JSON.dump(json)]]
  end
end
