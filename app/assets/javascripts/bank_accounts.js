  $(function() {
    addBankAccountFormMasks();
    var rates = gon.curr_org_ordered_curr;
    if (rates) {
      var tables = new Object();
      var tableId, currencyTable, currency;
      for (var i = 0; i <= rates.length - 1; i++) {
        currency = rates[i].toLowerCase();
        tableId = currency + '-accounts'
        currencyTable = $('#' + tableId);
        tables[tableId] = currencyTable.clone();
        if (currencyTable.length > 0) {
          currencyTable.sortable({
            axis:   "y",
            items:  ".item",
            delay: 200,
            helper: "clone",
            opacity: 0.5,
            containment: "parent",
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
              var it = ui.item;
              return $.ajax({
                type: "PUT",
                url: currencyTable.attr('data-url'),
                dataType: "json",
                data: {
                  id: it.data("item-id"),
                  position: tables[it.parent().attr('id')].children()[it.index()].dataset['startPosition']
                }
              });
            }
          });
        }
      };
    };
  });

function addBankAccountFormMasks() {
  $("form.new_bank_account input[name='bank_account[residue]']").
    inputmask('customized_currency');
}
