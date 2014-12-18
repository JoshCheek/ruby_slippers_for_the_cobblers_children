require 'parse_server'
require 'rack/test'

RSpec.describe ParseServer::App do
  include Rack::Test::Methods

  def app
    ParseServer::App
  end

  it 'can receive the code in the body or a "code" param' do
    asserter = lambda do |response|
      json = JSON.load(response.body)
      expect(json.fetch('type')).to eq 'integer'
      expect(json.fetch('value')).to eq '1'
    end
    asserter.call post('/', code: '1')
    asserter.call post('/', '1')
  end

  it 'parses the code with RawRubyToJsonable and returns a json object representing it' do
    response = post '/', code: '1+1'
    expect(response).to be_ok
    expect(response.content_type).to include 'json'
    JSON.load(response.body)
  end

  it 'returns a 400 BAD REQUEST if the code has a syntax error' do
    response = post '/', '1+'
    expect(response).to be_bad_request
    expect(response.content_type).to include 'json'
    error_message = JSON.load(response.body)
    expect(error_message['name']).to eq 'SyntaxError'
    expect(error_message['message']).to_not be_empty
    expect(error_message['backtrace']).to_not be_empty
  end
end
