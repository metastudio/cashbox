$(document).on("ready page:load", function () {
  if ($("#bank_accounts_table").length > 0) {
    return $("#bank_accounts_table").sortable({
      axis:   "y",
      items:  ".item",
      cursor: "move",
      sort: function(e, ui) {
        return ui.item.addClass("active-item-shadow");
      },
      stop: function(e, ui) {
        ui.item.removeClass("active-item-shadow");
        return ui.item.children("td").effect("highlight", {}, 1000);
      },
      update: function(e, ui) {
        var itemId   = ui.item.data("item-id");
        var position = ui.item.index();
        return $.ajax({
          type: "POST",
          url: $('#bank_accounts_table').attr('data-url'),
          dataType: "json",
          data: {
            id: itemId,
            position: position
          }
        });
      }
    });
  }
});
