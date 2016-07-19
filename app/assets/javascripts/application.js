// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/sortable
//= require jquery-ui/effect-highlight
//= require bootstrap
//= require moment
//= require bootstrap-datepicker
//= require jquery.inputmask
//= require jquery.inputmask.date.extensions
//= require jquery.inputmask.numeric.extensions
//= require jquery.responsiveText
//= require jquery-responsiveTables

//= require transactions
//= require bank_accounts
//= require statistics
//= require invoices
//= require jquery.inputmask.customization
//= require select2
//= require cocoon

function scrollTo($el) {
  $("html, body").animate({scrollTop: $el.offset().top}, 300);
}

$(function () {
  $('[data-toggle="tooltip"]').tooltip();
  $('.responsive-table').responsiveTables();
  $('.responsive-text').responsiveText();
})

$(function () {
  addCustomerSelect2('.customer-select2');
  addCustomerSelect2('.nested-customer-select2');
})

function addCustomerSelect2(fields) {
  var lastResultNames = [];
  $(fields).each(function() {
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
