---
title: "Opal: Ruby to Javascript Compiler"
---

<div class="page-header">
  <img src='https://secure.gravatar.com/avatar/88298620949a6534d403da2e356c9339?s=420&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-org-420.png' alt='' style='float:right;margin-top:-24px' width='128' height='128' />
  <h1>
    Opal
  </h1>
  <p>
    <b>Opal is a ruby to javascript compiler.</b> It is source-to-source, making it
    <b>fast</b> as a runtime. Opal <b>includes a compiler</b> (which can be run in any
    browser), a corelib and runtime implementation. The corelib/runtime is
    also <b>very small</b> (10.8kb gzipped).
  </p>
  <p>
    Opal is <a href="http://github.com/opal/opal">hosted on github</a>,
    has a Freenode IRC channel at <code>#opal</code>, and on twitter
    <a href="http://twitter.com/opalrb">@opalrb</a>.
  </p>
</div>

<div class="row-fluid">
  <div class="span4">
    <h2>Ruby in the Browser</h2>
    <p>
      Opal compiles ruby ahead of time into javascript to run on the
      client. Opal supports blocks, procs, classes, modules and more!
    </p>
  </div>

  <div class="span4">
    <h2>method_missing</h2>
    <p>
      Opal fully supports `method_missing` on all objects and classes to
      allow full metaprogramming on the client.
    </p>
  </div>

  <div class="span4">
    <h2>Native class</h2>
    <p>
      `Native` is a class provided to wrap native objects so that their
      properties and methods can be called directly from ruby code.
    </p>
  </div>
</div>

<div class="row-fluid">
  <div class="span4">
    <h2>Inline Javascript</h2>
    <p>
      X-Strings in opal are used to write javascript within ruby code,
      making it easier to call and wrap javascript code within your code.
    </p>
  </div>

  <div class="span4">
    <h2>opal-parser</h2>
    <p>
      `opal-parser.js` allows you to compile and run ruby code directly
      from script tags or strings for runtime `eval()` support.
    </p>
  </div>

  <div class="span4">
    <h2>Easy Debugging</h2>
    <p>
      Opal compiles into clean, readable code to help with debugging.
      Variables, ivars and method names are preserved in the output.
    </p>
  </div>
</div>

### Getting Started

#### Overview

```ruby
[1, 2, 3, 4].each do |a|
  puts a
end

class Foo
  attr_accessor :name

  def method_missing(sym, *args, &block)
    puts "You tried to call: #{sym}"
  end
end

adam = Foo.new
adam.name = 'Adam Beynon'
puts adam.name
adam.do_task

  # Output (in your browser console):
  #
  #   1
  #   2
  #   3
  #   4
  #   Adam Beynon
  #   You tried to call: do_task
```

[Try this code in your browser!](/try)

#### Installation

Install Opal from RubyGems:

```text
$ gem install opal
```

Or include it in your `Gemfile` for Bundler:

```ruby
gem 'opal'
```
