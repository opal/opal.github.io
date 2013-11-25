---
title: Getting started with Opal
author: Adam Beynon
tags: Opal, Sprockets
---

# Getting started with Opal

[Opal](http://github.com/opal/opal) is a source-to-source, ruby to javascript
compiler. It includes an implementation of the ruby corelib, as well as
various extensions for browser interactions, testing and client mvc, supplied
as gems.

At its very core, opal provides a simple method of compiling a string of ruby
into javascript that can run on top of the opal runtime, provided by opal.js:

```ruby
Opal.compile("[1, 2, 3].each { |a| puts a }")
# => "(function() { ... })()"
```

The produced javascript can then run in any browser. This only half solves the
problem. Opal was built to run larger client side applications, and to replace
javascript as the implementation language of these rich web applications. Where
opal provides the compiler, [opal-sprockets](http://github.com/opal/opal-sprockets)
provides the build system to combine multiple ruby source files into one output
file to run in the browser.

## Using opal-sprockets

`opal-sprockets` adds support to sprockets for compiling ruby (and erb) assets,
and treating them as first class javascript citizens. It works in a similar way
to coffeescript, where javascript files can simply `require` ruby sources, and
ruby sources can `require` javascript and other ruby files.

This relies on the opal load path. Any gem containing opal code registers that
directory to the opal load path. `opal-sprockets` will then use all opal load
paths when running sprockets instances. For rails applications,
[opal-rails](http://github.com/opal/opal-rails) does this automatically. For
building a simple application, we have to do this manually. So add opal-sprockets
to a `Gemfile` to get started:

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'opal'
gem 'opal-sprockets'
```

Next, we can use sprockets inside a simple rack app to get assets automatically
re-compiling between page loads. Add this to a `config.ru`:

```ruby
# config.ru
require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.main = 'application'
  s.append_path 'app'
}
```

The server configuration has two options set. Firstly, `main` is the top-level
file that should be included by default as the application entry-point. It is
`application` purely to mirror `rails`, but it can be replaced with any target
file you wish. Secondly, the `append_path()` call adds a custom directory to the
opal and sprockets load paths. Again, rails adds various `app/assets/javascripts`
directories for you, but in a custom application this is left to the user.

Next, we must make our top level `app/application.rb` file:

```ruby
# app/application.rb
require 'opal'

[1, 2, 3].each { |a| puts a }
```

The `require "opal"` line is needed as it includes the opal runtime and corelib.
Sprockets treats opal just as any other asset, so it is necessary to inlcude the
corelib in this manner. Once loaded, we will be able to run any ruby code as
seen below that line.

To run the application, start the rack server:

```
bundle exec rackup
```

Next, open `http://localhost:9292` in any web browser. If you view the development
console, you should see the three numbers printed.

## Adding more ruby sources

If you are familiar with sprockets, adding more ruby files should be simple. Add
an `app/user.rb` file to the mix:

```ruby
# app/user.rb
class User
  def initialize(name)
    @name = name
  end

  def admin?
    @name == "Adam"
  end
end
```

And include it in your application:

```ruby
# app/application.rb
require 'opal'
require 'user'

user = User.new('Bob')
puts user.admin?
# => false
```

Simply refresh the page in the browser, and view the console.
