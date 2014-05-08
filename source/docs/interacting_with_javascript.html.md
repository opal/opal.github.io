# Interacting with Javascript from Ruby

Opal tries to interact as cleanly with javascript and its api as much
as possible. Ruby arrays, strings, numbers, regexps, blocks and booleans
are just javascript native equivalents. The only boxed core features are
hashes.


## x-strings

As most of the corelib deals with these low level details, opal provides
a special syntax for inlining javascript code. This is done with
x-strings or "backticks", as their ruby use has no useful translation
in the browser.

```ruby
`window.title`
# => "Opal: Ruby to Javascript compiler"

%x{
  console.log("opal version is:");
  console.log(#{ RUBY_ENGINE_VERSION });
}

# => opal version is:
# => 0.6.0
```

Even interpolations are supported, as seen here.

This feature of inlining code is used extensively, for example in
Array#length:

```ruby
class Array
  def length
    `this.length`
  end
end
```

X-Strings also have the ability to automatically return their value,
as used by this example.


## Native

_Reposted from: [Mikamayhem](http://dev.mikamai.com/post/79398725537/using-native-javascript-objects-from-opal)_

Opal standard lib (stdlib) includes a `native` module, let’s see how it works and wrap `window`:

```ruby
require 'native'

window = Native(`window`) # equivalent to Native::Object.new(`window`)
```

Now what if we want to access one of its properties?

```ruby
window[:location][:href]                         # => "http://dev.mikamai.com/"
window[:location][:href] = "http://mikamai.com/" # will bring you to mikamai.com
```

And what about methods?

```ruby
window.alert('hey there!')
```

So let’s do something more interesting:

```ruby
class << window
  # A cross-browser window close method (works in IE!)
  def close!
    %x{
      return (#@native.open('', '_self', '') && #@native.close()) ||
             (#@native.opener = null && #@native.close()) ||
             (#@native.opener = '' && #@native.close());
    }
  end

  # let's assign href directly
  def href= url
    self[:location][:href] = url
  end
end
```

That’s all for now, bye!

```ruby
window.close!
```

