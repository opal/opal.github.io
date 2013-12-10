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
    also <b>very small</b>.
  </p>
  <p>
    Opal is <a href="http://github.com/opal/opal">hosted on github</a>,
    has a Freenode IRC channel at <code>#opal</code>, a <a href="https://groups.google.com/forum/#!forum/opalrb">mailing list</a>, and on twitter
    <a href="http://twitter.com/opalrb">@opalrb</a>.
  </p>

  <br>
  <a class="btn btn-default" href="/docs">Opal Documentation</a>.
</div>

## Getting Started

### Overview

```ruby
class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def admin?
    @name == 'Admin'
  end
end

user = User.new('Bob')
puts user
puts user.admin?
```

<a href="/try" class="btn btn-default">Try this code in your browser »</a>

### Installation

Install Opal from RubyGems:

```text
$ gem install opal
```

Or include it in your `Gemfile` for Bundler:

```ruby
gem 'opal'
```
