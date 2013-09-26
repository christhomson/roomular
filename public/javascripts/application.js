$(document).ready(function() {
  $("button").click(function() {
    $(this).closest("form").submit();
  });

  var classClassNames = $.unique($("#days .classes li").map(function(i, e) {
    return $(e).attr('class');
  }));

  var colorForClass = function(className) {
    var splitCourseCode = className.match(/([A-Z]*)([0-9]*)/)
    var rgbValues;
    switch (splitCourseCode[1]) {
      case "MATH": rgbValues = [232, 150, 200]; break;
      case "CS": rgbValues = [57, 219, 232]; break;
      case "STAT": rgbValues = [216, 255, 32]; break;
      case "CO": rgbValues = [59, 255, 106]; break;
      case "SCI": rgbValues = [51, 61, 255]; break;
      case "PHYS": rgbValues = [151, 76, 255]; break;
      case "CHEM": rgbValues = [232, 53, 24]; break;
      case "CHE": rgbValues = [232, 87, 135]; break;
      case "BIOL": rgbValues = [28, 232, 0]; break;
      case "ENVS": rgbValues = [51, 61, 255]; break;
      case "ENVE": rgbValues = [232, 57, 49]; break;
      case "PSYCH": rgbValues = [232, 224, 33]; break;
      case "PHIL": rgbValues = [232, 96, 17]; break;
      case "AFM": rgbValues = [151, 47, 232]; break;
      case "ECON": rgbValues = [151, 47, 232]; break;
      case "AHS": rgbValues = [35, 255, 157]; break;
      case "KIN": rgbValues = [232, 48, 45]; break;
      case "ACTSC": rgbValues = [218, 232, 47]; break;
      case "MSCI": rgbValues = [92, 232, 131]; break;
      case "REC": rgbValues = [133, 80, 232]; break;
      case "EARTH": rgbValues = [23, 135, 27]; break;
      case "MTE": rgbValues = [64, 135, 92]; break;
      case "NE": rgbValues = [235, 232, 80]; break;
      case "ME": rgbValues = [93, 195, 232]; break;
      case "ECE": rgbValues = [255, 195, 107]; break;
      case "GEOG": rgbValues = [53, 232, 82]; break;
      case "GERON": rgbValues = [135, 26, 15]; break;
      case "HRM": rgbValues = [135, 111, 23]; break;
      case "HIST": rgbValues = [232, 63, 0]; break;
      case "SPAN": rgbValues = [135, 120, 61]; break;
      case "STV": rgbValues = [96, 41, 232]; break;
      case "CIVE": rgbValues = [135, 120, 37]; break;
      default:
        rgbValues = [Math.round(Math.random() * 255), Math.round(Math.random() * 255), Math.round(Math.random() * 255)];
    }

    rgbValues[0] = Math.round(splitCourseCode[2] / 800 * rgbValues[0]) + rgbValues[0] + (splitCourseCode[2][1] * 6) - (splitCourseCode[2][2] * 3)
    rgbValues[1] = Math.round(splitCourseCode[2] / 800 * rgbValues[1]) + rgbValues[1] - (splitCourseCode[2][1] * 6) + (splitCourseCode[2][2] * 3)
    rgbValues[2] = Math.round(splitCourseCode[2] / 800 * rgbValues[2]) + rgbValues[2] + (splitCourseCode[2][1] * 6) + (splitCourseCode[2][2] * 3)
    return "rgbA(" + rgbValues[0] + ", " + rgbValues[1] + ", " + rgbValues[2] + ", " + 0.8 + ")"
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