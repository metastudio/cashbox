$(function () {

  'use strict';

  var organization = $('#current_organization').text().trim();

  if (location.pathname === "/" && location.search === '') {
    console.log("on main");
    App.cable.subscriptions.create({
      channel: "MainPageChannel",
      organization: organization
    }, {
      received: function(data) {
        $(data['view']).prependTo('.transactions').hide().fadeIn(1000);
        var bgc = $(data['id']).css('backgroundColor');
        $(data['id']).addClass('new-transaction');
        $(data['id']).animate({
          backgroundColor: bgc,
        }, 1000 );
        $("#sidebar").replaceWith(data['sidebar']);
        $("#total_balance").replaceWith(data['total_balance']);
      }
    });
  }
});