require 'rails_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }

  describe :validations do
    it {expect(FactoryGirl.build(:user)).to be_valid}
    it {expect(FactoryGirl.build(:user, username:"")).not_to be_valid}
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
end
