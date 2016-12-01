# Opal & Sprockets

Opal comes with built-in sprockets support, and provides a simple `Opal::Server`
class to make it easy to get a rack server up and running for trying out Opal.
This server will automatically recompile ruby sources when they change, meaning
you just need to refresh your page to autorun.

## Getting setup

Add `opal` to a `Gemfile`:

```ruby
#Gemfile
source 'https://rubygems.org'

gem 'opal', '>= 0.6.0'
```

And install with `bundle install`.

We need a directory to hold our Opal code, so create `app/` and add a simple
demo script to `app/application.rb`:

```ruby
# app/application.rb
require 'opal'

puts "hello world"
```

Finally, we need a html page to run, so create `index.html`:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>opal server example</title>
    <script src="/assets/application.js"></script>
  </head>
  <body>
  </body>
</html>
```

## Using Opal::Server

`Opal::Server` can be run like any rack app, so just add a `config.ru` file:

```ruby
# config.ru
require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.append_path 'app'

  s.main = 'application'

  s.index_path = 'index.html'
}
```

This rack app simply adds our `app/` directory to Opal load path, and sets our
main file to `application`, which will be found inside `app/`.

## Running the app

Run `bundle exec rackup` and visit the page `http://localhost:9292` in any
browser. Observe the console to see the printed statement.

You can just change `app/application.rb` and refresh the page to see any changes.

## Speed improvements for larger applications

You can use other opal compatible gems, either opal specific ones or pure ruby ones that are
compatible with opal. To use them you will also need to add ``` Opal.use_gem("some-gem") ```
to config.ru.

You will notice that for larger applications sprockets default file cache (in tmp/) can get quite
slow. Too speed things up you can use the memory cache sprockets supply by configuring it in the
`config.ru`


```ruby
 #as above ...

  s.index_path = 'index.html'
  s.sprockets.cache = Sprockets::Cache::MemoryStore.new(1000)
}
```

The number 1000 is the default size of keys the cache retains. Basically this is the number of files
in you system, so you can adjust accordingly.

Another way to speed up load-times is to switch debug off. In (default) debug mode the server will
generate one js file per ruby file, and as source maps are also on by default, one source map per
file. The separate request for several hundred files can easily add several seconds.
To avoid this, at the cost of less debugging (in the browser), add  ``` s.debug = false ``` to the
`config.ru` .
