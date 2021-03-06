require 'rails_helper'

describe Response do

  it {expect(FactoryGirl.build(:image_response)).to be_valid}
  it {expect(FactoryGirl.build(:text_response)).to be_valid}
  it {expect(FactoryGirl.build(:multiple_choice_response)).to be_valid}
  it {expect(FactoryGirl.build(:text_choice_response)).to be_valid}
  it {expect(FactoryGirl.build(:order_response)).to be_valid}
end
