$(function () {
  if ($('.piecharts').length) {
    drawChart('current-month', 'current-month-income-by-categories');
    drawChart('current-month', 'current-month-expense-by-categories');
    drawChart('current-month', 'current-month-income-by-customers');
    drawChart('current-month', 'current-month-expense-by-customers');
  }
  $(document).on('click', '#periods_bar li a', function () {
    drawChart($(this).data('period'), $(this).data('period') + '-income-by-categories');
    drawChart($(this).data('period'), $(this).data('period') + '-expense-by-categories');
    drawChart($(this).data('period'), $(this).data('period') + '-income-by-customers');
    drawChart($(this).data('period'), $(this).data('period') + '-expense-by-customers');
  });
});

var drawChart = function drawChart(period, element) {
  element = document.getElementById(element);
  if (element) {
    $.ajax({
      url: element.getAttribute('data-url'),
      type: 'get',
      data: { period: period }
    })
    .done(function(response) {
      draw(response, element, period);
    })
  };

  function draw(response, css_id, period) {
    if (response == null ) {
      $(css_id).removeAttr('id').addClass('alert alert-warning').html('No data');
      $(css_id).width('200').height(26);
      return false;
    };
    var data = response.data;
    var ids  = response.ids;
    var pieData = google.visualization.arrayToDataTable(data);
    var chart = new google.visualization.PieChart(css_id);
    var formatter = new google.visualization.NumberFormat(response.currency_format);
    formatter.format(pieData, 1);
    var options = {
      chartArea: {
        left: 10,
        top:  20,
        width: '100%',
        height: '320'
      },
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
