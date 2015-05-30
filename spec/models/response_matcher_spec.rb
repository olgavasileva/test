require 'rails_helper'

describe ResponseMatcher do

  describe :validations do
    it {expect(FactoryGirl.build(:response_matcher)).to be_valid}
    it {expect(FactoryGirl.build(:response_matcher, inclusion:"skip")).to be_valid}
    it {expect(FactoryGirl.build(:response_matcher, inclusion:"respond")).to be_valid}
    it {expect(FactoryGirl.build(:response_matcher, inclusion:"specific")).to be_valid}
    it {expect(FactoryGirl.build(:response_matcher, inclusion:nil)).not_to be_valid}
    it {expect(FactoryGirl.build(:response_matcher, inclusion:"garbage")).not_to be_valid}
  end

  describe :matched_users do
    context "With a question and some skippers and responders" do
      let(:question) {FactoryGirl.create :text_question}
      let(:skippers) {FactoryGirl.create_list :user, 3}
      let!(:responders) {FactoryGirl.create_list :text_response, 2, question:question}
      before {skippers.each{|user| question.skipped! user}}

      describe :skippers do
        let(:matcher) {FactoryGirl.create :text_response_matcher, :skip, question:question}

        it "returns the skipped users" do
          expect(matcher.matched_users).to match_array skippers
        end
      end

      describe :responders do
        let(:matcher) {FactoryGirl.create :text_response_matcher, :respond, question:question}

        it "returns the matched users" do
          expect(matcher.matched_users).to match_array responders.map{|skip| skip.user}
        end
      end
    end

    describe :specific do
      context "With a text question and some text responses" do
        let(:question) {FactoryGirl.create :text_question}
        let!(:response1) {FactoryGirl.create :text_response, question:question, text:"Now is the time"}
        let!(:response2) {FactoryGirl.create :text_response, question:question, text:"for all good men to come"}
        let!(:response3) {FactoryGirl.create :text_response, question:question, text:"to the aid of their country."}
        let(:matcher)  {FactoryGirl.build :text_response_matcher, :specific, question:question}

        it "should match specific text" do
          matcher.regex = "is the"
          expect(matcher.matched_users).to match_array [response1.user]

          matcher.regex = "country"
          expect(matcher.matched_users).to match_array [response3.user]

          matcher.regex = "to"
          expect(matcher.matched_users).to match_array [response2.user, response3.user]
        end
      end

      context "With a text choice question and some responses" do
        let(:question) {FactoryGirl.create :text_choice_question}
        let!(:response1) {FactoryGirl.create :text_choice_response, question:question}
        let!(:response2) {FactoryGirl.create :text_choice_response, question:question}
        let!(:response3) {FactoryGirl.create :text_choice_response, question:question, choice: response1.choice}
        let(:matcher) {FactoryGirl.build :choice_response_matcher, :specific, question:question}

        it "should match specific choices" do
          matcher.choice = response1.choice
          expect(matcher.matched_users).to match_array [response1.user, response3.user]

          matcher.choice = response2.choice
          expect(matcher.matched_users).to match_array [response2.user]
        end
      end

      context "With an image choice question" do
        let(:question) {FactoryGirl.create :image_choice_question}
        let!(:response1) {FactoryGirl.create :image_choice_response, question:question}
        let!(:response2) {FactoryGirl.create :image_choice_response, question:question}
        let!(:response3) {FactoryGirl.create :image_choice_response, question:question, choice: response1.choice}
        let(:matcher) {FactoryGirl.build :choice_response_matcher, :specific, question:question}

        describe "Various matchs" do
          it "should match specific choices" do
            matcher.choice = response1.choice
            expect(matcher.matched_users).to match_array [response1.user, response3.user]
          end

          it "should match specific choices" do
            matcher.choice = response2.choice
            expect(matcher.matched_users).to match_array [response2.user]
          end
        end
      end

      context "With a multiple choice question" do
        let(:question) {FactoryGirl.create :multiple_choice_question}
        let(:choice1) {FactoryGirl.create :multiple_choice, question:question}
        let(:choice2) {FactoryGirl.create :multiple_choice, question:question}
        let(:choice3) {FactoryGirl.create :multiple_choice, question:question}
        let!(:response1) {FactoryGirl.create :multiple_choice_response, question:question, choices:[choice1,choice2]}
        let!(:response2) {FactoryGirl.create :multiple_choice_response, question:question, choices:[choice1]}
        let!(:response3) {FactoryGirl.create :multiple_choice_response, question:question, choices:[choice2]}
        let(:matcher) {FactoryGirl.build :multiple_choice_response_matcher, :specific, question:question}

        describe "Various match combinations" do
          it "should match specific choices" do
            matcher.choice = choice1
            expect(matcher.matched_users).to match_array [response1.user, response2.user]
          end

          it "should match specific choices" do
            matcher.choice = choice2
            expect(matcher.matched_users).to match_array [response1.user, response3.user]
          end

          it "should match specific choices" do
            matcher.choice = choice3
            expect(matcher.matched_users).to be_empty
          end
        end
      end

      context "With an order question" do
        let(:question) {FactoryGirl.create :order_question}
        let(:choice1) {FactoryGirl.create :order_choice, question:question}
        let(:choice2) {FactoryGirl.create :order_choice, question:question}
        let(:choice3) {FactoryGirl.create :order_choice, question:question}
        let!(:response1) {FactoryGirl.create :order_choices_response, position: 1, choice: choice1}
        let!(:response2) {FactoryGirl.create :order_choices_response, position: 1, choice: choice2}
        let!(:response3) {FactoryGirl.create :order_choices_response, position: 1, choice: choice3}
        let!(:response4) {FactoryGirl.create :order_choices_response, position: 2, choice: choice2, order_response_id:response3.response}
        let(:matcher) {FactoryGirl.build :order_response_matcher, :specific, question:question}

        describe "Various match combinations" do
          it "should match specific choices" do
            matcher.first_place_choice = choice1
            expect(matcher.matched_users).to match_array [response1.response.user]
          end

          it "should match specific choices" do
            matcher.first_place_choice = choice2
            expect(matcher.matched_users).to match_array [response2.response.user]
          end

          it "should match specific choices" do
            matcher.first_place_choice = choice3
            expect(matcher.matched_users).to match_array [response3.response.user]
          end
        end
      end
    end
  end
end
