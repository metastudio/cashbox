$(function () {
  addInvoiceFormMasks();

  $('#invoice')
    .on('cocoon:after-insert', function(e) {
      $('.nested-fields td').css('padding', '8px');
      addCustomerSelect2('.nested-customer-select2:last');
    })
});

function addInvoiceFormMasks() {
  var $form = $("form.invoice");
  $form.find("input[name='invoice[amount]']").inputmask('customized_currency');
  datepickerInit($form.find('#invoice_starts_at.datepicker'));
  datepickerInit($form.find('#invoice_ends_at.datepicker'));
  datepickerInit($form.find('#invoice_sent_at.datepicker'));
  datepickerInit($form.find('#invoice_paid_at.datepicker'));
}


