require 'erb'

class Defs
  class ParseTemplate
    def self.parse(string)
      string.split(/^(?=\w)/).map { |template|
        declaration, *bodylines = template.strip.lines
        name, *argnames = declaration.split(/\W+/)
        body = parse_erb outdent(bodylines.join)
        [name.intern, {argnames: argnames, body: body}]
      }.to_h
    end

    def self.outdent(string)
      leading_whitespace = string.scan(/^\s*/).min_by(&:length)
      string.gsub(/^#{leading_whitespace}/, '')
    end

    def self.parse_erb(erb)
      ERB.new(erb, nil, "-%<>").src
    end
  end
end
