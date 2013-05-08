require 'bundler'
Bundler.require

set :markdown_engine, :redcarpet
set :markdown, :layout_engine => :erb,
               :fenced_code_blocks => true,
                :lax_html_blocks => true

activate :syntax

activate :directory_indexes

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# Add all Opal load paths to sprockets, so we can access opal.js,
# opal-parser.js and opal-jquery.js
set :js_assets_paths, Opal.paths.clone

configure :build do
  activate :minify_css
  activate :minify_javascript
end
