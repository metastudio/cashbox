function prepareForm() {
  var categoryId = $("#category_container").data("category");
  $("#transaction_category_id").find('option[value="' + categoryId + '"]').prop('selected', true).end()
   .find("option:not(:selected)").prop('disabled', true);
}

$(function() {
  prepareForm();
  $("#category_container").bind("DOMSubtreeModified", prepareForm);
});
