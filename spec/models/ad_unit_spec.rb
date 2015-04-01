require 'rails_helper'

RSpec.describe AdUnit do

  it { is_expected.to have_many(:background_images_ad_units)
        .dependent(:delete_all) }

  it { is_expected.to have_many(:background_images)
        .through(:background_images_ad_units) }

  describe 'validations' do
    before(:all) { @ad_unit = FactoryGirl.create(:ad_unit) }
    after(:all) { DatabaseCleaner.clean_with(:truncation) }
    let(:ad_unit) { @ad_unit }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:width) }
    it { is_expected.to validate_numericality_of(:width).only_integer }
    it { is_expected.to validate_presence_of(:height) }
    it { is_expected.to validate_numericality_of(:height).only_integer }
  end
end
