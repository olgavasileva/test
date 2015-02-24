require 'rails_helper'

class CustomTrackableTest
  include CustomTrackable

  attr_accessor \
    :sign_in_count,
    :current_sign_in_ip,
    :last_sign_in_ip,
    :current_sign_in_at,
    :last_sign_in_at,


  def save(opts={})
  end
end

RSpec.describe CustomTrackable do

  describe '#update_tracked_fields!' do
    it 'delegates to #update_tracked_fields and saves' do
      model = CustomTrackableTest.new
      expect(model).to receive(:update_tracked_fields).with(:request) { nil }
      expect(model).to receive(:save).with(validate: false)
      model.update_tracked_fields!(:request)
    end
  end

  describe '#update_tracked_fields' do
    it 'updates new values' do
      model = CustomTrackableTest.new

      request = double('ActionDispatch::Request', remote_ip: '10.0.0.1')
      model.update_tracked_fields(request)

      expect(model.current_sign_in_at).to be_present
      expect(model.last_sign_in_at).to eq(model.current_sign_in_at)

      expect(model.current_sign_in_ip).to eq('10.0.0.1')
      expect(model.last_sign_in_ip).to eq(model.current_sign_in_ip)

      expect(model.sign_in_count).to eq(1)
    end

    it 'rolls back existing values' do
      model = CustomTrackableTest.new

      old_at = 1.day.ago
      model.current_sign_in_ip = '10.0.0.1'
      model.current_sign_in_at = old_at
      model.sign_in_count = 1

      request = double('ActionDispatch::Request', remote_ip: '10.0.0.2')
      model.update_tracked_fields(request)

      expect(model.current_sign_in_at).to be_present
      expect(model.last_sign_in_at).to eq(old_at)

      expect(model.current_sign_in_ip).to eq('10.0.0.2')
      expect(model.last_sign_in_ip).to eq('10.0.0.1')

      expect(model.sign_in_count).to eq(2)
    end

    it 'handles requests missing :remote_ip' do
      expect_any_instance_of(ActionDispatch::Request).to receive(:remote_ip)
        .and_return('10.0.0.10')

      request = double('Grape::Request', env: {})
      model = CustomTrackableTest.new
      model.update_tracked_fields(request)

      expect(model.current_sign_in_ip).to eq('10.0.0.10')
    end
  end
end
