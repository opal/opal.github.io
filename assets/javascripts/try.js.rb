# backtick_javascript: true

require '_vendor/codemirror'
require '_vendor/ruby'
require '_vendor/javascript'
require 'try/examples'

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

  def initialize
    @flush = []

    @output = Editor.new :output, lineNumbers: false, mode: 'text', readOnly: true
    @viewer = Editor.new :viewer, lineNumbers: true, mode: 'javascript', readOnly: true, theme: 'tomorrow-night-eighties'
    @editor = Editor.new :editor, lineNumbers: true, mode: 'ruby', tabMode: 'shift', theme: 'tomorrow-night-eighties', extraKeys: {
      'Cmd-Enter' => -> *q { run_code }
    }
  end

  def setup_links
    $$[:document].querySelector('#run_code').addEventListener(:click) { |event|
      event.JS.preventDefault
      event.JS.stopPropagation
      run_code
    }

    $$[:document].querySelector('#link_code').addEventListener(:click) { |event|
      event.JS.preventDefault
      event.JS.stopPropagation
      $$[:location][:hash] = ""
      $$[:location][:search] = "code=#{$$.encodeURIComponent(@editor.value)}"
    }

    examples_container = $$[:document].querySelector('#examples')
    examples_container.innerText = ''

    TRY_EXAMPLES.each do |title, code|
      url = "?example=#{$$.encodeURIComponent(title)}"

      link = $$[:document].createElement(:a)
      link[:href] = url
      link[:innerText] = title

      spacer = $$[:document].createTextNode '   '

      link.addEventListener(:click) do |event|
        event.JS.preventDefault
        event.JS.stopPropagation

        @editor.value = code
        compile_code
        $$[:history].replaceState(
          {
            title: title,
            code: code,
          },
          nil.to_n,
          url
        )
      end

      $console.log(link)

      examples_container.appendChild spacer
      examples_container.appendChild link
    end
  end

  def setup_code
    hash = $$.decodeURIComponent($$[:location][:hash])
    search = $$.decodeURIComponent($$[:location][:search])
    run = false

    if hash.start_with?('#code=')
      title = "Code from url (hash)"
      code = hash['#code='.size..-1]

    elsif hash.start_with?('#code:')
      title = "Code from url (hash)"
      code = hash['#code:'.size..-1]

    elsif search.start_with?('?code=')
      title = "Code from url (query)"
      code = search['?code='.size..-1]

    elsif search.start_with?('?example=')
      title = search['?example='.size..-1]
      code = TRY_EXAMPLES[title].strip

    else
      title = 'Overview'
      code = TRY_EXAMPLES[title].strip
      run = true
    end

    @editor.value = code
    compile_code
    run_code if run
  end

  def setup
    setup_links
    setup_code
  end

  # Inspect in the browser console
  def p(*args)
    $console.log(*args.map(&:inspect))
    return *args
  end

  def compile_code
    @output.value = 'click "Run" to see the output'
    $$[:document].querySelector('#output').css(opacity: '0.5')
    code = Opal.compile(@editor.value, source_map_enabled: false)
    @viewer.value = code
  rescue StandardError, SyntaxError => err
    log_error err
  end

  def run_code
    compile_code
    @flush = []
    @output.value = ''
    eval_code @viewer.value
    $$[:document].querySelector('#output')[:style][:opacity] = '1'
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

  def attempt_compilation(ready: nil, parser: nil)
    @ready ||= ready
    @parser ||= parser
    compile_code if @ready && @parser
  end
end
$try = TryOpal.new

p $$[:document][:readyState]

case $$[:document][:readyState]
when :complete, :loaded, :interactive
  $try.setup
  $try.attempt_compilation ready: true
else
  $$[:document].addEventListener :DOMContentLoaded do
    $try.setup
    $try.attempt_compilation ready: true
  end
end

$$[:document].addEventListener :parser_loaded do
  p :parser_loaded
  $try.attempt_compilation parser: true
end

$stdout.write_proc = $stderr.write_proc = proc do |str|
  $try.print_to_output(str)
end
