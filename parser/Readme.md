Parser
======

This code implements the parser. It's done in Ruby b/c this problem has been solved a few times in Ruby,
so the interpreter can call out to it and get the ast in a JSON format, and not have to deal with the
details of parsing.

* To get dependencies `bundle`
  * If that fails, first run `gem install bundler`
* To run tests `rake parser:test`
* For server tasks `rake -T server`
* You can choose your own port by setting `RUBY_PARSER_PORT` environment variable
