init.push ->

  # Pie Charts
  #

  easyPieChartDefaults =
    animate: 2000
    scaleColor: false
    lineWidth: 6
    lineCap: 'square'
    size: 90
    trackColor: '#e5e5e5'

  $('#dashboard .pie-chart').easyPieChart($.extend({}, easyPieChartDefaults, barColor: PixelAdmin.settings.consts.COLORS[1]))


  # Line Chart
  #

  uploads_data = [
    { day: '2014-03-10', v: 20 },
    { day: '2014-03-11', v: 10 },
    { day: '2014-03-12', v: 15 },
    { day: '2014-03-13', v: 12 },
    { day: '2014-03-14', v: 5  },
    { day: '2014-03-15', v: 5  },
    { day: '2014-03-16', v: 20 }
  ]

  Morris.Line
    element: 'hero-graph'
    data: uploads_data
    xkey: 'day'
    ykeys: ['v']
    labels: ['Value']
    lineColors: ['#fff']
    lineWidth: 2
    pointSize: 4
    gridLineColor: 'rgba(255,255,255,.5)'
    resize: true
    gridTextColor: '#fff'
    xLabels: "day"
    xLabelFormat: (d)->
      ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov', 'Dec'][d.getMonth()] + ' ' + d.getDate()


  # Reach graph
  #

  $("#dashboard #reach_graph").pixelSparkline $("#dashboard #reach_graph").data().points,
    type: 'line'
    width: '100%'
    height: '45px'
    fillColor: ''
    lineColor: '#fff'
    lineWidth: 2
    spotColor: '#ffffff'
    minSpotColor: '#ffffff'
    maxSpotColor: '#ffffff'
    highlightSpotColor: '#ffffff'
    highlightLineColor: '#ffffff'
    spotRadius: 4
    highlightLineColor: '#ffffff'

  # Engagements bar Chart
  #

    $("#dashboard #engagements_graph").pixelSparkline $("#dashboard #engagements_graph").data().points,
      type: 'bar'
      height: '36px'
      width: '100%'
      barSpacing: 2
      zeroAxis: false
      barColor: '#ffffff'


  # Responses
  #

  $('#dashboard #responses .panel-body > div').slimScroll
    height: 300
    alwaysVisible: true
    color: '#888'
    allowPageScroll: true


  # Comments
  #

  $('#dashboard #comments .panel-body > div').slimScroll
    height: 300,
    alwaysVisible: true,
    color: '#888',
    allowPageScroll: true
