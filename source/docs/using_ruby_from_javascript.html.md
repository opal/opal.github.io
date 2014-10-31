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


## Hash

Since ruby hashes are implemented directly with an Opal class, there's no "toll-free" bridging available (unlike with strings and arrays, for example). However, it's quite possible to interact with hashes from Javascript:

```javascript
var myHash = Opal.hash({a: 1, b: 2});
// output of $inspect: {"a"=>1, "b"=>2}
myHash.$store('a', 10);
// output of $inspect: {"a"=>10, "b"=>2}
myHash.$fetch('b','');
// 2
myHash.$fetch('z','');
// ""
myHash.$update(Opal.hash({b: 20, c: 30}));
// output of $inspect: {"a"=>10, "b"=>20, "c"=>30}
myHash.$to_n(); // provided by the Native module
// output: {"a": 10, "b": 20, "c": 30} aka a standard Javascript object
```

(Be aware to_n produces a duplicate copy of the hash.)
