require 'defs/machine'

class Defs
  class ParseMachine
    def self.call(string)
      new(string).call
    end

    def initialize(string)
      self.string = string
    end

    def call
      self.attributes ||= begin
        { name:         ??,
          namespace:    ??,
          arg_names:    ??,
          description:  ??,
          labels:       ??,
          instructions: ??,
          children:     [],
        }
      end
    end

    private

    attr_accessor :string, :attributes
  end
end
