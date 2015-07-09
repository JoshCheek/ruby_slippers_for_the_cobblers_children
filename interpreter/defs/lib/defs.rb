class Defs
  def self.from_string(string)
    new parse(string)
  end

  ATTRIBUTES = [:name, :namespace, :arg_names, :desc, :register_names].freeze

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

  def self.parse(str, name: :root, args: [], namespace: [], desc: "Machine: /")
    { name:           name,
      desc:           desc || "Machine: #{["", *namespace, name].join '/'}",
      arg_names:      args,
      register_names: [],
      instructions:   [],
      namespace:      namespace,
      children:       str.split(/^(?=\w)/)
                         .map { |machine_def|
                           first, *rest = machine_def.strip.lines.map { |l| l.gsub /^  /, "" }
                           child_name,  *args = first.split(/\s+|\s*:\s*/).map(&:intern)
                           if rest.first.start_with? '>'
                             child_desc = rest.first[/(?<=> ).*/]
                             rest = rest.drop(1)
                           end

                           instr_lines     = rest.take_while { |line| line !~ /^\w+:/ }
                           rest            = rest.drop(instr_lines.length)
                           child_namespace = namespace
                           child_namespace += [name] unless name == :root
                           parse rest.join("\n"),
                                 name:      child_name,
                                 desc:      child_desc,
                                 args:      args,
                                 namespace: child_namespace
                         }
                         .each_with_object({}) { |defn, children|
                           children[defn[:name]] = defn
                         },
    }
  end

end
