require 'parser/current'    # => true

class Interpreter
  class Signature
    attr_accessor :arglist
    def initialize(arglist)
      self.arglist = arglist
    end
  end

  class RbBinding
    attr_accessor :ast, :parent, :constant, :self_object, :local_vars, :signature
    def initialize(ast: nil, signature: Signature.new([]), parent:, constant:, self_object:)
      self.ast         = ast
      self.parent      = parent
      self.constant    = constant
      self.signature   = signature
      self.local_vars  = {}
      self.self_object = self_object
    end

    def inspect
      "#<RbBinding ast:#{!!ast} parent:#{!!parent} constant:#{constant.inspect} self:#{self_object.inspect}>"
    end
  end

  class World
    def self.default
      world = new

      # toplevel infrastructure
      rb_BasicObject = world.add_object RbClass, name: :BasicObject, klass: nil, superclass: nil
      rb_Object      = world.add_object RbClass, name: :Object,      klass: nil, superclass: rb_BasicObject
      rb_Class       = world.add_object RbClass, name: :Class,       klass: nil, superclass: rb_Object

      world.toplevel_const = rb_Object

      rb_BasicObject.klass = rb_Class
      rb_Object.klass      = rb_Class
      rb_Class.klass       = rb_Class

      rb_NilClass = world.add_object RbClass,  klass: rb_Class, superclass: rb_Object, name: :NilClass
      rb_nil      = world.add_object RbObject, klass: rb_NilClass
      world.add_singleton :nil, rb_nil
      rb_BasicObject.superclass = rb_NilClass

      # main/toplevel_binding
      rb_main = world.add_object RbObject, klass: rb_Object
      toplevel_binding = RbBinding.new ast:         nil,
                                       parent:      nil,
                                       constant:    world.toplevel_const,
                                       self_object: rb_main

      world.push toplevel_binding

      # namespacing
      rb_Object.add_constant :Object           , rb_Object
      rb_Object.add_constant :Class            , rb_Class
      rb_Object.add_constant :BasicObject      , rb_BasicObject
      rb_Object.add_constant :NilClass         , rb_NilClass
      rb_Object.add_constant :TOPLEVEL_BINDING , toplevel_binding

      world
    end

    attr_accessor :toplevel_const, :objects, :singletons

    def initialize
      self.stack             = []
      self.objects           = {}
      self.singletons        = {}
      self.current_object_id = 0
    end

    def current_object
      current_scope.self_object
    end

    def current_constant
      current_scope.constant
    end

    def add_singleton(name, obj)
      raise "already set!" if singletons[name]
      singletons[name] = obj
    end
    def singleton(name)
      singletons.fetch name
    end

    def add_object(type, attrs)
      id = self.current_object_id
      self.current_object_id += 1
      objects[id] = type.new(attrs.merge object_id: id)
    end

    def current_scope
      stack.last
    end

    def push(binding)
      stack.push binding
    end

    def pop
      stack.pop
    end

    def each_stack(&block)
      stack.each(&block)
    end

    protected
    attr_accessor :current_object_id, :stack
  end

  class RbObject
    attr_accessor :object_id, :klass, :instance_variable_table
    def initialize(klass:, object_id:)
      self.klass                   = klass
      self.instance_variable_table = {}
      self.object_id               = object_id
    end
    def inspect
      ivars = instance_variable_table.map { |name, value| "#{name}=#{value.inspect}" }.join(' ')
      "#<#{klass.name}:#{object_id}#{' ' unless ivars.empty?}#{ivars}>"
    end
  end

  class RbClass < RbObject
    attr_accessor :name, :superclass, :method_table
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

    def add_constant(name, value)
      constants[name] = value
    end

    def get_constant(name)
      constants.fetch name
    end

    def has_constant?(name)
      !!constants[name]
    end

    def each_constant(&block)
      constants.each(&block)
    end

    private

    attr_accessor :constants
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

  # TODO: rename current_constant -> current_namespace
  #       toplevel_constant -> toplevel_namespace
  def eval_ast(ast)
    case ast.type
    when :begin
      world.push RbBinding.new(ast:         ast,
                               parent:      world.current_scope,
                               constant:    world.current_constant,
                               self_object: world.current_object)
      ast.children.each { |child| eval_ast child }
      world.pop
    when :class
      # target is (const nil :User)
      target, superclass, body = ast.children
      superclass ||= world.toplevel_const
      new_class_name = target.children.last
      namespace      = world.current_constant
      if namespace.has_constant? new_class_name
        klass = namespace.get_constant new_class_name
      else
        klass = RbClass.new name:       new_class_name,
                            superclass: superclass,
                            klass:      world.toplevel_const.get_constant(:Class),
                            superclass: superclass,
                            object_id:  world.objects.size
        namespace.add_constant new_class_name, klass
      end
      world.push RbBinding.new ast:         body,
                               parent:      nil,
                               constant:    klass,
                               self_object: klass
      eval_ast(body)
      world.pop
    when :const
      raise 'implement me'
    when :send
    when :def
      method_name, args, body = ast.children
      signature = eval_ast(args)
      method = RbBinding.new ast:         ast,
                             signature:   signature,
                             parent:      nil,
                             constant:    world.current_constant,
                             self_object: world.singleton(:nil)
      world.current_constant.method_table[method_name] = method
#          (def :initialize
#            (args
#              (arg :name))
#            (ivasgn :@name
#              (lvar :name)))))
    when :args
      args = ast.children
      Signature.new args.map { |type, name| [:req, name] } # obviously bullshit
    when :arg
    when :ivasgn
    when :lvasgn
    when :lvar
    when :str
    else
      raise "DID NOT HANDLE #{ast.inspect}"
    end
  end

  def pretty_inspect
    "CONSTANTS:\n"\
    "#{inspect_const_tree}"\
    "\n"\
    "STACK:\n"\
    "#{world.each_stack.map { |frame| "  #{frame.inspect}\n" }.join}\n"\
    "OBJECTS:\n"\
    "#{world.objects.map(&:last).map { |o| "  #{o.inspect}\n" }.join}"
  end

  def inspect_const_tree(const=world.toplevel_const, depth=1, already_seen=[])
    return '' if already_seen.include? const
    already_seen << const
    padding = ('  ' * depth)
    result  = ""
    result << padding << const.name.to_s << "\n"
    const.each_constant do |name, child|
      if child.kind_of? RbClass
        result << inspect_const_tree(child, depth+1, already_seen)
      else
        result << padding << '  ' << name.to_s << "\n"
      end
    end
    result
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

