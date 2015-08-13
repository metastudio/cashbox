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

  $(document).on('click', ".transaction .dropdown-menu li a, .transfer .dropdown-menu li a", function(e) {
    if ($(this).html() == 'Transfer') {
      $('#new_transaction').hide();
      $('#new_transfer_form').show();
    }
    else {
      $('#new_transfer_form').hide();
      $('#new_transaction').show();
    }
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

  $(document).on('keypress', '.select2-input', function(e) {
    if (e.keyCode === 32 && this.selectionStart === 0) {
      return false;
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
      $('#transfer_exchange_rate').parents('.col-sm-6').removeClass('hidden');
    }
  }
  else {
    if ($('#transfer_exchange_rate').is(":visible")) {
      $('#transfer_exchange_rate').parents('.col-sm-6').addClass('hidden');
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
    gon.curr_org_exch_rates === undefined) {

    if (gon.curr_org_exch_rates[fromCurr + '_TO_' + toCurr] === undefined) {
      $('.transfer_reference_id').find('.help-block').remove();
    }
    return;
  }

  var rate_hint = parseFloat(gon.curr_org_exch_rates[fromCurr + '_TO_' + toCurr]).toFixed(4);
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
