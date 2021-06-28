require 'opal'
require 'native'
require 'console'
require 'js'

$$[:document].addEventListener :DOMContentLoaded do
  $$[:document].querySelector('.navbar-toggle').addEventListener :click do |event|
    target = $$[:document].querySelector event.JS[:currentTarget].JS[:dataset].JS[:target]
    target[:classList].toggle(event.JS[:currentTarget].JS[:dataset].JS[:toggle])
  end
end
