class User
  attr_reader :name
  def initialize(name)
    @name = name
  end
end

user = User.new("Josh")
puts user.name

