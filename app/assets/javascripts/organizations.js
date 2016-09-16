$(function () {

  'use strict';

  $(document).ready(function () {
    $('.btn.new_account').on('ajax:success', function (e, data, status, xhr) {
      $('.row.new_account_form').empty();
      $('.row.previous_buttons').hide();
      $('.row.new_account_form').append(data);
    }).on('ajax:error', function (e, xhr, status, error) {
      $('.row.new_account_form').empty();
      $('.row.previous_buttons').hide();
      $('.row.new_account_form').append('<p>ERROR</p>');
    });
  });

});
