class Binary
  attr_accessor :parser_pidfile, :show_help, :errors, :main, :class_paths, :outstream, :errstream, :help_screen
  def initialize(main:nil, show_help:false, errors:[], parser_pidfile: default_pidfile, outstream:, errstream:, help_screen:)
    self.parser_pidfile = parser_pidfile
    self.help_screen    = help_screen
    self.outstream      = outstream
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

  def command(type, *params)
    case type
    when :run then common_command << '--interp'
    when :xml then (common_command << '-xml').concat(params)
    else raise "There is no command type: #{type.inspect}"
    end
  end

  def add_error(error)
    errors << error
    self
  end

  def print_errors
    puts red: "Errors:"
    errors.each do |err_msg|
      err_msg.each_line do |line|
        puts "  * #{line}"
      end
    end
  end

  def puts(*messages)
    messages.each do |message|
      case message
      when String then outstream.puts message
      when Hash   then message.each { |colour, message| puts __send__(colour, message) }
      else raise "huh?: #{message.inspect}"
      end
    end
  end

  def print_help
    puts help_screen % self.class.colours
  end

  def self.colours
    { black:   "\e[30m",
      red:     "\e[31m",
      green:   "\e[32m",
      orange:  "\e[33m",
      blue:    "\e[34m",
      magenta: "\e[35m",
      cyan:    "\e[36m",
      white:   "\e[37m",
      none:    "\e[39m",
    }
  end

  def colours
    self.class.colours
  end

  def none(msg=nil)
    "#{colours[:none]}#{msg}"
  end

  colours.each do |name, escape_sequence|
    define_method(name) do |msg=nil|
      msg ? "#{escape_sequence}#{msg}#{none}" : escape_sequence
    end
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
