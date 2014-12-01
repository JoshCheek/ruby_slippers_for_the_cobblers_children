# pick a default port if user hasn't
ENV['RUBY_PARSER_PORT'] ||= '3003'

# set pat
parser_bin_dir = File.expand_path('parser/bin', __dir__)
ENV['PATH'] = "#{parser_bin_dir}:#{ENV['PATH']}"

# shortcuts
task default: ['parser:test', 'interpreter:test']
task start:   'parser:server:start'
task stop:    'parser:server:stop'
task status:  'parser:server:status'
task run:     'parser:server:run'

# interpreter tasks
namespace :interpreter do
  desc 'Run interpreter test suite (server needs to be running)'
  task :test do
    sh 'haxe',
      '-main', 'ruby.RunTests',
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
    task(:run) { sh 'rackup parser/config.ru' }
  end
end
