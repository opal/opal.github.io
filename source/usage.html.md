---
title: "Using Opal"
---

<div class="page-header">
  <h1>Usage</h1>
</div>

## Rails

[opal-rails](https://github.com/opal/opal-rails#readme) is available to make
opal work directly inside rails applications.

## Simple Apps

If you have an example file `app.rb`:

```ruby
[1, 2, 3, 4].each do |n|
  puts n
end
```

You can write a rake task to compile the code:

```ruby
task :compile do
  src = File.read 'app.rb'
  js = Opal.parse src

  File.open('app.js', 'w+') { |o| o.puts js }
end
```

### Running compiled code

The opal runtime is required for running compiled ruby, which can be downloaded
[opal.js](http://opalrb.org/opal.js). Setup your HTML file:

```html
<!DOCTYPE html>
<html>
<head>
  <title>My first Opal application</title>
  <script src="opal.js"></script>
  <script src="app.js"></script>
</head>
  <body></body>
</html>
```
