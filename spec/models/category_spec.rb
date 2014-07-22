require 'rails_helper'

describe Category do

  describe :validations do
    it {FactoryGirl.build(:category).should be_valid}
    it {FactoryGirl.build(:category, name:nil).should_not be_valid}
  end

  describe :defaults do
    let(:category) {FactoryGirl.build :category}

    it {category.should be_valid}
  end

end
