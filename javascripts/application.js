Opal.queue(function(Opal) {/* Generated by Opal 1.8.2 */
  var $send = Opal.send, $gvars = Opal.gvars, self = Opal.top, nil = Opal.nil;
  if ($gvars.$ == null) $gvars.$ = nil;

  Opal.add_stubs('require,addEventListener,[],querySelector,toggle');
  
  self.$require("opal");
  self.$require("native");
  self.$require("console");
  self.$require("js");
  return $send($gvars.$['$[]']("document"), 'addEventListener', ["DOMContentLoaded"], function $$1(){    if ($gvars.$ == null) $gvars.$ = nil;

    return $send($gvars.$['$[]']("document").$querySelector(".navbar-toggle"), 'addEventListener', ["click"], function $$2(event){var target = nil;
      if ($gvars.$ == null) $gvars.$ = nil;

      
      if (event == null) event = nil;
      target = $gvars.$['$[]']("document").$querySelector(event["currentTarget"]["dataset"]["target"]);
      return target['$[]']("classList").$toggle(event["currentTarget"]["dataset"]["toggle"]);})});
});
