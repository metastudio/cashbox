$(function () {
  $('.amount').mask('00,000,000.00', {reverse: true} );
  $('.comission').mask('00,000,000.00', {reverse: true} );
  $('.rate').mask('00,000.0000', { reverse: true} );

  $('#q_date_from').mask('00/00/0000');
  $('#q_date_to').mask('00/00/0000');

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

  $(document).on('click', '#clear', function(e) {
    e.preventDefault();

    $('#q_amount_eq').val("");
    $('#q_comment_cont').val("");
    $('#q_category_id_eq').val("");
    $('#q_bank_account_id_eq').val("");
    $('#q_period').val("");
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
