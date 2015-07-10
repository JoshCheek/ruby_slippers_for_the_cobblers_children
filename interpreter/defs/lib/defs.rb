require 'json'
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

  def to_json
    as_json.to_json
  end

  def as_json
    children   = children().map { |k, v| [k, v.as_json] }.to_h
    key_values = ATTRIBUTES.map { |name| [name, @defn.fetch(name)] }
    key_values << [:children, children]
    key_values.to_h
  end

  private

  attr_reader :children
end
