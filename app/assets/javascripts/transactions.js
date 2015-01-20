$(function () {
  $(".transactions").on("click", ".transaction[data-edit-url]", function(el) {
    el.preventDefault();
    $.ajax({
      url: $(this).data("edit-url"),
      dataType: "script"
    });
  })

  $(document).on('click', '#new_transfer_btn', function(e) {
    e.preventDefault();

    $('#new_transaction').hide();
    $('#new_transfer_transaction').show();
  });

  $(document).on('click', '#new_residue_btn', function(e) {
    e.preventDefault();

    $('#new_transfer_transaction').hide();
    $('#new_transaction').show();
  });
});
