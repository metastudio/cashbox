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

//= require transactions
//= require organizations
//= require jquery.inputmask.customization

function scrollTo($el) {
  $("html, body").animate({scrollTop: $el.offset().top}, 300);
}

$(function () {
  $('[data-toggle="tooltip"]').tooltip();
})
