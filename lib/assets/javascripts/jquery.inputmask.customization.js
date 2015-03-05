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
      }
    });
})(jQuery);

