---
title: Getting Started
---

Opal is a Ruby to JavaScript compiler, an implementation of the Ruby corelib and stdlib, and associated gems for building fast client side web applications in Ruby.

## Installation

Opal is available as a gem, and can be installed via:

```
$ gem install opal
```

Or added to your Gemfile as:

```ruby
gem 'opal'
```

## Getting started with Opal

### Opal.compile

At its very core, Opal provides a simple method of compiling a string of Ruby into JavaScript that can run on top of the Opal runtime, provided by `opal.js`:

```ruby
Opal.compile("[1, 2, 3].each { |a| puts a }")
# => "(function() { ... })()"
```

### Opal::Builder

To build more complex projects, such as files that require other files, you can use `Opal::Builder`.  You can call `build` directly on `Opal::Builder`:

```ruby
Opal::Builder.build('/path/to/file.rb').to_s
```

Or you can create a new `Opal::Builder` instance and call `build` on it:

```ruby
builder = Opal::Builder.new(:stubs => ['opal'])
builder.append_paths('assets/js')
builder.use_gem('opal-jquery')
builder.build('/path/to/file.rb').to_s
```

In both cases, the output of `build(file).to_s` will be a string of JavaScript code.

By default `Opal::Builder` will include the runtime in the resulting JavaScript code, if you do not want that, use the `:stubs=>['opal']` option as shown above.

### CLI

Opal includes an executable that can be used to build Opal projects, using the `-c` option:

```sh
opal -c /path/to/file.rb > /path/to/file.js
```

By default `opal` will include the runtime in the resulting JavaScript code, if you do not want that, use the `-O` option.

### Sprockets

`Opal` includes sprockets support to sprockets for compiling Ruby (and erb) assets, and treating them as first class JavaScript citizens. It works in a similar way to CoffeeScript, where JavaScript files can simply require Ruby sources, and Ruby sources can require JavaScript and other Ruby files.

This relies on the Opal load path. Any gem containing Opal code registers that directory to the Opal load path. Opal will then use all Opal load paths when running sprockets instances. For Rails applications, opal-rails does this automatically. For building a simple application, we have to do this manually.

### Tilt

Opal includes tilt support, so that you can compile Ruby files to JavaScript using tilt:

```ruby
require 'tilt/opal'
Tilt.new('/path/to/file.rb').render
```

By default, this uses `Opal.compile`, so it doesn't handle require calls inside the file.  You can use the `:build` option to use `Opal::Builder`, so that requires will work correctly:

```ruby
require 'tilt/opal'
Tilt.new('/path/to/file.rb', :build => true).render
```

For more complete control, you can use the `:builder` option to pass in an `Opal::Builder` instance:

```ruby
require 'tilt/opal'
builder = Opal::Builder.new(:stubs => ['opal'])
Tilt.new('/path/to/file.rb', :builder => builder).render
```
