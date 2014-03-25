$(function () {
  $(".transactions").on("click", ".transaction[data-edit-url]", function(el) {
    el.preventDefault();
    $.ajax({
      url: $(this).data("edit-url"),
      dataType: "script"
    });
  })
});
