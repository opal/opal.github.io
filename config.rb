require 'bundler'
Bundler.require

set :markdown_engine, :redcarpet
set :markdown, :layout_engine => :erb,
               :fenced_code_blocks => true,
                :lax_html_blocks => true

activate :syntax
activate :sprockets

activate :directory_indexes

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'


after_configuration do
  Opal.paths.each do |p|
    sprockets.append_path p
  end
end

configure :build do
  activate :minify_css
  activate :minify_javascript
end
