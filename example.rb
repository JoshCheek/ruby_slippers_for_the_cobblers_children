require 'parser/current'

module MyRuby
  class Instruction
    def initialize(options={})
    end

    def inspect
      "<#{self.class.name.split("::").last}>"
    end
  end

  module HasAst
    attr_accessor :ast
    def initialize(options)
      self.ast = options.fetch(:ast)
      super
    end
  end

  module HasName
    attr_accessor :name
    def initialize(options)
      self.name = options.fetch(:name)
      super
    end
  end

  module Indentation
    module Indent
      def indent?() true  end
      def dedent?() false end
    end
    module DeDent
      def indent?() false end
      def dedent?() true  end
    end
    module NoOp
      def indent?() false end
      def dedent?() false end
    end
  end

  module Instructions
    BeginSequence                   = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndSequence                     = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    OpenClass                       = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    CloseClass                      = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginConstLookup                = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndConstLookup                  = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginMethodCall                 = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndMethodCall                   = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginFindReceiver               = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndFindReceiver                 = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    SetMethodName                   = Class.new(Instruction).include(HasAst).include(Indentation::Indent)

    BeginAddArgs                    = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndAddArgs                      = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginAddArg                     = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndAddArg                       = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginDefineMethod               = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndDefineMethod                 = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginBody                       = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndBody                         = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginParameters                 = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndParameters                   = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginInstanceVariableAssignment = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndInstanceVariableAssignment   = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginLocalVariableAssignment    = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndLocalVariableAssignment      = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    RequiredParameter               = Class.new(Instruction).include(HasAst).include(Indentation::Indent).include(HasName)
    SetInstanceVariableName         = Class.new(Instruction).include(HasAst).include(Indentation::Indent).include(HasName)
    SetLocalVariableName            = Class.new(Instruction).include(HasAst).include(Indentation::Indent).include(HasName)

    GetSymbol                       = Class.new(Instruction).include(Indentation::NoOp).include(HasAst)
    Self                            = Class.new(Instruction).include(Indentation::NoOp)
    ToplevelConstantLookup          = Class.new(Instruction).include(Indentation::NoOp)
    LookupLocalVariable             = Class.new(Instruction).include(Indentation::NoOp).include(HasAst).include(HasName)
  end

  def self.parse(raw_code)
    buffer                             = Parser::Source::Buffer.new('something')
    buffer.source                      = raw_code
    builder                            = Parser::Builders::Default.new
    builder.emit_file_line_as_literals = false
    parser                             = Parser::CurrentRuby.new builder
    parser.parse buffer
  end

  def self.walk(ast, instructions=[])
    case ast.type
    when :begin
      instructions << Instructions::BeginSequence.new(ast: ast)
      ast.children.each { |child| self.walk(child, instructions) }
      instructions << Instructions::EndSequence.new(ast: ast)
    when :class
      instructions << Instructions::OpenClass.new(ast: ast)
      name, superclass, body = ast.children
      self.walk(name, instructions)
      if superclass
        self.walk(superclass, instructions)
      else
        instructions << Instructions::ToplevelConstantLookup.new
      end
      self.walk(body, instructions)
      instructions << Instructions::CloseClass.new(ast: ast)
    when :const
      instructions << Instructions::BeginConstLookup.new(ast: ast)
      namespace, value = ast.children
      if namespace
        self.walk(namespace, instructions)
      else
        instructions << Instructions::ToplevelConstantLookup.new
      end
      instructions << Instructions::EndConstLookup.new(ast: ast)
    when :send
      instructions << Instructions::BeginMethodCall.new(ast: ast)
      instructions << Instructions::BeginFindReceiver.new(ast: ast)
      receiver, name, *args = ast.children
      if receiver
        self.walk(receiver, instructions)
      else
        instructions << Instructions::Self.new(ast: receiver)
      end
      instructions << Instructions::EndFindReceiver.new(ast: ast)
      instructions << Instructions::SetMethodName.new(ast: name)
      instructions << Instructions::BeginAddArgs.new(ast: args)
      args.each do |arg|
        instructions << Instructions::BeginAddArg.new(ast: arg)
        self.walk(arg, instructions)
        instructions << Instructions::EndAddArg.new(ast: arg)
      end
      instructions << Instructions::EndAddArgs.new(ast: args)
      instructions << Instructions::EndMethodCall.new(ast: ast)
    when :sym
      instructions << Instructions::GetSymbol.new(ast: ast)
    when :def
      instructions << Instructions::BeginDefineMethod.new(ast: ast)
      method_name, args, body = ast.children
      instructions << Instructions::SetMethodName.new(ast: ast) # used in more than one place, is this okay?
      self.walk(args, instructions)
      instructions << Instructions::BeginBody.new(ast: ast)
      if body
        self.walk(body, instructions)
      else
        instructions << Instructions::NilFromNothing.new(ast: ast)
      end
      instructions << Instructions::EndBody.new(ast: ast)
      instructions << Instructions::EndDefineMethod.new(ast: ast)
    when :args
      instructions << Instructions::BeginParameters.new(ast: ast)
      ast.children.each { |child| self.walk(child, instructions) }
      instructions << Instructions::EndParameters.new(ast: ast)
    when :arg
      instructions << Instructions::RequiredParameter.new(ast: ast, name: ast.children.first)
    when :ivasgn
      name, value = ast.children # in multiple assignment, this is not true
      instructions << Instructions::BeginInstanceVariableAssignment.new(ast: ast)
      instructions << Instructions::SetInstanceVariableName.new(ast: ast, name: name)
      self.walk(value, instructions)
      instructions << Instructions::EndInstanceVariableAssignment.new(ast: ast)
    when :lvasgn
      name, value = ast.children # in multiple assignment, this is not true
      instructions << Instructions::BeginLocalVariableAssignment.new(ast: ast)
      instructions << Instructions::SetLocalVariableName.new(ast: ast, name: name)
      self.walk(value, instructions)
      instructions << Instructions::EndLocalVariableAssignment.new(ast: ast)
    when :lvar
      instructions << Instructions::LookupLocalVariable.new(ast: ast, name: name)
    when :str
    else
      raise "DID NOT HANDLE #{ast.inspect}"
    end
    instructions
  end
end

raw_code = <<CODE
class User
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

user = User.new("Josh")
puts user.name
CODE

ast          = MyRuby.parse(raw_code)
instructions = MyRuby.walk ast

instructions.inject(0) do |depth, instruction|
  depth -= 1 if instruction.dedent?
  puts "  " * depth + instruction.inspect
  depth += 1 if instruction.indent?
  depth
end

# >> (begin
# >>   (class
# >>     (const nil :User) nil
# >>     (begin
# >>       (send nil :attr_reader
# >>         (sym :name))
# >>       (def :initialize
# >>         (args
# >>           (arg :name))
# >>         (ivasgn :@name
# >>           (lvar :name)))))
# >>   (lvasgn :user
# >>     (send
# >>       (const nil :User) :new
# >>       (str "Josh")))
# >>   (send nil :puts
# >>     (send
# >>       (lvar :user) :name)))

