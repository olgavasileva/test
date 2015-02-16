require 'rails_helper'

RSpec.describe DemographicsHelper do

  describe '#demographics_pie_chart' do

    let(:builder) { double() }
    let(:buckets) do
      [
        {name: 'Test', percent: 0.35},
        {name: 'Other', percent: 0.65}
      ]
    end

    let(:info) { {buckets: buckets} }

    it 'builds a pie chart' do
      expect(LazyHighCharts::HighChart).to receive(:new)
        .with('graph')
        .and_yield(builder)

      expect(builder).to receive(:tooltip).with(false)
      expect(builder).to receive(:chart).with({
        spacingTop: 0,
        spacingBottom: 0,
        height: 160
      })

      expect(builder).to receive(:plotOptions).with({
        pie: {
          size: 80,
          dataLabels: {enabled: false},
          showInLegend: true,
          center: [20, 25],
          colors: [DemographicsChartHelper::GREY_SCALE.first, '#000000']
        }
      })

      expect(builder).to receive(:legend).with({
        align: :right,
        verticalAlign: :top,
        layout: :vertical,
        labelFormat: '{label} {name}',
        borderWidth: 0,
        itemMarginBottom: 5
      })

      expect(builder).to receive(:series).with({
        type: 'pie',
        data: [
          {name: 'Test', y: 35.0, label: '35%'},
          {name: 'Other', y: 65.0, label: '65%'}
        ]
      })

      helper.demographics_pie_chart(info, '#000000')
    end

    context 'with no buckets' do
      let(:buckets) { [] }

      it 'still builds a chart' do
        chart = helper.demographics_pie_chart(info, '#0000000')
        expect(chart).to be_a(LazyHighCharts::HighChart)
      end
    end
  end

  describe '#demo_index_chart' do

    let(:builder) { double() }
    let(:buckets) do
      [
        {name: 'Test', index: 70},
        {name: 'Other', index: 130}
      ]
    end

    let(:info) { {buckets: buckets} }

    it 'builds a bar chart' do
      expect(LazyHighCharts::HighChart).to receive(:new)
        .with('graph')
        .and_yield(builder)

      expect(builder).to receive(:tooltip).with(false)
      expect(builder).to receive(:legend).with(false)

      expect(builder).to receive(:series).with(data: [70, 130])
      expect(builder).to receive(:dataLabels).with(padding: 1)
      expect(builder).to receive(:plotOptions).with({
        series: {
          stacking: 'normal',
          color: '#000000'
        }
      })

      expect(builder).to receive(:chart).with({
        type: :bar,
        height: 80,
        spacingTop: 0,
        spacingBottom: 20
      })

      expect(builder).to receive(:xAxis).with([
        {
          categories: ['Test', 'Other'],
          tickWidth: 0,
          lineWidth: 0
        },
        {
          categories: [70, 130],
          opposite: true,
          linkedTo: 0,
          tickWidth: 0,
          lineWidth: 0
        }
      ])

      expect(builder).to receive(:yAxis).with({
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

      helper.demographics_index_chart(info, '#000000')
    end

    context 'with no buckets' do
      let(:buckets) { [] }

      it 'still builds a chart' do
        chart = helper.demographics_index_chart(info, '#0000000')
        expect(chart).to be_a(LazyHighCharts::HighChart)
      end
    end
  end
end
