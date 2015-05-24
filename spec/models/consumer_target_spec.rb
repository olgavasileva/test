require 'rails_helper'

RSpec.describe ConsumerTarget do

  describe :validations do
    subject(:target) { FactoryGirl.build(:consumer_target) }

    it { expect(target.all_users).to eq false }
    it { expect(target.all_followers).to eq false }
    it { expect(target.all_groups).to eq false }
    it { expect(target.all_communities).to eq false }
  end

  describe :apply_to_question! do
    subject(:target) { FactoryGirl.build(:consumer_target, all_users: all_users, all_followers: all_followers, all_groups: all_groups, all_communities: all_communities) }

    let(:all_users) { false }
    let(:all_followers) { false }
    let(:all_groups) { false }
    let(:all_communities) { false }

    let(:question) { FactoryGirl.create :text_choice_question }
    let(:options) { {} }

    context "When all_users is set" do
      before { target.apply_to_question! question, options }
      let(:all_users) { true }
      it { expect(question.reload.kind).to eq 'public' }
      it { expect(QuestionTarget.where(question_id:question.reload.id)).to be_empty }
    end

    describe :followers do
      context "When all_followers is set" do
        let (:all_followers) { true }

        context "With 2 followers and 1 other user" do
          let(:followers) { FactoryGirl.create_list :user, 2 }
          before do
            followers.each{|f| f.follow! question.user}
            FactoryGirl.create(:user)
          end
          before { target.apply_to_question! question, options }

          it { expect(question.reload.kind).to eq 'targeted'}
          it { expect(QuestionTarget.where(question_id:question.reload.id).map{|qt| qt.respondent}).to match_array followers }
        end
      end

      context "When 2 of 3 followers are indicated" do
        let(:followers) { FactoryGirl.create_list :user, 3 }
        before { followers.each{|f| f.follow! question.user } }
        before { subject.followers << followers[0] }
        before { subject.followers << followers[1] }
        before { target.apply_to_question! question, options }

        it { expect(question.reload.kind).to eq 'targeted'}
        it { expect(QuestionTarget.where(question_id:question.reload.id).map{|qt| qt.respondent}).to match_array followers[(0..1)] }
      end
    end
  end
end
