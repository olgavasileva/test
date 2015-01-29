require 'rails_helper'

describe 'PUT /read_multiple' do
  let(:instance) { FactoryGirl.create(:instance, :logged_in) }
  let!(:messages) { FactoryGirl.create_list(:message, 4, user: instance.user) }
  let(:params) {{
    auth_token: instance.auth_token,
    ids: messages.map(&:id)
  }}
  let(:response_body) { JSON.parse(response.body) }

  before { put 'v/2.0/messages/read_multiple', params }

  it "marks as read messages of ids" do
    messages.each do |message|
      expect(message.reload.read_at).to_not be_nil
    end
  end

  it "responds with blank data" do
    expect(response_body).to eq Hash.new
  end
end
