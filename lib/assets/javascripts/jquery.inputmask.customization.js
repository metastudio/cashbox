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
          max: 21474836.4
      },
      'comission': {
        alias: 'customized_currency',
        max: 10000
      },
      'rate': {
        alias: 'customized_currency',
        digits: 4,
        max: 1000
      }
    });
})(jQuery);

