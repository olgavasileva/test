require 'rails_helper'

RSpec.describe BackgroundImagesAdUnit do
  before(:all) do
    @ad_unit = FactoryGirl.create(:ad_unit)
    @image = BackgroundImage.create!
  end

  after(:all) { DatabaseCleaner.clean_with(:truncation) }

  let(:ad_unit) { @ad_unit }
  let(:image) { @image }

  it { is_expected.to belong_to(:background_image) }
  it { is_expected.to belong_to(:ad_unit) }

  it { is_expected.to serialize(:meta_data) }

  describe 'validations' do
    it { is_expected.to allow_value(ad_unit.name).for(:ad_unit_name) }
    it { is_expected.to_not allow_value('invalid').for(:ad_unit_name)
          .with_message(:must_exist, against: :ad_unit) }

    it { is_expected.to allow_value(ad_unit).for(:ad_unit) }
    it { is_expected.to_not allow_value(nil).for(:ad_unit)
          .with_message(:must_exist) }

    it { is_expected.to allow_value(image).for(:background_image) }
    it { is_expected.to_not allow_value(nil).for(:background_image)
          .with_message(:must_exist) }

    it { is_expected.to_not allow_value(nil).for(:meta_data)
          .with_message(/must contain some data/) }

    it { is_expected.to_not allow_value({}).for(:meta_data)
          .with_message(/must contain some data/) }

    it { is_expected.to_not allow_value("string").for(:meta_data)
          .with_message(/must be a hash/) }

    it { is_expected.to allow_value({a: 1}).for(:meta_data) }
  end

  describe '#update_from_image_meta_data' do
    it 'sets the correct attributes' do
      record = BackgroundImagesAdUnit.new
      record.update_from_image_meta_data('skyscraper', {data: 'example'})
      expect(record.ad_unit_name).to eq('skyscraper')
      expect(record.meta_data).to eq({data: 'example'})
    end
  end

  describe '#update_from_image_meta_data!' do
    it 'delegates to #update_from_image_meta_data and calls #save!' do
      record = BackgroundImagesAdUnit.new

      expect(record).to receive(:update_from_image_meta_data)
        .with('skyscraper', {data: 'example'})

      expect(record).to receive(:save!) { nil }
      record.update_from_image_meta_data!('skyscraper', {data: 'example'})
    end
  end
end
