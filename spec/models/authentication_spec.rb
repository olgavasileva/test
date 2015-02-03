require 'rails_helper'

RSpec.describe Authentication do

  it { should belong_to(:user) }

  describe 'validations' do
    it { should validate_presence_of(:provider) }
    it { should validate_inclusion_of(:provider).in_array(Authentication::PROVIDERS) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:token) }

    describe 'for unique attributes' do
      before { FactoryGirl.create(:authentication) }
      it { should validate_uniqueness_of(:uid).scoped_to(:provider) }
    end
  end
end
