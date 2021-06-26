---
title: "WebAssembly and advanced regular expressions with Opal"
date: 2021-06-26
author: Interscript
---

*(This is a guest-post from the people at [Interscript](https://github.com/interscript/interscript), featuring an in-depth account of the work done around building a web-assebly bridge and compiling Onigmo for Opal)*

---

At [Ribose Inc](https://github.com/riboseinc) we develop [Interscript](https://github.com/interscript/interscript), an open source Ruby implementation of interoperable transliteration schemes from ALA-LC, BGN/PCGN, ICAO, ISO, UN (by UNGEGN) and many, many other script conversion system authorities. The goal of this project is to achieve interoperable transliteration schemes allowing quality comparisons.

We decided to port our software to JavaScript using Opal (the Ruby to JavaScript compiler), so it can be also used in web browsers and Node environments. The problem is - Opal translates Ruby regular expressions (upon which we rely quite heavily) to JavaScript almost verbatim. This made our ported codebase incompatible on principle, so we searched for a better solution.

Unfortunately, Regexp is basically something like a programming language that has more than a dozen of incompatible implementations - even across the web browsers: there is a new standard in ECMAScript which adds lookbehind assertions and Safari doesn't implement that (and we do need lookbehind assertions).

## Onigmo

Onigmo is a Regexp engine that is used by Ruby. It is a fork of Oniguruma, which is also in use by PHP and a few more programming languages. Fortunately, it's possible to compile it to a static WebAssembly module which can be interfaced with the Javascript land.

We tried compiling Onigmo using a simple handcrafted libc with no memory management
so as to reduce the size. This plan backfired (rightfully so), now we use wasi-libc:

https://github.com/WebAssembly/wasi-libc

The library is made to be able to use either of them, but use of wasi-libc is highly
encouraged. As we are concerned about the output size of the resulting WASM binaries, we chose not to use Emscripten, just the upstream LLVM/Clang and its WASM target.

## Opal-WebAssembly

After getting Onigmo, we noted, that the WebAssembly interface doesn't map 100% between C and JS. We can't pass strings verbatim and we need to do memory management (think: pointers). Is there a better solution for that than writing an Opal library to interface WebAssembly libraries?

The library is divided in two parts: there's a simple WebAssembly interface and there's a Ruby-FFI compatible binding that works on everything memory related and brings the C functions to seamlessly work with the Ruby (Opal actually) workflow.

The library has advanced beyond just being usable for this project. It should be quite
compatible with Ruby-FFI allowing C API bindings across all Ruby implementations. There
are some minor incompatibilities though.

Ruby-FFI assumes a shared memory model. WebAssembly has different memory spaces for a
calling process and each library (think about something like a segmented memory). This makes some assumptions false.

For instance, for the following code, we don't know which memory space to use:

```ruby
FFI::MemoryPointer.new(:uint8, 1200)
```

This requires us to use a special syntax, like:

```ruby
LibraryName.context do
  FFI::MemoryPointer.new(:uint8, 1200)
end
```

This context call makes it clear that we want this memory to be alocated in the
"LibraryName" space.

Another thing is that a call like the following:

```ruby
FFI::MemoryPointer.from_string("Test string")
```

Would not allocate the memory, but share the memory between the calling process and
the library. In Opal-WebAssembly we must allocate the memory, as sharing is not an option in the WASM model. Now, another issue comes into play. In regular Ruby a call similar to this should allocate the memory and clear it later, once the object is destroyed. In our case, we can't really access JavaScript's GC. This means we always need to free the memory ourselves.

Due to some Opal inadequacies, we can't interface floating-point fields in structs. This doesn't happen in Onigmo, but if needed in the future, a pack/unpack implementation for those will be needed.

Chromium browser doesn't allow us to load WebAssembly modules larger than 4KB synchronously. This means that we had to implement some methods for awaiting the load. This also means, that in the browser we can't use the code in a following way:

```html
<script src='file.js'></script>
<script>
  Opal.Library.$new();
</script>
```

This approach works in Node and possibly in other browsers, but Chromium requires us to
use promises:

```html
<script src='file.js'></script>
<script>
  Opal.WebAssembly.$wait_for("library-wasm").then(function() {
    Opal.Library.$new();
  });
</script>
```

There are certain assumptions of how a library should be loaded on Opal side - the FFI library creation depends on the WebAssembly module being already loaded, so we need to either move those definitions to a wait_for block or move require directives, like so:

```ruby
WebAssembly.wait_for "onigmo/onigmo-wasm" do
  require 'interscript'
  require 'my_application_logic'
end
```

*The source for opal-webassembly is available at https://github.com/interscript/opal-webassembly.*

## Opal-Onigmo

After having a nice library to bind with WebAssembly modules, writing an individual binding was very easy and the resulting code looks (in my opinion) very cool.

Our initial plan assumed upstreaming the code later on. I don't think it will be
possible or healthy. This library should stay as a separate gem for a couple of reasons.

First is that due to the memory issues, we aren't able to make it work as a drop-in
replacement. We need to manually call an `#ffi_free` method. Eg:

```ruby
re = Onigmo::Regexp.new("ab+")
# use the regular expression
re.ffi_free # free it afterwards and not use it anymore
```

At early stages our implementation of Opal-Onigmo we didn't consider the memory a
problem. When hit with a real world scenario, we found out, that it's a severe issue and
needs to be dealt with. As far as we know, the library doesn't leak any memory if the
regular expression memory is managed correctly.

The second is that after all, we don't really have a way of caching the compiled Regexps.
Furthermore, Onigmo compiled with WASM may not be as performant as the highly optimized JS
regexp engine. In this case it's much better to leave it as a drop-in replacement for
those who need more correctness.

Opal-Onigmo doesn't implement all the methods for Ruby Regexp, it was mostly meant for
completion of the Interscript project, but can be extended beyond. It implements a few
methods it needs to implement for String (this is just an option - you need to load
onigmo/core_ext manually), but most of the existing ones work without a problem. We
implemented a `Regexp.exec` (JavaScript) method, and the rest of Opal happened to mostly
interface with it. At the current time we know that `String#split` won't "just" work, but
`String#{index,rindex,partition,rpartition}` should.

Opal-Onigmo depends on the strings being coded as UTF-16. There are two reasons to that:

1. Opal includes methods for getting the binary form of strings in various encodings,
   but only methods for UTF-16 are valid for characters beyond the Basic Multilingual
   Plane (Unicode 0x0000 to 0xffff) which are used in 2 maps.
2. JavaScript uses UTF-16 strings internally.

*The source for opal-onigmo is available at https://github.com/interscript/opal-onigmo.*

## Interscript

Using Opal-Onigmo we made it so that it passes _all_ the tests (not counting transliterating Thai scripts which ultimately depends on an external process, which relies on machine learning). To optimize it, we use Opal-Onigmo _only_ when the regexp
is a more complex regexp, otherwise we fall back to an (ultimately faster) JavaScript regexp engine:

```ruby
def mkregexp(regexpstring)
  @cache ||= {}
  if s = @cache[regexpstring]
    if s.class == Onigmo::Regexp
      # Opal-Onigmo stores a variable "lastIndex" mimicking the JS
      # global regexp. If we want to reuse it, we need to reset it.
      s.reset
    else
      s
    end
  else
    # JS regexp is more performant than Onigmo. Let's use the JS
    # regexp wherever possible, but use Onigmo where we must.
    # Let's allow those characters to happen for the regexp to be
    # considered compatible: ()|.*+?{} ** BUT NOT (? **.
    if /[\\$^\[\]]|\(\?/.match?(regexpstring)
      # Ruby caches its regexps internally. We can't GC. We could
      # think about freeing them, but we really can't, because they
      # may be in use.
      @cache[regexpstring] = Onigmo::Regexp.new(regexpstring)
    else
      @cache[regexpstring] = Regexp.new(regexpstring)
    end
  end
end
```

It also never frees the regexps (see a previous note about #ffi_free), because we never know if a Regexp won't be in use later on (and the Regexps are actually cached in a Hash for performance reasons). The issue about dangling Regexps can be worked out in the future, but the JS API will need to change again. We would need to do something like:

```html
Opal.Interscript.$with_a_map("map-name", function() {
  // do some work with a map
});
```

This call would at the beginning allocate all the Regexps needed, and at the end, free
them all. The good news is that we would be able to somehow integrate loading transliteration maps from the network (along with dependencies) with such a construct.

## The future

Post writing this article we noted that JavaScript actually does implement a construct that would work like a destructor, allowing us to free the allocated memory dynamically. Unfortunately, that's the latest ECMAScript addition, which means there are still environments that don't support it (Safari) and there is one that needs an explicit flag (Node 13+).

https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/FinalizationRegistry

We could use it to implement some parts of ObjectSpace of Ruby and then use it in opal-webassembly to free memory on demand.

## Afterwords

This article was written long before it was published. Since then, Interscript was rewritten to a totally different architecture and doesn't use Opal anymore. We don't use Regexps directly anymore, but we created a higher-level (Ruby) DSL to describe the transliteration process that we compile directly to a highly-optimized pure Ruby/JavaScript code (and it can be extended to other languages as well). Ribose Inc still uses Opal in other projects, for example to build [Latexmath](https://github.com/plurimath/latexmath), a library that converts LaTeX math expressions to MathML, as a JavaScript library. We also contribute fixes back to the upstream Opal project.

For the Opal project, all this effort serves as an interesting experiment to establish further guidelines should we decide to increase Regexp compatibility in the future and can serve as a useful tool for anyone wanting to port his Ruby codebase with a heavy regexp use to JavaScript. It should also facilitate porting libraries that use Ruby-FFI currently.

The libraries we created are available under a 2-clause BSD license in the following repositories:

* https://github.com/interscript/Onigmo - Onigmo port to WebAssembly
* https://github.com/interscript/opal-onigmo - the Onigmo interface to Opal
* https://github.com/interscript/opal-webassembly - the FFI-like interface to Opal, using WebAssembly
* https://github.com/interscript/interscript/tree/v1 - the obsolete v1 branch of Interscript that used Opal and Opal-Onigmo
