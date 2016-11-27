require 'bundler'
Bundler.require

require 'middleman/rack'
require 'middleman-core/rack'

run Middleman::Rack.new(Middleman::Application.new)
