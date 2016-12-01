require 'opal'
require 'opal-parser'

require '_vendor/jquery'
require '_vendor/bootstrap'
require 'opal-jquery'

require '_vendor/codemirror'
require '_vendor/ruby'

require '_playground/editor'

module Playground
  class RSpecRunner
    def initialize
      @ruby = Playground::Editor.new(:ruby_pane, mode: 'ruby', lineNumbers: true,
                         theme: 'tomorrow-night-eighties', extraKeys: {
                          'Cmd-Enter' => proc { run_code }
                        })

      @result = Element['#result_pane']

      Element.find('#run-code').on(:click) { run_code }
      @link = Element.find('#link-code')

      hash = `decodeURIComponent(location.hash)`

      if hash.start_with? '#code:'
        @ruby.value = hash[6..-1]
      else
        @ruby.value = RUBY.strip
      end

      run_code
    end

    def run_code
      @link[:href] = "#code:#{`encodeURIComponent(#{@ruby.value})`}"
      js = Opal.compile @ruby.value

      update_iframe(<<-HTML)
        <!DOCTYPE html>
        <html>
          <head>
          </head>
          <body>
            <script src="../javascripts/rspec_results.js"></script>
            <script>
              #{js}
            </script>
            <script>
              Opal.Opal.RSpec.Runner.$autorun();
            </script>
            <style>
              #label { display: none; }
              #display-filters { display: none; }
            </style>
          </body>
        </html>
      HTML
    rescue => e
      alert "#{e.class}: #{e.message}"
    end

    def update_iframe(html)
      @result.html = <<-HTML
        <iframe class="result-frame" frameborder="0" style="width: 100%; height: 100%"></iframe>
      HTML

      iframe_element = Element[".result-frame"]

      %x{
        var iframe = #{iframe_element}[0], doc;

        if (iframe.contentDocument) {
          doc = iframe.contentDocument;
        } else if (iframe.contentWindow) {
          doc = iframe.contentWindow.document;
        } else {
          doc = iframe.document;
        }

        doc.open()
        doc.write(#{html});
        doc.close();
      }
    end

    RUBY = <<-EOF
User = Struct.new(:name) do
  def admin?
    name == 'Ford Prefect'
  end
end

describe 'User' do
  it "should initialize with the given name" do
    expect(User.new('Adam').name).to eq('Adam')
  end

  it "should be an admin only if user is Ford Prefect" do
    expect(User.new('Adam')).to_not be_admin
    expect(User.new('Ford Prefect')).to be_admin
  end

  it "compares admin? using ==" do
    name = double("name")
    expect(name).to receive(:==).once.and_return(true)
    user = User.new(name)
    # uncomment this line and re-running
    # user.admin?
  end
end
    EOF
  end
end

Document.ready? do
  Playground::RSpecRunner.new
end
