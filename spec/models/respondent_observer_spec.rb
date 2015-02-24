require 'rails_helper'

describe RespondentObserver do
  describe :after_create do
    it "adds a statisfy demographic when an ip address is set" do
      respondent = FactoryGirl.create :user, current_sign_in_ip:"0.0.0.0"
      expect(respondent.reload.demographics.count).to eq 1
      expect(respondent.reload.demographics.first.ip_address).to eq "0.0.0.0"
    end
  end

  describe :after_update do
    it "adds a statisfy demographic when an ip address is set" do
      respondent = FactoryGirl.create :user
      expect(respondent.demographics).to be_empty

      respondent.update_attributes current_sign_in_ip:"0.0.0.0"
      expect(respondent.reload.demographics.count).to eq 1
      expect(respondent.reload.demographics.first.ip_address).to eq "0.0.0.0"
    end
  end
end
