require 'rails_helper'

describe Response do

  it {expect(FactoryGirl.build(:image_response)).to be_valid}
  it {expect(FactoryGirl.build(:text_response)).to be_valid}
  it {expect(FactoryGirl.build(:multiple_choice_response)).to be_valid}
  it {expect(FactoryGirl.build(:text_choice_response)).to be_valid}
  it {expect(FactoryGirl.build(:order_response)).to be_valid}

  describe 'validations' do
    context 'for the same user and question' do
      let(:user) { FactoryGirl.create(:user) }
      let(:allow_answers) { true }
      let(:question) do
        FactoryGirl.create(:text_question, allow_multiple_answers_from_user: allow_answers)
      end

      before { FactoryGirl.create(:response, user: user, question: question) }

      let(:response) { TextResponse.new(user: user, question: question) }

      context 'when the question allows multiple answers from the user' do
        it 'allows the same user to create a response' do
          response.valid?
          message = "User has already answered this question"
          expect(response.errors[:base]).to_not include(message)
        end
      end

      context 'when the question does not allow multiple answers from the user' do
        let(:allow_answers) { false }

        xit 'does not allow the same user to create a response' do
          response.valid?
          message = "User has already answered this question"
          expect(response.errors[:base]).to include(message)
        end
      end
    end
  end
end
