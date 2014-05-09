---
title: "Opal: Ruby to Javascript Compiler"
---

<div class="jumbotron opal-front-jumbo">
  <img src='https://secure.gravatar.com/avatar/88298620949a6534d403da2e356c9339?s=420&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-org-420.png' alt='' style='float:right;margin-top:-24px' width='128' height='128' />
  <div class="page-header">
    <h1>Opal <small>Ruby to Javascript Compiler</small></h1>
    <p>It is source-to-source, making it fast as a runtime. Opal includes a compiler (which can be run in any browser), a corelib and runtime implementation. The corelib/runtime is also very small.</p>
    <p>
      <a href="/docs" class="btn btn-primary btn-lg" role="button"><i class="ion-ios7-copy"></i> Opal Documentation</a>
    </p>
  </div>
</div>

<div class="page-header">
  <p>
    Opal is <a href="http://github.com/opal/opal">hosted on github</a>,
    has a Freenode IRC channel at <code>#opal</code>, a <a href="https://groups.google.com/forum/#!forum/opalrb">mailing list</a>, and on twitter
    <a href="http://twitter.com/opalrb">@opalrb</a>.
  </p>
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
