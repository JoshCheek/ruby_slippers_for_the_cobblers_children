require 'app'
require 'rack/test'

RSpec.describe App do
  include Rack::Test::Methods

  def app
    App.new
  end

  it 'parses the code with RawRubyToJsonable and returns a json object representing it' do
    response = post '/', '1+1'
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
