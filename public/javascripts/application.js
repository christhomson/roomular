$(document).ready(function() {
  $("button").click(function() {
    $(this).closest("form").submit();
  });

  var classClassNames = $.unique($(".classes li").map(function(i, e) {
    return $(e).attr('class').split(' ')[0];
  }));

  var colorForClass = function(className) {
    return "rgba(" + Math.round(Math.random() * 255) + ", " + Math.round(Math.random() * 255) + ", " + Math.round(Math.random() * 255) + ", 0.33)"
  };

  classClassNames.each(function(i) {
    var className = classClassNames[i];
    if (className !== 'gap') {
      $("." + className).css({'background': colorForClass(className)});
    }
  });


  if ($(".classes li h3 a").size() > 0) {
    mixpanel.track_links(".classes li h3 a", "Clicked course link", function(e) {
      return {
        course: $(e).closest("a").text()
      }
    });
  }

  $("input#room").focus();
});