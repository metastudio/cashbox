(function ($) {
  $.extend($.inputmask.defaults.aliases, {
    'customized_currency': {
      alias: 'currency',
      prefix: '',
      groupSeparator: ' ',
      digitsOptional: true,
      clearMaskOnLostFocus: true,
      rightAlign: false,
      allowPlus: false,
      allowMinus: false,
      removeMaskOnSubmit: true,
    }
  });
})(jQuery);

