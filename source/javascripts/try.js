//= require _vendor/codemirror/codemirror
//= require _vendor/codemirror/ruby
//= require _vendor/codemirror/javascript
//= require _vendor/codemirror/coffeescript

//= require _vendor/js2coffee.min

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
  var viewJs = document.getElementById('view_js');
  var viewCs = document.getElementById('view_cs');

  // Add Event Handlers
  if (document.addEventListener) {
    run.addEventListener('click', compile, false);
    viewJs.addEventListener('click', setViewerModeJs, false);
    viewCs.addEventListener('click', setViewerModeCs, false);
  }
  // Support for older IE versions
  else {
    run.attachEvent('onclick', compile);
    viewJs.attachEvent('onclick', setViewerModeJs);
    viewCs.attachEvent('onclick', setViewerModeCs);
  }

  // Functions to update editor and viewer content
  function setViewerModeJs() { setViewerMode("js") }
  function setViewerModeCs() { setViewerMode("cs") }

  function setViewerMode( mode ) {
    if (mode == "js") {
      viewJs.classList.remove('disabled');
      viewCs.classList.add('disabled');
      viewer.setOption('mode','javascript')
    } else if (mode == "cs") {
      viewCs.classList.remove('disabled');
      viewJs.classList.add('disabled');
      viewer.setOption('mode','coffeescript');
    }
    compile();
  }

  function compile() {
    var old_puts = Opal.puts;
    var flush   = [];
    Opal.puts = function(a) {
      flush.push(a);
      output.setValue(flush.join("\n"));
    };

    output.setValue('');

    try {
      // Parse ruby into javascript
      var code = Opal.Opal.Parser.$new().$parse(editor.getValue());
      var viewerCode = code;
      // Process javascript into coffescript, if viewer in coffeescript mode
      window.viewer = viewer;
      if ( viewer.getMode().name=="coffeescript" ) {
        // Build javascript into coffescript
        viewerCode = Js2coffee.build(code);
      }
      // Update code in Viewer
      viewer.setValue(viewerCode);
      
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
