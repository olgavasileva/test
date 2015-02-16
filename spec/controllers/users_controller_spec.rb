require 'rails_helper'

RSpec.describe UsersController do
  include Devise::TestHelpers

  let(:user) { FactoryGirl.create(:user, :pro) }

  before { sign_in user }

  describe 'GET #demographics' do
    let(:question) { FactoryGirl.create(:text_choice_question, user: user) }

    subject { get :demographics, id: user.id, question_id: question.id }

    it 'renders the demographics page' do
      subject
      expect(response).to_not render_template('layouts/pixel_admin')
      expect(response).to render_template('demographics')
    end

    it 'assigns the @question' do
      subject
      expect(assigns(:question)).to eq(question)
    end

    it 'assigns the @demographics' do
      expect(Demographic).to receive(:aggregate_data_for_question) do |q|
        expect(q.id).to eq(question.id)
      end.and_return({})

      subject
      expect(assigns(:demographics)).to be_a(Hash)
    end

    context 'when a :choice_id is present' do
      let(:choice) { FactoryGirl.create(:text_choice, question: question) }

      subject { get :demographics, id: user.id, question_id: question.id, choice_id: choice.id }

      it 'loads choice demographics' do
        expect(Demographic).to receive(:aggregate_data_for_choice) do |c|
          expect(c.id).to eq(choice.id)
        end.and_return({})

        subject
        expect(assigns(:demographics)).to be_a(Hash)
      end
    end
  end
end
