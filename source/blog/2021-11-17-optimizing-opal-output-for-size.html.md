---
title: "Optimizing Opal output for size"
date: 2021-11-17
author: hmdne
---

Opal doesn't output the smallest code possible - that's not our goal. We want to output readable ES5 code and we have tools: JS minifiers
([Terser](https://terser.org/)) and [Google Closure Compiler](https://developers.google.com/closure/compiler/)), and tree shaking utilities
([opal-optimizer](https://github.com/hmdne/opal-optimizer)) to bring the code size down.

JavaScript and Ruby certainly have some different semantics. Some things work similarly (like open classes), but some don't - and those that don't
require some boilerplate code that not only reduces performance, but also increases load times, which for JavaScript code are crucial.

In this article we will particularly focus on Terser, since it's the most widely used tool for Opal postprocessing. Can Terser find every nook and
cranny and optimize the resulting code to the minimal JavaScript version possible? Unfortunately not. It doesn't have a knowledge about which
statements can produce side effects and which don't. And so it only does the transformations that are semantically equivalent. But while compiling,
we may know something more.

And so I attempted an exercise to reduce the size of [Asciidoctor.js](https://asciidoctor.org/) - a Ruby program to compile AsciiDoc documents
to HTML - compiled with Opal to JavaScript - which we use in our CI "performance" task. I took a code golf approach with an exception that we
need to produce a readable code (Terser takes care to uglify it) - let's make the smallest JavaScript AsciiDoc compiler by improving Opal compiler.
The main idea is to reduce the code size, not increase performance, but as I will sum this up later, those increases will happen together, but to a
lesser extent. This exercise took about 4 work days for me.

Those improvements will most probably land for Opal 1.4 release, to happen in late December, along with Ruby 3.1 support. But for now, let me take
you for a long journey during which you may learn a bit about how Opal compiles Ruby to JavaScript.

## Step 1. Do we need `self`?

In Opal, we always alias `this` to `self`. But, let's consider the following code. Do we really need to define `self` in that case?

```ruby
def loop
  while true
    yield
  end
end
```

And so, if a function doesn't reference self in any way (a special case will be x-strings), let's not compile it in. So, what gains for AsciiDoctor
do we get?

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.239 -> 6.123 (change: -1.86%)
                      Run time: 0.285 -> 0.284 (change: -0.10%)
                   Bundle size: 5257437 -> 5236087 (change: -0.41%)
          Minified bundle size: 1264503 -> 1254455 (change: -0.79%)
```

Not much, but at least some. Take note - we can't reliably compare the first two performance metrics. And also gains for different softwares will be
different. The minified bundle size is the minification with `terser -c`. Do also note, that all the following outputs of this kind will refer to entire
patchset, as compared to Opal v1.3.2.

## Step 2. Optimize methods that accept blocks

Ok, now for a very simple function:

```ruby
def a(&block)
end
```

You may wonder, what does this function compile into?

```javascript
  return (Opal.def(self, '$a', $a$1 = function $$a() {
    var $iter = $a$1.$$p, block = $iter || nil, self = this;

    if ($iter) $a$1.$$p = null;
    
    
    if ($iter) $a$1.$$p = null;;
    return nil;
  }, $a$1.$$arity = 0), nil) && 'a'
```

Hm, not so good. One statement is duplicated, too many variable declarations. We will focus quite a lot on this method, optimizing it step-by-step in
the following steps. So, this step gives us this:

```javascript
  return (Opal.def(self, '$a', $a$1 = function $$a() {
    var block = $a$1.$$p || nil;

    if (block) $a$1.$$p = null;
    
    ;
    return nil;
  }, $a$1.$$arity = 0), nil) && 'a'
```

Much better, right? How about the numbers?

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.225 -> 6.074 (change: -2.43%)
                      Run time: 0.285 -> 0.283 (change: -0.68%)
                   Bundle size: 5257437 -> 5220199 (change: -0.71%)
          Minified bundle size: 1264503 -> 1244281 (change: -1.60%)
```

Okay! That's not bad!

## Step 3. `nil && 'a'`?

The previous versions of Ruby tended to return `nil` for method definition, but later changed to return `Symbol`s (== `Strings` in Opal). So why we
actually need this `nil`? Let's reduce it:

```javascript
  return (Opal.def(self, '$a', $a$1 = function $$a() {
    var block = $a$1.$$p || nil;

    if (block) $a$1.$$p = null;
    
    ;
    return nil;
  }, $a$1.$$arity = 0), 'a')
```

And the numbers:

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.221 -> 6.097 (change: -1.98%)
                      Run time: 0.284 -> 0.283 (change: -0.21%)
                   Bundle size: 5257437 -> 5218997 (change: -0.73%)
          Minified bundle size: 1264503 -> 1243880 (change: -1.63%)
```

That's not much. Even though Opal has a lot of method definitions. But let's go ahead.

## Step 4. Helperize `Opal.def` and `Opal.defs`

What does helperize mean? Well - in Opal compiler we may make a statement `helper :def` to generate a file top-level statement that does
`var $def = Opal.def`. That's kinda like more code, right? But most files have more than one method defined, often even a lot of them. And Terser
can't reliably rename `Opal.def` to something shorter, but `$def` can safely become `S` or whatever it decides. So, our method (now with a broader
context) will produce this:

```javascript
  var $a$1, self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.$$$, $$ = Opal.$$, $def = Opal.def;

  return ($def(self, '$a', $a$1 = function $$a() {
    var block = $a$1.$$p || nil;

    if (block) $a$1.$$p = null;
    
    ;
    return nil;
  }, $a$1.$$arity = 0), 'a')
```

Is that much? Numbers:

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.232 -> 6.103 (change: -2.08%)
                      Run time: 0.283 -> 0.283 (change: -0.19%)
                   Bundle size: 5257437 -> 5214022 (change: -0.83%)
          Minified bundle size: 1264503 -> 1238407 (change: -2.06%)
```

Yes. It's quite a lot.

## Step 5. Optimize `slice` and `splice` calls.

We use those calls a lot for the rest arguments, in methods like `def a(arg, *restargs)`. `Opal.slice` is short for `Array.prototype.slice`.
Before this step, we used to output this:

```javascript
    $post_args = Opal.slice.call(arguments, 0, arguments.length);
```

Now we output this, which is equivalent:

```javascript
    $post_args = Opal.slice.call(arguments);
```

Numbers:

```
 Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.213 -> 6.107 (change: -1.71%)
                      Run time: 0.285 -> 0.282 (change: -0.81%)
                   Bundle size: 5257437 -> 5209571 (change: -0.91%)
          Minified bundle size: 1264503 -> 1234386 (change: -2.38%)
```

So, we are accelerating.

## Step 6. Optimize `$$arity` and function variables.

Back to our `def a(&block)` empty method. Can we optimize this part even further?

```javascript
  }, $a$1.$$arity = 0), 'a')
```

Also, why do we need this, isn't it wasteful? (do note that we also need to do `var $a$1`)

```javascript
  return ($def(self, '$a', $a$1 = function $$a() {
```

Let's optimize those things out:

```javascript
Opal.queue(function(Opal) {/* Generated by Opal 1.3.1 */
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.$$$, $$ = Opal.$$, $def = Opal.def;

  return ($def(self, '$a', function $$a() {
    var block = $$a.$$p || nil;

    if (block) $$a.$$p = null;
    
    ;
    return nil;
  }, 0), 'a')
});
```

Note the `0` argument. This is a shorthand for `{$$arity: 0}`. We can't do this optimization for a minority of methods that need additional properties set.
So, what are our gains now?

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.249 -> 6.058 (change: -3.05%)
                      Run time: 0.286 -> 0.279 (change: -2.17%)
                   Bundle size: 5257437 -> 5036072 (change: -4.21%)
          Minified bundle size: 1264503 -> 1089609 (change: -13.83%)
```

That's a serious optimization now, isn't it? Almost 14% lesser files? But let's not finish here, but go ahead, maybe we can get even smaller files!

## Step 7. Delete `$$p`

Why do we use things like `$$a.$$p`? Well - you may not know, if you aren't too familiar with Opal. This is how we pass a block argument, by setting a
`$$p` property on a called function. After a call, we unset it. But this statement: `if (block) $$a.$$p = null;`... why can't we just `delete $$a.$$p;`?
Do we lose some performance then? Perhaps - but not noticeably. And we gain a lot of space. So, our `def a(&block)` method compiled now looks like this:

```javascript
Opal.queue(function(Opal) {/* Generated by Opal 1.3.1 */
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.$$$, $$ = Opal.$$, $def = Opal.def;

  return ($def(self, '$a', function $$a() {
    var block = $$a.$$p || nil;

    delete $$a.$$p;
    
    ;
    return nil;
  }, 0), 'a')
});
```

And the numbers aren't much better, but cumulatively they are better:

```
 Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.239 -> 6.057 (change: -2.92%)
                      Run time: 0.286 -> 0.280 (change: -2.03%)
                   Bundle size: 5257437 -> 5032881 (change: -4.27%)
          Minified bundle size: 1264503 -> 1087119 (change: -14.03%)
```

## Step 8. Let's torture our method a little bit more

But why can't `Opal.def` itself return 'a'? If it does, we would be able to get to this form:

```javascript
Opal.queue(function(Opal) {/* Generated by Opal 1.3.1 */
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.$$$, $$ = Opal.$$, $def = Opal.def;

  return $def(self, '$a', function $$a() {
    var block = $$a.$$p || nil;

    delete $$a.$$p;
    
    ;
    return nil;
  }, 0)
});
```

We are getting much closer to plain JavaScript now.

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.253 -> 6.145 (change: -1.73%)
                      Run time: 0.285 -> 0.280 (change: -1.61%)
                   Bundle size: 5257437 -> 5028381 (change: -4.36%)
          Minified bundle size: 1264503 -> 1086206 (change: -14.10%)
```

## Step 9. `$$($nesting, 'Opal')['$coerce_to!'](self.$a(), self.$b(), self.$c())` what?

Oh, of course. It's our representation of:

```ruby
Opal.coerce_to!(a,b,c)
```

Can we make it into:

```javascript
var $Opal = Opal.Opal;
$Opal['$coerce_to!'](self.$a(), self.$b(), self.$c())
```

Those calls happen a lot in our corelib (let's say - a corelib is those parts of Ruby we don't have to require. stdlib is those libraries that is provided with
Ruby but we have to require, like 'json'. We will now focus a lot on our corelib). What's a result then?

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.258 -> 6.068 (change: -3.04%)
                      Run time: 0.287 -> 0.280 (change: -2.47%)
                   Bundle size: 5257437 -> 5041275 (change: -4.11%)
          Minified bundle size: 1264503 -> 1083267 (change: -14.33%)
```

We also similarly optimized an access to a few more constants like `Kernel`, `Object`, `BasicObject`.

_Also in this step we renamed `Opal.defineProperty` to just `Opal.prop`. Not much improvement on its own though.`

## Step 10. Top-level constant access optimization

What does `::String` compile into? Of course into `$$$("::", "String")`. Why? `"::"` is a special value here. If we would do something like `::A::B`, we would
get `$$$($$$("::", "A"), "B")`.

But why can't it become just... `$$$("String")`? It can. And our numbers now are:

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.269 -> 6.195 (change: -1.18%)
                      Run time: 0.287 -> 0.279 (change: -2.75%)
                   Bundle size: 5257437 -> 5020671 (change: -4.50%)
          Minified bundle size: 1264503 -> 1077085 (change: -14.82%)
```

Not too much, but... we also needed to replace a lot of calls in the corelib from `String` to `::String`. This will follow in the next steps.

## Step 11. Empty classes and modules.

Do empty classes happen a lot? Well - they do. Mostly when you define exceptions. Like we do:

```ruby
class StandardError     < ::Exception; end
class EncodingError       < ::StandardError; end
class ZeroDivisionError   < ::StandardError; end
class NameError           < ::StandardError; end
class NoMethodError         < ::NameError; end
class RuntimeError        < ::StandardError; end
class FrozenError           < ::RuntimeError; end
class LocalJumpError      < ::StandardError; end
class TypeError           < ::StandardError; end
class ArgumentError       < ::StandardError; end
class UncaughtThrowError    < ::ArgumentError; end
class IndexError          < ::StandardError; end
```

_The indentation denotes a hierarchy :)_

This used to compile to this:

```javascript
Opal.queue(function(Opal) {/* Generated by Opal 1.3.1 */
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.$$$, $$ = Opal.$$, $klass = Opal.klass;

  
  (function($base, $super, $parent_nesting) {
    var self = $klass($base, $super, 'StandardError');

    var $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$$('::', 'Exception'), $nesting);
  (function($base, $super, $parent_nesting) {
    var self = $klass($base, $super, 'EncodingError');

    var $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$$('::', 'StandardError'), $nesting);
  (function($base, $super, $parent_nesting) {
    var self = $klass($base, $super, 'ZeroDivisionError');

    var $nesting = [self].concat($parent_nesting);

    return nil
  })($nesting[0], $$$('::', 'StandardError'), $nesting);
(...yeah and it goes like this...)
```

The closure is kind of... unneeded, isn't it? Let's make it disappear for this particular special situation:

```javascript
Opal.queue(function(Opal) {/* Generated by Opal 1.3.1 */
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.$$$, $$ = Opal.$$, $klass = Opal.klass;

  
  $klass($nesting[0], $$$('Exception'), 'StandardError');
  $klass($nesting[0], $$$('StandardError'), 'EncodingError');
  $klass($nesting[0], $$$('StandardError'), 'ZeroDivisionError');
  $klass($nesting[0], $$$('StandardError'), 'NameError');
  $klass($nesting[0], $$$('NameError'), 'NoMethodError');
  $klass($nesting[0], $$$('StandardError'), 'RuntimeError');
  $klass($nesting[0], $$$('RuntimeError'), 'FrozenError');
  $klass($nesting[0], $$$('StandardError'), 'LocalJumpError');
  $klass($nesting[0], $$$('StandardError'), 'TypeError');
  $klass($nesting[0], $$$('StandardError'), 'ArgumentError');
  $klass($nesting[0], $$$('ArgumentError'), 'UncaughtThrowError');
  return ($klass($nesting[0], $$$('StandardError'), 'IndexError'), nil);
});
```

Much better! And numbers?

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.202 -> 6.022 (change: -2.90%)
                      Run time: 0.285 -> 0.276 (change: -3.02%)
                   Bundle size: 5257437 -> 5011915 (change: -4.67%)
          Minified bundle size: 1264503 -> 1072799 (change: -15.16%)
```

Yay! 15%!

## Step 12. `unless` becoming `else`?

Ok - let's take this expression:

```ruby
true unless false
```

What will it compile to?

```javascript
  if ($truthy(false)) {
  } else {
    true
  };
```

Well - makes some sense. Oh, you may ask do we need this $truthy call here? Well - in this particular example - we don't - but in general, JavaScript has different
truthiness semantics. `""` is falsy, `0` is falsy, `nil` is truthy (yeah - our `nil` is not JS `null`). But why an `if` and `else` branch. Let's do it better:

```javascript
  if (!$truthy(false)) {
    true
  };
```

And the numbers are:

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.164 -> 6.048 (change: -1.87%)
                      Run time: 0.284 -> 0.277 (change: -2.62%)
                   Bundle size: 5257437 -> 4994938 (change: -4.99%)
          Minified bundle size: 1264503 -> 1072746 (change: -15.16%)
```

Not much better in the minified bundle size - Terser did a good job here. But in the following it didn't...

## Step 13. Let's get out of the closure hell

```ruby
a || b || c || d || e
```

Seems simple, right? Can we compile it to the same thing in JS? Oh well, we can't... we have different truthy semantics as mentioned above. And also, if there's
a `next` call... you know `a || continue` is an invalid JavaScript? So... this code compiles to the following monster:

```javascript
  if ($truthy(($ret_or_1 = (function() {if ($truthy(($ret_or_2 = (function() {if ($truthy(($ret_or_3 = (function() {if ($truthy(($ret_or_4 = self.$a()))) {
    return $ret_or_4
  } else {
    return self.$b()
  }; return nil; })()))) {
    return $ret_or_3
  } else {
    return self.$c()
  }; return nil; })()))) {
    return $ret_or_2
  } else {
    return self.$d()
  }; return nil; })()))) {
    return $ret_or_1
  } else {
    return self.$e()
  }
```

Well. That's a lot of functions. And expressions like `next` don't happen here. Can't we at least use a ternary operator where we can:

```javascript
  if ($truthy(($ret_or_1 = ($truthy(($ret_or_2 = ($truthy(($ret_or_3 = ($truthy(($ret_or_4 = self.$a())) ? ($ret_or_4) : (self.$b())))) ? ($ret_or_3) : (self.$c())))) ? ($ret_or_2) : (self.$d()))))) {
    return $ret_or_1
  } else {
    return self.$e()
  }
```

This is still ugly. But we don't abuse the functions. Numbers:

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.269 -> 6.198 (change: -1.13%)
                      Run time: 0.286 -> 0.273 (change: -4.44%)
                   Bundle size: 5257437 -> 4868356 (change: -7.40%)
          Minified bundle size: 1264503 -> 1069576 (change: -15.42%)
```

We improved the performance quite a bit. And the un-Tersered code size - but Terser also gained a bit. We lost a bit of compiler performance though.

## Step 14. Various small optimizations

Opal doesn't support mutable strings (we have a plan to support them in the near future!) - and so we alert the developer if he tries to access them. But it's
a lot of method definitions. Let's compress them with a `define_method` loop.

We also sometimes compile empty files - called stubbing - so we can for example make `require "yaml"` not fail - even though we don't use YAML, but some compiled-in
method does. Let's make those compiled files smaller.

Also, `eval` in JavaScript is considered harmful. Let's at least use a different facility to support Ruby `instance_eval`.

Result:

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.071 -> 5.965 (change: -1.76%)
                      Run time: 0.285 -> 0.271 (change: -4.75%)
                   Bundle size: 5259054 -> 4856724 (change: -7.65%)
          Minified bundle size: 1264953 -> 1067161 (change: -15.64%)
```

Not much, but it still gives us some headroom.

## Step 15. `||` strikes again

Some libraries (like `parser`) happen to use `||` a lot. For each usage, we generate a new `$ret_or_X` where `X > 0` variable. This is so we can save the
left-hand-side expression and return it later, possibly. And we don't reuse them, so we get a very large `var $ret_or_1, $ret_or_2, $ret_or_3 ... $ret_or_42;`
definition. Let's reuse those.

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.110 -> 5.972 (change: -2.25%)
                      Run time: 0.286 -> 0.271 (change: -5.20%)
                   Bundle size: 5259054 -> 4826837 (change: -8.22%)
          Minified bundle size: 1264953 -> 1058462 (change: -16.32%)
```

A nice improvement!

## Step 16. More helperizing

In compiled Asciidoctor I found a lot of dynamic regexps. And we define them by `Opal.regexp([a,b,c])`. Let's make it just `$regexp([a,b,c])` and let's shorten
a lot of other definitions like this. At this point I noticed, that we don't run Terser with name mangling in effect. Let's change it just now. The numbers are
compared to Opal 1.3.2.

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.089 -> 6.006 (change: -1.36%)
                      Run time: 0.285 -> 0.269 (change: -5.39%)
                   Bundle size: 5259054 -> 4824589 (change: -8.26%)
          Minified bundle size: 1264953 -> 1054974 (change: -16.60%)
            Mangled & minified: 812275 -> 732066 (change: -9.87%)
```

That's fair enough.

## Step 17. Optimize instance variable access

For two reasons, we set `@variables` to `nil` by default if they are referenced. The first reason is obvious, `@variable` is compiled to `self.variable` and we
don't want `undefined` values to creep in - they are not an object and in Ruby everything is an object - we want to keep that impression, so in Opal `undefined`
doesn't exist (if you get `undefined` somewhere - you have hit a bug or accessed some low level interfaces). The second is to improve a shape for the JS engines
to optimize the code better.

The problem is, that the code looks like this:

```javascript
self.$$prototype.variable1 = self.$$prototype.variable2 = self.$$prototype.variable3 = self.$$prototype.variable4 = nil
```

Why not make it:

```javascript
var $proto = self.$$prototype;
$proto.variable1 = $proto.variable2 = $proto.variable3 = $proto.variable4 = nil
```

Remember - `$proto` can be safely renamed. `self.$$prototype` can't.

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.086 -> 6.014 (change: -1.19%)
                      Run time: 0.284 -> 0.269 (change: -5.28%)
                   Bundle size: 5259054 -> 4823880 (change: -8.27%)
          Minified bundle size: 1264953 -> 1053776 (change: -16.69%)
            Mangled & minified: 812275 -> 730112 (change: -10.12%)
```

## Step 18. `#method_missing` stubs definition optimization

How does `#method_missing` work on Opal? In JavaScript there's no facility for that. Well - we define so-called stubs, which means that for every call you want
to make, we define a method on `BasicObject` that basically calls `#method_missing`. This way no method is missing and all calls success. And if you use a call
like `#send`... we have an easier job here, but we don't want to use `#send` everywhere for performance reasons.

The stubs used to be defined this way, for every file:

```javascript
Opal.add_stubs(["$hello", "$new", "$<"]);
```

Let's make it shorter:

```javascript
Opal.add_stubs("hello,new,<");
```

This also helps the JS parsers. This is how Google Closure Compiler optimizes large arrays of Strings.

```
 Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.088 -> 6.008 (change: -1.30%)
                      Run time: 0.285 -> 0.271 (change: -5.08%)
                   Bundle size: 5259054 -> 4812284 (change: -8.50%)
          Minified bundle size: 1264953 -> 1044964 (change: -17.39%)
            Mangled & minified: 812275 -> 721296 (change: -11.20%)
```

## Step 19. Hiding `$$` and `$$$`.

What is `$$$` - I explained in one of the earlier parts. But what is `$$` - I haven't. This is a relative constant access function. This is a bit less performant,
because we have to iterate thru every `class` and `module` we are in and their ancestors - and `Object` and its ancestors as well. We store a list of modules and
classes in a `$nesting` variable. And then we can call `$$($nesting, "String")` to find our `String` - because - maybe it is an `Array::String`? Well, we know it
isn't, so we have to change our `corelib` furthermore a lot. And then - suddenly - some files don't need `$$`, so we don't need to helperize it.

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.082 -> 5.964 (change: -1.94%)
                      Run time: 0.284 -> 0.270 (change: -4.92%)
                   Bundle size: 5259054 -> 4811653 (change: -8.51%)
          Minified bundle size: 1264953 -> 1041721 (change: -17.65%)
            Mangled & minified: 812275 -> 720161 (change: -11.34%)
```

## Step 20. `$nesting` - do we need it?

Sometimes though, we don't even need `$nesting` to be computed. If our class is small, doesn't have classes defined in its namespace and we don't reference
constants relatively, we may skip computing `$nesting` altogether.

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.090 -> 5.952 (change: -2.27%)
                      Run time: 0.284 -> 0.269 (change: -5.26%)
                   Bundle size: 5259054 -> 4806185 (change: -8.61%)
          Minified bundle size: 1264953 -> 1036887 (change: -18.03%)
            Mangled & minified: 812275 -> 717787 (change: -11.63%)
```

## Step 21. Curry `$$`

I came upon an idea, that the `$$` method can be curried. Of course, this moves its definition from the top level scope to the class/module scope so it means
it may happen more often. So now we don't call `$$($nesting, "String")`, but we can simply call `$$("String")` because `$$` is defined with `$nesting`. Do we
get any optimization from that, then?

```
 Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.097 -> 5.976 (change: -1.99%)
                      Run time: 0.285 -> 0.270 (change: -5.41%)
                   Bundle size: 5259054 -> 4795627 (change: -8.81%)
          Minified bundle size: 1264953 -> 1027837 (change: -18.75%)
            Mangled & minified: 812275 -> 716231 (change: -11.82%)
```

Yes. And quite a big one if we don't mangle variable names.

## Step 22. Interpolated strings optimization

What do we do with strings like `"aaaa#{true}"` (also called dstrs)? Of course, we compile them to:

```javascript
"" + "aaaa" + (true)
```

Why does it make sense? Also, how comes this thing can use the `+` operator? Well, let me explain. In JavaScript, `"" + obj` is actually equivalent to
`"" + obj.toString()`. And `toString()` for Opal objects call `#to_s` - so this is exactly what `"aaaa#{true}` does in Ruby.

And you may say - ok, for strings like `"#{5}"` (being compiled to `"" + 5`) this makes sense. But if the first part of a dstr is a string, we don't need this
`""`. Yes - though, Terser applies this optimization, so there's 0 gain there.

```
 Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.087 -> 5.959 (change: -2.10%)
                      Run time: 0.284 -> 0.269 (change: -5.45%)
                   Bundle size: 5259054 -> 4783491 (change: -9.04%)
          Minified bundle size: 1264953 -> 1027837 (change: -18.75%)
            Mangled & minified: 812275 -> 716231 (change: -11.82%)
```

## Step 23. Hide `$parent_nesting` if it's not needed

This is a small one. But this is the last one in this patch series. Let's conclude it with compilation of this Ruby code:

```ruby
class A
  def x
  end
end
```

Opal 1.3.2 outputs this:

```javascript
Opal.queue(function(Opal) {/* Generated by Opal 1.3.2 */
  var self = Opal.top, $nesting = [], nil = Opal.nil, $$$ = Opal.$$$, $$ = Opal.$$, $klass = Opal.klass;

  return (function($base, $super, $parent_nesting) {
    var self = $klass($base, $super, 'A');

    var $nesting = [self].concat($parent_nesting), $A_x$1;

    return (Opal.def(self, '$x', $A_x$1 = function $$x() {
      var self = this;

      return nil
    }, $A_x$1.$$arity = 0), nil) && 'x'
  })($nesting[0], null, $nesting)
});
```

This patchset makes it output the following:

```javascript
Opal.queue(function(Opal) {/* Generated by Opal 1.3.2 */
  var $nesting = [], nil = Opal.nil, $klass = Opal.klass, $def = Opal.def;

  return (function($base, $super) {
    var self = $klass($base, $super, 'A');

    
    return $def(self, '$x', function $$x() {
      
      return nil
    }, 0)
  })($nesting[0], null)
});
```

Therefore we skip one variable more. And while some JS minifiers may find this thing and optimize it out itself, some don't

## Conclusion
After this patchset is merged, Opal will produce much cleaner code with much lesser complexity that you can read much easier without knowledge of how Opal actually
works under the hood. If you know Ruby, you are likely to know what `$super` means in this particular code (if you don't, it means a superclass, which `A` doesn't
have set). So, to conclude. What are the total gains from this entire patchset?

```
Comparison of the Asciidoctor (a real-life Opal application) compile and run:
                  Compile time: 6.073 -> 5.956 (change: -1.92%)
                      Run time: 0.284 -> 0.269 (change: -5.46%)
                   Bundle size: 5259054 -> 4781496 (change: -9.08%)
          Minified bundle size: 1264953 -> 1026844 (change: -18.82%)
            Mangled & minified: 812275 -> 715972 (change: -11.86%)
```

Of course - the numbers will depend on what you compile with Opal and how you minimize (or not). I tried compiling Opal-Parser and the size numbers reached about
15%. And you will get about 5% better performance (note - the performance gains are computed on a non-minified bundle, so if you minify you may get even better
performance gains).

This doesn't end the optimization efforts we have - there are still some ideas that weren't realized in this patchset.

This patchset is [located here](https://github.com/opal/opal/pull/2356). If you are interested in writing compilers, reading the source code of Opal compiler may
prove useful - it's relatively lightweight, well organized and it's all Ruby! All despite the fact, that Ruby is one of the hardest to parse programming languages
in existence (if not the hardest) - all lexing and parsing happens in a wonderful [parser](https://github.com/whitequark/parser) library which is also used by
[RuboCop](https://rubocop.org/) and many other gems!
