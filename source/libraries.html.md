---
title: "Libraries"
---

# Libraries

This page is a list of libraries built for opal

- [opal-jquery (jQuery)](http://github.com/opal/opal-jquery#readme)
- [opal-rails (Rails)](http://github.com/opal/opal-rails#readme)
- [opal-rspec (RSpec)](http://github.com/opal/opal-rspec#readme)
- [opal-vienna (Vienna)](http://github.com/opal/vienna#readme)
- [opal-nodejs (Nodejs / RVM)](http://github.com/opal/opal-node#readme)
- [opal-todomvc (TodoMVC)](http://github.com/opal/opal-todos#readme)


## opal-jquery

opal-jquery provides DOM access to opal by wrapping jQuery (or zepto)
and providing a nice ruby syntax for dealing with jQuery instances.
opal-jquery is [hosted on github](http://github.com/opal/opal-jquery).

jQuery instances are toll-free bridged to instances of the ruby class
`JQuery`, so they can be used interchangeably.

```ruby
elements = Element.find('.foo')
# => [<div class="foo">, ...]

elements.class
# => JQuery

elements.on(:click) do
  alert "element was clicked"
end
```
