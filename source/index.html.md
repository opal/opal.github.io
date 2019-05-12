---
title: "Opal: Ruby ♥︎ JavaScript"
---

<div class="jumbotron opal-front-jumbo">
  <div class="page-header">
    <img src='https://secure.gravatar.com/avatar/88298620949a6534d403da2e356c9339?s=420&d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-org-420.png' alt='' width='128' height='128' />
    <h1>Opal</h1>
    <h3 class="tagline">Ruby ♥︎ JavaScript</h3>
    <p>
      <br>
      <a href="#getting-started" class="btn btn-primary btn-lg" role="button"><i class="ion-ios-book"></i> Getting Started</a>
      <br>
      <br>
    </p>

    <p>
      Opal is a Ruby to JavaScript source-to-source compiler. <br>
      It comes packed with the Ruby corelib you know and love. <br>
      It is both fast as a runtime and small in its footprint.
    </p>

    <p>
      <!-- <a target="_blank" href="http://cdn.opalrb.com/opal/current/opal.min.js" class="btn btn-secondary btn-lg" role="button"><i class="ion-ios-download-outline"></i> opal.min.js</a>
      <a target="_blank" href="http://cdn.opalrb.com/opal/current/opal-parser.min.js" class="btn btn-secondary btn-lg" role="button"><i class="ion-ios-download-outline"></i> opal-parser.min.js</a>
      <a target="_blank" href="http://cdn.opalrb.com/" class="btn btn-lg" role="button"><i class="ion-ios-world-outline"></i> Use the CDN</a> -->
      <!-- <a href="http://cdn.opalrb.com/" class="btn btn-lg" role="button"><i class="ion-speedometer"></i> Use the CDN</a> -->
    <!-- </p>
    <p> -->
      <a href="#getting-started-rack-and-sprockets" class="btn btn-secondary btn-lg" role="button"><i class="ion-ios-book-outline"></i> Rack tutorial</a>
      <a href="#getting-started-rails" class="btn btn-secondary btn-lg" role="button"><i class="ion-ios-book-outline"></i> Rails tutorial</a>
      <a href="#getting-started-command-line-interface-cli" class="btn btn-secondary btn-lg" role="button"><i class="ion-ios-book-outline"></i> CLI tutorial</a>
      <a href="/libraries" class="btn btn-secondary btn-lg" role="button"><i class="ion-ios-glasses"></i> Awesome Opal</a>
      <!-- <a href="/docs" class="btn btn-secondary btn-lg" role="button"><i class="ion-ios-copy-outline"></i> Opal Documentation</a> -->
    </p>

  </div>
</div>

## Praise

<div class="praise">
  <div class="praise-item">
  <blockquote>Opal is truly amazing and it has taken me in a whole new direction.</blockquote>
  <em>— @mistergibson <a href="https://gitter.im/opal/opal?at=5a652b8de014122650743f80">from Gitter, on Jan 22 2018</a></em>
  </div class="praise-item">
  <div class="praise-item">
  <blockquote>Opal 0.11 is a blessing! Its a giant step forward to ruby on the client! Its just amazing what bugs i find in existing 0.10 code and do keep wondering, "How did this ever work at all?" I am amzed, fantastic 👍👍👍😄</blockquote>
  <em>— @janbiedermann <a href="https://gitter.im/opal/opal?at=5a63763fce68c3bc74e0e07d">from Gitter, on Jan 20 2018</a></em>
  </div class="praise-item">
  <div class="praise-item">
  <blockquote>These guys are great. We have a large production app (www.catprint.com) that thanks to opal is 100% RUBY. The UI part is about 17K of opal code, using the hyperstack (www.hyperstack.org) framework.<br>
  In practice Opal == MRI Ruby, very reliable and solid.</blockquote>
  <em>— @catmando <a href="https://gitter.im/opal/opal?at=5c02cd4b9f38cc0fd58c3b7f">from Gitter, on Dec 1 2018</a></em>
  </div class="praise-item">
</div>


## Overview

<p class="run-code"><a href="/try" class="btn btn-default btn-code">Try this code <i style="vertical-align: middle" class="ion-ios-play"></i></a></p>

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

# the output will go to your browser's console
puts user
puts user.admin?
```


---

<span id="getting-started">

## Getting Started: Rack

Add `rack` to your `Gemfile`.

```ruby
gem 'rack'
```

Setup the Opal rack-app in your `config.ru` as follows:

```ruby
require 'opal'

run(Opal::SimpleServer.new do |s|
  # the name of the ruby file to load. To use more files they must be required from here (see app)
  s.main = 'application'

  # the directory where the code is (add to opal load path )
  s.append_path 'app'

  # need to set the index explicitly for opal server to pick it up
  s.index_path = 'index.html.erb'
end)
```

Add a file named `hello_world.js.rb` to `app/` with your hello world:

```ruby
require 'opal'
require 'native'
$$.alert 'Hello World from Opal!'
```

Then start the server with `bundle exec rackup` and visit [http://localhost:9292](http://localhost:9292).

<br>
<br>
<a href="https://github.com/opal/opal-sprockets#readme" class="btn btn-primary btn-lg" role="button"><i class="ion-ios-book-outline"></i> Learn more about Opal Sprockets</a>
<br>
<br>


---

## Getting Started: Rails

Add `opal-rails` to your Rails app's `Gemfile`:

```ruby
gem 'opal-rails'
```

Rename `app/assets/javascripts/application.js` to `app/assets/javascripts/application.js.rb` and replace its contents with this code:

```ruby
require 'opal'
require 'opal_ujs'
require 'turbolinks'
require_tree '.'
```

Create a "Hello World" controller:

```ruby
bin/rails generate controller HelloWorld index
```

Replace the contents of `app/assets/javascripts/hello_world.js.rb` with:

```ruby
Document.ready? do
  Element.find('body').html = '<h1>Hello World from Opal!</h1>'
end
```

Start the server with `bin/rails server` and visit: [http://localhost:3000/hello_world/index](http://localhost:3000/hello_world/index).

<br>
<br>
<a href="https://github.com/opal/opal-rails#readme" class="btn btn-primary btn-lg" role="button"><i class="ion-ios-book-outline"></i> Learn more about Opal Rails</a>
<br>
<br>

---

## Getting Started: Command Line Interface (CLI)

Install `opal` from Rubygems:

```bash
gem install opal
```

Write this code to `hello_world.js.rb`:

```ruby
require 'ostruct'
greeting = OpenStruct.new(type: :Hello, target: :World, source: :Opal)
puts "#{greeting.type} #{greeting.target} from #{greeting.source}!"
```

Run it with Node.js (assuming it's installed):

```bash
opal hello_world.js.rb
# => Hello World from Opal!
```

Compile it to a JavaScript file:

```bash
opal -c hello_world.js.rb > hello_world.js
node hello_world.js
# => Hello World from Opal!
```

For a full list of supported options see:

```bash
opal --help
```


<br>
<br>
<a href="https://github.com/opal/opal#usage" class="btn btn-primary btn-lg" role="button"><i class="ion-ios-book-outline"></i> Learn more about the CLI</a>
<br>
<br>



---

## Resources

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
</div>

