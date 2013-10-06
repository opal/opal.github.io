//= require _vendor/codemirror
//= require _vendor/ruby
//= require _vendor/javascript
//= require opal
//= require opal-parser
//= require opal-jquery

$(function() {
  var output = CodeMirror(document.getElementById("output"), {
    lineNumbers: false,
    mode: "javascript",
    readOnly: true
  });

  var viewer = CodeMirror(document.getElementById("viewer"), {
    lineNumbers: true,
    mode: "javascript",
    readOnly: true
  });

  var editor = CodeMirror(document.getElementById("editor"), {
    lineNumbers: true,
    mode: "ruby",
    tabMode: "shift"
  });

  var run = document.getElementById('run_code');
  var link = document.getElementById('link_code');

  if (run.addEventListener) {
    run.addEventListener('click', compile, false);
  }
  else {
    run.attachEvent('onclick', compile);
  }

  var flush = [];

  var puts = function(str) {
    flush.push(str);
    output.setValue(flush.join("\n"));
  };

  Opal.gvars.stdout.$puts = function() {
    for (var i = 0; i < arguments.length; i++) {
      puts(arguments[i]);
    }
  };

  // Functions to update editor and viewer content
  function compile() {
    flush   = [];
    output.setValue('');

    try {
      var code = Opal.Opal.Parser.$new().$parse(editor.getValue(), Opal.hash("source_map_enabled", false));
      viewer.setValue(code);
      eval(code);
    }
    catch (err) {
      puts('' + err + "\n" + err.stack);
    }

    link.href = '#code:' + encodeURIComponent(editor.getValue());
    return false;
  }

  var hash = decodeURIComponent(location.hash);
  if (hash.indexOf('#code:') === 0) {
    editor.setValue(hash.substr(6));
  }
  else {
    editor.setValue("class Foo\n  attr_accessor :name\n\n  def method_missing(sym, *args, &block)\n    puts \"You tried to call: #{sym}\"\n  end\nend\n\nadam = Foo.new\nadam.name = 'Adam Beynon'\nputs adam.name\nadam.do_task");
  }

  compile();
});
