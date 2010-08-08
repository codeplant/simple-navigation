// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery(document).ready(function($) {
  //$('a[rel*=facebox]').facebox();

  $('.example_content a').each(function() {
    var hrefLoc = $(this).attr('href');
    var exampleTag = $(this).closest('.example_content');
    if (!exampleTag.hasClass('no_anchor')) {
      var exampleId = exampleTag.attr('id');
      $(this).attr('href', hrefLoc + '#' + exampleId);
    }
  });

});
