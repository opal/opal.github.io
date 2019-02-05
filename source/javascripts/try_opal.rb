require 'opal'
require 'opal-parser'
require 'opal-jquery'
require 'js'

DEFAULT_TRY_CODE = <<-'RUBY'
def title(s)
  puts "~ #{s} ~\n" + '~' * (s.size+4) + "\n\n"
  yield
  puts "\n\n\n"
end

title "The basics" do
  puts say = "I love Ruby"
  puts say.sub('love', "*love*").upcase
  3.times { puts "#{say.sub("love", "❤️")}!" }
end

title "Interacting with the DOM" do
  require 'native'
  puts "The page title is #{$$[:document][:title].inspect}."
  puts "The current URL is #{$$[:location][:href].inspect}."

  # Uncomment the following lines to ask for a name:
  #
  # name = $$.prompt "Please enter your name"
  # $$.alert("Hello #{name}!")
end

title "Classes, objects and procs" do
  class User
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def admin?
      @name == 'Joe'
    end

    def method_missing(name, *args, &block)
      if name.start_with?('can_') && name.end_with?('?')
        admin? ? true : false
      end
    end
  end

  bob = User.new('Bob')
  joe = User.new('Joe')

  user_is_admin = -> user do
    "#{user.name} #{user.admin? ? 'is' : 'is not'} an admin."
  end

  user_can_swim = -> user, action do
    "#{user.name} #{user.can_swim? ? 'can' : 'cannot'} swim."
  end

  puts user_is_admin.call joe
  puts user_can_swim.call joe
  puts user_is_admin.call bob
  puts user_can_swim.call bob
end
RUBY

class TryOpal
  class Editor
    def initialize(dom_id, options)
      @native = `CodeMirror(document.getElementById(dom_id), #{options.to_n})`
    end

    def value=(str)
      `#@native.setValue(str)`
    end

    def value
      `#@native.getValue()`
    end
  end

  def self.instance
    @instance ||= self.new
  end

  def initialize
    @flush = []

    @output = Editor.new :output, lineNumbers: false, mode: 'text', readOnly: true
    @viewer = Editor.new :viewer, lineNumbers: true, mode: 'javascript', readOnly: true, theme: 'tomorrow-night-eighties'
    @editor = Editor.new :editor, lineNumbers: true, mode: 'ruby', tabMode: 'shift', theme: 'tomorrow-night-eighties', extraKeys: {
      'Cmd-Enter' => -> { run_code }
    }

    @link = Element.find('#link_code')
    Element.find('#run_code').on(:click) { run_code }

    hash = `decodeURIComponent(location.hash || location.search)`

    if hash =~ /^[#?]code:/
      @editor.value = hash[6..-1]
    else
      @editor.value = DEFAULT_TRY_CODE.strip
    end
  end

  def compile_code
    @output.value = 'click "Run" to see the output'
    @link[:href] = "?code:#{`encodeURIComponent(#{@editor.value})`}"
    code = Opal.compile(@editor.value, source_map_enabled: false)
    @viewer.value = code
  rescue StandardError, SyntaxError => err
    log_error err
  end

  def run_code
    compile_code
    @flush = []
    eval_code @viewer.value
  rescue StandardError, SyntaxError => err
    log_error err
  end

  def eval_code(js_code)
    `eval(js_code)`
  end

  def log_error(err)
    puts "#{err}\n#{`err.stack`}"
  end

  def print_to_output(str)
    @flush << str
    @output.value = @flush.join('')
  end
end

Document.ready? do
  $stdout.write_proc = $stderr.write_proc = proc do |str|
    TryOpal.instance.print_to_output(str)
  end
  TryOpal.instance.compile_code
end
