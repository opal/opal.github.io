require 'opal-parser'

$$[:document].dispatchEvent JS.new($$[:Event].to_n, :parser_loaded)
