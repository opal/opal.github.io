//= require _vendor/codemirror
//= require _vendor/ruby
//= require _vendor/javascript
//= require _vendor/opal
//= require _vendor/opal-parser
//= require _vendor/opal-jquery

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

  // Functions to update editor and viewer content
  function compile() {
    var old_puts = Opal.puts;
    var flush   = [];
    Opal.puts = function(a) {
      flush.push(a);
      output.setValue(flush.join("\n"));
    };

    output.setValue('');

    try {
      var code = Opal.Opal.Parser.$new().$parse(editor.getValue());
      viewer.setValue(code);
      eval(code);
    }
    catch (err) {
      Opal.puts('' + err + "\n" + err.stack);
    }

    Opal.puts = old_puts;
    link.href = '#code:' + encodeURIComponent(editor.getValue());
    return false;
  }

  var hash = decodeURIComponent(location.hash);
  if (hash.indexOf('#code:') === 0) {
    editor.setValue(hash.substr(6));
  }
  else {
    editor.setValue("class Foo\n  attr_accessor :name\nend\n\nadam = Foo.new\nadam.name = 'Adam Beynon'\nputs adam.name");
  }

  compile();
});
