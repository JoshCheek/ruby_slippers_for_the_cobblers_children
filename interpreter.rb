require 'parser/current'    # => true

class Interpreter
  class StackFrame
    class Null < StackFrame
      def initialize(ast: nil, scope: nil, self_object:)
        super
      end
    end

    def initialize(ast:, scope:, self_object:)
      self.ast         = ast
      self.scope       = scope
      self.self_object = self_object
    end
  end

  class World
    def self.default
      object_class = Class.new(Class::BasicObject.new)
      main         = Object.new(klass: object_class)
      self.world.push_stack StackFrame::Null.new(self_object: main)
    end

    attr_accessor :stack

    def initialize
      @stack = []
    end

    def push_stack(stackframe)
      stack.push stackframe
    end

    def pop_stack
      stack.pop
    end

    def peek_stack
      stack.last
    end

    def current_object
      peek_stack.self_object
    end
  end

  class Class
    class BasicObject < Class
      def initialize
        super nil
      end
    end

    attr_reader :superclass
    attr_reader :method_table
    def initialize(superclass)
      self.superclass   = superclass
      self.method_table = {}
    end
  end

  attr_accessor :world
  def initialize
    self.world = World.default
  end

  def eval(raw_code)
    eval_ast parse(raw_code)
  end

  def parse(raw_code)
    buffer                             = Parser::Source::Buffer.new('something')
    buffer.source                      = raw_code
    builder                            = Parser::Builders::Default.new
    builder.emit_file_line_as_literals = false
    parser                             = Parser::CurrentRuby.new builder
    parser.parse buffer
  end

  def eval_ast(ast)
    case ast.type
    when :begin
      world.push_stack StackFrame.new(ast: ast, scope: world.peek_stack, self_object: world.current_object)
      ast.children.each { |child| eval_ast child }
      world.pop_stack
    when :class
      # target is (const nil :User)
      target, superclass, body = ast.children
      superclass     ||= world.toplevel_const
      new_class_name = target.children.last
      namesace = world.current_constant
      if c.has_const?(new_class_name)
        klass = c.get_const(new_class_name)
      else
        klass = Class.new(superclass)
        c.set_const(new_class_name, klass)
      end
      world.push_stack StackFrame.new(ast: body, scope: StackFrame::Null, self_object: klass)
      eval_ast(body)
    when :const
    when :send
    when :def
    when :args
    when :arg
    when :ivasgn
    when :lvasgn
    when :lvar
    when :str
    else
      raise "DID NOT HANDLE #{ast.inspect}"
    end
  end
end

# => (begin
#      (class
#        (const nil :User) nil
#        (begin
#          (send nil :attr_reader
#            (sym :name))
#          (def :initialize
#            (args
#              (arg :name))
#            (ivasgn :@name
#              (lvar :name)))))
#      (lvasgn :upser
#        (send
#          (const nil :User) :new
#          (str "Josh")))
#      (send nil :puts
#        (send
#          (send nil :user) :name)))

