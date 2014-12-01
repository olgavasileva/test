require 'rails_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }

  describe :next_feed_questions do
    let(:other_user) do
      u = FactoryGirl.create(:user)
      u.followers << user
      u
    end

    let(:user_group) do
      g = FactoryGirl.create(:group, user: other_user)
      g.member_users << user
      g
    end

    let(:all_target) { FactoryGirl.create(:target, all_users: true) }
    let(:follower_target) { FactoryGirl.create(:target, followers: [user]) }
    let(:group_target) { FactoryGirl.create(:target, groups: [user_group]) }

    let!(:untargeted_question) { FactoryGirl.create(:question) }
    let!(:special_case_question) { FactoryGirl.create(:question, special: true) }
    let!(:all_target_question) { FactoryGirl.create(:question, target: all_target) }
    let!(:follower_target_question) { FactoryGirl.create(:question, target: follower_target) }
    let!(:group_target_question) { FactoryGirl.create(:question, target: group_target) }
    let!(:scored_question) { FactoryGirl.create(:question, score: 10, target: all_target) }
    let!(:following_question) { FactoryGirl.create(:question, user: other_user, target: all_target) }

    let(:questions) { user.next_feed_questions }

    ## For legacy questions, we are allowing untargeted questions if we run out of other options
    # it "does not return untargeted questions" do
    #   expect(questions).to_not include untargeted_question
    # end

    it "returns special case questions first" do
      expect(questions.first).to eq special_case_question
    end

    it "returns all-targeted questions" do
      expect(questions).to include all_target_question
    end

    it "returns follower-targeted questions" do
      expect(questions).to include follower_target_question
    end

    xit "returns group-targeted questions" do
      expect(questions).to include group_target_question
    end

    it "returns follower-targeted questions before all-targeting questions" do
      follower_targeted_idx = questions.index(follower_target_question)
      all_targeted_idx = questions.index(all_target_question)

      expect(follower_targeted_idx).to be < all_targeted_idx
    end

    xit "returns group-targeted questions before all-targeting questions" do
      group_targeted_idx = questions.index(group_target_question)
      all_targeted_idx = questions.index(all_target_question)

      expect(group_targeted_idx).to be < all_targeted_idx
    end

    it "returns higher score questions before lower/no score questions" do
      scored_question_idx = questions.index(scored_question)
      unscored_question_idx = questions.index(all_target_question)

      expect(scored_question_idx).to be < unscored_question_idx
    end

    it "returns following user-created questions before scored questions" do
      following_question_idx = questions.index(following_question)
      scored_question_idx = questions.index(scored_question)

      expect(following_question_idx).to be < scored_question_idx
    end

    it "returns following user-completed & shared questions before created & unshared"
    it "returns following user-created & shared questions before completed & shared"
    it "returns untargeted staff questions before following user questions"
    it "returns targeted staff questions before untargeted"

  end

  describe :validations do
    it {expect(FactoryGirl.build(:user)).to be_valid}
    it {expect(FactoryGirl.build(:user, username:nil)).not_to be_valid}
  end

  describe :comments_on_its_questions do

    context "When there is a comment on a question created by a user" do
      let!(:user) {FactoryGirl.create :user}
      let!(:text_question) {FactoryGirl.create :text_question, user:user}
      let!(:comment) { FactoryGirl.create :comment, commentable:text_question }

      it {expect(user.comments_on_its_questions).to match_array [comment]}
    end

  end

  describe :comments_on_its_responses do

    context "When there is a comment on a response to a question created by a user" do
      let!(:user) {FactoryGirl.create :user}
      let!(:text_question) {FactoryGirl.create :text_question, user:user}
      let!(:text_response) {FactoryGirl.create :text_response, question:text_question}
      let!(:comment) { FactoryGirl.create :comment, commentable:text_response }

      it {expect(user.comments_on_its_responses).to match_array [comment]}
    end

  end

  describe :comments_on_questions_and_responses do
    context "When there is a comment on a question created by a user" do
      let!(:user) {FactoryGirl.create :user}
      let!(:text_question) {FactoryGirl.create :text_question, user:user}
      let!(:question_comment) { FactoryGirl.create :comment, commentable:text_question }

      context "When there is a comment on a response to a question created by a user" do
        let!(:text_response) {FactoryGirl.create :text_response, question:text_question}
        let!(:response_comment) { FactoryGirl.create :comment, commentable:text_response }

        it {expect(user.comments_on_questions_and_responses).to match_array [question_comment, response_comment]}
      end
    end
  end

  describe :next_feed_questions do
    let(:user) {FactoryGirl.create :user}

    context "With 5 active questions in the pool" do
      let!(:questions) { [q1,q2,q3,q4,q5] }
      let(:q1) {FactoryGirl.create :text_question}
      let(:q2) {FactoryGirl.create :text_question}
      let(:q3) {FactoryGirl.create :text_question}
      let(:q4) {FactoryGirl.create :text_question}
      let(:q5) {FactoryGirl.create :text_question}

      it "A user's feed will be populated by those 5 questions" do
        expect(user.next_feed_questions(5)).to match_array questions
      end

      context "When the 3rd question is 'special'" do
        let(:q3) {FactoryGirl.create :text_question, special:true}

        it "the 'special' quesetion should be the first in the feed" do
          expect(user.next_feed_questions(5)[0]).to eq q3
        end
      end

      context "When the 2nd question is already in the user's feed" do
        before { user.feed_questions << q2 }

        it "the 2nd question shouldn't be added again" do
          expect(user.next_feed_questions(5)).to match_array (questions - [q2])
        end
      end
    end
  end
end
