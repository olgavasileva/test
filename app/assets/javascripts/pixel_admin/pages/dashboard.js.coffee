$(document).on 'page:change', ->

  # From app.js
  COLORS = ['#71c73e', '#77b7c5', '#d54848', '#6c42e5', '#e8e64e', '#dd56e6', '#ecad3f', '#618b9d', '#b68b68', '#36a766', '#3156be', '#00b3ff', '#646464', '#a946e8', '#9d9d9d']

  # Pie Charts
  #

  easyPieChartDefaults =
    animate: 2000
    scaleColor: false
    lineWidth: 6
    lineCap: 'square'
    size: 90
    trackColor: '#e5e5e5'

  $('#dashboard .pie-chart').easyPieChart($.extend({}, easyPieChartDefaults, barColor: COLORS[1]))


  # Line Chart
  #

  if $('#hero-graph').length
    Morris.Line
      element: 'hero-graph'
      data: $('#hero-graph').data().points
      xkey: 'day'
      ykeys: ['v']
      labels: ['Completes']
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

  $(document).on 'html:loaded', '#recent_responses', ->
    $('#recent_responses .panel-body > div').slimScroll
      height: 300
      alwaysVisible: true
      color: '#888'
      allowPageScroll: true

  # Comments
  #

  $(document).on 'html:loaded', '#recent_comments', ->
    $('#recent_comments .panel-body > div').slimScroll
      height: 300,
      alwaysVisible: true,
      color: '#888',
      allowPageScroll: true
