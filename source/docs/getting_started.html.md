---
title: Getting started with Opal
---

# Getting started with Opal

At its very core, opal provides a simple method of compiling a string of ruby
into javascript that can run on top of the opal runtime, provided by opal.js:

```ruby
Opal.compile("[1, 2, 3].each { |a| puts a }")
# => "(function() { ... })()"
```

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
  # the entry-point (main) to the app
  s.main = 'application'

  # add additional dirs to opal/sprockets load path
  s.append_path 'app'
}
```

Next, we must make our main app file `app/application.rb`:

```ruby
# app/application.rb

# when using sprockets/rails, we must include the corelib
require 'opal'

[1, 2, 3].each { |a| puts a }
```

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

## Custom html

`Opal::Server` provides a default html page for content. You can just create
an `index.html` or `index.html.erb` page to have custom html content. The
`javascript_include_tag` helpers acts just like in rails:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>opal demo</title>

    <%= javascript_include_tag 'application' %>
  </head>
  <body>
  </body>
</html>
```

## Using jQuery with Opal

`opal-jquery` provides a nice clean wrapper around jquery for dom interaction.
Add the gem to your Gemfile:

```ruby
# Gemfile
source 'https://rubygems.org'

gem 'opal'
gem 'opal-sprockets'
gem 'opal-jquery'
```

Also, add some jquery code:

```ruby
# app/application.rb

require 'opal'
require 'jquery'
require 'opal-jquery'

Document.ready? do
  alert "jquery is ready!"
end
```

**Note**: you must supply your own version of jquery, as opal-jquery just wraps
and existing instance. Place `jquery.js` into `app/` for the require system to
find it. You can also use `Zepto` instead.

Restart the server, and visit the page! Go to the
[opal-jquery homepage](http://github.com/opal/opal-jquery) for more documentation.
