# Using Ruby methods from Javascript

Accessing classes and methods defined in Opal from the javascript runtime is
possible via the `Opal` js object. The following class:

```ruby
class Foo
  def bar
    puts "called bar on class Foo defined in ruby code"
  end
end
```

Can be accessed from javascript like this:

```javascript
Opal.Foo.$new().$bar();
// => "called bar on class Foo defined in ruby code"
```

Remember that all ruby methods are prefixed with a `$`.

In the case that a method name can't be called directly due to a javascript syntax error, you will need to call the method using bracket notation. For example, you can call `foo.$merge(...)` but not `foo.$merge!(...)`, `bar.$fetch('somekey')` but not `bar.$[]('somekey')`. Instead you would write it like this: `foo['$merge!'](...)` or `bar['$[]']('somekey')`.
