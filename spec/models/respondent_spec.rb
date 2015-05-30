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
      before {FactoryGirl.create :question_action_response, respondent: respondent, created_at: Date.current - (n-1).days}

      it {is_expected.to include respondent}
    end

    context "When there is a response from n+1 days ago" do
      before {FactoryGirl.create :question_action_response, respondent: respondent, created_at: Date.current - (n+1).days}

      it {is_expected.not_to include respondent}
    end

    context "When there is a skip from n-1 days ago" do
      before {FactoryGirl.create :question_action_skip, respondent: respondent, created_at: Date.current - (n-1).days}

      it {is_expected.to include respondent}
    end

    context "When there is a skip from n+1 days ago" do
      before {FactoryGirl.create :question_action_skip, respondent: respondent, created_at: Date.current - (n+1).days}

      it {is_expected.not_to include respondent}
    end
  end

  describe :inactive do
    let(:respondent) { FactoryGirl.create :user }
    let(:n) {5}

    subject {Respondent.inactive n}

    context "When there is a response from n-1 days ago" do
      before {FactoryGirl.create :question_action_response, respondent: respondent, created_at: Date.current - (n-1).days}

      it {is_expected.not_to include respondent}
    end

    context "When there is a response from n+1 days ago" do
      before {FactoryGirl.create :question_action_response, respondent: respondent, created_at: Date.current - (n+1).days}

      it {is_expected.to include respondent}
    end

    context "When there is a skip from n-1 days ago" do
      before {FactoryGirl.create :question_action_skip, respondent: respondent, created_at: Date.current - (n-1).days}

      it {is_expected.not_to include respondent}
    end

    context "When there is a skip from n+1 days ago" do
      before {FactoryGirl.create :question_action_skip, respondent: respondent, created_at: Date.current - (n+1).days}

      it {is_expected.to include respondent}
    end
  end

  describe :followers do
    let(:respondent) { FactoryGirl.create :respondent }

    context "When the user has 3 followers and 2 non-followers" do
      before { FactoryGirl.create_list :relationship, 3, leader: respondent }
      before { FactoryGirl.create_list :respondent, 2 }
      it { expect(respondent.followers.count).to eq 3 }
    end
  end

  describe :fellow_community_members do
    context "When the user belongs to a community with 3 other members and 2 non-members" do
      let(:community) { FactoryGirl.create :community }
      before { FactoryGirl.create_list :community_member, 3, community: community }
      before { FactoryGirl.create_list :respondent, 2 }
      let(:respondent) { community.user }

      it { expect(respondent.fellow_community_members.count).to eq 3 + 1}
    end
  end
end
