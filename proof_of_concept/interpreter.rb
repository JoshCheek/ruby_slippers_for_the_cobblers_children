require 'parser/current'    # => true

class Interpreter

  # -> _, _=_, *_, _:_, _:, **_ { }.parameters.map &:first
  # # => [:req, :opt, :rest, :keyreq, :key, :keyrest]
  class Signature
    attr_accessor :arglist
    def initialize(arglist)
      self.arglist = arglist
    end

    # prob should be something more like https://github.com/JoshCheek/bindable_block/blob/aea3b9bbdcaf9e9f5d938b05578827ca5d480bdc/lib/bindable_block/arg_aligner.rb
    def locals_for(values)
      argnames = arglist.map(&:last)
      Hash[argnames.zip(values)]
    end
  end

  class RbBinding
    attr_accessor :ast, :parent, :constant, :self_object, :local_vars, :signature
    def initialize(ast: nil, local_vars:{}, signature: Signature.new([]), parent:, constant:, self_object:)
      self.ast         = ast
      self.parent      = parent
      self.constant    = constant
      self.signature   = signature
      self.local_vars  = local_vars
      self.self_object = self_object
    end

    def inspect
      ast_inspected = !ast ? nil : ast.kind_of?(Proc) ? 'proc' : "(#{ast.type}...)"
      "#<RbBinding ast:#{ast_inspected} parent:#{!!parent} constant:#{constant.inspect} self:#{self_object.inspect} local_vars=#{local_vars.inspect}>"
    end

    def set_local(name, val)
      local_vars[name] = val
    end

    def get_local(name)
      local_vars.fetch(name) {
        if parent
          parent.get_local(name)
        else
          raise "NO LOCAL! #{name.inspect}"
        end
      }
    end
  end

  class World
    attr_accessor :toplevel_namespace, :objects, :singletons, :symbols

    def initialize
      self.stack             = []
      self.symbols           = {}
      self.objects           = {}
      self.singletons        = {}
      self.current_object_id = 0
    end

    def current_object
      current_scope.self_object
    end

    def current_namespace
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

    def get_symbol(name)
      value = symbols[name]
      return value if value
      symbol_class      = toplevel_namespace.get_constant(:Symbol)
      symbol            = add_object RbObject, klass: symbol_class
      symbols[name] = symbol
      symbol.set_internal :value, name
      symbol
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
    attr_accessor :current_object_id, :stack, :symbols
  end

  class RbObject
    attr_accessor :object_id, :klass, :ivars, :internal_vars
    def initialize(klass:, object_id:)
      self.klass         = klass
      self.ivars         = {}
      self.object_id     = object_id
      self.internal_vars = {}
    end

    def set_ivar(name, value)
      ivars[name] = value
    end

    def get_ivar(name)
      ivars[name]
    end

    def set_internal(key, value)
      internal_vars[key] = value
    end

    def get_internal(key)
      internal_vars.fetch(key)
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

    def has_method?(name)
      method_table.key? name
    end

    def def_method(name, method)
      method_table[name] = method
    end

    def get_method(name)
      method_table.fetch name
    end

    def each_method(&block)
      method_table.each(&block)
    end

    def inspect
      name.to_s
    end

    def add_constant(name, value)
      raise "Already assigned #{name.inspect}" if has_constant? name # technically not correct behaviour, but I'm tired and making a lot of mistakes
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
    self.world = World.new

    # toplevel infrastructure
    rb_BasicObject = world.add_object RbClass, name: :BasicObject, klass: nil, superclass: nil
    rb_Object      = world.add_object RbClass, name: :Object,      klass: nil, superclass: rb_BasicObject
    rb_Class       = world.add_object RbClass, name: :Class,       klass: nil, superclass: rb_Object

    rb_BasicObject.klass = rb_Class
    rb_Object.klass      = rb_Class
    rb_Class.klass       = rb_Class

    world.toplevel_namespace = rb_Object
    world.toplevel_namespace.add_constant :Object      , rb_Object
    world.toplevel_namespace.add_constant :Class       , rb_Class
    world.toplevel_namespace.add_constant :BasicObject , rb_BasicObject

    rb_NilClass = world.add_object RbClass,  klass: rb_Class, superclass: rb_Object, name: :NilClass
    rb_nil      = world.add_object RbObject, klass: rb_NilClass
    world.add_singleton :nil, rb_nil
    rb_BasicObject.superclass = rb_NilClass
    world.toplevel_namespace.add_constant :NilClass, rb_NilClass

    # main/toplevel_binding
    rb_main = world.add_object RbObject, klass: rb_Object
    toplevel_binding = RbBinding.new ast:         nil,
                                     parent:      nil,
                                     constant:    world.toplevel_namespace,
                                     self_object: rb_main

    world.push toplevel_binding
    rb_Object.add_constant :TOPLEVEL_BINDING, toplevel_binding

    # Object
    rb_Object.def_method :inspect, RbBinding.new(
      local_vars:  {},
      signature:   Signature.new([]), # these will be set in binding
      ast:         lambda { |world, binding|
        s = binding.self_object
        if binding.klass.has_method?(:inspect) # should actually use respond_to
          send_message s, :inspect, []
        else
          inspected_ivars = s.ivars.map { |name, value| "#{name}=#{value.inspect}" }.join(' ')
          "#<#{s.klass.name}:#{s.object_id}#{' ' unless s.ivars.empty?}#{inspected_ivars}>"
        end
      },
      parent:      rb_nil,
      constant:    rb_nil,
      self_object: rb_nil
    )

    # Class
    rb_Class.def_method :allocate, RbBinding.new(
      local_vars:  {},
      signature:   Signature.new([]), # these will be set in binding
      ast:         lambda { |world, bnd|
        world.add_object(RbObject, klass: bnd.self_object)
      },
      parent:      rb_nil,
      constant:    rb_nil,
      self_object: rb_nil
    )

    # Symbol
    rb_Symbol = world.add_object RbClass, klass: rb_Class, superclass: rb_Object, name: :Symbol
    world.toplevel_namespace.add_constant :Symbol, rb_Symbol
    rb_Object.def_method :inspect, RbBinding.new(
      local_vars:  {},
      signature:   Signature.new([]), # these will be set in binding
      ast:         lambda { |world, binding| binding.self_object.get_internal(:value).to_s },
      parent:      rb_nil,
      constant:    rb_nil,
      self_object: rb_nil
    )

    # String
    rb_String = world.add_object RbClass, klass: rb_Class, superclass: rb_Object, name: :String
    world.toplevel_namespace.add_constant :String, rb_String
    rb_Object.def_method :inspect, RbBinding.new(
      local_vars:  {},
      signature:   Signature.new([]), # these will be set in binding
      ast:         lambda { |world, binding| binding.self_object.get_internal(:value).to_s },
      parent:      rb_nil,
      constant:    rb_nil,
      self_object: rb_nil
    )

    # init the world
    rb_Object.def_method :instance_variable_get, RbBinding.new(
      local_vars:  {},
      signature:   Signature.new([[:req, :ivar_name]]), # these will be set in binding
      ast:         lambda { |world, binding| binding.self_object.get_ivar binding.get_local(:ivar_name) },
      parent:      rb_nil,
      constant:    rb_nil,
      self_object: rb_nil
    )

    rb_Object.def_method :puts, RbBinding.new(
      local_vars:  {},
      signature:   Signature.new([[:rest, :strings_for_now]]),
      ast:         lambda { |world, binding| ::Kernel.puts "PRINTED INTERNALLY: #{binding.get_local(:strings_for_now).inspect}"; rb_nil },
      parent:      rb_nil,
      constant:    rb_nil,
      self_object: rb_nil
    )
    eval File.read(File.expand_path('../init.rb', __FILE__))
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
    # to allow for interop between parsed code and internal code
    return ast.call(world, world.current_scope) if ast.kind_of? Proc
    return world.singleton(:nil)                if ast.nil?

    case ast.type
    when :begin
      world.push RbBinding.new(ast:         ast,
                               parent:      world.current_scope,
                               constant:    world.current_namespace,
                               self_object: world.current_object)
      return_val = nil
      ast.children.each { |child| return_val = eval_ast child }
      world.pop
      return_val
    when :class
      # target is (const nil :User)
      target, superclass, body = ast.children
      superclass ||= world.toplevel_namespace
      new_class_name = target.children.last
      namespace      = world.current_namespace
      if namespace.has_constant? new_class_name
        klass = namespace.get_constant new_class_name
      else
        klass = RbClass.new name:       new_class_name,
                            superclass: superclass,
                            klass:      world.toplevel_namespace.get_constant(:Class),
                            superclass: superclass,
                            object_id:  world.objects.size
        namespace.add_constant new_class_name, klass
      end
      world.push RbBinding.new ast:         body,
                               parent:      nil,
                               constant:    klass,
                               self_object: klass
      result = eval_ast(body)
      world.pop
    when :send
      get_target, message, *arg_getters = ast.children
      target = get_target ? eval_ast(get_target) : world.current_scope.self_object
      args   = arg_getters.map { |arg_getter| eval_ast arg_getter }
      send_message target, message, args
    when :def
      method_name, args, body = ast.children
      signature = eval_ast(args)
      method = RbBinding.new ast:         body, # conflation of ast: thing that tells me where in the source I came from, vs here, it's "thing I want to execute"
                             signature:   signature,
                             parent:      nil,
                             constant:    world.current_namespace,
                             self_object: world.singleton(:nil)
      world.current_namespace.def_method method_name, method
      method_name
    when :args
      args = ast.children
      Signature.new(args.map { |arg| eval_ast arg })
    when :lvasgn
      name, value_code = ast.children
      value = eval_ast(value_code)
      world.current_scope.set_local name, value
      value
    when :sym
      world.get_symbol(ast.children.first)
    when :str
      if ast.children.size != 1
        require "pry"
        binding.pry
      end
      rb_String = world.toplevel_namespace.get_constant(:String)
      string    = world.add_object RbObject, klass: rb_String
      value     = ast.children.first
      string.set_internal :value, value
      value
    when :const
      namespace, name = ast.children
      namespace ||= world.toplevel_namespace
      namespace.get_constant name
    when :lvar
      world.current_scope.get_local ast.children.first
    when :arg
      [:req, ast.children.last]
    when :self
      world.current_scope.self_object
    when :ivasgn
      name, value_ast = ast.children
      value = eval_ast(value_ast)
      world.current_scope.self_object.set_ivar(name, value)
    when :ivar
      name = ast.children.first
      world.current_scope.self_object.get_ivar(name)
    else
      raise "DID NOT HANDLE #{ast.inspect}"
    end
  end

  def send_message(target, message, args)
    ancestor = target.klass
    until !ancestor || ancestor.has_method?(message)
      break if RbClass === ancestor
      ancestor = ancestor.superclass
    end

    unless ancestor.has_method? message
      require "pry"
      binding.pry
    end

    method  = ancestor.get_method(message)
    locals  = method.signature.locals_for(args)
    binding = RbBinding.new ast:          method.ast,
                            signature:    method.signature,
                            parent:       method.parent,
                            constant:     target.klass,
                            local_vars:   locals,
                            self_object:  target
    world.push binding
    result = eval_ast(binding.ast)
    world.pop
    result
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

  def inspect_const_tree(const=world.toplevel_namespace, depth=1, already_seen=[])
    return '' if already_seen.include? const
    already_seen << const
    padding = ('  ' * depth)
    result  = ""
    result << padding << '::' << const.name.to_s << "\n"

    const.each_method do |name, method|
      result << padding << '  #' << name.to_s << "\n"
    end

    const.each_constant do |name, child|
      if child.kind_of? RbClass
        result << inspect_const_tree(child, depth+1, already_seen)
      else
        result << padding << '  ::' << name.to_s << "\n"
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

