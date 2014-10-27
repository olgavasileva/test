require 'rails_helper'

describe Segment do

  describe :validations do
    it {expect(FactoryGirl.build(:segment)).to be_valid}
    it {expect(FactoryGirl.build(:segment, name: nil)).not_to be_valid}
  end

  describe :matched_users do
    describe TextResponseMatcher do
      pending
    end

    describe OrderResponseMatcher do
      pending
    end

    describe ChoiceResponseMatcher do
      pending
    end
  end

end