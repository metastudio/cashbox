$(document).on("ready page:load", function () {
  if ($("#usd_accounts").length > 0) {
    $("#usd_accounts").sortable({
      axis:   "y",
      items:  ".item",
      delay: 200,
      helper: "clone",
      opacity: 0.5,
      tolerance: "pointer",
      cursor: "move",
      sort: function(e, ui) {
        return ui.item.addClass("active-item-shadow");
      },
      stop: function(e, ui) {
        ui.item.removeClass("active-item-shadow");
        return ui.item.children("td").effect("highlight", {}, 1000);
      },
      update: function(e, ui) {
        return $.ajax({
          type: "PUT",
          url: $('#usd_accounts').attr('data-url'),
          dataType: "json",
          data: {
            id: ui.item.data("item-id"),
            position: ui.item.index()
          }
        });
      }
    });
  }
  if ($("#rub_accounts").length > 0) {
    $("#rub_accounts").sortable({
      axis:   "y",
      items:  ".item",
      delay: 200,
      helper: "clone",
      opacity: 0.5,
      tolerance: "pointer",
      cursor: "move",
      sort: function(e, ui) {
        return ui.item.addClass("active-item-shadow");
      },
      stop: function(e, ui) {
        ui.item.removeClass("active-item-shadow");
        return ui.item.children("td").effect("highlight", {}, 1000);
      },
      update: function(e, ui) {
        return $.ajax({
          type: "PUT",
          url: $('#rub_accounts').attr('data-url'),
          dataType: "json",
          data: {
            id: ui.item.data("item-id"),
            position: ui.item.index()
          }
        });
      }
    });
  }
});

