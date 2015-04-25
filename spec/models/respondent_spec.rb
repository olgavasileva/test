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

  describe :needs_more_feed_items? do
    context "When there are n active public questions" do
      before { expect(Question).to receive_message_chain(:active, :publik, :count).and_return(n) }
      let(:n) {6}

      context "When all but one of them are public visible feed items for the respondent" do
        let(:respondent) {FactoryGirl.create :user, auto_feed:false}
        before { expect(respondent).to receive_message_chain(:feed_items, :publik, :count).and_return(n-1) }

        it {expect(respondent.needs_more_feed_items?).to be_truthy}
      end

      context "When all of them are public visible feed items for the respondent" do
        let(:respondent) {FactoryGirl.create :user, auto_feed:false}
        before { expect(respondent).to receive_message_chain(:feed_items, :publik, :count).and_return(n) }

        it {expect(respondent.needs_more_feed_items?).to be_falsy}
      end
    end
  end

  describe :purge_feed_items! do
    let(:respondent) { FactoryGirl.create :user }
    let(:n) { 2 }

    context "When there are n+2 visible public items in the respondent's feed" do
      before {FactoryGirl.create_list :feed_item, n+2, user: respondent }
      it { expect{respondent.purge_feed_items! n.to_s}.to change{respondent.reload.feed_items.visible.count}.to(n) }

      context "When the user has 1 answered and 1 skipped feed item" do
        before {FactoryGirl.create :feed_item, :answered, user: respondent}
        before {FactoryGirl.create :feed_item, :skipped, user: respondent}

        it { expect{respondent.purge_feed_items! n.to_s}.to change{respondent.reload.feed_items.visible.count}.to(n) }
        it { expect{respondent.purge_feed_items! n.to_s}.not_to change{respondent.reload.feed_items.skipped.count} }
        it { expect{respondent.purge_feed_items! n.to_s}.not_to change{respondent.reload.feed_items.answered.count} }
      end
    end

    context "When there are n-1 visible public items in the respondent's feed" do
      before {FactoryGirl.create_list :feed_item, n-1, user: respondent }
      it { expect{respondent.purge_feed_items! n.to_s}.not_to change{respondent.reload.feed_items.visible.count} }
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
