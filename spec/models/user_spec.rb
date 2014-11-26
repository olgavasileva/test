require 'rails_helper'

describe User do

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
