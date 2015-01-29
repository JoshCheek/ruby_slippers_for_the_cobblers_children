# !! CAN'T USE THIS YET !!
#
# Went through the effort of figuring out how to do this, hoping to gain access to RTTI
# and other things. There's a bug on the development branch, though, that causes
# it to explode when accessing standard file descriptors. Commented on the in-progress
# PR to fix it: https://github.com/HaxeFoundation/haxe/pull/3763


# -----  Helper code -----
require 'open3'
require 'shellwords'
module Shell
  attr_accessor :outstream

  def dir?(dirname)
    sh 'test', '-d', dirname
  end

  def cd(dirname)
    print_sh 'cd', dirname
    Dir.chdir dirname
  end

  def mkdir(*args)
    sh 'mkdir', *args
  end

  def git(*args)
    sh "git", *args
  end

  def make(*args)
    sh 'make', *args
  end

  def sed(*args)
    sh 'sed', *args
  end

  def sh(*command)
    print_sh *command
    system *command or exit!
  end

  def print_sh(*command)
    program, *args = command.map { |arg| arg.to_s.chomp }
    outstream.puts "\e[35m#{program}\e[39m#{args.map { |arg| " \e[36m#{arg}\e[39m" }.join('')}"
  end

  def title(title)
    outstream.puts "\e[37m=====\e[92m  #{title}  \e[37m=====\e[39m"
  end

  def step(step_name)
    outstream.puts "\e[34m#{step_name}\e[39m"
  end

  def fail_script(reason, status=1)
    outstream.puts "\e[31m#{reason}\e[39m"
    exit status
  end
end

# -----  Script  -----
extend Shell
self.outstream = $stdout
root           = File.expand_path __dir__
source_dir     = File.join root, 'source'
install_dir    = "#{root}/built"

title 'Building haxe source'
step 'setup'
cd root
mkdir '-p', "#{install_dir}/bin"


step 'Getting latest code'
if dir? source_dir
  cd source_dir
  git 'pull'
else
  git 'clone', 'https://github.com/HaxeFoundation/haxe.git', source_dir
  cd source_dir
end

step 'Verifying repo is unmodified'
git 'status', '--short'
sh 'test -z "$(git status --porcelain)"' or # I know this is stupid, but I spent a long time trying to find a better way -.-
  fail_script 'Working tree is dirty!'

step 'Updating to correct branch and submodule'
git 'checkout', 'development'
git 'submodule', 'update', '--init', '--recursive'


step 'Fixing Makefile to install locally'
sed '-i', '', '-E', "/^INSTALL_DIR=/s,/usr,#{install_dir},", 'Makefile'

step 'Building the repo'
make or fail_script 'Make failed!'

step 'Installing the repo'
make 'install' or fail_script 'make install failed!'

step 'Cleaning up'
make 'clean'
git 'checkout', '--', 'Makefile'
