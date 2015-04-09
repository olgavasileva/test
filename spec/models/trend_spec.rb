require 'rails_helper'

describe Trend do
  describe :defaults do
    it { expect(Trend.new.calculated_at).to be_present }
    it { expect(Trend.new.new_event_count).to eq 0 }
    it { expect(Trend.new.filter_event_count).to eq 0 }
    it { expect(Trend.new.filter_minutes).to eq 0 }
    it { expect(Trend.new.rate).to eq 0 }
  end

  describe :event! do
    let(:trend) { FactoryGirl.create :trend }

    it { expect { trend.event! }.to change { trend.new_event_count }.by 1 }
  end

  describe :calculate! do
    let(:trend) { FactoryGirl.create :trend }

    it { expect(trend.rate).to eq 0 }

    context "When there are a series of events over time" do
      let(:data) {[[0, 0], [1, 1], [0, 1], [1, 0], [0, 0], [1, 1], [0, 1], [1, 0], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [100, 10], [10, 10], [1000, 10], [0, 10], [10, 0], [0, 10], [1000, 100], [1000, 10], [11000, 10], [100, 10], [100, 10], [100, 10], [100, 10], [100, 10], [100, 10], [100, 10], [100, 10], [100, 10], [100, 10], [100, 10], [100, 10], [100, 10], [0, 0], [1, 1], [0, 1], [1, 0], [0, 0], [1, 1], [0, 1], [1, 0], [1, 1], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [11, 10], [9, 10], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [0, 1], [5, 1], [6, 1], [0, 1]]}
      let(:results) {[0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.92, 0.96, 0.96, 0.96, 0.96, 0.96, 0.96, 0.96, 0.96, 0.96, 0.96, 0.98, 3.65, 2.98, 24.76, 24.76, 19.91, 19.91, 12.12, 18.24, 97.91, 91.08, 84.48, 78.13, 72.08, 66.37, 61.00, 56.00, 51.36, 47.08, 43.17, 39.59, 36.35, 33.42, 33.42, 33.42, 33.42, 33.42, 33.42, 33.42, 33.42, 33.42, 33.42, 28.23, 28.23, 22.89, 22.89, 18.88, 18.88, 15.78, 15.78, 13.34, 13.34, 11.38, 11.38, 9.79, 9.79, 8.47, 8.47, 7.38, 7.38, 6.47, 6.47, 5.70, 5.70, 5.05, 5.05, 4.50, 4.50, 4.03, 4.03, 3.62, 3.62, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 3.28, 2.77, 2.77, 2.77]}

      before { allow_any_instance_of(Trend).to receive(:save).and_return(nil) }

      pending "should match Dave's results" do
        minutes_since_last_calculation = 0
        data.each_with_index do |(new_event_count, elapsed_minutes), i|
          minutes_since_last_calculation += elapsed_minutes
          allow(trend).to receive(:minutes_since_last_calculation).and_return(minutes_since_last_calculation)
          new_event_count.times { trend.event! }

          calculated = trend.calculate!

          minutes_since_last_calculation = 0 if calculated

          total_new_events = trend.new_event_count
          filter_event_count = trend.filter_event_count
          filter_minutes = trend.filter_minutes

          # format = "%3d:nV: %8.2f nM: %8.2f vB: %8.2f mB: %8.2f fV: %8.2f fM: %8.2f T: %8.2f"
          # values = [i, new_event_count, elapsed_minutes, total_new_events, minutes_since_last_calculation, filter_event_count, filter_minutes, trend.rate]
          # puts format % values

          expect(trend.rate).to be_within(0.1).of results[i]
        end
      end
    end
  end
end
