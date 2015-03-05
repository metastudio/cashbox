$(function () {
  addTransactionFormMasks();
  addTranferFormMasks();

  $('#q_date_from').inputmask('d/m/y');
  $('#q_date_to').inputmask('d/m/y');

  show_hide_period_additional_input();

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
    show_hide_period_additional_input();
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

  $(document).on('change', '#transfer_amount', function(e) {
    prep_rate_and_hints(exchange_rate = false, hints = true)
  });

  $(document).on('change', '#transfer_exchange_rate', function(e) {
    prep_rate_and_hints(exchange_rate = false, hints = true)
  });

  $(document).on('change', '#transfer_bank_account_id', function(e) {
    prep_rate_and_hints(exchange_rate = true, hints = true)
  });

  $(document).on('change', '#transfer_reference_id', function(e) {
    prep_rate_and_hints(exchange_rate = true, hints = true)
  });
});

function prep_rate_and_hints(exchange_rate, hints) {
  var fromCurr = $('#transfer_bank_account_id option:selected').parent().attr('label');
  var toCurr = $('#transfer_reference_id option:selected').parent().attr('label');

  if (exchange_rate) {
    show_hide_exchange_rate(fromCurr, toCurr)
  }
  if (hints) {
    add_remove_hints(fromCurr, toCurr);
  }
}

function show_hide_exchange_rate(fromCurr, toCurr) {
  if (fromCurr != undefined && toCurr != undefined && fromCurr != toCurr ) {
    if (!$('#transfer_exchange_rate').is(":visible")) {
      $('#transfer_comission').parents('.col-sm-2').addClass('col-sm-1').removeClass('col-sm-2');
      $('#transfer_exchange_rate').parents('.col-sm-1').removeClass('hidden');
    }
  }
  else {
    if ($('#transfer_exchange_rate').is(":visible")) {
      $('#transfer_exchange_rate').parents('.col-sm-1').addClass('hidden')
      $('#transfer_comission').parents('.col-sm-1').addClass('col-sm-2').removeClass('col-sm-1');
    }
  }
}

function show_hide_period_additional_input() {
  if($('#q_period').val() == 'custom') {
    datepicker_init($('#q_date_from.datepicker'));
    datepicker_init($('#q_date_to.datepicker'));
    $('#custom-daterange').removeClass('hidden');
  }
  else {
    $('#q_date_from').val('');
    $('#q_date_to').val('');
    $('#custom-daterange').addClass('hidden');
  }
}

function add_remove_hints(fromCurr, toCurr) {
  if (fromCurr != undefined && toCurr != undefined && fromCurr != toCurr ) {
    var rate_hint = parseFloat(gon.current_org_rates[fromCurr + '_TO_' + toCurr]).toFixed(4);
    if ($('.transfer_exchange_rate .help-block').html() != rate_hint) {
      $('.transfer_exchange_rate .help-block').remove();
      $('.transfer_exchange_rate').append('<span class="help-block">' + rate_hint + '</span>');
    }

    var amount = parseFloat($('#transfer_amount').val().replace(/\,/g,''));
    var rate = parseFloat($('#transfer_exchange_rate').val().replace(/\,/g,''));
    if (amount && rate) {
      var end_sum = (amount * rate).toFixed(2);
      if ($('.transfer_reference_id .help-block').html() != end_sum) {
        $('.transfer_reference_id .help-block').remove();
        $('.transfer_reference_id').append('<span class="help-block">' + end_sum + '</span>');
      }
    }
  }
}

function datepicker_init(selector) {
  selector.datepicker({
    format: 'dd/mm/yyyy',
    autoclose: true
  });
}

function addTransactionFormMasks() {
  $("form.transaction input[name='transaction[amount]']").inputmask('customized_currency');
}

function addTranferFormMasks() {
  $("form.transfer input[name='transfer[amount]']").inputmask('customized_currency');
  $("form.transfer input[name='transfer[comission]']").inputmask('customized_currency');
  $("form.transfer input[name='transfer[exchange_rate]']").inputmask('customized_currency');
}
