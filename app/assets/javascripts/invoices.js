$(function () {
  addInvoiceFormMasks();

  $('#invoice')
    .on('cocoon:after-insert', function(e) {
      $('.nested-fields td').css('padding', '8px');
      addCustomerSelect2('.nested-customer-select2:last');
      $('.nested-amount:last').inputmask('customized_currency');
      $('#invoice_amount').prop('disabled', true);
    })
    .on('cocoon:after-remove', function(e) {
      calculateInvoiceAmount();
      $('#invoice_amount').prop('disabled', ($('#invoice tr.nested-fields:visible').size() > 0));
    })

  $(document).on('change', '.nested-amount', function(e) {
    calculateInvoiceAmount();
  });
});

function addInvoiceFormMasks() {
  var $form = $("form.invoice");
  $form.find("input[name='invoice[amount]']").inputmask('customized_currency');
  $('.nested-amount').each(function() {
    $(this).inputmask('customized_currency');
  });
  datepickerInit($form.find('#invoice_starts_at.datepicker'));
  datepickerInit($form.find('#invoice_ends_at.datepicker'));
  datepickerInit($form.find('#invoice_sent_at.datepicker'));
  datepickerInit($form.find('#invoice_paid_at.datepicker'));
}

function calculateInvoiceAmount() {
  var sum = 0;
  $('.nested-amount').each(function() {
    sum = sum + parseFloat($(this).val().replace(/\,/g,''));
  });
  $("#invoice_amount").val(sum);
}


