$(function () {
  addTransactionFormMasks();
  addTranferFormMasks();

  $('#q_amount_eq').inputmask('customized_currency');
  $('#q_customer_id_eq').select2();

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

  $(document).on('click', '.clear-form', function(e) {
    e.preventDefault();

    // clear all fields in the form, instead of the standard reset
    $(this).closest('form').find(':input').removeAttr('checked').removeAttr('selected').not(':button, :submit, :reset, :hidden, :radio, :checkbox').val('');
    $('#q_customer_id_eq').select2('data', { id: 0, text: 'Customer' });
  });

  $(document).on('change', '#q_period', function(e) {
    showHidePeriodAdditionalInput();
  });

  $(document).on('click', '.close[data-edit-remove]', function(e) {
    $($(this).attr('data-edit-remove')).remove();
  });

  $(document).on('change', '#transfer_amount, #transfer_exchange_rate', function(e) {
    prepRateAndHints(exchange_rate = false);
  });

  $(document).on('change', '#transfer_bank_account_id, #transfer_reference_id', function(e) {
    prepRateAndHints(exchange_rate = true);
  });

  $('.select2-input').on('keypress', function(e) {
    if (e.keyCode === 32 && this.selectionStart === 0) {
      return false;
    }
  });

  $(document).on('click', '#submit_btn', function(e) {
    if ($(".tab-pane.active").attr('id') == 'transfer') {
      $('.tab-pane.active #new_transfer_form').submit();
    } else {
      $('.tab-pane.active #new_transaction').submit();
      trans_id = $('#submit_btn').data('trans-id');
      $('#edit_transaction_' + trans_id).submit();
    }
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
      $('#transfer_exchange_rate').parents('#rate_col').removeClass('hidden');
    }
  }
  else {
    if ($('#transfer_exchange_rate').is(":visible")) {
      $('#transfer_exchange_rate').parents('#rate_col').addClass('hidden');
      //$('#transfer_exchange_rate').parents('#rate_col').find('#rate_hint').remove();
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
  var $transferRate = $('.transfer_exchange_rate');
  if (fromCurr === undefined || toCurr === undefined || fromCurr == toCurr ||
    gon.curr_org_exch_rates === undefined) {
    return;
  }

  var rate_hint = parseFloat(gon.curr_org_exch_rates[fromCurr + '_TO_' + toCurr]).toFixed(4);
  var rate_hint_input = '<p class="help-block" id="rate_hint">Default rate: ' + rate_hint + '</p>'
  $transferRate.parents('#rate_col').find('#rate_hint').remove();
  $transferRate.parents('#rate_col').prepend(rate_hint_input);

  var amount = parseFloat($('#transfer_amount').val().replace(/\,/g,''));
  var rate = parseFloat($('#transfer_exchange_rate').val().replace(/\,/g,''));
  if (amount && rate) {
    var end_sum = (amount * rate).toFixed(2);
    var end_sum_input = '<p class="help-block" id="end_sum_hint">Calculate sum: ' + end_sum + '</p>'
    $transferRate.parents('#rate_col').find('#end_sum_hint').remove();
    $transferRate.parents('#rate_col').append(end_sum_input);
  }
}

function datepickerInit(selector) {
  selector.datepicker({
    format: 'dd/mm/yyyy',
    startDate: '01/01/1900',
    endDate: '+1y',
    autoclose: true,
    todayHighlight: true,
    todayBtn: true
  });
}

function addTransactionFormMasks() {
  var $form = $("form.transaction")
  $form.find("input[name='transaction[amount]']").inputmask('customized_currency');
  datepickerInit($form.find('#transaction_date.datepicker'));
  addCustomerSelect2($form);
}

function addTranferFormMasks() {
  var $form = $("form.transfer");
  $form.find("input[name='transfer[amount]']").inputmask('customized_currency');
  $form.find("input[name='transfer[comission]']").inputmask('customized_currency');
  $form.find("input[name='transfer[exchange_rate]']").inputmask('rate');
  datepickerInit($form.find('#transfer_date.datepicker'));
}

function addCustomerSelect2($form) {
  var lastResultNames = [];
  var $customerField = $form.find("input[name='transaction[customer_name]']");
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
