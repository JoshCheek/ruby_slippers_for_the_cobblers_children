# pick a default port if user hasn't
ENV['RUBY_PARSER_PORT'] ||= '3003'

# Fix PATH:
parser_bin_dir   = File.expand_path('parser/bin',   __dir__) # currently only offers ast_for, but I'm not actually using it anymore (I usually curl, anyway), so maybe delete it
ENV['PATH'] = "#{parser_bin_dir}:#{ENV['PATH']}"

# shortcuts
task default: ['parser:test', 'interpreter:test']
task start:   'parser:server:start'
task stop:    'parser:server:stop'
task status:  'parser:server:status'
task run:     'parser:server:run'

# frontend tasks
desc 'Run the frontend code'
task :frontend do
  sh 'frontend/bin/run'
end

# interpreter tasks
namespace :interpreter do
  desc 'Run interpreter test suite (server needs to be running)'
  task :test do
    cd 'interpreter' do
      sh 'env NODE_PATH=src mocha --compilers js:babel/register --bail'
      sh 'mrspec defs -I defs/lib defs/spec --fail-fast'
    end
  end

  desc 'Generate the machine definitions'
  task :definitions do
    cd 'interpreter' do
      infile            = "the_machines.definitions"
      machines_file     = "src/vm/machine_definitions.js"
      instructions_file = "src/vm/instructions.js"

      sh "defs/bin/generate -m=#{machines_file} -i=#{instructions_file} < #{infile}"
      sh "npm run exec -- " \
           "js-beautify --indent-size 2 --unescape-strings --end-with-newline --jslint-happy " \
                       "--replace #{instructions_file} " \
                       "--replace #{machines_file} "
    end
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
