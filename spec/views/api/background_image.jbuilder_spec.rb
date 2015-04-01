require 'rails_helper'

RSpec.require 'rails_helper'

RSpec.describe 'api/background_image.jbuilder' do
  let(:image) { FactoryGirl.create(:choice_image) }

  before { assign(:image, ChoiceImage.new) }
  before { render template: 'api/background_image' }

  let(:json) { JSON.parse(rendered) }
  subject { json }

  it { is_expected.to have_json_key(:image) }

  context 'the background_image object' do
    subject { json['image'] }

    it { is_expected.to have_json_key(:image_id) }
    it { is_expected.to have_json_key(:image_url) }
    it { is_expected.to have_json_key(:image_meta_data) }
  end
end
