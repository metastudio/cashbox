$(function () {

  'use strict';

  var organization = $('#current_organization').text().trim();

  if (location.pathname === "/" && location.search === '') {
    var current_user_id = $('.current_user_id').data('id');
    App.cable.subscriptions.create({
      channel: "MainPageChannel",
      organization: organization
    }, {
      received: function(data) {
        if (data['user_id'] !== current_user_id) {
          addTransactionToList (
            data['id'],
            data['view'],
            data['sidebar'],
            data['total_balance']
          );
        }
      }
    });
  }
});
