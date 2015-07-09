class Defs
  def self.from_string(string)
    new parse(string)
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
    "#<#{self.class}:#{attrs.join}\n>"
  end

  private

  attr_reader :children

  def self.parse(str, name: :root, arg_names: [], namespace: [], description: "Machine: /", instructions: [])
    { name:           name,
      description:    description || "Machine: #{["", *namespace, name].join '/'}",
      arg_names:      arg_names,
      register_names: [],
      instructions:   instructions,
      namespace:      namespace,
      children:       str.split(/^(?=\w)/)
                         .map { |machine_def|
                           first, *rest = machine_def.strip.lines.map { |l| l.gsub /^  /, "" }
                           child_name, *arg_names = first.split(/\s+|\s*:\s*/).map(&:intern)

                           if rest.first.start_with? '>'
                             child_desc = rest.first[/(?<=> ).*/]
                             rest = rest.drop(1)
                           end

                           raw_instrs = rest.take_while { |line| line !~ /^\w+:/ }
                           rest        = rest.drop(raw_instrs.length)
                           [ child_name, parse( rest.join("\n"),
                                                name:         child_name,
                                                description:  child_desc,
                                                arg_names:    arg_names,
                                                namespace:    namespace + (name == :root ? [] : [name]),
                                                instructions: parse_instructions(raw_instrs),
                                              )
                           ]
                         }.to_h
    }
  end

  def self.parse_instructions(raw_instructions)
    raw_instructions
    # but got ["/ast($ast)"]
    [[:globalToRegister, :ast, :@_1], [:runMachine, [:ast], [:@_1]]]
  end

end
