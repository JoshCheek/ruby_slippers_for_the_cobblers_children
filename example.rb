require 'parser/current'

module MyRuby
  class Instruction
    def initialize(options={})
    end

    def inspect
      "#<Instruction for #{self.class.name}>"
    end
  end

  module HasAst
    attr_accessor :ast
    def initialize(options)
      self.ast = options.fetch(:ast)
      super
    end
  end

  module Instructions
    BeginSequence          = Class.new(Instruction).include(HasAst)
    EndSequence            = Class.new(Instruction).include(HasAst)
    OpenClass              = Class.new(Instruction).include(HasAst)
    CloseClass             = Class.new(Instruction).include(HasAst)
    ConstantLookup         = Class.new(Instruction).include(HasAst)
    ToplevelConstantLookup = Class.new(Instruction)
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
      ast.children.each { |child| walk child, instructions }
      instructions << Instructions::EndSequence.new(ast: ast)
    when :class
      instructions << Instructions::OpenClass.new(ast: ast)
      name, superclass, body = ast.children
      walk name, instructions
      if superclass
        walk superclass, instructions
      else
        instructions << Instructions::ToplevelConstantLookup.new
      end
      walk body, instructions
      instructions << Instructions::CloseClass.new(ast: ast)
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

puts instructions.map(&:inspect)

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

