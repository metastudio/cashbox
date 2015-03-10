$(function () {
  addTransactionFormMasks();
  addTranferFormMasks();

  $('#q_date_from').inputmask('d/m/y');
  $('#q_date_to').inputmask('d/m/y');
  $('#q_amount_eq').inputmask('customized_currency');

  showHidePeriodAdditionalInput();

  $(document).on('click', '.transaction[data-edit-url]', function(e) {
    e.preventDefault();

    $.ajax({
      url: $(this).data("edit-url"),
      dataType: "script"
    });
  });

  $(document).on('click', '[data-stop-propagation=true]', function(e) {
    e.stopPropagation();
  });

  $(document).on('click', '#new_transfer_btn', function(e) {
    e.preventDefault();

    $('#new_transaction').hide();
    $('.transaction-type selected').html('Transfer')
    $('#new_transfer_form').show();
  });

  $(document).on('change', '#q_period', function(e) {
    showHidePeriodAdditionalInput();
  });

  $(document).on('click', '.close[data-edit-remove]', function(e) {
    $($(this).attr('data-edit-remove')).remove();
  });

  $(document).on('click', '#new_transaction_btn', function(e) {
    e.preventDefault();

    $('#new_transfer_form').hide();
    $('.transaction-type selected').html('Transaction');
    $('#new_transaction').show();
  });

  $(document).on('change', '#transfer_amount, #transfer_exchange_rate', function(e) {
    prepRateAndHints(exchange_rate = false);
  });

  $(document).on('change', '#transfer_bank_account_id, #transfer_reference_id', function(e) {
    prepRateAndHints(exchange_rate = true);
  });
});

function prepRateAndHints(exchange_rate, hints) {
  var fromCurr = $('#transfer_bank_account_id option:selected').parent().attr('label');
  var toCurr = $('#transfer_reference_id option:selected').parent().attr('label');

  if (exchange_rate) {
    showHideExchangeRate(fromCurr, toCurr);
  }
  addRemoveHints(fromCurr, toCurr);
}

function showHideExchangeRate(fromCurr, toCurr) {
  if (fromCurr != undefined && toCurr != undefined && fromCurr != toCurr ) {
    if (!$('#transfer_exchange_rate').is(":visible")) {
      $('#transfer_comission').parents('.col-sm-2').addClass('col-sm-1').removeClass('col-sm-2');
      $('#transfer_exchange_rate').parents('.col-sm-1').removeClass('hidden');
    }
  }
  else {
    if ($('#transfer_exchange_rate').is(":visible")) {
      $('#transfer_exchange_rate').parents('.col-sm-1').addClass('hidden');
      $('#transfer_comission').parents('.col-sm-1').addClass('col-sm-2').removeClass('col-sm-1');
    }
  }
}

function showHidePeriodAdditionalInput() {
  if($('#q_period').val() == 'custom') {
    datepickerInit($('#q_date_from.datepicker'));
    datepickerInit($('#q_date_to.datepicker'));
    $('#custom-daterange').removeClass('hidden');
  }
  else {
    $('#q_date_from').val('');
    $('#q_date_to').val('');
    $('#custom-daterange').addClass('hidden');
  }
}

function addRemoveHints(fromCurr, toCurr) {
  if (fromCurr === undefined || toCurr === undefined || fromCurr == toCurr ||
    gon.current_org_rates === undefined) {

    if (gon.current_org_rates[fromCurr + '_TO_' + toCurr] === undefined) {
      $('.transfer_reference_id').find('.help-block').remove();
    }
    return;
  }

  var rate_hint = parseFloat(gon.current_org_rates[fromCurr + '_TO_' + toCurr]).toFixed(4);
  var $transferRate = $('.transfer_exchange_rate');
  if ($transferRate.find('.help-block').html() != rate_hint) {
    $transferRate.find('.help-block').remove();
    // there is no help block in the beginning
    $transferRate.append('<span class="help-block">' + rate_hint + '</span>');
  }


  var amount = parseFloat($('#transfer_amount').val().replace(/\,/g,''));
  var rate = parseFloat($('#transfer_exchange_rate').val().replace(/\,/g,''));
  if (amount && rate) {
    var end_sum = (amount * rate).toFixed(2);
    var $transferReference = $('.transfer_reference_id');
    if ($transferReference.find('.help-block').html() != end_sum) {
      $transferReference.find('.help-block').remove();
      // there is no help block in the beginning
      $transferReference.append('<span class="help-block">' + end_sum + '</span>');
    }
  }
}

function datepickerInit(selector) {
  selector.datepicker({
    format: 'dd/mm/yyyy',
    autoclose: true
  });
}

function addTransactionFormMasks() {
  $("form.transaction input[name='transaction[amount]']").inputmask('customized_currency');
}

function addTranferFormMasks() {
  var $form = $("form.transfer");
  $form.find("input[name='transfer[amount]']").inputmask('customized_currency');
  $form.find("input[name='transfer[comission]']").inputmask('customized_currency');
  $form.find("input[name='transfer[exchange_rate]']").inputmask('rate');
}
