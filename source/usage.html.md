---
title: "Using Opal"
---

<div class="page-header">
  <h1>Usage</h1>
</div>

## Rails

[opal-rails](https://github.com/opal/opal-rails#readme) is available to make
opal work directly inside rails applications.

## Build a static application

If you wish to build a standalone application, you can use a simple rake
task to help. Opal uses a set of load paths internally to resolve code
dependencies, so it is always a good idea to keep your ruby code inside
a directory.

Start by making a `app/application.rb` file to hold our demo code:

```ruby
# app/application.rb

require "opal"

puts "Wow, running in Opal!"
```

You will notice the `require "opal"` line which will automatically
include the opal runtime and corelib into our output, giving us access
to the `puts()` method.

To build this, we need a rake task to load a new opal environment, add
our `app/` directory to the load path, and then to build our target file
`application.rb` which will be found because it is inside our added load
path.

```ruby
# Rakefile

desc "Build our app to build.js"
task :build do
  env = Opal::Environment.new
  env.append_path "app"

  File.open("build.js", "w+") do |out|
    out << env["application"].to_s
  end
end
```

Now, if you run `rake build` you will get the `build.js` output file
with our application compiled, with the opal runtime included as well.

To run the application, lets create a very simple html file:

```html
<!DOCTYPE html>
<html>
  <head>
    <script src="build.js"></script>
  </head>
  <body>
  </body>
</html>
```

Now, open this html file and check the browsers console. You should see
our message printed in the console.
