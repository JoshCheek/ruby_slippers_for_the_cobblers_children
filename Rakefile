task default: :test

desc 'Start the server in dev mode'
task :server do
  sh "rackup config.ru -p #{ENV.fetch 'RUBY_PARSER_PORT', 3003}"
end

task test: ['test:server', 'test:interpreter']
namespace :test do
  desc 'Run the server tests'
  task :server do
    sh 'rspec'
  end

  desc 'Run the interpreter tests'
  task :interpreter do
    raise 'Not implemented' # need to figure out how to run tests in haxe
  end
end
