$(function () {
  // show_hide_period_additional_input();

  $(document).on('click', '.transaction[data-edit-url]', function(e) {
    e.preventDefault();
    $.ajax({
      url: $(this).data("edit-url"),
      dataType: "script"
    });
  });

  // $(document).on('change', '#q_simple_period', function(e) {
  //   show_hide_period_additional_input();
  // });
});

// function show_hide_period_additional_input() {
//   if ($('#q_simple_period').val() == 'quarter') {
//     hide_input($('#q_custom_period.daterange'));
//     show_input($('#q_quarter'));
//   }
//   else if($('#q_simple_period').val() == 'custom') {
//     $('#q_custom_period.daterange').daterangepicker({ format: 'DD/MM/YYYY' });
//     hide_input($('#q_quarter'));
//     show_input($('#q_custom_period.daterange'));
//   }
//   else {
//     hide_input($('#q_quarter'));
//     hide_input($('#q_custom_period.daterange'));
//   }
// }

// function show_input(input) {
//   input.parents('.col-sm-2').removeClass('hidden');
//   input.attr('disabled', false);
// }
// function hide_input(input) {
//   input.parents('.col-sm-2').addClass('hidden');
//   input.attr('disabled', true);
// }
