---
title: "Opal: Ruby to JavaScript Compiler"
---

<div class="jumbotron opal-front-jumbo">
  <img src='https://secure.gravatar.com/avatar/88298620949a6534d403da2e356c9339?s=420&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-org-420.png' alt='' style='float:right;margin-top:-24px' width='128' height='128' />
  <div class="page-header">
    <h1>Opal <small>Ruby to JavaScript Compiler</small></h1>
    <p>It is source-to-source, making it fast as a runtime. Opal includes a compiler (which can be run in any browser), a corelib and runtime implementation. The corelib/runtime is also very small.</p>
    <p>
      <a href="/docs" class="btn btn-primary btn-lg" role="button"><i class="ion-ios7-copy"></i> Opal Documentation</a>
      <a target="_blank" href="http://cdn.opalrb.org/opal/current/opal.min.js" class="btn btn-secondary btn-lg" role="button"><i class="ion-android-download"></i> opal.min.js</a>
      <a target="_blank" href="http://cdn.opalrb.org/opal/current/opal-parser.min.js" class="btn btn-secondary btn-lg" role="button"><i class="ion-android-download"></i> opal-parser.min.js</a>
      <a target="_blank" href="http://cdn.opalrb.org/" class="btn btn-lg" role="button"><i class="ion-earth"></i> Use the CDN</a>
      <!-- <a href="http://cdn.opalrb.org/" class="btn btn-lg" role="button"><i class="ion-speedometer"></i> Use the CDN</a> -->
    </p>
  </div>
</div>

<div class="page-header">
  <p>
    Opal is <a href="http://github.com/opal/opal#readme">hosted on GitHub <i class="ion-social-github"></i></a>.
  </p>

  <p>
    You can join the community by chatting <i class="ion-chatbubbles"></i> on <b>Gitter</b> at <a href="https://gitter.im/opal/opal">opal/opal</a> or on Freenode IRC (channel: <code>#opal</code>).
  </p>

  <p>
    Ask questions on <i>stack</i><b>overflow</b> by using the <a href="http://stackoverflow.com/questions/ask?tags=opalrb">#opalrb</a>  tag.
  </p>

  <p>
    Discuss on the <a href="https://groups.google.com/forum/#!forum/opalrb">mailing list <i class="ion-email"></i></a>
    or on <i class="ion-social-twitter"></i> <b>Twitter</b> <a href="http://twitter.com/opalrb">@opalrb</a>.
  </p>
  <p>
    Stay updated on the latest Opal news from around the web with the <a href="http://opalist.co">Opalist newsletter <i class="ion-paper-airplane"></i></a>.
  </p>
</div>

## Getting Started

### Overview

<p class="run-code"><a href="/try" class="btn btn-default btn-code">Run this code in your browser <i class="ion-ios7-play"></i></a></p>

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

### Installation

Install Opal from RubyGems:

```text
$ gem install opal
```

Or include it in your `Gemfile` for Bundler:

```ruby
gem 'opal'
```
