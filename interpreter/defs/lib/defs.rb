class Defs
  def self.from_string(string)
    new parse_body(string)
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

  def self.parse_body(str, name: :root, args: [], ns: [], desc: "Machine: /", instrs: [])
    child_ns = [*ns, name].tap { |ns| ns.pop if name == :root }
    { name:           name,
      description:    desc || "Machine: #{["", *ns, name].join '/'}",
      arg_names:      args,
      register_names: [],
      instructions:   instrs,
      namespace:      ns,
      children:       str.split(/^(?=\w)/)
                         .map { |s| parse_defn s.strip, child_ns }
                         .map { |c| [c[:name], c] }
                         .to_h
    }
  end

  def self.parse_defn(str, ns)
    first, *rest = str.strip.lines.map { |l| l.gsub /^  /, "" }
    name,  *args = first.split(/\s+|\s*:\s*/).map(&:intern)

    if rest.first.start_with? '>'
      desc = rest.first[/(?<=> ).*/]
      rest = rest.drop(1)
    end

    instrs = rest.take_while { |line| line !~ /^\w+:/ }
    body   = rest.drop(instrs.length).join("\n")

    parse_body body, name: name, desc: desc, args: args, ns: ns, instrs: parse_instrs(instrs)
  end

  def self.parse_instrs(instrs)
    instrs
    # but got ["/ast($ast)"]
    [[:globalToRegister, :ast, :@_1], [:runMachine, [:ast], [:@_1]]]
  end
end
