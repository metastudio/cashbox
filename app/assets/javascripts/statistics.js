$(function () {
  $.ajax({
    url: $('#income-by-customers').data("url"),
    dataType: 'json'
  })
  .done(function(response) {
    drawChart(response, 'income-by-customers', 'Income by customers');
  })

  $.ajax({
    url: $('#expense-by-customers').data("url"),
    dataType: 'json'
  })
  .done(function(response) {
    drawChart(response, 'expense-by-customers', 'Expense by customers');
  })
});

function drawChart(response, css_id, title) {
  if (response == null ) {
    $('.piecharts').addClass('alert alert-warning').html('No data');
    return false;
  };
  var data = response.data;
  var ids  = response.ids;
  var pieData = google.visualization.arrayToDataTable(data);

  var chart = new google.visualization.PieChart(document.getElementById(css_id));

  var formatter = new google.visualization.NumberFormat(response.currency_format);
  formatter.format(pieData, 1);

  var options = {
    title: title,
    tooltip: { isHtml: true },
    sliceVisibilityThreshold: .0000001
  };
  chart.draw(pieData, options);

  function selectHandler() {
    var selectedItem = chart.getSelection()[0];
    if (selectedItem) {
      var customer = pieData.getValue(selectedItem.row, 0);
      var income   = pieData.getValue(selectedItem.row, 1);
      if (customer != 'Other') {
        for (var i = data.length - 1; i >= 0; i--) {
          if (customer == data[i][0]) {
            window.location.href = "/?q%5Bcustomer_id_eq%5D=" + ids[i] +
              "&q%5Bperiod%5D=current_month";
            break;
          }
        };
      };
    }
  }
  google.visualization.events.addListener(chart, 'select', selectHandler);
}
