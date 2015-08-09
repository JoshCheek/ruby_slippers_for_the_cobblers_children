class Defs
  class Machine
    attr_accessor :name, :namespace, :arg_names, :description, :labels, :instructions, :children

    def initialize(attributes={})
      attributes        = attributes.dup
      self.name         = attributes.delete(:name)         || ""
      self.namespace    = attributes.delete(:namespace)    || []
      self.arg_names    = attributes.delete(:arg_names)    || []
      self.description  = attributes.delete(:description)  || ""
      self.labels       = attributes.delete(:labels)       || []
      self.instructions = attributes.delete(:instructions) || []
      self.children     = (attributes.delete(:children)    || [])
                            .map { |name, child| [name, self.class.new(child)] }
                            .to_h
    end

    def [](key)
      children.fetch key do
        raise KeyError, "No key #{key.inspect} in #{children.keys.inspect}"
      end
    end

    def inspect
      attrs = [:name, :namespace, :arg_names, :description, :labels, :instructions]
                .map { |name| "\n  #{name}: #{__send__(name).inspect}" } \
                << "\n  children: #{children.keys}"
      "#<#{self.class}:#{attrs.join}\n>"
    end
  end
end
