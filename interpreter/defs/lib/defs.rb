class Defs
  def self.parse(body,
                 current_name=:root,
                 current_desc=nil,
                 current_args=[],
                 namespace=[])
    machines = body
      .split(/^(?=\w)/)
      .map(&:strip)
      .map { |machine_def|
        first, *rest = machine_def.lines
        name, arg_string = first.split(/\s*:\s*/, 2)
        name = name.intern
        args = arg_string.split.map(&:intern)

        rest.map! { |line| line.gsub(/^  /, "") }
        if rest.first.start_with? '>'
          desc = rest.first[/(?<=> ).*/]
          rest = rest.drop(1)
        end

        instr_lines  = rest.take_while { |line| line !~ /^\w+:/ }
        # instructions = p
        rest         = rest.drop(instr_lines.length)
        child_namespace = namespace
        child_namespace += [current_name] unless current_name == :root
        parse rest.join("\n"), name, desc, args, child_namespace
      }
      .each_with_object({}) { |defn, children|
        children[defn[:name]] = defn
      }

    current_desc ||=
      "machine: " <<
        if current_name == :root
          '/'
        else
          [*namespace, current_name].map { |n| "/#{n}" }.join("")
        end

    {name:         current_name,
     desc:         current_desc,
     arg_names:    current_args,
     register_names:    [],
     instructions: [],
     namespace:    namespace,
     children:     machines,
    }
  end

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
end
