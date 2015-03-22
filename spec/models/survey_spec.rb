require 'rails_helper'

RSpec.describe Survey do

  it { is_expected.to belong_to(:user).class_name('Respondent') }

  describe 'validations' do
    context 'for user' do
      it 'does not allow Users that do not exist' do
        expect(subject).to_not allow_value(99999)
          .for(:user_id)
          .with_message(:must_exist, against: :user)
      end

      it 'allows existing Users' do
        user = FactoryGirl.create(:user)
        expect(subject).to allow_value(user).for(:user)
      end
    end
  end
end
