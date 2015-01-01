# pick a default port if user hasn't
ENV['RUBY_PARSER_PORT'] ||= '3003'

# set PATH
parser_bin_dir = File.expand_path('parser/bin', __dir__)
ENV['PATH'] = "#{parser_bin_dir}:#{ENV['PATH']}"

# shortcuts
task default: ['parser:test', 'interpreter:test']
task start:   'parser:server:start'
task stop:    'parser:server:stop'
task status:  'parser:server:status'
task run:     'parser:server:run'

# frontend tasks
desc 'Compiles and runs all frontend code'
task frontend: ['frontend:cpp:run', 'frontend:java:run']

namespace :frontend do
  namespace :cpp do
    desc 'Compile the interpreter to c++'
    task :compile do
      ENV['PATH'] = '/usr/bin:' << ENV['PATH'] # b/c I'm accidentally overriding bins it uses to compile (https://github.com/JoshCheek/dotfiles/blob/485fd3fcdcaf5714b8744a39b58828784dac8d87/bin/strip)
      sh 'haxe',
        '-main', 'RubyLib',
        '-cp',   'frontend',
        '-cp',   'interpreter/src',
        '-cpp',  'frontend/cpp'
    end

    desc 'Run the frontend\'s c++ interpreter'
    task run: 'frontend:cpp:compile' do
      sh 'frontend/cpp/RubyLib'
    end
  end

  namespace :java do
    desc 'Compile the interpreter to Java'
    task :compile do
      sh 'haxe',
        '-main', 'RubyLib',
        '-cp',   'frontend',
        '-cp',   'interpreter/src',
        '-java', 'frontend/java'
    end

    desc 'Run the frontend\'s Java interpreter'
    task run: 'frontend:java:compile' do
      sh 'java', '-jar', 'frontend/java/RubyLib.jar'
    end
  end

  namespace :neko do
    desc 'Run the frontend\'s code with neko'
    task :run do
      sh 'haxe',
        '-main', 'RubyLib',
        '-cp',   'frontend',
        '-cp',   'interpreter/src',
        '--interp'
    end
  end

  namespace :flash do
    desc 'Compile the interpreter to flash'
    task :compile do
      sh 'haxe',
        '-main', 'RubyLib',
        '-cp',   'frontend',
        '-cp',   'interpreter/src',
        '-swf',  'frontend/RubyLib.swf'
    end

    desc 'Run the frontend\'s flash interpreter'
    task run: 'frontend:flash:compile' do
      raise "I don't know how to runs swf files :/
             presumably the browser can do it, but it shows nothing.
             Perhaps b/c it's printing to some stream that isn't printed on the screen"
    end
  end
end

# interpreter tasks
namespace :interpreter do
  desc 'Run interpreter test suite (server needs to be running)'
  task :test do
    sh 'haxe',
      '-main', 'RunTests',
      '-cp',   'interpreter/src',
      '-cp',   'interpreter/test',
      '--interp'
  end
end

# parser tasks
namespace :parser do
  desc 'Run interpreter test suite'
  task :test do
    sh 'rspec',
      '-I',        'parser/lib',
      '-I',        'parser/spec',
      '--pattern', 'parser/spec/**/*_spec.rb',
      '--format',  'documentation',
      '--colour'
  end

  namespace :server do
    def self.puma(command)
      sh "pumactl --config-file parser/puma_config.rb #{command}"
    end

    desc 'Ensure the server is running'
    task(:start) { puma 'start' }

    desc 'Ensure the server is stopped'
    task(:stop) { puma 'stop' }

    desc 'Restart the server'
    task(:restart) { puma 'restart' }

    desc 'Report the status of the server'
    task(:status) { puma 'status' }

    desc 'Run the server in this process'
    task(:run) { sh "rackup parser/config.ru -p #{ENV.fetch 'RUBY_PARSER_PORT'}" }
  end
end
