require 'rails_helper'

RSpec.describe Setting do

  describe '.fetch_values' do
    it 'returns a hash of the request key/value pairs' do
      Setting.create!(key: 'test', value: 'value')
      Setting.create!(key: 'other', value: 'other_value')

      hash = Setting.fetch_values('test', 'other')
      expect(hash[:test]).to eq('value')
      expect(hash['test']).to eq('value')
      expect(hash[:other]).to eq('other_value')
      expect(hash['other']).to eq('other_value')
    end

    it 'allows for non-existent keys' do
      hash = Setting.fetch_values('invalid')
      expect(hash[:invalid]).to eq(nil)
    end
  end

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
