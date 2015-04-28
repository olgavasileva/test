require 'rails_helper'

RSpec.describe TwoCents::Questions do
  before do
    @instance = FactoryGirl.create(:instance, :logged_in)
    @questions = FactoryGirl.create_list(:text_choice_question, 2, {
      tag_list: ['test'],
      user: @instance.user
    })

    @questions.last.update_column(:created_at, 1.day.ago)
  end

  let(:instance) { @instance }
  let(:token) { instance.auth_token }

  describe 'GET #tagged' do
    it 'returns the questions matching the tag' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'test'
      expect(json.length).to eq(2)
    end

    it 'allows for mixed case queries' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'TesT'
      expect(json.length).to eq(2)
    end

    it 'returns :per_page number of questions matching the tag' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'test', per_page: 1
      expect(json.length).to eq(1)
    end

    it 'returns :page number for the questions matching the tag' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'test', per_page: 1, page: 2
      expect(json.first['question']['id']).to eq(@questions.last.id)
    end

    it 'does not return questions not matching the tag' do
      get 'v/2.0/questions/tagged', auth_token: token, tag: 'other'
      expect(json.length).to eq(0)
    end

    context "When there are 2 questions each with the same 2 tags and a question with only one of the tags" do
      let(:tag1) {"tag1"}
      let(:tag2) {"tag2"}
      let(:tags) {[tag1, tag2]}
      let(:question1) {FactoryGirl.create :text_question, tag_list:[tag1, tag2]}
      let(:question2) {FactoryGirl.create :text_question, tag_list:[tag1, tag2]}
      let(:question3) {FactoryGirl.create :text_question, tag_list:[tag1]}
      before {@questions = [question1, question2, question3]}

      it { expect(Question.tagged_with(tag1)).to match_array [question1, question2, question3] }
      it { expect(Question.tagged_with(tag2)).to match_array [question1, question2] }
      it { expect(Question.tagged_with(tags)).to match_array [question1, question2] }
      it { expect(Question.tagged_with(tags, any: false)).not_to match_array [question1, question2, question3] }
      it { expect(Question.tagged_with(tags, any: true)).to match_array [question1, question2, question3] }
    end
  end
end
