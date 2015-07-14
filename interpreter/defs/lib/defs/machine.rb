class Defs
  class Machine
    ATTRIBUTES = [:name, :namespace, :arg_names, :description, :instructions].freeze

    def initialize(defn)
      @defn = defn
      @children = defn.fetch(:children).map { |name, child| [name, self.class.new(child)] }.to_h
    end

    ATTRIBUTES.each do |attr|
      define_method(attr) { @defn.fetch attr }
    end

    def [](key)
      children.fetch key do
        raise KeyError, "No key #{key.inspect} in #{children.keys.inspect}"
      end
    end

    def inspect
      attrs = ATTRIBUTES.map do |name|
        "\n  #{name}: #{@defn.fetch(name).inspect}"
      end
      attrs << "\n  children: #{children.keys}"
      "#<#{self.class}:#{attrs.join}\n>"
    end

    attr_reader :children
  end
end
