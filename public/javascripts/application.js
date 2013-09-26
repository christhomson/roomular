$(document).ready(function() {
  $("button").click(function() {
    $(this).closest("form").submit();
  });

  var classClassNames = $.unique($("#days .classes li").map(function(i, e) {
    return $(e).attr('class');
  }));

  var colorForClass = function(className) {
    return "rgb(" + Math.round(Math.random() * 255) + ", " + Math.round(Math.random() * 255) + ", " + Math.round(Math.random() * 255) + ")"
  };

  classClassNames.each(function(i) {
    var className = classClassNames[i];
    $("." + className).css({'background': colorForClass(className)});
  });

  $(".classes li").each(function(i, e) {
    paddingPercent = (3.57 * $(e).data('half-hours')) + '%'
    $(e).css({'padding-top': paddingPercent, 'padding-bottom': paddingPercent});
  });

  $("input#room").focus();
});