$(function () {

  $.extend($.inputmask.defaults, {
    autoUnmask: true, clearMaskOnLostFocus: true, rightAlign: false,
    allowPlus: false, allowMinus: false, removeMaskOnSubmit: true
  });

  $('.amount').inputmask('currency', {
    prefix: '', clearMaskOnLostFocus: true, rightAlign: false,
    max: 21474836.47, allowPlus: false, allowMinus: false, removeMaskOnSubmit: true
  });

  // var toFr = $('#transaction_amount').val();
  // var formattedAmount = $.inputmask.format(toFr, { alias: 'currency' });
  // console.log(formattedAmount);
  // $('#transaction_amount').val(formattedAmount);
  // var formattedAmount = $.inputmask.format("2331973", { alias: "dd/mm/yyyy"});

  $('.comission').inputmask('currency', {
    prefix: '', clearMaskOnLostFocus: true, rightAlign: false,
    max: 10000, allowMinus: false, allowPlus: false, removeMaskOnSubmit: true
  });
  $('.rate').inputmask('currency', {
    prefix: '', digits: 4, clearMaskOnLostFocus: true, rightAlign: false,
    max: 1000, allowMinus: false, allowPlus: false, removeMaskOnSubmit: true
  });

  $('#q_date_from').inputmask('d/m/y');
  $('#q_date_to').inputmask('d/m/y');

  if ($('#transfer_exchange_rate').size()) {
    show_hide_exchange_rate();
  }
  if ($('#q_period').size()) {
    show_hide_period_additional_input();
  }

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

  $(document).on('change', '#transfer_bank_account_id', function(e) {
    if ($('#transfer_exchange_rate').size()) {
      show_hide_exchange_rate();
    }
  });

  $(document).on('change', '#transfer_reference_id', function(e) {
    if ($('#transfer_exchange_rate').size()) {
      show_hide_exchange_rate();
    }
  });
});

function show_hide_exchange_rate() {
  fromCurr = $('#transfer_bank_account_id option:selected').attr('data_currency');
  toCurr = $('#transfer_reference_id option:selected').attr('data_currency')

  if (fromCurr != undefined && toCurr != undefined && fromCurr != toCurr) {
    $('#transfer_comission').parents('.col-sm-2').addClass('col-sm-1').removeClass('col-sm-2');
    $('#transfer_exchange_rate').parents('.col-sm-1').removeClass('hidden');
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

function datepicker_init(selector) {
  selector.datepicker({
    format: 'dd/mm/yyyy',
    autoclose: true
  });
}
