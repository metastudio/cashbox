$(function () {
  drawBalanceChart(null, getScale(), getStep(), 'main-balance');
  drawCustomersChart('income');
  if ($(".piecharts").length) {
    var period = $("#periods_bar li.active a").data("period");
    drawPieCharts(period);
  }
  $(document).on("click", "#periods_bar li a", function () {
    var period = $(this).data("period");
    drawPieCharts(period);
    updateUrlParam("customers_period", period);
  });
  $(document).on('click', '#balance_scale li a', function () {
    var scale = $(this).data('scale');
    setStep(0);
    drawBalanceChart(null, scale, getStep, 'main-balance');
    setScale(scale);
    updateUrlParam("balance_scale", scale);
  });
  $(document).on('click', '#customers_chart li a', function () {
    var type = $(this).data('type');
    drawCustomersChart(type);
    updateUrlParam("customers_type", type);
  });
  $(document).on('click', '#balance_navigation a', function (e) {
    e.preventDefault();
    var step = getStep();
    var scale = getScale();
    if ($(this).hasClass('right-step')) {
      if (step > 0) {
        step -= 1;
        setStep(step);
        drawBalanceChart(null, scale, step, 'main-balance');
        updateUrlParam("balance_step", step);
      }
      toggleStep('.left_step_wrapper', true);
    }
    else if ($(this).hasClass('left-step')){
      step += 1;
      setStep(step);
      drawBalanceChart(null, scale, step, 'main-balance');
      updateUrlParam("balance_step", step);
    }
    if (step === 0) {
      toggleStep('.right_step_wrapper', false);
    }
    if (step === 1) {
      toggleStep('.right_step_wrapper', true);
    }
  });
});

var setStep = function setStep(step) {
  $('#balance_navigation').data('step', step);
};

var getStep = function getStep() {
  var step = $('#balance_navigation').data('step');
  return step;
};

var setScale = function setScale(scale) {
  $('#balance_scale').data('scale', scale);
};

var getScale = function getScale() {
  var scale = $('#balance_scale').data('scale');
  return scale;
};

function toggleStep(elementSelector, state) {
  var element = $(elementSelector);
  element.find('a').toggleClass('hide', !state);
  element.find('span').toggleClass('hide', state);
}

var drawChart = function drawChart(period, element) {
  element = document.getElementById(element);
  if (element) {
    $.ajax({
      url: element.getAttribute('data-url'),
      type: 'get',
      data: { customers_period: period }
    })
    .done(function(response) {
      draw(response, element, period);
    });
  }

  function draw(response, css_id, period) {
    if (response == null ) {
      $(css_id).removeAttr('id').addClass('alert alert-warning').html('No data');
      $(css_id).width('200').height(26);
      return false;
    }
    var data = response.data;
    var ids  = response.ids;
    var pieData = google.visualization.arrayToDataTable(data);
    var chart = new google.visualization.PieChart(css_id);
    var formatter = new google.visualization.NumberFormat(response.currency_format);
    formatter.format(pieData, 1);

    var total = google.visualization.data.group(pieData, [{
      type: 'string',
      column: 0,
      modifier: function () {return 'Hash';}
    }], [{
      type: 'number',
      column: 1,
      aggregation: google.visualization.data.sum
    }]);

    var suffix = response.currency_format['suffix'] || '';
    var prefix = response.currency_format['prefix'] || '';

    var options = {
      title: 'Total: ' + prefix + total.getValue(0, 1).format(2) + suffix,
      chartArea: {
        left: 10,
        top:  20,
        width: '100%',
        height: '320'
      },
      tooltip: {
        text: 'percentage',
        isHtml: true,
        textStyle: { bold: true }
      },
      sliceVisibilityThreshold: 0
    };
    chart.draw(pieData, options);

    function selectHandler() {
      var selectedItem = chart.getSelection()[0];
      if (selectedItem) {
        var item = pieData.getValue(selectedItem.row, 0);
        if (item.indexOf('Other') == -1) {
          for (var i = data.length - 1; i >= 0; i--) {
            if (item == data[i][0] && css_id.classList.contains('customers')) {
              window.location.href = "/?q%5Bcustomer_id_eq%5D=" + ids[i] +
                "&q%5Bperiod%5D=" + period;
              break;
            } else if (item == data[i][0] && css_id.classList.contains('categories')) {
              window.location.href = "/?q%5Bcategory_id_eq%5D=" + ids[i] +
                "&q%5Bperiod%5D=" + period;
              break;
            } else {
              continue;
            }
          };
        };
      }
    }
    google.visualization.events.addListener(chart, 'select', selectHandler);
  }
};

var drawBalanceChart = function drawBalanceChart(period, scale, step, element) {
  element = document.getElementById(element);
  if (element) {
    $.ajax({
      url: element.getAttribute('data-url'),
      type: 'get',
      data: {
        balance_step: step,
        customers_period: period,
        balance_scale: scale
      },
      beforeSend: function () {
        if (element.id == "main-balance") {
          toggleBalanceSpinner(false);
        }
      }
    })
    .done(function(response) {
      draw(response, element, period);
    });
  }

  function draw(response, css_id, period) {
    if (response == null ) {
      $(css_id).removeAttr('id').addClass('alert alert-warning').html('No data');
      return false;
    };
    var data = response.data;
    var chartData = google.visualization.arrayToDataTable(data);
    var chart = null;
    if (css_id.id == 'main-balance') {
      chart = new google.visualization.ComboChart(css_id);
    } else {
      chart = new google.visualization.ColumnChart(css_id);
    }
    var formatter = new google.visualization.NumberFormat(response.currency_format);
    formatter.format(chartData, 1);
    formatter.format(chartData, 2);
    if (css_id.id == 'main-balance') {
      formatter.format(chartData, 3);
    }

    if (response['next_step_blank']) {
      toggleStep('.left_step_wrapper', false);
    }

    var options = {
      chart: {
        title: 'Balance',
        subtitle: 'Incomes, Expenses, Total balance',
      },
      chartArea: {
        top:  30,
        width: '76%'
      },
      seriesType: 'bars',
      series: {2: {type: 'line'}},
      tooltip: { isHtml: true },
      animation: {
        duration: 1000,
        easing: 'in',
        startup: true
      },
    };

    google.visualization.events.addListener(chart, 'ready', function() {
      toggleBalanceSpinner(true)
    });

    chart.draw(chartData, options);

    google.visualization.events.addListener(chart, 'select', selectHandler);

    function selectHandler() {
      var selectedItem = chart.getSelection()[0];
      if (selectedItem != undefined && selectedItem.row != null && selectedItem.column != null) {
        if (selectedItem) {
          var item = chartData.getValue(selectedItem.row, selectedItem.column);

            for (var i = data.length - 1; i >= 0; i--) {
              if (item == data[i][1]) {
                var date = new Date(data[i][0]);
                var year = date.getFullYear();
                var month = dateNumber(date.getMonth() + 1);
                var lastDay = new Date(year, month + 1, 0).getDate();
                window.location.href = "/?q%5Bcategory_type_eq%5D=Income" +
                  "&q%5Bdate_from%5D=01%2F" + month +"%2F" + year +
                  "&q%5Bdate_to%5D=" + lastDay + "%2F" + month + "%2F" + year;
                break;
              } else if (item == data[i][2]) {
                window.location.href = "/?q%5Bcategory_type_eq%5D=Expense" +
                  "&q%5Bdate_from%5D=01%2F" + month +"%2F" + year +
                  "&q%5Bdate_to%5D=" + lastDay + "%2F" + month + "%2F" + year;
                break;
              } else {
                continue
              }
            };
        }
      }
    }

  }
};

var drawCustomersChart = function drawCustomersChart (type) {
  var element = document.getElementById('customers-chart');

  if (element) {
    $.ajax({
      url: element.getAttribute('data-url'),
      type: 'get',
      data: {
        customers_type: type
      }
    })
    .done(function(response) {
      draw(response, element);
    });
  }

  function draw(response, css_id) {
    if (response == null ) {
      $(css_id).removeAttr('id').addClass('alert alert-warning').html('No data');
      return false;
    }
    var data = response.data;
    var chartData = google.visualization.arrayToDataTable(data);
    var chart = new google.visualization.ColumnChart(element);
    var formatter = new google.visualization.NumberFormat(response.currency_format);

    var columns_count = response.data[0].length - 2;

    for (var i = 0; i <= columns_count; i++) {
      formatter.format(chartData, i);
    }

    var options = {
      chartArea: {
        top:  30,
        width: '90%',
        height: '76%',
        bottom: 50
      },
      legend: { position: 'top', maxLines: 3 },
      bar: { groupWidth: '75%' },
      isStacked: true,
    };

    chart.draw(chartData, options);
  }
};

function dateNumber(number) {
  if (number < 10) {
    return "0" + number;
  }
  else {
    return number;
  }
}

function updateUrlParam (param, value) {
  var params = initUrlParams();
  params[param] = value;
  updateUrl(params);
  return params;
}

function initUrlParams () {
  var search = window.location.search;
  if (search.length > 0) {
    return queryString();
  } else {
    return {
      balance_scale: "months",
      balance_step: 0,
      customers_type: "income",
      customers_period: "current-month"
    };
  }
}

function updateUrl(params) {
  window.history.pushState(null, "", "/statistics?"+$.param(params));
}

Number.prototype.format = function(n, x) {
  var re = '(\\d)(?=(\\d{' + (x || 3) + '})+' + (n > 0 ? '\\.' : '$') + ')';
  return this.toFixed(Math.max(0, ~~n)).replace(new RegExp(re, 'g'), '$1,');
};

function toggleBalanceSpinner(state) {
  $('.balance-chart.spinner-backround').toggleClass('hide', state);
}

function queryString() {
  // This function is anonymous, is executed immediately and
  // the return value is assigned to QueryString!
  var query_string = {};
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
        // If first entry with this name
    if (typeof query_string[pair[0]] === "undefined") {
      query_string[pair[0]] = decodeURIComponent(pair[1]);
        // If second entry with this name
    } else if (typeof query_string[pair[0]] === "string") {
      var arr = [ query_string[pair[0]],decodeURIComponent(pair[1]) ];
      query_string[pair[0]] = arr;
        // If third or later entry with this name
    } else {
      query_string[pair[0]].push(decodeURIComponent(pair[1]));
    }
  }
  return query_string;
}

function drawPieCharts (period) {
  drawChart(period, period + "-income-by-categories");
  drawChart(period, period + "-expense-by-categories");
  drawChart(period, period + "-income-by-customers");
  drawChart(period, period + "-expense-by-customers");
  drawChart(period, period + "-totals-by-customers");
  drawBalanceChart(period, null, null, period + "-balances-by-customers");
}
