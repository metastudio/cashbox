  $(function() {
    var rates = gon.curr_org_ordered_curr;
    if (rates) {
      var currency, tableId;
      for (var i = 0; i <= rates.length - 1; i++) {
        currency = rates[i].toLowerCase();
        currencyTable = $('#' + currency + '_' + 'accounts');
        if (currencyTable.length > 0) {
          currencyTable.sortable({
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
                url: currencyTable.attr('data-url'),
                dataType: "json",
                data: {
                  id: ui.item.data("item-id"),
                  position: ui.item.index()
                }
              });
            }
          });
        }
      };
    };
  });
