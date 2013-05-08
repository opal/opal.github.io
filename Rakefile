require 'bundler'
Bundler.require

require 'middleman-gh-pages'

task :opal_jquery do
  path = Opal.paths.find { |p| p =~ /opal-jquery/ }

  sources = Dir[File.join path, '**/*.rb'].map { |a|
    Opal.parse File.read a
  }

  File.open("build/opal-jquery.js", "w") { |f|
    f << sources.join("\n")
  }
end

task :opal do
  Opal::Processor.arity_check_enabled = false

  env = Sprockets::Environment.new
  Opal.paths.each { |p| env.append_path p }

  File.open("build/opal.js", "w") { |f|
    f << env['opal'].to_s
  }

  File.open("build/opal-parser.js", "w") { |f|
    f << env['opal-parser'].to_s
  }
end

desc "Build opal, opal-parser and opal-jquery to source/"
task :opals => [:opal, :opal_jquery]

