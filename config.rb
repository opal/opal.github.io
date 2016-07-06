require 'bundler'
Bundler.require

set :markdown_engine, :redcarpet

set :markdown, layout_engine: :erb,
               fenced_code_blocks: true,
               lax_html_blocks: true,
               with_toc_data: true

activate :syntax
activate :sprockets

activate :blog do |blog|
  blog.prefix = "blog"
end

activate :directory_indexes

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

page "/docs/*", :layout => "docs"
page "/blog/*", :layout => :blog

after_configuration do
  Opal.paths.each do |p|
    sprockets.append_path p
  end
end

configure :build do
  activate :minify_css
  activate :minify_javascript
end

helpers do
  def body_for(resource)
    html = resource.render layout: nil
    Nokogiri::HTML::DocumentFragment.parse html
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
