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
    BeginSequence          = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndSequence            = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    OpenClass              = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    CloseClass             = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    BeginConstLookup       = Class.new(Instruction).include(HasAst).include(Indentation::Indent)
    EndConstLookup         = Class.new(Instruction).include(HasAst).include(Indentation::DeDent)

    ToplevelConstantLookup = Class.new(Instruction).include(Indentation::NoOp)
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
  puts "  " * depth + instruction.inspect
  if instruction.indent?
    depth + 1
  elsif instruction.dedent?
    depth - 1
  else
    depth
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

