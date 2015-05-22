require 'rails_helper'

describe Respondent do
  it { is_expected.to have_many(:surveys) }
  it { is_expected.to have_many(:embeddable_units).through(:surveys) }

  describe :quantcast_demographic_required? do
    let(:respondent) { FactoryGirl.create(:user) }
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

  describe :active do
    let(:respondent) { FactoryGirl.create :user }
    let(:n) {5}

    subject {Respondent.active n}

    context "When there is a response from n-1 days ago" do
      before {FactoryGirl.create :feed_item, :answered, user: respondent, updated_at: Date.current - (n-1).days}

      it {is_expected.to include respondent}
    end

    context "When there is a response from n+1 days ago" do
      before {FactoryGirl.create :feed_item, :answered, user: respondent, updated_at: Date.current - (n+1).days}

      it {is_expected.not_to include respondent}
    end
  end

  describe :inactive do
    let(:respondent) { FactoryGirl.create :user }
    let(:n) {5}

    subject {Respondent.inactive n}

    context "When there is a response from n-1 days ago" do
      before {@fi = FactoryGirl.create :feed_item, :answered, updated_at: Date.current - (n-1).days}
      let(:respondent) {@fi.user}

      it {is_expected.not_to include respondent}
    end

    context "When there is a response from n+1 days ago" do
      before {FactoryGirl.create :feed_item, :answered, user: respondent, updated_at: Date.current - (n+1).days}

      it {is_expected.to include respondent}
    end
  end
end
