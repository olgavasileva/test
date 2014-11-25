require 'rails_helper'

describe 'GET /messages' do
  let(:common_params) {{
    auth_token: instance.auth_token
  }}
  let(:other_params) {{ }}
  let(:params) { common_params.merge(other_params) }
  let(:instance) { FactoryGirl.create(:instance, :authorized, :logged_in) }
  let!(:messages) { FactoryGirl.create_list(:message, 4, user: instance.user) }
  let(:response_body) { JSON.parse(response.body) }
  let(:response_message_ids) { response_body['messages'].map { |m| m['message']['id'] } }

  before { get 'v/2.0/messages', params }

  it "returns all user's messages" do
    expect(response_message_ids).to eq messages.map(&:id)
  end

  # todo: make into shared example, extend for logic (see messages_spec)
  it "returns data in the 'messages' view" do
    datum_keys = %w[id type read_at created_at body]

    response_body['messages'].each do |datum|
      expect(datum['message'].keys).to match_array datum_keys
    end
  end

  context "with previous_last_id param" do
    let(:other_params) {{
      previous_last_id: messages[2].id
    }}

    it "returns records after the one specified by previous_last_id" do
      expect(response_message_ids).to eq [messages[3].id]
    end
  end

  context "with count param" do
    let(:other_params) {{
      count: 2
    }}

    it "returns first n records specified by count" do
      expect(response_message_ids).to eq messages.first(2).map(&:id)
    end
  end
end
