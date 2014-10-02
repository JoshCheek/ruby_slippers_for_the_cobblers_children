require_relative 'interpreter'

code = <<CODE
class User
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

user = User.new("Josh")
puts user.name
CODE

visitor = lambda do |*args|
  puts "ARGS: #{args.inspect}"
end


interpreter = Interpreter.new
interpreter.eval code#, visitor

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

