require 'bundler'
Bundler.require

# https://stackoverflow.com/a/71994319
require 'uri'
def URI.escape(url)
  url
end

set :markdown_engine, :redcarpet

set :markdown, layout_engine: :erb,
               fenced_code_blocks: true,
               lax_html_blocks: true,
               with_toc_data: true

activate :syntax

activate :blog do |blog|
  blog.prefix = "blog"
end

activate :directory_indexes

set :images_dir, 'images'

page "/docs/*", :layout => "docs"
page "/blog/*", :layout => :blog

configure :build do
  activate :minify_css
end

helpers do
  def body_for(resource)
    html = resource.render layout: nil
    Nokogiri::HTML::DocumentFragment.parse html
  end

  def javascript_include_tag(name, options = {})
    options.merge!(onload: Opal::Sprockets.load_asset(name) + ";console.log('loaded #{name}')")
    super(sprockets_path(name + ".js") || name, options)
  end

  def stylesheet_link_tag(name, options = {})
    super(sprockets_path(name + ".css") || name, options)
  end

  def sprockets_path(name)
    assets_path = Dir["#{__dir__}/source/assets/.*.json"].first
    assets = File.exist?(assets_path) ? JSON.parse(File.read(assets_path)) : {}
    asset = assets.dig("assets", name)
    asset ? "/assets/#{asset}" : nil
  end

  def table_of_contents(resource)
    body = body_for resource

    content = []
    in_list = false

    headings = body.css('h2,h3')
    headings.each_with_index do |h, idx|
      subheading = h.name == 'h3'

      if subheading and !in_list
        in_list = true
        content << %Q{\n<ul class="subchapter">}
      elsif !subheading and in_list
        in_list = false
        content << "\n</ul>"
      elsif subheading
        in_list = true
      end

      li_class = subheading ? 'toc-list-subchapter' : 'toc-list-chapter'

      content << %Q{\n<li class="#{li_class}">}
      content << content_tag(:a, h.text, href: '#' + h[:id].to_s)

      unless headings[idx + 1] && headings[idx + 1].name == 'h3'
        content << '</li>'
      end
    end

    content << "\n</ul></li>" if in_list

    %Q{<ul class="nav opal-sidebar">#{content.join}</ul>}
  end
end

ignore '*.sass'
ignore '*.scss'

activate(:external_pipeline,
  name: :sprockets,
  command: "bin/build-sprockets #{'--watch' unless build?}",
  source: "assets/",
)
