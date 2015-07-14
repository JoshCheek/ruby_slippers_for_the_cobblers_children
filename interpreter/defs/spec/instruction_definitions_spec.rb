require 'defs'

RSpec.describe Defs::Instructions do
  def parse_instructions(instructions_string)
    Defs::Instructions.parse(instructions_string)
  end

  it 'parses instructions, recording the name, args, and body' do
    instructions = parse_instructions <<-DEFS.gsub(/^    /, "")
    getKey(toRegister, hashRegister, key)
      {"toRegister":   <%= toRegister.to_json %>,
       "hashRegister": <%= hashRegister.to_json %>,
       "key":          <%= key.to_json %>,
      }
    other()
      lol
    DEFS

    expect(instructions.keys).to eq([:getKey, :other])

    expect(instructions[:getKey][:argnames]).to eq ["toRegister", "hashRegister", "key"]
    expect(instructions[:getKey][:body]).to eq \
      %'{"toRegister":   "toRegister",\n'+
      %' "hashRegister": "hashRegister",\n'+
      %' "key":          "key",\n'+
      %'}'

    expect(instructions[:other][:argnames]).to eq []
    expect(instructions[:other][:body]).to eq "lol"
  end
end
