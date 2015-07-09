class Defs
  def self.from_string(string)
    new parse string,
              name:      :root,
              desc:      "Container for all the machines",
              args:      [],
              namespace: []
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

  def self.description_for(attrs)
    ns   = attrs.fetch :namespace
    name = attrs.fetch :name
    desc = attrs.fetch :desc, nil
    desc = "Machine: " << ["", *ns, name].join("/")
  end

  def self.parse(body, attrs)
    namespace    = attrs.fetch :namespace
    current_args = attrs.fetch :args
    current_name = attrs.fetch :name

    { name:           current_name,
      desc:           description_for(attrs),
      arg_names:      current_args,
      register_names: [],
      instructions:   [],
      namespace:      namespace,
      children:       body
                        .split(/^(?=\w)/)
                        .map(&:strip)
                        .map { |machine_def|
                          first, *rest = machine_def.lines.map { |l| l.gsub /^  /, "" }
                          name,  *args = first.split(/\s+|\s*:\s*/).map(&:intern)
                          if rest.first.start_with? '>'
                            desc = rest.first[/(?<=> ).*/]
                            rest = rest.drop(1)
                          end

                          instr_lines     = rest.take_while { |line| line !~ /^\w+:/ }
                          rest            = rest.drop(instr_lines.length)
                          child_namespace = namespace
                          child_namespace += [current_name] unless current_name == :root
                          parse rest.join("\n"),
                                name:      name,
                                desc:      desc,
                                args:      args,
                                namespace: child_namespace
                        }
                        .each_with_object({}) { |defn, children|
                          children[defn[:name]] = defn
                        },
    }
  end

end
