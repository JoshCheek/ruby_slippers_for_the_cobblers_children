require 'parser/current'
require 'json'

class RawRubyToJsonable
  # receives raw ruby code (a String)
  # return a data structure that can be directly converted into json
  # meaning String, Array, Hash, Fixnum, Float, nil
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
    # eg "1"
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
    # eg ":abc"
    when :sym
      assert_children ast, 1
      {'type'  => 'symbol',
       'value' => ast.children[0].to_s
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
    # eg "1;2" and "(1;2)"
    when :begin
      {'type'     => 'expressions',
       'children' => ast.children.map { |child| translate child }
      }
    # eg "begin;1;2;end"
    when :kwbegin
      {'type'     => 'keyword_begin',
       'children' => ast.children.map { |child| translate child }
      }
    # eg "a.b()"
    #    "b()"
    #    "a.b"
    #    a % b
    when :send
      target, message, *args = ast.children
      {'type'    => 'send',
       'target'  => translate(target),
       'message' => message.to_s,
       'args'    => args.map { |arg| translate arg },
      }
    # eg "val = 1"
    when :lvasgn
      assert_children ast, 2
      { 'type'  => 'assign_local_variable',
        'name'  => ast.children[0].to_s,
        'value' => translate(ast.children[1]),
      }
    # eg "val = 1; val" NOTE: if you do not set the local first, then it becomes a send instead (ie parser is aware of the local)
    when :lvar
      assert_children ast, 1
      { 'type' => 'lookup_local_variable',
        'name' => ast.children[0].to_s,
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
