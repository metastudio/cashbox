$(function () {
  path = window.location.href.split('/');
  if (path[path.length - 1] == 'statistics') {
    getStatistics('current-month');
  };
  $(document).on('click', '#periods_bar li a', function(e) {
    getStatistics($(this).data('period'));
  });
});

function drawChart(response, css_id, title, period) {
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

function getStatistics(period){
  var pieInc = document.getElementById(period + '-income-by-customers');
  if (pieInc) {
    $.ajax({
      url: pieInc.getAttribute('data-url'),
      type: 'get',
      data: { 'period': period }
    })
    .done(function(response) {
      drawChart(response, pieInc, 'Income by customers', period);
    })
  };

  var pieExp = document.getElementById(period + '-expense-by-customers');
  if (pieExp) {
    $.ajax({
      url: pieExp.getAttribute('data-url'),
      type: 'get',
      data: { 'period': period }
    })
    .done(function(response) {
      drawChart(response, pieExp, 'Expense by customers', period);
    })
  };
}
