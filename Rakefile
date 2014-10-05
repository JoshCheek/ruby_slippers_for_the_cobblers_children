task default: :test

desc 'Run the tests'
task :test do
  sh 'rspec'
end

desc 'Install major deps (not Ruby, though :P)'
task :install do
  # install bundler if it isn't available
  begin
    require 'bundler'
  rescue LoadError
    sh 'gem install bundler'
  end

  # install all the gems
  sh 'bundle install'

  # install elm (language we're using for frontend)
  sh 'elm -v >/dev/null || open http://install.elm-lang.org/Elm-Platform-0.13.pkg'
end

desc 'Build the frontent code'
task :build do
  sh 'elm --make interpreter/Interpreter.elm'
end
