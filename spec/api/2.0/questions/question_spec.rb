require 'rails_helper'

describe 'GET questions/question' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let(:question) { FactoryGirl.create(:question) }
  let(:params) { {
      auth_token: instance.auth_token,
      question_id: question.id
  } }

  before { get 'v/2.0/questions/question', params }

  it 'responds with all question data' do
    expect(json).to have_json_key(:id).eq(question.id)
    expect(json).to have_json_key(:summary)
  end

  context 'when have responses to this question by user' do
    before { @choice = FactoryGirl.create :choice, question: question }
    before { @answer = FactoryGirl.create :response, question: question, user: instance.user, choice_id: @choice.id }
    before { get 'v/2.0/questions/question', params }
    it 'shows chosen choice' do
      json['summary']['choices'].each do |choice|
        expect(choice['user_answered']).to eq true
      end
    end

    context 'many answers' do
      before { @choice2 = FactoryGirl.create :choice, question: question }
      before { @answers = [@answer, FactoryGirl.create(:response, question: question, user: instance.user, choice_id: @choice2.id)] }
      before { get 'v/2.0/questions/question', params }
      it 'shows chosen choice' do
        json['summary']['choices'].each do |choice|
          expect(choice['user_answered']).to eq true
        end
      end
    end

    context 'many answers, but not all are chosen' do
      before { @choice2 = FactoryGirl.create :choice, question: question }
      before { get 'v/2.0/questions/question', params }
      it 'shows chosen choice' do
        choices = json['summary']['choices']
        expect(choices.first['user_answered']).to eq true
        expect(choices.second['user_answered']).to eq false
      end
    end
  end


  context "When supplying the quetion uuid in stead of the id" do
    let(:params) { {
        auth_token: instance.auth_token,
        question_uuid: question.uuid
    } }

    it 'responds with all question data' do
      expect(json).to have_json_key(:id).eq(question.id)
      expect(json).to have_json_key(:summary)
    end
  end

  context "Without authenticating" do
    let(:params) { {
        question_id: question.id
    } }

    it 'responds with all question data' do
      expect(json).to have_json_key(:id).eq(question.id)
      expect(json).to have_json_key(:summary)
    end
  end
end
