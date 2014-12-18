$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'parse_server'
run ParseServer::App
