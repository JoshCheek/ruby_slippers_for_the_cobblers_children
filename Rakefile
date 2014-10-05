task default: :test

desc 'Run the tests'
task :test do
  sh 'rspec'
end

desc 'install major deps (not Ruby, though :P)'
task :install do
  begin
    require 'bundler'
  rescue LoadError
    sh 'gem install bundler'
  end
  sh 'bundle install'
end
