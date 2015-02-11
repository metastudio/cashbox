$(function () {
  if ($('#transfer_exchange_rate').size()) {
    show_hide_exchange_rate();
  }

  $(document).on('click', '.transaction[data-edit-url]', function(e) {
    e.preventDefault();

    $.ajax({
      url: $(this).data("edit-url"),
      dataType: "script"
    });
  });

  $(document).on('click', '.category-link', function(e) {
    e.stopPropagation();
  });

  $(document).on('click', '#new_transfer_btn', function(e) {
    e.preventDefault();

    $('#new_transaction').hide();
    $('.transaction-type selected').html('Transfer')
    $('#new_transfer_form').show();
  });

  $(document).on('change', '#q_period', function(e) {
    if ($('#transfer_exchange_rate').size()) {
      show_hide_exchange_rate();
    }
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
    $('#q_custom_period.daterange').daterangepicker({ format: 'DD/MM/YYYY' });
    show_input($('#q_custom_period.daterange'));
  }
  else {
    hide_input($('#q_custom_period.daterange'));
  }
}

function show_input(input) {
  input.parents('.col-sm-2').removeClass('hidden');
  input.attr('disabled', false);
}
function hide_input(input) {
  input.parents('.col-sm-2').addClass('hidden');
  input.attr('disabled', true);
}
