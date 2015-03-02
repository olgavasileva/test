require 'rails_helper'

RSpec.describe SocialProfile::BaseAdapter do

  let(:adapter) { described_class.new('token', 'secret') }

  describe '#token' do
    subject { adapter.token }
    it { should eq('token') }
  end

  describe '#secret' do
    subject { adapter.secret }
    it { should eq('secret') }
  end

  describe '#provider' do
    subject { adapter.provider }
    it { should eq('base') }
  end

  [
    :uid,
    :first_name,
    :last_name,
    :name,
    :username,
    :email,
    :gender,
    :birthdate
  ].each do |attribute|
    describe "##{attribute}" do
      subject { adapter.send(attribute) }
      it { should eq(nil) }
    end
  end
end
