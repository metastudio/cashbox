$(function () {
  addInvoiceFormMasks();

  $('#invoice')
    .on('cocoon:after-insert', function(e) {
      $('.nested-fields td').css('padding', '8px');
      addInvoiceNestedCustomerSelect2();
    })
});

function addInvoiceFormMasks() {
  var $form = $("form.invoice");
  $form.find("input[name='invoice[amount]']").inputmask('customized_currency');
  datepickerInit($form.find('#invoice_starts_at.datepicker'));
  datepickerInit($form.find('#invoice_ends_at.datepicker'));
  datepickerInit($form.find('#invoice_sent_at.datepicker'));
  datepickerInit($form.find('#invoice_paid_at.datepicker'));
  addInvoiceCustomerSelect2($form);
  addInvoiceNestedCustomerSelect2()
}

function addInvoiceCustomerSelect2($form) {
  var lastResultNames = [];
  var $customerField = $form.find("input[name='invoice[customer_name]']");
  var url = $customerField.data('url');

  $customerField.select2({
    maximumInputLength: 255,
    width: 'resolve',
    ajax: {
      url: url,
      dataType: "json",
      data: function (name_includes) {
        var queryParameters = {
          query: { term: name_includes }
        }
        return queryParameters;
      },
      results: function(data, page) {
        lastResultNames = $.map( data, function(customer, i) { return customer.name });
        return {
          results: $.map( data, function(customer, i) {
            return {
              id: customer.name, text: customer.name
            }
          })
        }
      }
    },
    createSearchChoice: function (input) {
      input = input.replace(/^\s+/, '').replace(/\s+$/, '')
      if (input !== '')
      {
        var new_item = lastResultNames.indexOf(input) < 0;
        if (new_item) {
          return { id: input, text: input + " (new)" }
        }
      }
    }
  });

  var name = $customerField.data('value');
  if (name) {
    $customerField.select2("data", { id: name, text: name });
  }
}

function addInvoiceNestedCustomerSelect2() {
  var lastResultNames = [];

  $('.nested-customer').each(function() {
    $(this).select2({
      maximumInputLength: 255,
      width: 'resolve',
      ajax: {
        url: $(this).data('url'),
        dataType: "json",
        data: function (name_includes) {
          var queryParameters = {
            query: { term: name_includes }
          }
          return queryParameters;
        },
        results: function(data, page) {
          lastResultNames = $.map( data, function(customer, i) { return customer.name });
          return {
            results: $.map( data, function(customer, i) {
              return {
                id: customer.name, text: customer.name
              }
            })
          }
        }
      },
      createSearchChoice: function (input) {
        input = input.replace(/^\s+/, '').replace(/\s+$/, '')
        if (input !== '')
        {
          var new_item = lastResultNames.indexOf(input) < 0;
          if (new_item) {
            return { id: input, text: input + " (new)" }
          }
        }
      }
    });

    var name = $(this).data('value');
    if (name) {
      $(this).select2("data", { id: name, text: name });
    }
  });
}


