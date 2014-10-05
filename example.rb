require_relative 'interpreter'

code = <<CODE
class User
  def initialize(name)
    self.name = name
  end

  def name
    @name
  end

  def name=(name)
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
# p interpreter.parse(code)
interpreter.eval code#, visitor
puts interpreter.pretty_inspect

# (begin
#   (class
#     (const nil :User) nil
#     (begin
#       (def :initialize
#         (args
#           (arg :name))
#         (send
#           (self) :name=
#           (lvar :name)))
#       (def :name
#         (args)
#         (ivar :@name))
#       (def :name=
#         (args
#           (arg :name))
#         (ivasgn :@name
#           (lvar :name)))))
#   (lvasgn :user
#     (send
#       (const nil :User) :new
#       (str "Josh")))
#   (send nil :puts
#     (send
#       (lvar :user) :name)))
