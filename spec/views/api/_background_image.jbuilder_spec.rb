require 'rails_helper'

RSpec.describe 'api/_background_image.jbuilder' do
  before do
    @ad_unit_one = FactoryGirl.create(:ad_unit)
    @ad_unit_two = FactoryGirl.create(:ad_unit)
    @image = ChoiceImage.create!(meta_data: {
      @ad_unit_one.name => {example: 'data'},
      @ad_unit_two.name => {example: 'other'}
    })
  end

  let(:ad_unit_one) { @ad_unit_one }
  let(:ad_unit_two) { @ad_unit_two }
  let(:image) { @image }

  let(:json) do
    render partial: 'api/background_image', locals: {image: image}
    JSON.parse(rendered)
  end

  before do
    allow(@image).to receive(:device_image_url)
      .and_return('http://placehold.it/100x100.png')
  end

  subject { json }

  it { is_expected.to have_json_key(:image_id).eq(image.id) }
  it { is_expected.to have_json_key(:image_url).eq(image.device_image_url) }

  context 'when the image is nil' do
    let(:image) { nil }
    it { is_expected.to have_json_key(:image_meta_data).eq(nil) }
  end

  context 'when the image exists and has ad_unit_infos' do
    it { is_expected.to have_json_key(:image_meta_data).eq({
      ad_unit_one.name => {'example' => 'data'},
      ad_unit_two.name => {'example' => 'other'}
    }) }
  end
end
