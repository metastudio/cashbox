(function ($) {
  $.extend($.inputmask.defaults.aliases, {
    'customized_currency': {
      prefix: '',
      alias: 'currency',
      clearMaskOnLostFocus: true,
      rightAlign: false,
      allowPlus: false,
      allowMinus: false,
      removeMaskOnSubmit: true,
    },
    'rate': {
      alias: 'customized_currency',
      digits: 4
    }
  });
})(jQuery);

