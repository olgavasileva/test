require 'rails_helper'

describe Response do
  it {except(FactoryGirl.build(:image_response)).to be_valid}
  it {except(FactoryGirl.build(:text_response)).to be_valid}
  it {except(FactoryGirl.build(:multiple_choice_response)).to be_valid}
  it {except(FactoryGirl.build(:choice_response)).to be_valid}
  it {except(FactoryGirl.build(:star_response)).to be_valid}
  it {except(FactoryGirl.build(:percent_response)).to be_valid}
  it {except(FactoryGirl.build(:order_response)).to be_valid}
end
