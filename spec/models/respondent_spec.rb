require 'rails_helper'

describe Respondent do
  let(:respondent) { FactoryGirl.create(:user) }

  describe :quantcast_demographic_required? do
    subject {respondent.reload.quantcast_demographic_required?}

    context "When there is no demographic data for this respondent" do
      it { expect(subject).to eq true}
    end

    context "When there is demographic data for this respondent that is 29 days old" do
      before {FactoryGirl.create :demographic, :quantcast, respondent: respondent, updated_at: (Date.current - 1.month)}

      it { expect(subject).to eq false}
    end

    context "When there is demographic data for this respondent that is 30 days old" do
      before {FactoryGirl.create :demographic, :quantcast, respondent: respondent, updated_at: (Date.current - 1.month - 1.day)}

      it { expect(subject).to eq true}
    end
  end
end
