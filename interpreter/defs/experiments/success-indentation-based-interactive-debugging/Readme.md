What
----

A context sensitive grammar purely to practice parsing.

Shout out to [Hsing-Hui Hsu](https://twitter.com/SoManyHs) for her
[RubyConf talk](http://confreaks.tv/videos/rubyconf2015-time-flies-like-an-arrow-fruit-flies-like-a-banana-parsers-for-great-good),
the mechanical walkthrough of building the tree was what ultimately got me to succeed for the first time.
This is the second time, to see if I could take it up a notch by adding whitespace sensitive nesting.


Grammar
-------

It parses this indentation-based format:

```
fn(arg)
  a0
    a0.0
      a0.0.0
  b0
    b0.0
    b0.1
      b0.1.0
    b0.2
```


BNF
---

```
root:          statements eos
statements:    statement*
statement:     (function | nested_line | line) "\n"?
function:      identifier argument_list "\n" indent statements outdent
argument_list: '(' identifier ')'
identifier:    /[\w\d.]+/
nested_line:   line "\n" indent statements outdent
line:          identifier
```


License
-------

[Just do what the fuck you want to](http://www.wtfpl.net/about/).
