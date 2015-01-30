require 'rails_helper'
require 'tasks/shared_rake'

describe 'db:clear_duplicate_answers' do
  include_context 'rake'
  let!(:user) { FactoryGirl.create :user }
  let!(:question) { FactoryGirl.create :question }
  let!(:choice) { FactoryGirl.create :choice, question: question }
  let!(:responses) { FactoryGirl.create_list :response, 10, question: question, user: user, choice_id: choice.id }

  it 'removes all duplicates' do
    subject.invoke(question.id.to_s)
    expect(Response.all.length).to eq 1
    expect(Response.all.to_a).to eq [responses.first]
  end
end

describe 'db:clear_duplicate_answers:dry' do
  include_context 'rake'
  let!(:user) { FactoryGirl.create :user }
  let!(:question) { FactoryGirl.create :question }
  let!(:choice) { FactoryGirl.create :choice, question: question }
  let!(:responses) { FactoryGirl.create_list :response, 10, question: question, user: user, choice_id: choice.id }

  it 'shows duplicates count' do
    output = capture(:stdout) do
      subject.invoke(question.id.to_s)
    end
    expect(output).to include "Question##{question.id} has 10 duplicating answers"
  end
end