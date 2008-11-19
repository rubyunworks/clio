
$.getScript("http://tigerops.org/assets/libs/shjs/sh_main.js");
$.getScript("http://tigerops.org/assets/libs/shjs/lang/sh_ruby.js");

/* $.getScript('../assets/systems/prettify/prettify.js') */

$(document).ready(function(){
  /* $.toc('#content h1,h2,h3,h4').appendTo('.toc'); */
  $('pre').addClass('sh_ruby');
  sh_highlightDocument();
});

