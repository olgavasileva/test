require 'rails_helper'

RSpec.describe BackgroundImage do
  before(:all) { @ad_unit = FactoryGirl.create(:ad_unit) }
  after(:all) { DatabaseCleaner.clean_with(:truncation) }
  let(:ad_unit) { @ad_unit }

  it { is_expected.to have_many(:questions) }
  it { is_expected.to have_many(:choices) }
  it { is_expected.to have_many(:ad_unit_infos)
        .class_name('BackgroundImagesAdUnit')
        .dependent(:delete_all) }

  describe 'validations' do
    it { is_expected.to_not allow_value("some_string").for(:meta_data)
          .with_message(/must be a Hash/, against: :base) }

    it { is_expected.to_not allow_value(key: "some_string").for(:meta_data)
          .with_message(/of non\-empty \{key \=\> Hash\} pairs/, against: :base) }

    it { is_expected.to_not allow_value({invalid: {}, other: {}}).for(:meta_data)
          .with_message(/of non\-empty \{key \=\> Hash\} pairs/, against: :base) }

    it { is_expected.to_not allow_value({invalid: {a:1}, other: {b:2}}).for(:meta_data)
          .with_message(/contains invalid keys\: invalid, other/, against: :base) }

    it { is_expected.to allow_value({ad_unit.name => {a:1}}).for(:meta_data) }
  end

  describe 'saving' do
    it 'creates BackgroundImageAdUnit records from the meta data' do
      image = BackgroundImage.create!
      image.meta_data = {ad_unit.name => {a: 1}}
      expect{image.save!}.to change{image.reload.ad_unit_infos.count}.by(1)
    end
  end

  describe '#ad_unit_info' do
    it 'returns the first BackgroundImagesAdUnit record for the given name' do
      image = BackgroundImage.create!
      info = BackgroundImagesAdUnit.create!({
        ad_unit: ad_unit,
        background_image: image,
        meta_data: {example: :data}
      })

      image.reload
      expect(image.ad_unit_info(ad_unit.name)).to eq(info)
    end
  end
end
