class Binary
  attr_accessor :parser_pidfile, :show_help, :errors, :main, :class_paths, :outstream, :errstream
  def initialize(main:nil, show_help:false, errors:[], parser_pidfile: default_pidfile, outstream:$stdout, errstream:$stderr)
    self.parser_pidfile = parser_pidfile
    self.show_help      = show_help
    self.errors         = errors
    self.main           = main
  end

  def interpreter_root
    @interpreter_root ||= File.dirname File.dirname __FILE__
  end

  def class_paths
    @class_paths ||= ['src', 'test']
  end

  alias show_help? show_help

  def errors?
    errors.any?
  end

  def server_down?
    !server_up?
  end

  def server_up?
    File.exist? parser_pidfile
  end

  def cd_root!
    Dir.chdir interpreter_root
  end

  def command(type)
    case type
    when :run then common_command << '--interp'
    else raise "There is no command type: #{type.inspect}"
    end
  end

  def add_error(error)
    errors << error
    self
  end

  private

  def common_command
    command = ['haxe']
    command << '-main' << main if main
    class_paths.each { |cp| command << '-cp' << cp }
    command
  end

  def default_pidfile
    @pidfile ||= File.expand_path '../parser/tmp/puma.pid', interpreter_root
  end
end
