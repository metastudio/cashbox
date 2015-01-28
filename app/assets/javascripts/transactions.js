$(function () {
  $(document).on('click', '.transaction[data-edit-url]', function(e) {
    e.preventDefault();
    $.ajax({
      url: $(this).data("edit-url"),
      dataType: "script"
    });
  });
});
