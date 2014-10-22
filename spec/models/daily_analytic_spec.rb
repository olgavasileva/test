require 'rails_helper'

describe DailyAnalytic do

  describe "Increment and fetch" do
    let(:user) {FactoryGirl.create :user}
    let(:another_user) {FactoryGirl.create :user}
    it "Increments the data by 1 when called" do
      expect(DailyAnalytic.fetch :test, Date.today, user).to eq 0
      DailyAnalytic.increment! :test, user
      expect(DailyAnalytic.fetch :test, Date.today, user).to eq 1
      DailyAnalytic.increment! :test, user
      expect(DailyAnalytic.fetch :test, Date.today, user).to eq 2
      DailyAnalytic.increment! :test, user
      DailyAnalytic.increment! :test, user
      expect(DailyAnalytic.fetch :test, Date.today, user).to eq 4
      DailyAnalytic.increment! :test, another_user
      expect(DailyAnalytic.fetch :test, Date.today, user).to eq 4
    end
  end
end
