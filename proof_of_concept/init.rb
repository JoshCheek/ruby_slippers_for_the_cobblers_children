# can I get this from rbx?

class Class
  def new(arg)
    instance = allocate
    instance.initialize(arg)
    instance
  end

  # def attr_reader(name)
  #   define_method(name) { instance_variable_get "@#{name}" }
  # end
end
