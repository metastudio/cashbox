$(function () {
  getStatistics('current-month');

  // $( "a[href$='current_month']" ).click(function() {
  //   getStatistics('current-month');
  // });

  // $( "a[href$='previous-month']" ).click(function() {
  //   getStatistics('previous-month');
  // });

  // $( "a[href$='current-quarter']" ).click(function() {
  //   getStatistics('current-quarter');
  // });

  // $( "a[href$='this_year']" ).click(function() {
  //   getStatistics('this-year');
  // });

  // $( "a[href$='all_time']" ).click(function() {
  //   getStatistics('all-time');
  // });

});

function drawChart(response, css_id, title) {
  // if (response == null ) {
  //   $('.piecharts').addClass('alert alert-warning').html('No data');
  //   return false;
  // };
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

  function selectHandler() {
    var selectedItem = chart.getSelection()[0];
    if (selectedItem) {
      var customer = pieData.getValue(selectedItem.row, 0);
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

function getStatistics(period){
  pieId = period + '-income-by-customers';
  pieId = document.getElementById(pieId);
  $.ajax({
    url: pieId.getAttribute('data-url'),
    type: 'post',
    data: { 'period': period }
  })
  .done(function(response) {
    drawChart(response, pieId, 'Income by customers');
  })

  pieId = period + '-expense-by-customers';
  pieId = document.getElementById(pieId);
  $.ajax({
    url: pieId.getAttribute('data-url'),
    type: 'post',
    data: { 'period': period }
  })
  .done(function(response) {
    drawChart(response, pieId, 'Expense by customers');
  })
}
