require 'rails_helper'
require 'tasks/shared_rake'

describe 'db:clear_spam' do
  include_context 'rake'
  let!(:ok_comments) { FactoryGirl.create_list :comment, 10, body: 'some text' }
  let!(:spam_comments) { FactoryGirl.create_list :comment, 10, body: 'some text http://hello.world' }
  it 'removes all these comments' do
    output = capture(:stdout) { subject.invoke }
    expect(Comment.all.pluck(:id)).to eq ok_comments.map(&:id)
  end
  context 'nested comments' do
    let!(:nested_spam_comments) {
      FactoryGirl.create_list :comment, 5, body: 'some text', commentable: spam_comments.first
    }

    it 'removes it cascade' do
      output = capture(:stdout) { subject.invoke }
      expect(Comment.all.pluck(:id)).to eq ok_comments.map(&:id)
    end
  end
end

describe 'db:clear_spam:dry' do
  include_context 'rake'
  let!(:ok_comments) { FactoryGirl.create_list :comment, 10, body: 'some text' }
  let!(:spam_comments) { FactoryGirl.create_list :comment, 10, body: 'some text http://hello.world' }
  it 'should not remove these comments' do
    output = capture(:stdout) { subject.invoke }
    expect(Comment.all.pluck(:id)).to eq (ok_comments + spam_comments).map(&:id)
  end
end
