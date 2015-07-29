$(function () {
  if ($('.piecharts').length) {
    drawChart('current-month', 'current-month-income-by-customers', 'Income by customers');
    drawChart('current-month', 'current-month-expense-by-customers', 'Expense by customers');
  }
  $(document).on('click', '#periods_bar li a', function () {
    drawChart($(this).data('period'), $(this).data('period') + '-income-by-customers', 'Income by customers');
    drawChart($(this).data('period'), $(this).data('period') + '-expense-by-customers', 'Expense by customers');
  });
});

var drawChart = function drawChart(period, element, title) {
  element = document.getElementById(element);
  if (element) {
    $.ajax({
      url: element.getAttribute('data-url'),
      type: 'get',
      data: { period: period }
    })
    .done(function(response) {
      draw(response, element, title, period);
    })
  };

  function draw(response, css_id, title, period) {
    if (response == null ) {
      $(css_id).removeAttr('id').addClass('alert alert-warning').html('No data');
      return false;
    };
    var data = response.data;
    var ids  = response.ids;
    var pieData = google.visualization.arrayToDataTable(data);
    var chart = new google.visualization.PieChart(css_id);
    var formatter = new google.visualization.NumberFormat(response.currency_format);
    formatter.format(pieData, 1);
    var options = {
      title: title,
      tooltip: { isHtml: true },
      sliceVisibilityThreshold: .0000001
    };
    chart.draw(pieData, options);

    function selectHandler(peroid) {
      var selectedItem = chart.getSelection()[0];
      if (selectedItem) {
        var customer = pieData.getValue(selectedItem.row, 0);
        if (customer != 'Other') {
          for (var i = data.length - 1; i >= 0; i--) {
            if (customer == data[i][0]) {
              window.location.href = "/?q%5Bcustomer_id_eq%5D=" + ids[i] +
                "&q%5Bperiod%5D=" + period;
              break;
            }
          };
        };
      }
    }
    google.visualization.events.addListener(chart, 'select', selectHandler);
  }
};
