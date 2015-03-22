require 'rails_helper'

RSpec.describe Survey do

  it { is_expected.to belong_to(:user).class_name('Respondent') }

  describe 'validations' do
    context 'for user' do
      it { is_expected.to_not allow_value(99999)
          .for(:user_id)
          .with_message(:must_exist, against: :user) }

      it { is_expected.to allow_value(FactoryGirl.create(:user)).for(:user) }
    end
  end
end
