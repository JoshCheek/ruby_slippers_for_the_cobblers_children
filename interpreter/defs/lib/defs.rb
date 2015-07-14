require 'defs/machine'
require 'defs/parse_machine'

require 'defs/template'
require 'defs/parse_template'

require 'defs/instruction_definitions'

class Defs
  def self.from_string(defstring)
    defs             = parse_document(defstring)
    machine_code     = defs[:templates].machines(defs[:machines])
    instruction_code = defs[:templates].instructions(defs[:instructions])
    {machines: machine_code, instructions: instruction_code}
  end

  def self.parse_document(defstring)
    defstring
      .gsub(/^(.*)\n=+$/, "==\n\\1")
      .split(/^==\n?$/)
      .reject(&:empty?)
      .map { |section|
        title, *section_lines = section.strip.lines
        title, section = title.downcase.chomp, section_lines.join
        case title
        when 'templates'    then [:templates,    Template.new(ParseTemplate.parse section)]
        when 'machines'     then [:machines,     Machine.new(ParseMachine.from_string section)]
        when 'instructions' then [:instructions, InstructionDefinitions.parse(section)]
        else raise "Unknown title: #{title.inspect}"
        end
      }.to_h
  end
end
