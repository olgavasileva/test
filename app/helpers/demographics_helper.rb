module DemographicsHelper

  GREY_SCALE = %w{#2e2e2e #454545 #5c5c5c #707070 #828282 #999999 #b0b0b0 #d3d3d3}.freeze

  def demographic_pie_chart(info, color=nil)
    bucket_data = []
    max_index = nil
    max_value = 0
    info[:buckets].each_with_index do |b, i|

      if b[:percent] > max_value
        max_value = b[:percent]
        max_index = i
      end

      value = b[:percent] * 100
      bucket_data.push({
        name: b[:name],
        y: value,
        label: number_to_percentage(value, precision: 0)
      })
    end

    colors = GREY_SCALE[0..(info[:buckets].length-1)]
    colors[max_index] = color if color && max_index

    LazyHighCharts::HighChart.new('graph') do |f|
      f.tooltip false

      f.chart({
        spacingTop: 0,
        spacingBottom: 0,
        height: 160
      })

      f.plotOptions({
        pie: {
          size: 80,
          dataLabels: {enabled: false},
          showInLegend: true,
          center: [20, 25],
          colors: colors
        }
      })

      f.legend({
        align: :right,
        verticalAlign: :top,
        layout: :vertical,
        labelFormat: '{label} {name}',
        borderWidth: 0,
        itemMarginBottom: 5
      })

      f.series(type: 'pie', data: bucket_data)
    end
  end

  def demographic_index_chart(info, color='#1794C0')
    names = info[:buckets].map{ |b| b[:name] }
    indexes = info[:buckets].map{ |b| b[:index] }

    LazyHighCharts::HighChart.new('graph') do |f|
      f.tooltip false
      f.legend false
      f.series(data: indexes)
      f.dataLabels(padding: 1)
      f.plotOptions(series: {stacking: 'normal', color: color})

      f.chart({
        type: :bar,
        height: info[:buckets].count * 40,
        spacingTop: 0,
        spacingBottom: 20
      })

      f.xAxis([
        {
          categories: names,
          tickWidth: 0,
          lineWidth: 0
        },
        {
          categories: indexes,
          opposite: true,
          linkedTo: 0,
          tickWidth: 0,
          lineWidth: 0
        }
      ])

      f.yAxis({
        min: 0,
        max: 200,
        plotLines: [
          {
            zIndex: 10,
            value: 100,
            dashStyle: "ShortDash",
            width: 2,
            color: '#dddddd',
            label: {
              text: "US Average",
              rotation: 0,
              verticalAlign: :bottom,
              align: :center
            }
          }
        ],
        labels: {enabled: false},
        title: {enabled: false},
        gridLineWidth: 0
      })
    end
  end
end
