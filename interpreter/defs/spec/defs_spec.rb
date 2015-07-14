require 'defs'
require 'json'


RSpec.describe Defs do
  it 'parses each segment, and renders them into the templates' do
    defs = Defs.from_string <<-DEFS.gsub(/^    /, "")
    Templates
    =========

    machines(root)
      {"root": <%= root.name.to_json %>, "firstChildName": <%= helper root %>}

    helper(root)
      <%= root.children.first.last.name.to_json %>

    instructions(instructions)
      {"instructions": [
        <% instructions.map do |name, attrs| %>
          { "name": <%= name.to_json %>,
            "args": <%= attrs[:argnames].to_json %>,
            "body": <%= attrs[:body] %>
          }
        <% end.join(", ") %>
      ]}

    Machines
    ========

    somename:
      @a <- @b.c

    Instructions
    ============

    getKey(toRegister, hashRegister, key)
      {"toRegister":   <%= toRegister.to_json %>,
       "hashRegister": <%= hashRegister.to_json %>,
       "key":          <%= key.to_json %>
      }
    DEFS

    expect(JSON.parse defs[:machines]).to eq({
      "root"           => "root",
      "firstChildName" => "somename",
    })

    expect(JSON.parse defs[:instructions]).to eq({
      "instructions" => [
        { "name" => "getKey",
          "args" => ['toRegister', 'hashRegister', 'key'],
          "body" => {
            "toRegister"   => "toRegister",
            "hashRegister" => "hashRegister",
            "key"          => "key"
          },
        },
      ]
    })
  end

  it 'parses the real definitions' do
    path = File.expand_path '../../the_machines.definitions', __dir__
    body = File.read(path)
    Defs.from_string body # shouldn't explode
  end
end
