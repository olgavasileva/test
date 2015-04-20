require 'rails_helper'

RSpec.describe Setting do

  describe '.fetch_value' do
    it 'returns nil when the key cannot be found' do
      value = Setting.fetch_value('invalid_value')
      expect(value).to eq(nil)
    end

    it 'returns the default when the key cannot be found' do
      value = Setting.fetch_value('invalid_value', :default)
      expect(value).to eq(:default)
    end

    it 'returns the value when the key can be found' do
      Setting.create!(key: 'test', value: 'awesome_algorithm_value')
      value = Setting.fetch_value('test')
      expect(value).to eq('awesome_algorithm_value')
    end
  end
end
