class Defs
  class Template
    attr_reader :__list
    def initialize(list)
      @__list = list
      list.each do |name, definition|
        instance_eval <<-DEFINITION, "evald_template_for_#{name}"
          def #{name}(#{definition[:argnames].join(", ")})
            #{definition[:body]}
          end
        DEFINITION
      end
    end
  end
end
