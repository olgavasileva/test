require 'rails_helper'

describe :search do
  let(:params) { {} }
  let(:setup_questions) {}
  before { setup_questions }
  before { post "v/2.0/questions/search", Hash[params].to_json, {"CONTENT_TYPE" => "application/json"} }

  context "With all required params" do
    let(:params) { {auth_token: auth_token, search_text: search_text, count: count} }
    let(:search_text) { "Some Text" }
    let(:count) { 10 }

    context "With a logged in user" do
      let(:auth_token) {instance.auth_token}
      let(:instance) {FactoryGirl.create :instance, :logged_in}
      let(:user) {instance.user}

      context "With some questions" do
        let!(:q1) { FactoryGirl.create :text_choice_question, title: "Would you like to dance?" }
        let!(:c11) { FactoryGirl.create :text_choice, question: q1, title: "Text Choice 11", rotate: true }
        let!(:c12) { FactoryGirl.create :text_choice, question: q1, title: "Text Choice 12", rotate: true }
        let!(:c13) { FactoryGirl.create :text_choice, question: q1, title: "Text Choice 13", rotate: false }
        let!(:q2) { FactoryGirl.create :text_choice_question, title: "Green Eggs or Ham?" }
        let!(:c21) { FactoryGirl.create :text_choice, question: q2, title: "Text Choice 21", rotate: true }
        let!(:q3) { FactoryGirl.create :text_question, title: "How much wood would a wood chuck chuck if a wood chuck could chuck wood?" }
        let!(:q4) { FactoryGirl.create :text_question, tag_list: ['eggs'] }

        let(:all_questions) { [q1, q2, q3, q4] }

        let(:setup_questions) {
          all_questions
          c11
          c12
          c13
          c21
        }

        context "When the search string doesn't match any questions" do
          let(:search_text) { "NO MATCH" }

          it 'returns the correct result' do
            expect(response.status).to eq 201
            expect(json).to eq []
          end
        end

        context "When the search string matches one question and one tag" do
          let(:search_text) { "Eggs" }

          it 'returns the correct result' do
            expect(response.status).to eq 201
            expect(json.map { |q| q["question"]["id"] }).to eq [q4.id, q2.id]
          end
        end

        context "When the search string matches two questions" do
          let(:search_text) { "would" }

          it 'returns the correct result' do
            expect(response.status).to eq 201
            expect(json.map { |q| q["question"]["id"] }).to eq [q3.id, q1.id]
          end
        end

        context "When the search string matches the choice of one of the questions" do
          let(:search_text) { "Choice 21" }

          it 'returns the correct result' do
            expect(response.status).to eq 201
            expect(json.map { |q| q["question"]["id"] }).to eq [q2.id]
          end
        end

        context 'include_skipped = true' do
          let(:search_text) { 'Text Choice 21' }
          let(:params) { {auth_token: auth_token, search_text: search_text, count: count, include_skipped: true} }
          before { FeedItem.question_skipped! q2, user }
          before { Response.create(question: q1, user: user) }
          it { expect(json.length).to eq 1 }
        end

        context 'include_skipped = true && include_answered = true' do
          let(:search_text) { 'Text Choice' }
          let(:params) { {auth_token: auth_token, search_text: search_text, count: count, include_skipped: true, include_answered: true} }
          before { FeedItem.question_skipped! q2, user }
          before { Response.create(question: q1, user: user) }
          it { expect(json.length).to eq 2 }
        end

        context 'include_answered = true' do
          let(:search_text) { 'Text Choice 21' }
          let(:params) { {auth_token: auth_token, search_text: search_text, count: count, include_answered: true} }
          before { FeedItem.question_skipped! q2, user }
          before { Response.create(question: q1, user: user) }
          it { expect(json.length).to eq 1 }
        end

      end
    end
  end
end
