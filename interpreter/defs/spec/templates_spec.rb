require 'defs'

RSpec.describe Defs::Template do
  def parse_templates(templates_string)
    parsed = Defs::ParseTemplate.parse templates_string
    Defs::Template.new parsed
  end

  it 'returns an object with each template name as a method, taking the specified args, and filling out the body when called' do
    template = parse_templates <<-TEMPLATES.gsub(/^    /, "")
    greet(target)
      <% if target =~ /^w/ %>
        Hello, <%= target %>.
      <% else %>
        HELLO <%= scream target %>!
      <% end %>

    scream(string)
      <%= string.upcase %>
    TEMPLATES
    expect(template.greet("world").strip).to eq 'Hello, world.'
    expect(template.greet("to your little friend").strip).to eq 'HELLO TO YOUR LITTLE FRIEND!'
  end

  it 'records each template\'s name, args, and body, available from .__list' do
    template = parse_templates <<-TEMPLATES.gsub(/^    /, "")
    abc(d, e, f)
      the <% d + e + f %> body

    ghi(jkl)
      <%= jkl %>
    TEMPLATES

    expect(template.__list.length).to eq 2
    expect(template.__list[:abc][:argnames]).to eq ["d", "e", "f"]
    expect(template.__list[:ghi][:argnames]).to eq ["jkl"]
  end

  it 'is not confused by empty lines in the body'

  it 'outdents everything within control flow erb'
  # something about ending with a dash
end
