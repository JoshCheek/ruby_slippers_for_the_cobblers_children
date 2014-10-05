require 'parser/current'    # => true

class Interpreter
  class RbBinding
    attr_accessor :ast, :parent, :constant, :self_object
    def initialize(ast: nil, parent:, constant:, self_object:)
      self.ast         = ast
      self.parent      = parent
      self.constant    = constant
      self.self_object = self_object
    end

    def inspect
      "#<RbBinding ast:#{!!ast} parent:#{!!parent} constant:#{constant.inspect} self:#{self_object.inspect}>"
    end
  end

  class World
    def self.default
      world          = new

      rb_BasicObject = RbClass.new name:       :BasicObject,
                                   superclass: nil,
                                   klass:      nil,
                                   object_id:  0

      rb_Object      = RbClass.new name:       :Object,
                                   superclass: rb_BasicObject,
                                   klass:      nil,
                                   object_id:  1

      rb_Class       = RbClass.new name:       :Class,
                                   superclass: rb_Object,
                                   klass:      nil,
                                   object_id:  2

      rb_Class.klass       = rb_Class
      rb_BasicObject.klass = rb_Class
      rb_Object.klass      = rb_Class
      world.toplevel_const = rb_Object

      rb_main              = RbObject.new klass:        rb_Object,
                                          object_id:    3 # we'll deal with singleton stuff later

      toplevel_binding     = RbBinding.new ast:         nil,
                                           parent:      nil,
                                           constant:    world.toplevel_const,
                                           self_object: rb_main

      rb_Object.constants[:Object]           = rb_Object
      rb_Object.constants[:BasicObject]      = rb_Object
      rb_Object.constants[:TOPLEVEL_BINDING] = toplevel_binding

      world.objects[rb_BasicObject.object_id] = rb_BasicObject
      world.objects[rb_Object     .object_id] = rb_Object
      world.objects[rb_Class      .object_id] = rb_Class
      world.objects[rb_main       .object_id] = rb_main

      world.stack.push toplevel_binding
      world
    end

    attr_accessor :stack, :toplevel_const, :objects

    def initialize
      self.stack   = []
      self.objects = {}
    end

    def current_scope
      stack.last
    end

    def current_object
      current_scope.self_object
    end

    def current_constant
      current_scope.constant
    end
  end

  class RbObject
    attr_accessor :object_id, :klass, :instance_variable_table
    def initialize(klass:, instance_variable_table: {}, object_id:)
      self.klass                   = klass
      self.instance_variable_table = instance_variable_table
      self.object_id               = object_id
    end
    def inspect
      ivars = instance_variable_table.map { |name, value| "#{name}=#{value.inspect}" }.join(' ')
      "#<#{klass.name}:#{object_id}#{' ' unless ivars.empty?}#{ivars}>"
    end
  end

  class RbClass < RbObject
    attr_accessor :name, :superclass, :method_table, :constants
    def initialize(name: , superclass:, **keywords)
      self.name         = name
      self.superclass   = superclass
      self.method_table = {}
      self.constants    = {}
      super(keywords)
    end
    def inspect
      name.to_s
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
      world.stack.push RbBinding.new(ast:         ast,
                                     parent:      world.current_scope,
                                     constant:    world.current_constant,
                                     self_object: world.current_object)
      ast.children.each { |child| eval_ast child }
      world.stack.pop
    when :class
      # target is (const nil :User)
      target, superclass, body = ast.children
      superclass ||= world.toplevel_const
      new_class_name = target.children.last
      namespace      = world.current_constant # obviously flawed
      if namespace.constants[new_class_name]
        klass = namespace[new_class_name]
      else
        klass = RbClass.new name:       new_class_name,
                            superclass: superclass,
                            klass:      world.toplevel_const.constants[:Class],
                            superclass: superclass,
                            object_id:  world.objects.size
        namespace.constants[new_class_name] = klass
      end
      world.stack.push RbBinding.new(ast:         body,
                                     parent:      nil,
                                     constant:    klass,
                                     self_object: klass)
      eval_ast(body)
      world.stack.pop
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

  def print_world(stream)
    stream.puts "CONSTANTS"
    stream.puts world.toplevel_const.inspect
    stream.puts

    stream.puts "STACK:"
    world.stack.each { |frame| stream.puts "  #{frame.inspect}" }
    stream.puts ""

    stream.puts "OBJECTS:"
    world.objects.each { |id, o| stream.puts "  #{o.inspect}" }
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

