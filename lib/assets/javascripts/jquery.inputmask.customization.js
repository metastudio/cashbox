(function ($) {
  $.extend($.inputmask.defaults.aliases, {
    'customized_currency': {
      alias: 'currency',
      prefix: '',
      clearMaskOnLostFocus: true,
      rightAlign: false,
      allowPlus: false,
      allowMinus: false,
      radixFocus: false,
      removeMaskOnSubmit: true
    },
    'rate': {
      alias: 'customized_currency',
      digits: 4
    }
  });
})(jQuery);

