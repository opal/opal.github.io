---
title: RSpec
---

# RSpec

`opal-rspec` allows opal to use rspec for running specs in javascript
environments. It comes with built-in support for running rspec with custom
`phantomjs` and standard web browser formatters. Also, async spec examples
are supported to reflect browser usage of ruby applications.

```ruby
describe User do
  it "can be created with a name" do
    expect(User.new).to_not be_persisted
  end
end
```

### Installation

Add the `opal-rspec` gem to your Gemfile:

```ruby
# Gemfile
gem 'opal'
gem 'opal-rspec'
```

## Running specs

### phantomjs

To run specs, a rake task can be added which will load all spec files
from `spec/`:

```ruby
# Rakefile
require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)
```

Then, to run your specs inside phantomjs, just run the rake task:

```sh
$ bundle exec rake
```

### In a Browser

`opal-rspec` can use sprockets to build and serve specs over a simple rack server. Add the following to a `config.ru` file:

```ruby
# config.ru
require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.main = 'opal/rspec/sprockets_runner'
  s.append_path 'spec'
  s.debug = false
}
```

Then run the rack server bundle exec rackup and visit `http://localhost:9292` in any web browser.
