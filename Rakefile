task default: :test

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
