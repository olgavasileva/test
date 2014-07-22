require 'rails_helper'

describe Response do
  it {FactoryGirl.build(:image_response).should be_valid}
  it {FactoryGirl.build(:text_response).should be_valid}
  it {FactoryGirl.build(:multiple_choice_response).should be_valid}
  it {FactoryGirl.build(:choice_response).should be_valid}
  it {FactoryGirl.build(:star_response).should be_valid}
  it {FactoryGirl.build(:percent_response).should be_valid}
  it {FactoryGirl.build(:order_response).should be_valid}
end
