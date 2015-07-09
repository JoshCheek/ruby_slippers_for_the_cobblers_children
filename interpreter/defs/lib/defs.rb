require 'defs/parse_machine'

class Defs
  def self.from_string(def_string)
    new ParseMachine.from_root(def_string)
  end

  ATTRIBUTES = [:name, :namespace, :arg_names, :description, :register_names, :instructions].freeze

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

  private

  attr_reader :children
end
