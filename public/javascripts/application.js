$(document).ready(function() {
  $("button").click(function() {
    $(this).closest("form").submit();
  });
});