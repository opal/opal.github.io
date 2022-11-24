---
title: "Opal 1.6 and Opal-RSpec 1.0"
date: 2022-11-24
author: hmdne, elia, janbiedermann
---

We are happy to announce that Opal 1.6 and Opal-RSpec 1.0 are out!

Opal is a Ruby (3.1) to JavaScript (ES5) compiler allowing you to write frontend code in pure Ruby and have it translated to clean and efficient JavaScript. It also includes a highly compatible core library that includes all the methods you've come to love. All this with a robust support of source maps, so you can debug Ruby code, not JavaScript in your Web Console. It can be used both to create websites entirely in Ruby (using [Opal-Browser](https://github.com/opal/opal-browser), or [ports of known JavaScript libraries](https://opalrb.com/libraries/)) and to port existing Ruby libraries to JavaScript, to be ran both in Node.JS and in web browsers (and other JavaScript environments).

Opal-RSpec is an Opal port of [RSpec](https://rspec.info/), a well known Ruby testing tool, allowing you to easily test your Ruby applications in browser and in Node, just like you can do so with MRI.

This release of Opal is focused primarily on improving upon MRI compatibility. We now fully support freezing and also we now have a new robust and hackable control flow instruction handling implementation (think: `break`, `next`, `return`...). Also, Windows support has been improved and Opal gained a parallel compile support - significantly improving compile times on multicore systems. In addition, the `await` subsystem is no longer experimental.

Try it now on [opalrb.com/try](https://opalrb.com/try), or get started instantly with no further steps required (except for installing Ruby):

```
gem install opal
# Try either of the following examples:
opal -e 'puts "Hello world!"'
opal -ce 'puts "Hello world!"' > hello_world.js; node hello_world.js
opal -OcEe 'puts "Hello world!"'
# Or run it in a web browser:
bundle init
bundle add opal-browser puma
bundle add rack -v '< 3'
bundle exec opal -Rserver -qopal-browser -rbrowser -e '$document.write("Hello world!")'
```

<div id="continue-reading"></div>

## Freeze

There are a couple of features that we wouldn't think Opal would be able to support with the current approach of transpiling Ruby code to JavaScript. The most known one is mutable strings, which we can't easily support, because we rely on a notion of sharing the same type between the Ruby and JavaScript environment (and JavaScript has immutable strings...).

One of those features is freezing. Thanks to @janbiedermann, we now have a robust freezing system across the codebase, using carefully crafted `Object.seal` statements. With this you can harden your codebase to ensure that JavaScript libraries don't mess with your objects and that you are using the Ruby gems in Opal correctly as well.

*We have working [proof-of-concept patches](https://github.com/opal/opal/pull/2358) to make mutable strings work, but they still need some time to mature...*

## Robust control flow instructions system (aka closure tracking)

Most of the time Opal gets control flow instructions (namely: `break`, `next`, `return`, `redo`, `retry`) correctly. Many Ruby gems can work with Opal verbatim, perhaps just needing easy adjustments due to our lack of mutable strings. But sometimes, for unknown reasons, we can get a `break` wrong and have no easy answer why a Gem doesn't work. Well, no more.

Introducing closure tracking: we did a refactor of our codebase, moving (unifying and heavily improving) all the control flow instructions logic in [a single 250 line file](https://github.com/opal/opal/blob/master/lib/opal/nodes/closure.rb). Doing this, allowed us to easily close 4 old issues and get many more [MSpec](https://github.com/ruby/mspec) [Ruby Specs](https://github.com/ruby/spec) passing.

We are aware that this is still not perfect and perhaps we haven't covered some edge cases. But the simplification of the code will easily allow us to improve upon those in the future.

*If you update your code to Opal 1.6, you may encounter some issues if you relied on old behavior*

## Windows improvements

For those of you, that use Windows as your development platform, we have prepared a lot of bugfixes to support all the development tools we provide. Also the compiler and generated source maps treat Windows line endings correctly. We also now run full test suites on Windows machines to ensure Opal remains fully working on Windows in the future.

## Runtime performance

There will be a significant performance improvement for code or DSLs that use a lot of blocks.

## Parallel compilation (aka prefork)

In this release we introduce parallel compilation for `Opal::Builder`, which will cause our Ruby process to fork a number (3/4 of your CPU core count by default) of processes that will compile every file of your application in parallel.

Until recently, it used to be a big problem with Opal, that compile times were slow. Because a large part of the Opal core and standard libraries are also written in Ruby, those are also needed to be compiled with your application. We used to do most of our Opal application development using Sprockets, which supported caching (albeit with some unfortunate bugs and caveats...) and since Opal 1.3 we have a robust caching support everywhere, without needing Sprockets.

Truth be told, Sprockets is now moving to maintenance mode and so is Opal-Sprockets (we are still committed to supporting it, because we understand it's widely used in production). In the meantime we are focusing on `Opal::Builder`, which is an alternative implementation for building JavaScript files from our Ruby code. This is the class that is used by the `opal` CLI command, but also `Opal::SimpleServer` and also it can be used directly to compile your JavaScript inside a `Rakefile`.

*This feature doesn't work on Windows due to a lack of support for forking... Also it doesn't work in JavaScript environments, for the same reason... But due to a pluggable nature of this subsystem, it should be feasible to implement the same thing using some other approach on those platforms.*

## Opal-RSpec 1.0

Opal-RSpec has been updated to now use the latest RSpec version. A huge part of Opal-RSpec has been rewritten. We now support diffs and provide a source fragment. We also now have a robust support for async tests - [either using promises, or using await facility of Opal](https://opalrb.com/docs/guides/v1.5.1/async). This also means there's a slight incompatibility, because we need to use `PromiseV2` not `PromiseV1` (which as of yet is still a default `Promise` implementation).

We have decided to break compatibility with anything lesser than Opal v1.6 - if you still depend on an older Opal version, you can keep using Opal-RSpec v0.8 and we will still accept patches for this version.

*Please take a look at the [README](https://github.com/opal/opal-rspec/blob/master/README.md) to take note of other incompatible changes since v0.8.*

## Conclusion

As always this version brings a lot of other bug fixes and small improvements, please have a look at the full changelog. If you want to know more, have questions, or want to start contributing, please [join the Slack channel](https://slack.opalrb.com) and ask around, we're always happy to welcome new people to the community!

---

### Resources (Opal)

* [Changelog for v1.6.0](https://github.com/opal/opal/releases/tag/v1.6.0)
* [List of commits](https://github.com/opal/opal/compare/v1.5.1...v1.6.0) / [raw diff](https://github.com/opal/opal/compare/v1.5.1...v1.6.0.diff)
* [Updated website](https://opalrb.com)
* [Documentation](http://opalrb.com/docs/)

### Resources (Opal-RSpec)

* [Opal-RSpec](https://github.com/opal/opal-rspec)
* [README](https://github.com/opal/opal-rspec/blob/master/README.md)
